function [left, right, svm] = nodeSplitParallel(trset, trsetInd)
%nodeSplitSerial Splits the input data in two parts
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
nThreads = 8;
solver = 3;
svmParams = sprintf('-s %d -n %d -q', solver, nThreads);

% Set SVM parameters
nData = length(trsetInd);
nTrainingData = min(nData, 20*10^3);
classes = trset.classIndex;

X = trset.features(trsetInd, :);
Y = trset.classIndex(trsetInd);

% Initialize struct to be used by all the threads for result saving
threadStruct(nSVMs) = struct('infoGain', 0, 'leftSplit', [], 'rightSplit', [], 'svm', []);
models = train_multi(double(Y(1:nTrainingData)), sparse(double(X(1:nTrainingData, :))), svmParams);
allSplits = svmPredict(models, X);

for i = 1:nSVMs
    try
        % Calculate information gain
        leftIndexes = trsetInd(allSplits(:,i) == 0);
        rightIndexes = trsetInd(allSplits(:,i) == 1);
        leftClasses = classes(leftIndexes);
        rightClasses = classes(rightIndexes);
        threadStruct(i).infoGain = informationGain(classes(trsetInd), leftClasses, rightClasses);
        threadStruct(i).leftSplit = leftIndexes;
        threadStruct(i).rightSplit = rightIndexes;
        threadStruct(i).svm = models(i);
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

