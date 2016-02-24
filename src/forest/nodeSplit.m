function [left, right, svm] = nodeSplit(trset, trsetInd)
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
numSVMs = 100;

% Set SVM parameters
nData = length(trsetInd);
nTrainingData = min(nData, 20*10^3);
classes = trset.classIndex;

X = trset.features(trsetInd, :);
Y = trset.classIndex(trsetInd);

% perm = randperm(length(Y));
% X = X(perm,:);
% Y = Y(perm);
% Remember to clear unwanted variables

% NOTE TO SELF: X and testSet fit in memory (3.5 gb). The problem lies in
% converting them to sparse format which requires them to be converted to
% doubles which doubles the required memory (7gb). In addition with the
% loading of the entire training set in memory (3.5gb) and the possible
% memory requirements of the svm training, out of memory happens.

% Initialize struct to be used by all the threads for result saving
threadStruct(numSVMs) = struct('infoGain', 0, 'leftSplit', [], 'rightSplit', [], 'svm', []);

for i = 1:numSVMs
    
    % Generate random binary partition of class labels
    ind = randi([1 size(X,1)], nTrainingData, 1);
    y = binaryPartition(Y(ind));

    fprintf('Training svm %d on %d instances...\n', i, nTrainingData);
    fprintf('Positive %d - Negative %d \n', sum(y==1), sum(y==0));
    
    try
        % Train the SVM and discard training data
        model = train(double(y), sparse(double(X(ind, :))), '-s 2 -n 8 -q');
        split = svmPredict(model, X);
%         split = zeros(nData, 1);
%         split(1:length(y)) = y;
%         split(length(y)+1:end) = svmPredict(model, X(nTrainingData+1:end, :)); 
    catch ME
        disp(getReport(ME,'extended'));
        continue;
    end

    % Calculate information gain
    leftIndexes = trsetInd(split == 0);
    rightIndexes = trsetInd(split == 1);
    leftClasses = classes(leftIndexes);
    rightClasses = classes(rightIndexes);
   
    threadStruct(i).infoGain = informationGain(classes(trsetInd), leftClasses, rightClasses);
    threadStruct(i).leftSplit = leftIndexes;
    threadStruct(i).rightSplit = rightIndexes;
    threadStruct(i).svm = model;
    
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

function yb = binaryPartition(y)

presentClasses = unique(y);
yb = y;

randMap = randi([0 1], length(presentClasses), 1);

while length(unique(randMap)) == 1
    fprintf('stuck\n');
    disp(presentClasses);
    randMap = randi([0 1], length(presentClasses), 1);
end

for j = 1:length(randMap)
    yb(y==presentClasses(j)) = randMap(j);
end

end

