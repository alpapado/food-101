function [ left, right ] = nodeSplit( data )
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

% Set training set
X = features(:, 1:numTrainingData);

infoGain = zeros(numSVMs, 1);

for i = 1:numSVMs
    % Generate random binary partition of class labels
    y = randi([0 1], numTrainingData, 1);

    % Train the SVM
    svmStruct = svmtrain(X', y);

    % Classify the rest of the data
    testSet = features(:, numTrainingData+1:end);
    svmResult = svmclassify(svmStruct, testSet' );
    split = [y; svmResult];

    left = find(split == 0);
    right = find(split == 1);
end

end

