function [ randomTree ] = growRandomTree( trainingSet )
%growRandomTree Grows a random tree on the given training set.
%   trainingSet: Struct containing 2 fields: features, class
% On each node, many decision functions are generated. The decision
% function that achieves the highest information gain is kept. Binary SVMs
% on a random binary partition of the class labels are used as decision 
% functions
randomTree = tree(trainingSet);
 
% Has the termination criterion been met?
% If not split the node in 2


end

