function [left, right, svm] = nodeSplit(trainingSet, trainingSetIndexes)
%nodeSplit Splits the input data in two parts
%   Generates n binary SVMs as decision functions on random binary partitions
%   of the class labels in data. Keeps the one that maximizes the
%   information gain criterion.
% trainingSet: The total training set on which the tree is being grown. 
% Note that since it is not changed inside the function body, no copy is created.
% That is useful for saving memory space
% trainingSetIndexes: Indexes of the total training set that define the input data for
% the current tree node
left = struct('trainingIndex', [], 'classIndex', []);
right = struct('trainingIndex', [], 'classIndex', []);

% Number of SVM models to be trained as decision function
numSVMs = 100;

% Set SVM parameters
numData = length(trainingSetIndexes);
numTrainingData = min(10*10^3, floor(0.6 * numData)); 
classes = extractfield(trainingSet, 'classIndex');

X = transpose(reshape(extractfield(trainingSet(trainingSetIndexes), 'features'), [8576, numData]));

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
%        fprintf('Training svm %d on %d instances...\n', i, numTrainingData);
        model = train(y, sparse(double(X(1:numTrainingData, :))), '-s 2 -n 8 -q');
      
%       fprintf('Classifying %d instances...\n', numData-numTrainingData);
        
        % Classify the rest of the data by spliting them in blocks for
        % memory efficiency
        numChunks = 8;
        chunkSize = ceil((numData - numTrainingData) / numChunks);

        split = zeros(numData, 1);
        split(1:length(y)) = y;     
        for j = 1:numChunks
            startIndex = numTrainingData + 1 + (j-1) * chunkSize;
            endIndex = min(startIndex + chunkSize - 1, numData);
            result = predict(zeros(length(startIndex:endIndex), 1), sparse(double(X(startIndex:endIndex, :))), model, '-q');
            split(startIndex:endIndex) = result;
        end      

    catch ME
        disp(ME);
        continue;
    end

    % Calculate information gain
    leftIndexes = trainingSetIndexes(split == 0);
    rightIndexes = trainingSetIndexes(split == 1);
    leftClasses = classes(leftIndexes);
    rightClasses = classes(rightIndexes);
    
    threadStruct(i).infoGain = informationGain(classes(trainingSetIndexes), leftClasses, rightClasses);
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

function infoGain = informationGain(data, dataLeft, dataRight)
%informationGain Computes the information gain from partitioning data into
%dataLeft and dataRight
%   The information gain is computed, using the 'shannon' formula for
%   the entropy in a vector
type = 'shannon';

entropyLeft = numel(dataLeft) * wentropy(dataLeft, type) / numel(data);
entropyRight = numel(dataRight) * wentropy(dataRight, type) / numel(data);
initialEntropy = wentropy(data, type);
infoGain = initialEntropy - entropyLeft - entropyRight;

end

