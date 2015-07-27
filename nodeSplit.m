function [ left, right, svm ] = nodeSplit( trSetIndexes )
%nodeSplit Splits the input data in two parts
%   Generate n binary SVMs as decision functions on random binary partitions
%   of the class labels in data. Hold the one that maximizes the
%   information gain criterion.
% data: Struct containing fields: features, class,
global TRAININGSET;

data = TRAININGSET(trSetIndexes);

% Number of SVM models to be trained as decision function
numSVMs = 100;

% Set SVM parameters
numData = size(data, 2);
numTrainingData = min(20*10^3, floor(0.6 * numData)); % decision function training data
features = reshape( extractfield(data, 'features'), [8576, numData] );
classes = extractfield(TRAININGSET, 'classIndex');

% Set training set
X = features(:, 1:numTrainingData);

% Set test set
testSet = features(:, numTrainingData+1:end);

% Initialize struct to be used by all the threads for result saving
threadStruct(numSVMs) = struct('infoGain', 0, 'leftSplit', [], 'rightSplit', [], 'svm', []);

parfor i = 1:numSVMs
    % Generate random binary partition of class labels
    y = randi([0 1], numTrainingData, 1);
    
    % Keep generating random binary partion until at least 1 sample of 
    % each class (0 or 1) is generated
    while size(unique(y), 1) < 2
        y = randi([0 1], numTrainingData, 1);
    end
     
    try
        % Train the SVM
%         svmModel = fitcsvm(X', y, 'KernelFunction', 'linear');
        model = discardSupportVectors(compact(fitcsvm(X', y, 'KernelFunction', 'linear'))); % Discard training data

        % Classify the rest of the data
        svmResult = predict(model, testSet');
        split = [y; svmResult];
    catch ME
        disp(ME.identifier);
        continue;
    end

    % Calculate information gain
    leftIndexes = trSetIndexes(split == 0);
    rightIndexes = trSetIndexes(split == 1);
    leftClasses = classes(leftIndexes);
    rightClasses = classes(rightIndexes);
    
    threadStruct(i).infoGain = informationGain(classes, leftClasses, rightClasses);
    threadStruct(i).leftSplit = leftIndexes;
    threadStruct(i).rightSplit = rightIndexes;
    threadStruct(i).svm = model;
    
end

% Choose the split with the largest information gain
infoGains = extractfield(threadStruct, 'infoGain');
indexOfMaxGain = find(infoGains == max(infoGains) );
bestSplitLeft = threadStruct(indexOfMaxGain).leftSplit;
bestSplitRight = threadStruct(indexOfMaxGain).rightSplit;
svm = threadStruct(indexOfMaxGain).svm;
left = bestSplitLeft;
right = bestSplitRight;

end

