num_bases = 256;
beta = 0.4;
batch_size = 1000;
num_iters = 100;
opt_choice = 2;

if opt_choice==1
    sparsity_func= 'epsL1';
    epsilon = 0.01;
elseif opt_choice==2
    sparsity_func= 'L1';
    epsilon = [];
end

load('food_sift_sample_norm_big');
load('sc_L1_b256_beta0.4_20160112T193515.mat');

pars.patch_size = size(X,1);
pars.num_patches = size(X,2);
pars.num_bases = num_bases;
pars.num_trials = num_iters;

if exist('batch_size', 'var') && ~isempty(batch_size)
    pars.batch_size = batch_size; 
else
    pars.batch_size = size(X,2)/10;
end

pars.sparsity_func = sparsity_func;
pars.beta = beta;
pars.epsilon = epsilon;

pars.noise_var = 1;
pars.sigma = 1;
pars.VAR_basis = 1;