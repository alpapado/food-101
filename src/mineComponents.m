function models = mineComponents(trees, metrics, vset, params)
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
distinct = metrics.distinct;

% For a single class y, evaluate how many discriminative samples are
% located in each leaf by considering distinct(l,c)
for y = 1:numClasses
    fprintf('class %d --> ', y);
    tic;
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
    models(y,:) = trainModels(topLeaves, y, vset);
    toc;
end

end

function models = trainModels(topLeaves, class, vset)
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
    vind = extractfield(leaf.cvData, 'validationIndex');
    
    % Balance the training set
    tempX = vset.features(vind, :);
    tempY = transpose(double(leafClasses == class));
 
    negatives = find(tempY==0);
    positives = find(tempY==1);
%     fprintf('Initial negatives=%d  positives=%d\n', length(negatives), length(positives));
   
    inbalance = randi([250 500], 1, 1);
    
    negativesToKeep = negatives(randi([1 length(negatives)], length(positives)+inbalance, 1));
    tempY = tempY([positives; negativesToKeep]);
    tempX = tempX([positives; negativesToKeep], :);
    
    permutation = randperm(length(tempY));
    X = tempX(permutation, :);
    y = tempY(permutation);

%     fprintf('After balancing negatives=%d  positives=%d\n', length(find(y==0)), length(find(y==1)));
    % Train model
    model = train(y, sparse(double(X)), '-s 3 -q');
    models(i).svm = model;
    
%     y1 = predict(y, sparse(double(X)), model, '-q')
%     y2 = svmPredict(model, X);
%     isequal(y1, y2)
%     meval = evaluateModel(model, X, y);
%     fprintf('F-measure = %s\n\n', num2str(meval(4)));
%     
    % TODO Hard negative mining
end

end

