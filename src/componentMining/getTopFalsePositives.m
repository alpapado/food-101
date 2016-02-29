function Xnew = getTopFalsePositives( model, X, y )
%getTopFalsePositives Summary of this function goes here
%   Detailed explanation goes here

[yh, scores] = svmPredict(model, X);
positives = y == 1;
fp = yh(~positives) == 1;
fpInd = find(fp==1);
N = 20;

if length(fpInd) < N
    N = length(fpInd);
end

fprintf('False positives = %d\n', sum(fp));
[~, ia] = sort(abs(scores(fp)), 'descend');
Xnew = X(fpInd(ia(1:N)), :);
    
end


