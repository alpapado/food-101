function [left, right, svm] = nodeSplit(trset, trsetInd)
%nodeSplit Splits the input data in two parts
%   Generates n binary SVMs as decision functions on random binary partitions
%   of the class labels in data. Keeps the one that maximizes the
%   information gain criterion.
% trset: The total training set on which the tree is being grown. 
% Note that since it is not changed inside the function body, no copy is created.
% That is useful for saving memory space
% trsetInd: Indexes of the total training set that define the input data for
% the current tree node
left = struct('trainingIndex', [], 'classIndex', []);
right = struct('trainingIndex', [], 'classIndex', []);

% Number of SVM models to be trained as decision function
nSVMs = 100;

% Set SVM parameters
nData = length(trsetInd);
nTrainingData = min(20*10^3, floor(0.6 * nData)); 
classes = trset.classIndex;

X = trset.features(trsetInd, :);

% Remember to clear unwanted variables

% NOTE TO SELF: X and testSet fit in memory (3.5 gb). The problem lies in
% converting them to sparse format which requires them to be converted to
% doubles which doubles the required memory (7gb). In addition with the
% loading of the entire training set in memory (3.5gb) and the possible
% memory requirements of the svm training, out of memory happens.

% Initialize struct to be used by all the threads for result saving
threadStruct(nSVMs) = struct('infoGain', 0, 'leftSplit', [], 'rightSplit', [], 'svm', []);
[candidates, y] = train_multi(randi([0 1], nTrainingData, 1), sparse(double(X(1:nTrainingData, :))), '-s 3 -q');

W = reshape(extractfield(candidates, 'w'), [8576 nSVMs]);
y = reshape(y, nTrainingData, nSVMs);
pred = X(nTrainingData+1:end, :) * W;
allSplits = [y; pred];

for i = 1:nSVMs
    try
        % Calculate information gain
        leftIndexes = trsetInd(allSplits(:,i) == 0);
        rightIndexes = trsetInd(allSplits(:,i) == 1);
        leftClasses = classes(leftIndexes);
        rightClasses = classes(rightIndexes);

        informationGain(classes(trsetInd), leftClasses, rightClasses);
        threadStruct(i).infoGain = informationGain(classes(trsetInd), leftClasses, rightClasses);
        threadStruct(i).leftSplit = leftIndexes;
        threadStruct(i).rightSplit = rightIndexes;
        threadStruct(i).svm = candidates(i);
    catch ME
        disp(getReport(ME,'extended'));
    end
    
end

% Choose the split with the largest information gain
infoGains = extractfield(threadStruct, 'infoGain');
indexOfMaxGain = find(infoGains == max(infoGains) );
bestSplitLeft = threadStruct(indexOfMaxGain).leftSplit;
bestSplitRight = threadStruct(indexOfMaxGain).rightSplit;

% Set return parameters
svm = threadStruct(indexOfMaxGain).svm;
left.trainingIndex = bestSplitLeft;
left.classIndex = classes(bestSplitLeft);
right.trainingIndex = bestSplitRight;
right.classIndex = classes(bestSplitRight);

end

function infoGain = informationGain(X, L, R)
%informationGain Computes the information gain from partitioning X into
% L and R

entropyLeft = numel(L) * entropy(L) / numel(X);
entropyRight = numel(R) * entropy(R) / numel(X);
initialEntropy = entropy(X);
infoGain = initialEntropy - entropyLeft - entropyRight;

end

function E = entropy(X)
    probX = arrayfun(@(x)length(find(X==x)), unique(X)) / length(X);
    E = -sum(probX .* log2(probX));
end

