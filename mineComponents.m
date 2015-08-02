function [ models ] = mineComponents( leaves, validationSet, numComponents, numClasses )
%mineComponents Summary of this function goes here
%   Detailed explanation goes here

models(numClasses, numComponents) = struct('svm', []);

% Compute distinctivess measure for all leaves
distinct = distinctiveness(leaves, validationSet, numClasses);

% For a single class y, evaluate how many discriminative samples are
% located in each leaf by considering distinct(l,c)
for y = 1:numClasses
    fprintf('class %d --> ', y);
    
    % Sort leaves according to distinction score for current class
    score = distinct(:, y);
    [sortedDistinct, indexes] = sort(score, 'descend');
    fprintf('best leaves scores = %s\n', num2str(sortedDistinct(1:numComponents) ) );
    sortedLeaves = leaves(indexes);
    
    % Prune sortedLeaves
    prunedLeaves = pruneLeaves(sortedLeaves);
    
    % Select top N (numComponents) leaves
    topLeaves = prunedLeaves(1:numComponents);
    
    % Train models for each top leaf
    models(y,:) = trainModels(topLeaves, y);
end

end

