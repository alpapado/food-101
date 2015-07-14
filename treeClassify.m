function [ rTree ] = treeClassify(rTree, data)
%treeClassify Classify data using the given tree
% Data is contained in the root of the tree at first and is gradually
% split into the other nodes of the tree

iterator = rTree.breadthfirstiterator;

% Assign all the cv data to the root of the tree
temp = rTree.get(1);
temp.cvData = data;
rTree = rTree.set(1, temp);

for node = iterator
    
    if rTree.isleaf(node)
        continue;
    end

    svmStruct = rTree.get(node).svm;
    nodeCvData = rTree.get(node).cvData;
    numData = size(nodeCvData, 2);
    cvSet = reshape( extractfield(nodeCvData, 'features'), [8576, numData] );
    split = predict(svmStruct, cvSet');
    cvLeft = nodeCvData(split == 0);
    cvRight = nodeCvData(split == 1);

    children = rTree.getchildren(node);
    leftId = children(1);
    rightId = children(2);
    
    % Assign cv data of children
    temp = rTree.get(leftId);
    temp.cvData = cvLeft;
    rTree = rTree.set(leftId, temp);
    
    temp = rTree.get(rightId);
    temp.cvData = cvRight;
    rTree = rTree.set(rightId, temp);
end

end

