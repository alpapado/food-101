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
numSVMs = 100;

% Set SVM parameters
numData = length(trsetInd);
numTrainingData = min(20*10^3, floor(0.6 * numData)); 
classes = trset.classIndex;

X = trset.features(trsetInd, :);

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
    y = randi([0 1], numTrainingData, 1);
    
    % Keep generating random binary partion until at least 1 sample of 
    % each class (0 or 1) is generated
    while size(unique(y), 1) < 2
        y = randi([0 1], numTrainingData, 1);
    end
     
    try
        % Train the SVM and discard training data
        fprintf('Training svm %d on %d instances...', i, numTrainingData);
        tstart = tic;
        model = train(y, sparse(double(X(1:numTrainingData, :))), '-s 3 -q');
        telapsed = toc(tstart);
        fprintf('Elapsed time is %f\n', telapsed);
        
        fprintf('Classifying %d instances with custom svm predict...', numData-numTrainingData);
        tstart = tic;
        split = zeros(numData, 1);
        split(1:length(y)) = y;
        split(length(y)+1:end) = svmPredict(model, X(numTrainingData+1:end, :));
        telapsed = toc(tstart);
        fprintf('Elapsed time is %f\n', telapsed);
        
    catch ME
        disp(ME);
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

