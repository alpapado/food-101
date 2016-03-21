#include <math.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <omp.h>
#include "linear.h"
#include <time.h>
#include "mex.h"
#include "linear_model_matlab.h"

#ifdef MX_API_VER
#if MX_API_VER < 0x07030000
typedef int mwIndex;
#endif
#endif

#define CMD_LEN 2048
#define Malloc(type,n) (type *)malloc((n)*sizeof(type))
#define INF HUGE_VAL
#define NUMBER_OF_FIELDS 6
#define NUM_OF_RETURN_FIELD 6

void print_null(const char *s) {}
void print_string_matlab(const char *s) {mexPrintf(s);}

static const char *field_names[] = {
	"Parameters",
	"nr_class",
	"nr_feature",
	"bias",
	"Label",
	"w",
};

void exit_with_help()
{
	mexPrintf(
	"Usage: model = train(training_label_vector, training_instance_matrix, 'liblinear_options', 'col');\n"
	"liblinear_options:\n"
	"-s type : set type of solver (default 1)\n"
	"  for multi-class classification\n"
	"	 0 -- L2-regularized logistic regression (primal)\n"
	"	 1 -- L2-regularized L2-loss support vector classification (dual)\n"	
	"	 2 -- L2-regularized L2-loss support vector classification (primal)\n"
	"	 3 -- L2-regularized L1-loss support vector classification (dual)\n"
	"	 4 -- support vector classification by Crammer and Singer\n"
	"	 5 -- L1-regularized L2-loss support vector classification\n"
	"	 6 -- L1-regularized logistic regression\n"
	"	 7 -- L2-regularized logistic regression (dual)\n"
	"  for regression\n"
	"	11 -- L2-regularized L2-loss support vector regression (primal)\n"
	"	12 -- L2-regularized L2-loss support vector regression (dual)\n"
	"	13 -- L2-regularized L1-loss support vector regression (dual)\n"
	"-c cost : set the parameter C (default 1)\n"
	"-p epsilon : set the epsilon in loss function of SVR (default 0.1)\n"
	"-e epsilon : set tolerance of termination criterion\n"
	"	-s 0 and 2\n" 
	"		|f'(w)|_2 <= eps*min(pos,neg)/l*|f'(w0)|_2,\n" 
	"		where f is the primal function and pos/neg are # of\n" 
	"		positive/negative data (default 0.01)\n"
	"	-s 11\n"
	"		|f'(w)|_2 <= eps*|f'(w0)|_2 (default 0.001)\n" 
	"	-s 1, 3, 4 and 7\n"
	"		Dual maximal violation <= eps; similar to libsvm (default 0.1)\n"
	"	-s 5 and 6\n"
	"		|f'(w)|_1 <= eps*min(pos,neg)/l*|f'(w0)|_1,\n"
	"		where f is the primal function (default 0.01)\n"
	"	-s 12 and 13\n"
	"		|f'(alpha)|_1 <= eps |f'(alpha0)|,\n"
	"		where f is the dual function (default 0.1)\n"
	"-B bias : if bias >= 0, instance x becomes [x; bias]; if < 0, no bias term added (default -1)\n"
	"-wi weight: weights adjust the parameter C of different classes (see README for details)\n"
	"-v n: n-fold cross validation mode\n"
	"-C : find parameter C (only for -s 0 and 2)\n"
	"-n nr_thread : parallel version with [nr_thread] threads (default 1; only for -s 0, 2, 11)\n"
	"-q : quiet mode (no outputs)\n"
	"col:\n"
	"	if 'col' is setted, training_instance_matrix is parsed in column format, otherwise is in row format\n"
	);
}

// liblinear arguments
struct parameter param;		// set by parse_command_line
struct problem prob;		// set by read_problem
struct model* model_;
struct feature_node *x_space;
int flag_cross_validation;
int flag_find_C;
int flag_omp;
int flag_C_specified;
int flag_solver_specified;
int col_format_flag;
int nr_fold;
double bias;
struct model** models = Malloc(struct model*, 100);

