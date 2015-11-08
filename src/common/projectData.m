function Z = projectData(X, avg, U)
%PROJECTDATA Computes the reduced data representation when projecting only 
%on to the top k eigenvectors
%   Z = projectData(X, avg, U) computes the projection of 
%   the inputs X, after centering, into the reduced dimensional space spanned by
%   U. It returns the projected examples in Z.
%

m = size(X, 1);
X = X - repmat(avg, m, 1);
Z = X * U;

end
