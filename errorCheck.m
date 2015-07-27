function [ tree1, tree2, tree3] = errorCheck( rTree )
%errorCheck Summary of this function goes here
%   Detailed explanation goes here
% cvSetSize = length(rTree.get(1).cvData);

iterator = rTree.depthfirstiterator;
tree1 = rTree;
tree2 = rTree;
tree3 = tree(rTree, 'clear');

for i = 1:size(iterator, 2);
    node = iterator(i);
    temp = rTree.get(node);
    tree3 = tree3.set(node, temp.trData);
%     tree1 = tree1.set(node, size(temp.trData,2));
%     tree2 = tree2.set(node, size(temp.cvData,2));
%     
%     if isempty(temp.cvData) 
%         tree3 = tree3.set(node, '');
%     else
%         tree3 = tree3.set(node, num2str( extractfield(temp.cvData, 'id') ) );
%     end
% end
% 
% leafIndexes = rTree.findleaves();
% s = 0;
% svm = 0;
% for l = 1:length(leafIndexes)
%     if isempty(rTree.get(leafIndexes(l)).cvData)
%         continue
%     end
%     s = s + length(rTree.get(leafIndexes(l)).cvData);
%     ids = extractfield(rTree.get(leafIndexes(l)).cvData, 'id');
%     fprintf('Leaf %d samples : %s\n', l, num2str(ids));
%     
%     if (~isempty(rTree.get(leafIndexes(l)).svm))
%         svm = svm + 1;
%     end
% end
% 
% fprintf('Validation set size -> %d samples\n', cvSetSize);
% fprintf('All leaves of tree together -> %d samples\n', s);
% fprintf('Non empty svms (should be zero) -> %d\n', svm);
% tree1.tostring
% tree2.tostring
end

