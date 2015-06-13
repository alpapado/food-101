function [ forest ] = growRandomForest(numTrees)
%growRandomForest Grow a forest consisting of numTrees random trees
%   Detailed explanation goes here
% forest = [];
% Read class labels from file
nData = 10000;
field1 = 'trData'; field2 = 'cvData'; field3 = 'svm';

for i = 1:numTrees
    data = sampleTrainingData(nData);
    root = struct(field1, data, field2, [], field3, []);
    rTree = tree(root);
    rTree = growRandomTree(data, rTree, 1);
    forest(i) = rTree;
end


end

