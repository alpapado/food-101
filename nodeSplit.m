function [ left, right, svm ] = nodeSplit( data )
%nodeSplit Splits the input data in two parts
%   Generate n binary SVMs as decision functions on random binary partitions
%   of the class labels in data. Hold the one that maximizes the
%   information gain criterion.
% data: Struct containing fields: features, class,

% Number of SVM models to be trained as decision function
numSVMs = 100;

% Set SVM parameters
numData = size(data, 2);
numTrainingData = min(20*10^3, floor(0.6 * numData)); % decision function training data
features = reshape( extractfield(data, 'features'), [8576, numData] );
classes = extractfield(data, 'classIndex');

% Set training set
X = features(:, 1:numTrainingData);
testSet = features(:, numTrainingData+1:end);

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
    
    % Train the SVM 1
    svmModel = fitcsvm(X', y, 'KernelFunction', 'linear');
    compactModel = compact(svmModel); % Discard training data

   matlab = ver;
   if strcmp(matlab(1).Release, 'R2015a')
       % **** R2015 only compatible ****
       model = discardSupportVectors(compactModel); % Discard support vectors
       % **** --------------------- ****
   else
       model = compactModel;
   end
%    try
%        % **** R2015 only compatible ****
%        model = discardSupportVectors(compactModel); % Discard support vectors
%        % **** --------------------- ****
%    catch      
%        fprintf('exception \n');
%        model = compactModel;
%    end
    
    % Classify the rest of the data
    svmResult = predict(model, testSet');
    
%     tic
%     svmModel2 = svmtrain(X', y);
%     svmResult2 = svmclassify(svmModel2, testSet' );
%     toc
    
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
        svm = model;
    end
    
end

% Choose the split with the largest information gain
left = data(bestSplitLeft);
right = data(bestSplitRight);


end

