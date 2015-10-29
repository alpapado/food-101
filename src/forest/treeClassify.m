function [ rTree ] = treeClassify(rTree, vset)
%treeClassify Classify data using the given tree
% Data arriving at a node, are sent to either its left or right child based
% on the decision function (linear svm) of the node.

iterator = rTree.breadthfirstiterator;

% Assign all the cv data to the root of the tree
rootCvData = struct('validationIndex', 1:length(vset.classIndex), 'classIndex', extractfield(vset,'classIndex'));
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
    X = vset.features(cvDataIndices, :);
    
    % Classify 
    split = svmPredict(model, X);
    cvLeft = cvDataIndices(split == 0);
    cvRight = cvDataIndices(split == 1);
    children = rTree.getchildren(n);
    leftId = children(1);
    rightId = children(2);
    
    % Assign cv data of children
    if ~isempty(cvLeft)
        childCvData = struct('validationIndex', cvLeft, 'classIndex', vset.classIndex(cvLeft));
        temp = rTree.get(leftId);
        temp.cvData = childCvData;
        rTree = rTree.set(leftId, temp);
    end
    
    if ~isempty(cvRight)
        childCvData = struct('validationIndex', cvRight, 'classIndex', vset.classIndex(cvRight));
        temp = rTree.get(rightId);
        temp.cvData = childCvData;
        rTree = rTree.set(rightId, temp);
    end
end

end

