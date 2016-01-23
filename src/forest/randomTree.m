function rtree = randomTree(rtree, parentId, trset )
%randomTree Grows a random binary tree on the given training set.
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
% rtree: Variable of type 'tree', that holds the growing tree and that
%is updated as the tree growing process continues.
% parentId: Variable that shows which node of the tree is the caller of the
%function. ('randomTree' is a recursive function so this is an
%auxilliary variable)
% trset: A reference to the entire training set that is used for
%growing the tree. Since it is not changed inside this function no copy of
%it is created and no memory issue arises.

fprintf('Node %d...', parentId);

% Calculate the splits
parent = rtree.get(parentId);
tic;
[left, right, svm] = nodeSplit(trset, extractfield(parent.trData, 'trainingIndex'));
toc;
% Set parents svm
parent.svm = svm;
rtree = rtree.set(parentId, parent);

% Set left node
leftNode = struct('trData', left, 'cvData', [], 'svm', []);
[rtree, newNodeLeftId] = rtree.addnode(parentId, leftNode);

% Set right node
rightNode = struct('trData', right, 'cvData', [], 'svm', []);
[rtree, newNodeRightId] = rtree.addnode(parentId, rightNode);

% FOR DEBUGGING PURPOSES
% fprintf('parent: %s\n', num2str(length(parent.trData.classIndex)));
% fprintf('left: %s\n', num2str(length(leftNode.trData.classIndex)));
% fprintf('right: %s\n\n', num2str(length(rightNode.trData.classIndex)));

% Has the termination criterion been met?
% If not split each new node in 2
stopLeft = stopGrowing(trset, left.trainingIndex, rtree, newNodeLeftId);
if stopLeft ~= true
    rtree = randomTree(rtree, newNodeLeftId, trset);
end

stopRight = stopGrowing(trset, right.trainingIndex, rtree, newNodeRightId);
if  stopRight ~= true
    rtree = randomTree(rtree, newNodeRightId, trset);
end


end

function stop = stopGrowing(trset, trsetInd, tree, nodeId)
%stopGrowing Checks the termination conditions for stopping the random tree
%growth
%   Termination conditions:
%   1) A node contains too few samples (< 25 ).
%   2) A node contains samples of a single class.
%   3) A maximum value of depth of the tree has been reached.
%

stop = false;
maxDepth = 5;
minSamples = 25;

% Check condition #1
numData = size(trsetInd, 2);
if numData < minSamples
    fprintf('Too few samples left\n');
    stop = true;
end

% Check condition #2
classes = trset.classIndex(trsetInd);
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

