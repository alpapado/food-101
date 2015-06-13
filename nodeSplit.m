function [ left, right, svm ] = nodeSplit( data )
%nodeSplit Splits the input data in two parts
%   Generate n binary SVMs as decision functions on random binary partitions
%   of the class labels in data. Hold the one that maximizes the
%   information gain criterion.
% data: Struct containing fields: features, class,

% Number of SVM models to train
numSVMs = 100;

% Set SVM parameters
numData = size(data, 2);
numTrainingData = floor(0.2 * numData);
features = reshape( extractfield(data, 'features'), [8576, numData] );
classes = extractfield(data, 'classIndex');

% Set training set
X = features(:, 1:numTrainingData);

infoGain = -realmax;
bestSplitLeft = zeros(numData, 1);
bestSplitRight = zeros(numData, 1);

for i = 1:numSVMs
    % Generate random binary partition of class labels
    y = randi([0 1], numTrainingData, 1);
    
    % Keep generating random binary partion until at least 1 sample of 
    % each class (0 or 1) is generated
    while size(unique(y), 1) < 2
        y = randi([0 1], numTrainingData, 1);
    end
    
    % Train the SVM
    try
      svmStruct = svmtrain(X', y);
    catch me
       size(data)
       y 
    end

    % Classify the rest of the data
    testSet = features(:, numTrainingData+1:end);
    svmResult = svmclassify(svmStruct, testSet' );
    split = [y; svmResult];

    % Calculate information gain
    leftIndexes = split == 0;
    rightIndexes = split == 1;
    leftClasses = extractfield(data(leftIndexes), 'classIndex');
    rightClasses = extractfield(data(rightIndexes), 'classIndex');
    
    temp = informationGain(classes, leftClasses, rightClasses);
    
    if temp > infoGain
        infoGain = temp;
        bestSplitLeft = leftIndexes;
        bestSplitRight = rightIndexes;
        svm = svmStruct;
    end
    
end

% Choose the split with the largest information gain
left = data(bestSplitLeft);
right = data(bestSplitRight);

end

