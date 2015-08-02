function [ tree1, tree2, tree3] = errorCheck( rTree )
%errorCheck Summary of this function goes here
%   Detailed explanation goes here
cvSetSize = length(rTree.get(1).cvData);

iterator = rTree.depthfirstiterator;
% tree1 = rTree;
% tree2 = rTree;
% tree3 = tree(rTree, 'clear');

for i = 1:size(iterator, 2);
    nodeId = iterator(i);
    node = rTree.get(nodeId);
    
    if rTree.isleaf(nodeId)
        continue;
    end
    
    children = rTree.getchildren(nodeId);
    leftId = children(1);
    rightId = children(2);
   
    nodeSize = length(node.cvData);
    leftSize = length(rTree.get(leftId).cvData);
    rightSize = length(rTree.get(rightId).cvData);
    
    if nodeSize ~= leftSize + rightSize
        fprintf('error \n');
    end
end

end

