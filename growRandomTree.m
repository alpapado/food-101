function [ randomTree ] = growRandomTree(randomTree, parentId )
%growRandomTree Grows a random tree on the given training set.
%   trainingSet: Struct containing 2 fields: features, class
% On each node, many decision functions are generated. The decision
% function that achieves the highest information gain is kept. Binary SVMs
% on a random binary partition of the class labels are used as decision 
% functions
%global TRAININGSET;

% TODO: trData, cvData must be indexes pointing to the original training struct
% instead of full structs themselves

% Node fields
field1 = 'trData'; field2 = 'cvData'; field3 = 'svm';

% Calculate the splits
parent = randomTree.get(parentId);
[left, right, svm] = nodeSplit(parent.trData);

% Set parents svm
parent.svm = svm;
randomTree = randomTree.set(parentId, parent);

% Discard parents' training data after training
% temp2 = rmfield(temp, 'trData');

% Set left node
leftNode = struct(field1, left, field2, [], field3, []);
[randomTree, newNodeLeftId] = randomTree.addnode(parentId, leftNode);

% Set right node
rightNode = struct(field1, right, field2, [], field3, []);
[randomTree, newNodeRightId] = randomTree.addnode(parentId, rightNode);

% FOR DEBUGGING PURPOSES
fprintf('parent: %s\n', num2str(parent.trData));
fprintf('left: %s\n', num2str(leftNode.trData));
fprintf('right: %s\n\n', num2str(rightNode.trData));

% Has the termination criterion been met?
% If not split each new node in 2
stopLeft = stopGrowing(left, randomTree, newNodeLeftId);
if stopLeft ~= true
    randomTree = growRandomTree(randomTree, newNodeLeftId);
% else
    % Discard training set
%     temp = randomTree.get(newNodeLeftId);
%     temp2 = rmfield(temp, 'trData');
%     randomTree = randomTree.set(newNodeLeftId, temp2);
end

stopRight = stopGrowing(right, randomTree, newNodeRightId);
if  stopRight ~= true
    randomTree = growRandomTree(randomTree, newNodeRightId);
% else
    % Discard training set
%     temp = randomTree.get(newNodeRightId);
%     temp2 = rmfield(temp, 'trData');
%     randomTree = randomTree.set(newNodeRightId, temp2);
end


end

