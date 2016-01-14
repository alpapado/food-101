function components = mineComponents(leaves, metrics, vset, params)
%mineComponents Mine discriminative components using the forest leaves
%   The process is as follows: First, the leaves are sorted based on their
%   distinctiveness. Those that contain too much similar information are
%   filtered out. Then for each class, the top N leaves are selected and
%   for each one a linear binary SVM is trained to act as a component
%   model. For training, the most confident samples of class y of a
%   selected leaf act as positive set, while a large repository of samples
%   act as negative. In addition, iterative hard-negative mining is
%   performed in order to speed up the process.

nClasses = params.nClasses;
nComponents = params.nComponents;
components(nClasses, nComponents) = struct('svm', []);


distinct = metrics.distinct;

% For a single class y, evaluate how many discriminative samples are
% located in each leaf by considering distinct(l,c)
for y = 1:nClasses
    fprintf('class %d --> ', y);
    tic;
    % Sort leaves according to distinction score for current class
    distScore = distinct(:, y);
    [~, indexes] = sort(distScore, 'descend');
    sortedLeaves = leaves(indexes);
    
    % Prune sortedLeaves
    prunedLeaves = sortedLeaves;
%     prunedLeaves = pruneLeaves(sortedLeaves);
    
    % Select top N (numComponents) leaves
    topLeaves = prunedLeaves(1:nComponents);
    
    % Train models for each top leaf
    components(y,:) = trainModels(topLeaves, y, vset);
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
nModels = length(topLeaves);
iterations = 0; % Hard negative iterations
models(nModels) = struct('svm', []);

for i = 1:nModels
    leaf = topLeaves(i);

    leafClasses = extractfield(leaf.cvData, 'classIndex');
    vind = extractfield(leaf.cvData, 'validationIndex');
    
    X = vset.features(vind, :);
    y = transpose(double(leafClasses == class));
 
    % Do hard negative mining
    model = hardNegativeMining(X, y, iterations);
    models(i).svm = model;
       
end

end

function model = hardNegativeMining(X, y, iterations)
    
    % Negatives to be used for hard negative mining later
    negativeTestVectors = X(y==0, :); 

    negatives = find(y==0);
    positives = find(y==1);
    fprintf('Initial negatives=%d  positives=%d\n', length(negatives), length(positives));
   
    imbalance = randi([50 150], 1, 1);
    
    negativesToKeep = negatives(1:length(positives) + imbalance);
    
    % Remove the negative samples contained in the initial training set
    negativeTestVectors = negativeTestVectors(length(positives) + imbalance + 1:end, :);  
    
    y = y([positives; negativesToKeep]);
    X = X([positives; negativesToKeep], :);
    
    % Shuffle 
    permutation = randperm(length(y));
    X = X(permutation, :);
    y = y(permutation);
    fprintf('After balancing negatives=%d  positives=%d\n', length(find(y==0)), length(find(y==1)));
    
    % Train model once
    model = train(y, sparse(double(X)), '-s 3 -q');
    
    for i = 1:iterations
        nTestNegatives = size(negativeTestVectors, 1);    
        tempX = negativeTestVectors;
        tempY = zeros(nTestNegatives, 1);
        
        positives = y == 1;
        [predicted, accuracy] = evaluateModel(model, tempX,  tempY);
        fprintf('Iteration %d accuracy = %f - \n', i, accuracy);
        
        % Get false positives, add them to X and retrain the model
        fp = predicted(~positives) == 1;
%        fprintf('False positives = %d\n', sum(fp));
        
        X = [X; negativeTestVectors(fp, :)];
        y = [y; tempY(fp)];
%        fprintf('negatives=%d  positives=%d\n', length(find(y==0)), length(find(y==1)));
        model = train(y, sparse(double(X)), '-s 3 -q');
        negativeTestVectors(fp, :) = []; % Remove negatives
%         size(negativeTestVectors,1)
    end
    fprintf('\n');
end

