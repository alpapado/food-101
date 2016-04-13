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
    sorted = leaves(indexes);
    
    % Prune sortedLeaves
    pruned = pruneLeaves(sorted, y);
    
    % Select top N (numComponents) leaves
    top = pruned(1:nComponents);
    
    % Train models for each top leaf
    components(y,:) = trainModels(top, y, vset);
    toc;
end

end

function models = trainModels(top, class, vset)
%trainModels For each leaf in the topLeaves list trains a SVM
%   The samples belonging to the given class in each leaf are used as
%   positive examples while a large repository of negative samples,
%   randomly selected from the entire trainingSet, is used as negative
%   samples. The training procedure is further refined using hard negative
%   mining.
nModels = length(top);
iterations = 10; % Hard negative iterations
models(nModels) = struct('svm', []);

negatives = (vset.classIndex ~= class); % Get negative indices

for i = 1:nModels
    leaf = top(i);
    
    leafClasses = transpose(leaf.cvData.classIndex);
    vind = leaf.cvData.validationIndex;

    X = vset.features(vind, :);
    y = transpose(double(leafClasses == class));
 
    % Create large negative pool
    negativePool = vset.features(negatives, :); % Fill the pool
    
    % Do hard negative mining
    model = hardNegativeMining(X, y, iterations, negativePool);
    models(i).svm = model;
       
end

models = models';
models = cell2mat(extractfield(models(:), 'svm'));

end

function model = hardNegativeMining(X, y, iterations, negativePool)

    pos = y==1;
    X = X(pos, :);
    y = y(pos);
    X = [X; negativePool(1:2000, :)];
    y = [y; zeros(2000, 1)];
    negativeTestVectors = negativePool(2001:end, :);
    nTestNegatives = size(negativeTestVectors, 1);
    
    fprintf('negatives=%d  positives=%d\n', length(find(y==0)), length(find(y==1)));
    % <------------------------------->
    
    % Train model once
    model = train(y, sparse(double(X)), '-s 3 -q');

    batchSize = ceil(nTestNegatives / iterations);

    for i = 1:iterations
           
        istart = (i-1)*batchSize + 1;
        iend = min(istart+ batchSize-1, nTestNegatives);
        
        tempX = negativeTestVectors(istart:iend, :);
        tempY = zeros(size(tempX,1), 1);
        
        Xnew = getTopFalsePositives( model, tempX, tempY);
        
        X = [X; Xnew];
        y = [y; zeros(size(Xnew, 1), 1)];
        fprintf('negatives=%d  positives=%d\n', length(find(y==0)), length(find(y==1)));
        model = train(y, sparse(double(X)), '-s 3 -q');

    end
    fprintf('\n');
end

