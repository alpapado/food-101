function [ tree1, tree2] = errorCheck( rTree )
%errorCheck Summary of this function goes here
%   Detailed explanation goes here

iterator = rTree.breadthfirstiterator;
tree1 = rTree;
tree2 = rTree;

for i = 1:size(iterator, 2);
    node = iterator(i);
    temp = rTree.get(node);
    tree1 = tree1.set(node, size(temp.trData,2));
    tree2 = tree2.set(node, size(temp.cvData,2));
end

% tree1.tostring
% tree2.tostring
end

