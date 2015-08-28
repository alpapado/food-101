function [ models ] = trainModels( topLeaves, class, validationSet )
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

