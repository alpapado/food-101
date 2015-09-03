function [ randomTree ] = growRandomTree(randomTree, parentId, trainingSet )
%growRandomTree Grows a random binary tree on the given training set.
% 
% Grows a binary tree with the following procedure:
% On each node, a number of linear SVMs is generated on random binary
% partitions of the class labels, to be used as decision functions. 
% Among all the generated svm models, the one that
% provides the largest information gain is selected and is used to split
% the input data of the node into two parts.

% Each node of the tree contains the following variables:
% trData: Indexes pointing to the tree training set and their corresponding 
%classes, that show which data from the training set have made it to this node.
% cvData: Indexes pointing to the tree validation set and their corresponding 
% classes, that show which data from the validation set have made it to this node.
% svm: The decision function that has been appointed to this node. If the
%node is a leaf of the tree, svm is empty.

% The function accepts the following inputs:
% randomTree: Variable of type 'tree', that holds the growing tree and that
%is updated as the tree growing process continues.
% parentId: Variable that shows which node of the tree is the caller of the
%function. ('growRandomTree' is a recursive function so this is an
%auxilliary variable)
% trainingSet: A reference to the entire training set that is used for
%growing the tree. Since it is not changed inside this function no copy of
%it is created and no memory issue arises.


% Node fields
field1 = 'trData'; field2 = 'cvData'; field3 = 'svm';

% Calculate the splits
parent = randomTree.get(parentId);
[left, right, svm] = nodeSplit(trainingSet, extractfield(parent.trData, 'trainingIndex'));

% Set parents svm
parent.svm = svm;
randomTree = randomTree.set(parentId, parent);

% Set left node
leftNode = struct(field1, left, field2, [], field3, []);
[randomTree, newNodeLeftId] = randomTree.addnode(parentId, leftNode);

% Set right node
rightNode = struct(field1, right, field2, [], field3, []);
[randomTree, newNodeRightId] = randomTree.addnode(parentId, rightNode);

% FOR DEBUGGING PURPOSES
% fprintf('parent: %s\n', num2str(length(parent.trData.classIndex)));
% fprintf('left: %s\n', num2str(length(leftNode.trData.classIndex)));
% fprintf('right: %s\n\n', num2str(length(rightNode.trData.classIndex)));

% Has the termination criterion been met?
% If not split each new node in 2
stopLeft = stopGrowing(trainingSet, left.trainingIndex, randomTree, newNodeLeftId);
if stopLeft ~= true
    randomTree = growRandomTree(randomTree, newNodeLeftId, trainingSet);
end

stopRight = stopGrowing(trainingSet, right.trainingIndex, randomTree, newNodeRightId);
if  stopRight ~= true
    randomTree = growRandomTree(randomTree, newNodeRightId, trainingSet);
end


end

function stop = stopGrowing(trainingSet, trainingSetIndexes, tree, nodeId)
%stopGrowing Checks the termination conditions for stopping the random tree
%growth
%   Termination conditions:
%   1) A node contains too few samples (< 25 ).
%   2) A node contains samples of a single class.
%   3) A maximum value of depth of the tree has been reached.
%

stop = false;
maxDepth = 7;
minSamples = 25;

% Check condition #1
numData = size(trainingSetIndexes, 2);
if numData < minSamples
    fprintf('Too few samples left\n');
    stop = true;
end

% Check condition #2
classes = extractfield(trainingSet(trainingSetIndexes), 'classIndex');
if numel(unique(classes)) == 1
    fprintf('Single class samples left\n');
    stop = true;
end

% Check condition #3
depthTree = depthtree(tree);
if depthTree.get(nodeId) >= maxDepth
    fprintf('Max depth reached\n');
    stop = true;
end

end

