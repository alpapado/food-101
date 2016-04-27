function [ftRank,ftScore] = rfe(ft,label,param)
% Feature selection using SVM-recursive feature elimination (SVM-RFE) with
%	correlation bias reduction (CBR). LIBSVM is needed.
%	This is the original linear version of SVM-RFE in Guyon "Gene selection 
%	for cancer classification using support vector machines".
%	CBR is designed to deal with the problem in SVM-RFE when lots of highly
%	correlated features exist.
%   Only tested on binary-class cases. For multi-class cases, we simply
%   add the feature weights of each binary-class subproblems. This strategy
%   hasn't been verified.
%
%	FT :	feature matrix, each row is a sample. Better be scaled, such as
%		zero-mean and unit-variance
%	LABEL :	column vector of class labels of FT
%	PARAM : struct of parameters. All parameters are listed in the "default
%		parameters" section below. If the number of parameters scares you,
%		just tune the important parameters:
%	PARAM.rfeC : the parameter C in	SVM training.  See LIBSVM toolbox for meaning.
%	PARAM.useCBR : whether or not use the CBR strategy. If lots of highly
%		correlated features exist, use it may be better.
%	PARAM.Rth : correlation coef threshold for highly corr features.
%
%	FTRANK :	feature ranking result, most important first
%	FTSCORE :	a continuous score of each feature in FTRANK. Just for
%		logging purpose in this function.
%
% Please refer to Ke Yan et al., Feature selection and analysis on correlated
%	gas sensor data with recursive feature elimination, Sensors and Actuators
%	B: Chemical, 2015


% default parameters, can be changed by specifying the field in PARAM
% parameters for general SVM-RFE
rfeC = 2^0; % parameter C in SVM training
nStopChunk = 60; % when number of features is less than this num, start 
% removing one-by-one for precision. if set to inf, only remove one-by-one,
% accurate but slow.
rmvRatio = .5; % ratio of num of removed features before stopChunk

% parameters for CBR
useCBR = true; % whether or not use CBR
nOutCorrMax = 1; % max num of highly correlated features that can be removed
%	each iteration, when no feature highly corr with them is still kept. See our paper
Rth = .9; % corrcoef threshold for highly corr features

defParam % handle the parameters

% prepare
nFt = size(ft,2);
ftOut = find(std(ft)<=1e-5); % indices of removed features. First, remove constant features
ftIn = setdiff(1:nFt,ftOut); % indices of survived features
ftScore = [];

if useCBR
	R_all = abs(corrcoef(ft));%abs(corr(ft,'type','spearman'));%
end

kerOpt.C = rfeC;
kerOpt.type = 0; % only linear

% run
while ~isempty(ftIn)
	
	nFtIn = length(ftIn);
% 	[supVec,alpha_signed] = trainSVM(ft(:,ftIn),label,kerOpt);
	
	% criteria for each ft in ftIn, the larger the more important
% 	w2_in = sum((alpha_signed'*supVec).^2,1); % sum is used to add up the 
    w2_in = trainSVM(ft(:,ftIn),label,kerOpt);
	% feature weights of each binary-class subproblems. This strategy hasn't been verified.
	criteria = w2_in;
	[criterion_sort,idx] = sort(criteria,'ascend');
	% figure,plot(ftIn,criteria,'.-')
	
	% for logging purpose
	w2_tmp = nan(1,nFt);
	w2_tmp(ftIn) = criteria;
	ftScore = [ftScore;w2_tmp];
	
	% how many features to remove
	if nFtIn > nStopChunk
		nRemove = floor(nFtIn*rmvRatio);
		if nFtIn-nRemove < nStopChunk
			nRemove = nFtIn-nStopChunk;
		end
	else
		nRemove = 1;
	end
	
	ftOutCur = idx(1:nRemove); % to be removed
	FocRealIdx = ftIn(ftOutCur); % the real ft indices
	
	% CBR
	if useCBR && Rth < 1 && nRemove > 1
		ftInTemp = ftIn;
		ftInTemp(ftOutCur) = [];
		
		no_rmv = [];
		% rescue some features
		for iFtOut = nRemove:-1:1
			inSimilarNum = nnz(R_all(FocRealIdx(iFtOut),ftInTemp) > Rth);
			outSimilarNum = nnz(R_all(FocRealIdx(iFtOut),FocRealIdx) > Rth);
			if inSimilarNum < 1 && outSimilarNum > nOutCorrMax
				no_rmv = [no_rmv iFtOut];
				ftInTemp = [ftInTemp FocRealIdx(iFtOut)];
			end
		end
		ftOutCur(no_rmv) = [];
		FocRealIdx = ftIn(ftOutCur); % the real ft indices
		
	end % if useCBR && Rth < 1 && nRemove > 1
	
	ftOut = [ftOut,FocRealIdx];
	ftIn(ftOutCur) = [];
	
	if nRemove>1, fprintf('%d|',length(ftIn)); end
end % while ~isempty(ftIn)

ftRank = fliplr(ftOut); % least important ft in the end
ftScore = ftScore(:,ftRank); % just for logging. sorted according to ftRank

end


function [W] = trainSVM(X,Y,kerOpt)
% use libsvm to find the support vectors and alphas

type = sprintf('-s 2 -n 8 -c %f -q', kerOpt.C);
model = train(double(Y), sparse(double(X)), type);
if isempty(model)
	error('liblinear cannot be trained properly. Please check your data')
end

W = model.w;

% svIdxs = model.sv_indices; % older versions of libSVM don't have it

end
