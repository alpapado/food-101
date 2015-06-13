function [ randomTree ] = growRandomTree( trainingSet, randomTree, parentId )
%growRandomTree Grows a random tree on the given training set.
%   trainingSet: Struct containing 2 fields: features, class
% On each node, many decision functions are generated. The decision
% function that achieves the highest information gain is kept. Binary SVMs
% on a random binary partition of the class labels are used as decision 
% functions

% Node fields
field1 = 'trData'; field2 = 'cvData'; field3 = 'svm';

% Calculate the splits
[left, right, svm] = nodeSplit(trainingSet);

% Set parents svm
temp = randomTree.get(parentId);
temp.svm = svm;
randomTree = randomTree.set(parentId, temp);

% Set left node
leftNode = struct(field1, left, field2, [], field3, []);
[randomTree, newNodeLeftId] = randomTree.addnode(parentId, leftNode);

% Set right node
rightNode = struct(field1, right, field2, [], field3, []);
[randomTree, newNodeRightId] = randomTree.addnode(parentId, rightNode);

% Has the termination criterion been met?
% If not split each new node in 2
stopLeft = stopGrowing(left, randomTree, newNodeLeftId);
if stopLeft ~= true
    randomTree = growRandomTree(left, randomTree, newNodeLeftId);
end

stopRight = stopGrowing(right, randomTree, newNodeRightId);
if  stopRight ~= true
    randomTree = growRandomTree(right, randomTree, newNodeRightId);
end


end

