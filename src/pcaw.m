function Xw = pcaw(X, pca)
%pcaw Performs pca whitening on the input data X
%   PCA whitening is a preprocessing techique that causes the different
%   components in the input data X, to become uncorrelated and to have unit
%   variance.

% Regularization parameter
epsilon = 10^(-5);

% Get params
m = size(X, 1);
S = pca.S;
U = pca.U;
avg = pca.avg;

% Center the data
X = X - repmat(avg, m, 1);

% Whiten the data
% X * U is the projection of X, to the pca vector space (Xrot)
Xw = X * U * diag(1./sqrt(diag(S) + epsilon));

end

