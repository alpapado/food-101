function [ rTree ] = growRandomForest(numTrees, numTrainingData)
%growRandomForest Grow a forest consisting of numTrees random trees
%   numTrees : Number of trees in forest
%   n : Number of training data for a tree
field1 = 'trData'; field2 = 'cvData'; field3 = 'svm';
% load('validationSet.mat'); % Load validation set
trees(numTrees) = struct('leaves', []);
minStep = 100;
maxStep = 250;
global TRAININGSET;
global VALIDATIONDATA;
VALIDATIONDATA = TRAININGSET;

for i = 1:numTrees
    fprintf('Tree %d\n', i);
    TRAININGSET = sampleTrainingData(numTrainingData, minStep, maxStep); % Generate training set
    root = struct(field1, 1:length(TRAININGSET), field2, [], field3, []);
    
    % Train tree
    rTree = tree(root);
    rTree = growRandomTree(rTree, 1);
    
    % Classify validation set using previously trained tree
%     rTree = treeClassify(rTree, validationSet);
    
    % Extract leaves
%     leafIndices = rTree.findleaves();
%     leaves = struct(field2, [], field3, []);
%     
%     for l = 1:length(leafIndices)
%         leaves(l) = rTree.get(leafIndices(l));
%     end
%     trees(i).leaves = leaves;
end


end

