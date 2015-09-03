function models = mineComponents(trees, validationSet, params)
%mineComponents Mine discriminative components using the forest leaves
%   The process is as follows: First, the leaves are sorted based on their
%   distinctiveness. Those that contain too much similar information are
%   filtered out. Then for each class, the top N leaves are selected and
%   for each one a linear binary SVM is trained to act as a component
%   model. For training, the most confident samples of class y of a
%   selected leaf act as positive set, while a large repository of samples
%   act as negative. In addition, iterative hard-negative mining is
%   performed in order to speed up the process.

numClasses = params.numClasses;
numComponents = params.numComponents;
models(numClasses, numComponents) = struct('svm', []);

leaves = cell2mat(extractfield(trees, 'leaves'));
[~, ~, ~, distinct] = load('metrics');

% For a single class y, evaluate how many discriminative samples are
% located in each leaf by considering distinct(l,c)
for y = 1:numClasses
    fprintf('class %d --> ', y);
    
    % Sort leaves according to distinction score for current class
    distScore = distinct(:, y);
    [~, indexes] = sort(distScore, 'descend');
    sortedLeaves = leaves(indexes);
    
    % Prune sortedLeaves
    % TODO Speed up and fix pruneLeaves function
    prunedLeaves = sortedLeaves;
%     prunedLeaves = pruneLeaves(sortedLeaves);
    
    % Select top N (numComponents) leaves
    topLeaves = prunedLeaves(1:numComponents);
    
    % Train models for each top leaf
    models(y,:) = trainModels(topLeaves, y, validationSet);
end

end

function models = trainModels(topLeaves, class, validationSet)
%trainModels For each leaf in the topLeaves list trains a SVM
%   The samples belonging to the given class in each leaf are used as
%   positive examples while a large repository of negative samples,
%   randomly selected from the entire trainingSet, is used as negative
%   samples. The training procedure is further refined using hard negative
%   mining.
numModels = length(topLeaves);
models(numModels) = struct('svm', []);

for i = 1:numModels
    leaf = topLeaves(i);

    leafClasses = extractfield(leaf.cvData, 'classIndex');
    vsetIndexes = extractfield(leaf.cvData, 'validationIndex');
    numData = length(vsetIndexes);
    
    % Balance the training set
    tempX = transpose(reshape(extractfield(validationSet(vsetIndexes), 'features'), [8576, numData]));
    tempY = transpose(double(leafClasses == class));
 
    negatives = find(tempY==0);
    positives = find(tempY==1);
%     fprintf('Initial negatives=%d  positives=%d\n', length(negatives), length(positives));
    
    negativesToKeep = negatives(1:length(positives)+50);
    tempY = tempY([positives; negativesToKeep]);
    tempX = tempX([positives; negativesToKeep], :);
    
    permutation = randperm(length(tempY));
    X = tempX(permutation, :);
    y = tempY(permutation);

%     fprintf('After balancing negatives=%d  positives=%d\n', length(find(y==0)), length(find(y==1)));
    % Train model
    model = train(y, sparse(double(X)), '-s 2 -n 8 -q');
    models(i).svm = model;

%     eval = evaluateModel(model, X, y);
%     fprintf('F-measure = %s\n', num2str(eval(4)));
    
    % TODO Hard negative mining
end

end

