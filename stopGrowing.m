function [ stop ] = stopGrowing( node, tree, nodeId )
%stopGrowing Checks the termination conditions for stopping the random tree
%growth
%   Conditions include:
%   1) A node contains too few samples (< 25 ).
%   2) A node contains samples of a single class.
%   3) A maximum value of depth of the tree has been reached.
%
%   node is a struct containing the following fields:
%   a) features 
%   b) classLabel
%   c) classIndex

stop = false;
maxDepth = 7;
minSamples = 25;

% Check condition #1
numData = size(node, 2);
if numData < minSamples
    fprintf('Too few samples left\n');
    stop = true;
end

% Check condition #2
classes = extractfield(node, 'classIndex');
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

