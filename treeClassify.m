function [ rTree ] = treeClassify(rTree, validationSet)
%treeClassify Classify data using the given tree
% Data is contained in the root of the tree at first and is gradually
% split into the other nodes of the tree

iterator = rTree.breadthfirstiterator;

% Assign all the cv data to the root of the tree
temp = rTree.get(1);
temp.cvData = 1:length(validationSet);
rTree = rTree.set(1, temp);

for node = iterator
    
    if rTree.isleaf(node)
        continue;
    end

    model = rTree.get(node).svm;
    cvDataIndices = extractfield(rTree.get(node), 'cvData');
    nodeCvData = validationSet(cvDataIndices);
    numData = size(nodeCvData, 2);
    cvSet = transpose(reshape( extractfield(nodeCvData, 'features'), [8576, numData] ));
    split = predict(zeros(numData,1), sparse(double(cvSet)), model, '-q');
    cvLeft = cvDataIndices(split == 0);
    cvRight = cvDataIndices(split == 1);
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

