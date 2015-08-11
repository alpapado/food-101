function [ rTree ] = treeClassify(rTree, validationSet)
%treeClassify Classify data using the given tree
% Data arriving at a node, are sent to either its left or right child based
% on the decision function (linear svm) of the node.

iterator = rTree.breadthfirstiterator;

% Assign all the cv data to the root of the tree
rootCvData = struct('validationIndex', 1:length(validationSet), 'classIndex', extractfield(validationSet,'classIndex'));
temp = rTree.get(1);
temp.cvData = rootCvData;
rTree = rTree.set(1, temp);

for n = iterator
    
    if rTree.isleaf(n)
        continue;
    end
  
    node = rTree.get(n);
    model = node.svm;
    cvDataIndices = extractfield(node.cvData, 'validationIndex');
    numData = length(validationSet(cvDataIndices));
    X = transpose(reshape( extractfield(validationSet(cvDataIndices), 'features'), [8576, numData]));
    
    % Classify the rest of the data by spliting them in blocks for memory efficiency
    numChunks = 10;
    chunkSize = ceil(numData / numChunks);
    split = zeros(numData, 1);
   
    for j = 1:numChunks
        startIndex = 1 + (j-1) * chunkSize;
        endIndex = min(startIndex + chunkSize - 1, numData);
        result = predict(zeros(length(startIndex:endIndex), 1), sparse(double(X(startIndex:endIndex, :))), model, '-q');
        split(startIndex:endIndex) = result;
    end
    
    cvLeft = cvDataIndices(split == 0);
    cvRight = cvDataIndices(split == 1);
    children = rTree.getchildren(n);
    leftId = children(1);
    rightId = children(2);
    
    % Assign cv data of children
    if ~isempty(cvLeft)
        childCvData = struct('validationIndex', cvLeft, 'classIndex', extractfield(validationSet(cvLeft), 'classIndex'));
        temp = rTree.get(leftId);
        temp.cvData = childCvData;
        rTree = rTree.set(leftId, temp);
    end
    
    if ~isempty(cvRight)
        childCvData = struct('validationIndex', cvRight, 'classIndex', extractfield(validationSet(cvRight),'classIndex'));
        temp = rTree.get(rightId);
        temp.cvData = childCvData;
        rTree = rTree.set(rightId, temp);
    end
end

end

