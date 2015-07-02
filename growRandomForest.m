function [ forest ] = growRandomForest(allData, numTrees)
%growRandomForest Grow a forest consisting of numTrees random trees
%   Detailed explanation goes here
% forest = [];
% Read class labels from file
n = 200 * 10^3; % 200k samples for training 
field1 = 'trData'; field2 = 'cvData'; field3 = 'svm';
forest(numTrees) = struct('tree', []);

parfor i = 1:numTrees
    fprintf('Tree %d\n', i);
    data = sampleTrainingData(n, allData);
    root = struct(field1, data, field2, [], field3, []);
    rTree = tree(root);
    rTree = growRandomTree(data, rTree, 1);
    forest(i).tree = rTree;
end


end

