function [ models ] = mineComponents( trees, validationSet, params )
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