// nrhs should be 3
int parse_command_line(int nrhs, const mxArray *prhs[], char *model_file_name)
{
	int i, argc = 1;
	char cmd[CMD_LEN];
	char *argv[CMD_LEN/2];
	void (*print_func)(const char *) = print_string_matlab;	// default printing to matlab display

	// default values
	param.solver_type = L2R_L2LOSS_SVC_DUAL;
	param.C = 1;
	param.eps = INF; // see setting below
	param.p = 0.1;
	param.nr_thread = 1;
	param.nr_weight = 0;
	param.weight_label = NULL;
	param.weight = NULL;
	param.init_sol = NULL;
	flag_cross_validation = 0;
	col_format_flag = 0;
	flag_C_specified = 0;
	flag_solver_specified = 0;
	flag_find_C = 0;
	flag_omp = 0;
	bias = -1;


	if(nrhs <= 1)
		return 1;

	if(nrhs == 4)
	{
		mxGetString(prhs[3], cmd, mxGetN(prhs[3])+1);
		if(strcmp(cmd, "col") == 0)
			col_format_flag = 1;
	}

	// put options in argv[]
	if(nrhs > 2)
	{
		mxGetString(prhs[2], cmd,  mxGetN(prhs[2]) + 1);
		if((argv[argc] = strtok(cmd, " ")) != NULL)
			while((argv[++argc] = strtok(NULL, " ")) != NULL)
				;
	}

	// parse options
	for(i=1;i<argc;i++)
	{
		if(argv[i][0] != '-') break;
		++i;
		if(i>=argc && argv[i-1][1] != 'q' && argv[i-1][1] != 'C') // since options -q and -C have no parameter
			return 1;
		switch(argv[i-1][1])
		{
			case 's':
				param.solver_type = atoi(argv[i]);
				flag_solver_specified = 1;
				break;
			case 'c':
				param.C = atof(argv[i]);
				flag_C_specified = 1;
				break;
			case 'p':
				param.p = atof(argv[i]);
				break;
			case 'e':
				param.eps = atof(argv[i]);
				break;
			case 'B':
				bias = atof(argv[i]);
				break;
			case 'n':
				flag_omp = 1;
				param.nr_thread = atoi(argv[i]);
				break;
			case 'v':
				flag_cross_validation = 1;
				nr_fold = atoi(argv[i]);
				if(nr_fold < 2)
				{
					mexPrintf("n-fold cross validation: n must >= 2\n");
					return 1;
				}
				break;
			case 'w':
				++param.nr_weight;
				param.weight_label = (int *) realloc(param.weight_label,sizeof(int)*param.nr_weight);
				param.weight = (double *) realloc(param.weight,sizeof(double)*param.nr_weight);
				param.weight_label[param.nr_weight-1] = atoi(&argv[i-1][2]);
				param.weight[param.nr_weight-1] = atof(argv[i]);
				break;
			case 'q':
				print_func = &print_null;
				i--;
				break;
			case 'C':
				flag_find_C = 1;
				i--;
				break;
			default:
				mexPrintf("unknown option\n");
				return 1;
		}
	}

	set_print_string_function(print_func);

	// default solver for parameter selection is L2R_L2LOSS_SVC
	if(flag_find_C)
	{
		if(!flag_cross_validation)
			nr_fold = 5;
		if(!flag_solver_specified)
		{
			mexPrintf("Solver not specified. Using -s 2\n");
			param.solver_type = L2R_L2LOSS_SVC;
		}
		else if(param.solver_type != L2R_LR && param.solver_type != L2R_L2LOSS_SVC)
		{
			mexPrintf("Warm-start parameter search only available for -s 0 and -s 2\n");
			return 1;
		}
	}

	//default solver for parallel execution is L2R_L2LOSS_SVC
	if(flag_omp)
	{
		if(!flag_solver_specified)
		{
			mexPrintf("Solver not specified. Using -s 2\n");
			param.solver_type = L2R_L2LOSS_SVC;
		}
		else if(param.solver_type != L2R_LR && param.solver_type !=  L2R_L1LOSS_SVC_DUAL && param.solver_type != L2R_L2LOSS_SVC && param.solver_type != L2R_L2LOSS_SVR)
		{
			mexPrintf("Parallel LIBLINEAR is only available for -s 0, 2, 11 now.\n");
			return 1;
		}
#ifndef CV_OMP
		//mexPrintf("Total threads used: %d\n", param.nr_thread);
#endif
	}
#ifdef CV_OMP
	if(flag_cross_validation)
	{
		int cvthreads = nr_fold;
		int maxthreads = omp_get_num_procs();
		if(flag_omp)
		{
			omp_set_nested(1);
			maxthreads = omp_get_num_procs()/param.nr_thread;
		}
		if(cvthreads > maxthreads)
			cvthreads = maxthreads;
		omp_set_num_threads(cvthreads);
		mexPrintf("Total threads used: %d\n", cvthreads*param.nr_thread);
	}
#endif

	if(param.eps == INF)
	{
		switch(param.solver_type)
		{
			case L2R_LR: 
			case L2R_L2LOSS_SVC:
				param.eps = 0.01;
				break;
			case L2R_L2LOSS_SVR:
				param.eps = 0.001;
				break;
			case L2R_L2LOSS_SVC_DUAL: 
			case L2R_L1LOSS_SVC_DUAL: 
			case MCSVM_CS: 
			case L2R_LR_DUAL: 
				param.eps = 0.1;
				break;
			case L1R_L2LOSS_SVC: 
			case L1R_LR:
				param.eps = 0.01;
				break;
			case L2R_L1LOSS_SVR_DUAL:
			case L2R_L2LOSS_SVR_DUAL:
				param.eps = 0.1;
				break;
		}
	}
	return 0;
}

