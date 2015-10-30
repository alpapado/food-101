function [U, S, avg] = pca(X)
%PCA Run principal component analysis on the dataset X
%   [U, S] = pca(X) computes eigenvectors of the covariance matrix of X
%   Returns the eigenvectors U, the eigenvalues (on diagonal) in S
%

% Useful values
m = size(X, 1);

% Center X
avg = mean(X, 1);
X = X - repmat(avg, m, 1);


Sigma = 1 / m * (X' * X);
[U, S, ~] = svd(Sigma);

end
