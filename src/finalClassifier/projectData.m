function Z = projectData(X, avg, U_reduce)
%PROJECTDATA Computes the reduced data representation when projecting only 
%on to the top k eigenvectors
%   Z = projectData(X, U, K) computes the projection of 
%   the normalized inputs X into the reduced dimensional space spanned by
%   the first K columns of U. It returns the projected examples in Z.
%

m = size(X, 1);
X = X - repmat(avg, m, 1);

% U_reduce = U(:, 1:K);
Z = X * U_reduce;
end
