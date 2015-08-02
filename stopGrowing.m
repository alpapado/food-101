function [ stop ] = stopGrowing( trainingSet, trainingSetIndexes, tree, nodeId )
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

