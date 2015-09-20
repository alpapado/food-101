function Xr = ssrt(X)
%ssrt Signed square root tranformation
%   Perform signed square root transformation on the given vector X. This
%   is done in two steps:
%   1) L1 normalize the input vector
%   2) Square root each element

l1 = norm(X, 1);
Xr = sign(X) .* sqrt( abs(X) ./ l1);


end

