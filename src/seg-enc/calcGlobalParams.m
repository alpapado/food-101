function params = calcGlobalParams(params)
%calcGlobalParams Calculate a gmm and a pca representation of the data
%   Detailed explanation goes here

featureGmm = struct('means', [], 'covariances', [], 'priors', []);
labGmm = struct('means', [], 'covariances', [], 'priors', []);
featurePca = struct('avg', [], 'U', [], 'S', []);
labPca = struct('avg', [], 'U', [], 'S', []);

[Xd, Xc] = getFeatureSample(2000);

% Order of calculations:
% 0) SURFs are transformed using signed square rooting (done in
% getFeatureSample)
% 1) PCA is computed 
% 2) Data is projected to pca space
% 3) Projected data is whitened using pca whitening
% 4) GMMs are computed on data from 3)

% Step 0
allFeatures = Xd;
allLabs = Xc;
modes = params.modes;

% Step 1
% Compute pca for surfs
fprintf('Computing pca for features\n');
tic;
[U, S, avg] = pca(allFeatures);
toc;
featurePca.avg = avg;
featurePca.U = U;
featurePca.S = S;

% Compute pca for labs
fprintf('Computing pca for labs\n');
tic;
[U, S, avg] = pca(allLabs);
toc;
labPca.avg = avg;
labPca.U = U;
labPca.S = S;

% Step 2 and 3
allFeatures = pcaw(allFeatures, featurePca);
allLabs = pcaw(allLabs, labPca);

% Step 4
% Fit gmm to surfs
fprintf('Fitting gmm to features\n');
tic;[means, covariances, priors] = vl_gmm(allFeatures', modes);toc;
featureGmm.means = means;
featureGmm.covariances = covariances;
featureGmm.priors = priors;
clear allSurfs;

% Fit gmm to labs
fprintf('Fitting gmm to labs\n');
tic;[means, covariances, priors] = vl_gmm(allLabs', modes);toc;
labGmm.means = means;
labGmm.covariances = covariances;
labGmm.priors = priors;
clear allLabs;

params = struct('labGmm', labGmm, 'labPca', labPca, 'featureGmm', featureGmm, 'featurePca', featurePca);

end
