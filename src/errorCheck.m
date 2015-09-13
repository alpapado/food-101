function errorCheck(segments)
s = 0;
    for i = 1:max(max(segments))
        s = s + sum(sum(segments==i));
        fprintf('%d has %d\n', i, sum(sum(segments==i))); 
    end

fprintf('Total % d  Should be %d\n', s, size(segments, 1) * size(segments, 2));

end


% function [ tree1, tree2, tree3] = treeErrorCheck( rTree )
% %errorCheck Summary of this function goes here
% %   Detailed explanation goes here
% cvSetSize = length(rTree.get(1).cvData);
% 
% iterator = rTree.depthfirstiterator;
% % tree1 = rTree;
% % tree2 = rTree;
% % tree3 = tree(rTree, 'clear');
% 
% for i = 1:size(iterator, 2);
%     nodeId = iterator(i);
%     node = rTree.get(nodeId);
%     
%     if rTree.isleaf(nodeId)
%         continue;
%     end
%     
%     children = rTree.getchildren(nodeId);
%     leftId = children(1);
%     rightId = children(2);
%    
%     nodeSize = length(node.cvData);
%     leftSize = length(rTree.get(leftId).cvData);
%     rightSize = length(rTree.get(rightId).cvData);
%     
%     if nodeSize ~= leftSize + rightSize
%         fprintf('error \n');
%     end
% end
% 
% end

