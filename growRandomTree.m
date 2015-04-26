function [ randomTree ] = growRandomTree( trainingSet, randomTree, parentId )
%growRandomTree Grows a random tree on the given training set.
%   trainingSet: Struct containing 2 fields: features, class
% On each node, many decision functions are generated. The decision
% function that achieves the highest information gain is kept. Binary SVMs
% on a random binary partition of the class labels are used as decision 
% functions

[left, right] = nodeSplit(trainingSet);

[randomTree, newNodeLeft] = randomTree.addnode(parentId, left);
[randomTree, newNodeRight] = randomTree.addnode(parentId, right);

% Has the termination criterion been met?
% If not split each new node in 2
stopLeft = stopGrowing(left, randomTree, newNodeLeft);
if stopLeft ~= true
    randomTree = growRandomTree(left, randomTree, newNodeLeft);
end

stopRight = stopGrowing(right, randomTree, newNodeRight);
if  stopRight ~= true
    randomTree = growRandomTree(right, randomTree, newNodeRight);
end


end

