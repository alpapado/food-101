function Xr = ssrt(X)
%ssrt Signed square root tranformation
%   Perform signed square root transformation on the given vector X. This
%   is done in two steps:
%   1) L1 normalize the input vector
%   2) Square root each element

[m, n] = size(X);
Xr = zeros(m, n);
eps = 10^(-7);

for i = 1:m
    l1 = norm(X(i,:), 1);
    Xr(i,:) = sign(X(i,:)) .* sqrt( abs(X(i,:)./ (l1+eps)) );
end


end