static void fake_answer(int nlhs, mxArray *plhs[])
{
	int i;
	for(i=0;i<nlhs;i++)
		plhs[i] = mxCreateDoubleMatrix(0, 0, mxREAL);
}

int read_problem_sparse(const mxArray *label_vec, const mxArray *instance_mat)
{
	mwIndex *ir, *jc, low, high, k;
	// using size_t due to the output type of matlab functions
	size_t i, j, l, elements, max_index, label_vector_row_num;
	mwSize num_samples;
	double *samples, *labels;
	mxArray *instance_mat_col; // instance sparse matrix in column format

	prob.x = NULL;
	prob.y = NULL;
	x_space = NULL;

	if(col_format_flag)
		instance_mat_col = (mxArray *)instance_mat;
	else
	{
		// transpose instance matrix
		mxArray *prhs[1], *plhs[1];
		prhs[0] = mxDuplicateArray(instance_mat);
		if(mexCallMATLAB(1, plhs, 1, prhs, "transpose"))
		{
			mexPrintf("Error: cannot transpose training instance matrix\n");
			return -1;
		}
		instance_mat_col = plhs[0];
		mxDestroyArray(prhs[0]);
	}

	// the number of instance
	l = mxGetN(instance_mat_col);
	label_vector_row_num = mxGetM(label_vec);
	prob.l = (int) l;

	if(label_vector_row_num!=l)
	{
		mexPrintf("Length of label vector does not match # of instances.\n");
		return -1;
	}
	
	// each column is one instance
	labels = mxGetPr(label_vec);
	samples = mxGetPr(instance_mat_col);
	ir = mxGetIr(instance_mat_col);
	jc = mxGetJc(instance_mat_col);

	num_samples = mxGetNzmax(instance_mat_col);

	elements = num_samples + l*2;
	max_index = mxGetM(instance_mat_col);

	prob.y = Malloc(double, l);
	prob.x = Malloc(struct feature_node*, l);
	x_space = Malloc(struct feature_node, elements);

	prob.bias=bias;

	j = 0;
	for(i=0;i<l;i++)
	{
		prob.x[i] = &x_space[j];
		prob.y[i] = labels[i];
		low = jc[i], high = jc[i+1];
		for(k=low;k<high;k++)
		{
			x_space[j].index = (int) ir[k]+1;
			x_space[j].value = samples[k];
			j++;
	 	}
		if(prob.bias>=0)
		{
			x_space[j].index = (int) max_index+1;
			x_space[j].value = prob.bias;
			j++;
		}
		x_space[j++].index = -1;
	}

	if(prob.bias>=0)
		prob.n = (int) max_index+1;
	else
		prob.n = (int) max_index;

	return 0;
}

