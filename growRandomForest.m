function [ forest ] = growRandomForest(numTrees)
%growRandomForest Grow a forest consisting of numTrees random trees
%   Detailed explanation goes here
% forest = [];
% Read class labels from file
nData = 10000;

for i = 1:numTrees
    data = sampleTrainingData(nData);
    rTree = tree(data);
    rTree = growRandomTree(data, rTree, 1);
    forest(i) = rTree;
end


end