// Interface function of matlab
// now assume prhs[0]: label prhs[1]: features
void mexFunction( int nlhs, mxArray *plhs[],
		int nrhs, const mxArray *prhs[] )
{
	const char *error_msg;
	srand(time(NULL));

	if(nlhs > 2)
	{
		exit_with_help();
		fake_answer(nlhs, plhs);
		return;
	}

	// Transform the input Matrix to libsvm format
	if(nrhs > 1 && nrhs < 5)
	{
            int err=0;

            if(!mxIsDouble(prhs[0]) || !mxIsDouble(prhs[1]))
            {
                    mexPrintf("Error: label vector and instance matrix must be double\n");
                    fake_answer(nlhs, plhs);
                    return;
            }

            if(mxIsSparse(prhs[0]))
            {
                    mexPrintf("Error: label vector should not be in sparse format");
                    fake_answer(nlhs, plhs);
                    return;
            }

            if(parse_command_line(nrhs, prhs, NULL))
            {
                    exit_with_help();
                    destroy_param(&param);
                    fake_answer(nlhs, plhs);
                    return;
            }

            if(mxIsSparse(prhs[1]))
                    err = read_problem_sparse(prhs[0], prhs[1]);
            else
            {
                    mexPrintf("Training_instance_matrix must be sparse; "
                            "use sparse(Training_instance_matrix) first\n");
                    destroy_param(&param);
                    fake_answer(nlhs, plhs);
                    return;
            }

            // train's original code
            error_msg = check_parameter(&prob, &param);

            if(err || error_msg)
            {
                    if (error_msg != NULL)
                            mexPrintf("Error: %s\n", error_msg);
                    destroy_param(&param);
                    free(prob.y);
                    free(prob.x);
                    free(x_space);
                    fake_answer(nlhs, plhs);
                    return;
            }

            // if all has gone well, procede with training
            int i;
            
            omp_set_num_threads(param.nr_thread);

            #pragma omp parallel for private(i)
            for (i = 0; i < 100; i++){
                problem sub_prob_omp;
                sub_prob_omp.l = prob.l;
                sub_prob_omp.n = prob.n;
                sub_prob_omp.x = prob.x;
                sub_prob_omp.bias = prob.bias;
                sub_prob_omp.y = Malloc(double,prob.l);

                double* map = Malloc(double, 101);
                int has0;
                int has1;

                do {
                    // Generate random binary partition
                    for (int jj = 0; jj < 101; jj++){
                        //map[jj] = round( (double)rand() / (double)RAND_MAX );
                        map[jj] = rand() % 2;
                    }
                    
                    // Make sure both binary labels are present
                    has0 = 0;
                    has1 = 0;

                    // Assign each present class to a binary label
                    for (int jj = 0; jj < prob.l; jj++){
                        int map_index = (int) prob.y[jj]; // This is between 1 and 101

                        if (map[map_index] == 0)
                            has0 = 1;

                        if (map[map_index] == 1)
                            has1 = 1;

                        // The -1 is to correct for the C indexing starting at 0
                        sub_prob_omp.y[jj] = map[map_index-1];
                    }

                } while(!has0 || !has1);

                models[i] = train(&sub_prob_omp, &param);

                free(map);
                free(sub_prob_omp.y);
            }

            mwSize dims[2] = {1, 100};
            mwSize ndim = 2;
            mwIndex j;
            (void) prhs;

            plhs[0] = mxCreateStructArray(ndim, dims, NUMBER_OF_FIELDS, field_names); 

            double *ptr;
            mxArray **rhs;
            rhs = (mxArray **)mxMalloc(sizeof(mxArray *)*NUM_OF_RETURN_FIELD);

            int nr_w;
            int out_id;
            int n, w_size;
            
            for (j = 0; j < 100; j++) {
                out_id = 0;

                // Parameters
                // for now, only solver_type is needed
                rhs[out_id] = mxCreateDoubleMatrix(1, 1, mxREAL);
                ptr = mxGetPr(rhs[out_id]);
                ptr[0] = models[j]->param.solver_type;
                mxSetFieldByNumber(plhs[0], j, out_id, rhs[out_id]);
                out_id++;

                // nr_class
                rhs[out_id] = mxCreateDoubleMatrix(1, 1, mxREAL);
                ptr = mxGetPr(rhs[out_id]);
                ptr[0] = models[j]->nr_class;
                mxSetFieldByNumber(plhs[0], j, out_id, rhs[out_id]);
                out_id++;

                if(models[j]->nr_class==2 && models[j]->param.solver_type != MCSVM_CS)
                        nr_w=1;
                else
                        nr_w=models[j]->nr_class;

                // nr_feature
                rhs[out_id] = mxCreateDoubleMatrix(1, 1, mxREAL);
                ptr = mxGetPr(rhs[out_id]);
                ptr[0] = models[j]->nr_feature;
                mxSetFieldByNumber(plhs[0], j, out_id, rhs[out_id]);
                out_id++;

                // bias
                rhs[out_id] = mxCreateDoubleMatrix(1, 1, mxREAL);
                ptr = mxGetPr(rhs[out_id]);
                ptr[0] = models[j]->bias;
                mxSetFieldByNumber(plhs[0], j, out_id, rhs[out_id]);
                out_id++;

                if(models[j]->bias>=0)
                        n=models[j]->nr_feature+1;
                else
                        n=models[j]->nr_feature;

                w_size = n;
                // Label
                if(models[j]->label)
                {
                        rhs[out_id] = mxCreateDoubleMatrix(models[j]->nr_class, 1, mxREAL);
                        ptr = mxGetPr(rhs[out_id]);
                        for(i = 0; i < models[j]->nr_class; i++)
                                ptr[i] = models[j]->label[i];
                }
                else
                        rhs[out_id] = mxCreateDoubleMatrix(0, 0, mxREAL);

                mxSetFieldByNumber(plhs[0], j, out_id, rhs[out_id]);
                out_id++;

                // w
                rhs[out_id] = mxCreateDoubleMatrix(nr_w, w_size, mxREAL);
                ptr = mxGetPr(rhs[out_id]);
                for(int k = 0; k < w_size*nr_w; k++)
                        ptr[k]=models[j]->w[k];

                mxSetFieldByNumber(plhs[0], j, out_id, rhs[out_id]);
                out_id++;              

            }
    
            destroy_param(&param);
            free(prob.y);
            free(prob.x);
            free(x_space);
	}
	else
	{
		exit_with_help();
		fake_answer(nlhs, plhs);
		return;
	}
}
