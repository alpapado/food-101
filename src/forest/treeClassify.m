function [ rtree ] = treeClassify(rtree, vset)
%treeClassify Classify data using the given tree
% Data arriving at a node, are sent to either its left or right child based
% on the decision function (linear svm) of the node.

iterator = rtree.breadthfirstiterator;

% Assign all the cv data to the root of the tree
rootCvData = struct('validationIndex', 1:length(vset.classIndex), 'classIndex', extractfield(vset,'classIndex'));
temp = rtree.get(1);
temp.cvData = rootCvData;
rtree = rtree.set(1, temp);

for n = iterator
    
    if rtree.isleaf(n)
        continue;
    end
  
    node = rtree.get(n);    
    model = node.svm;
        
    cvDataIndices = extractfield(node.cvData, 'validationIndex');
    X = vset.features(cvDataIndices, :);
    
    % Classify 
    split = svmPredict(model, X);
    cvLeft = cvDataIndices(split == 0);
    cvRight = cvDataIndices(split == 1);
    children = rtree.getchildren(n);
    leftId = children(1);
    rightId = children(2);
    
%     n
%     node.cvData
%     size(cvLeft)
%     size(cvRight)
%     pause
    
    % Assign cv data of children
    if ~isempty(cvLeft)
        childCvData = struct('validationIndex', cvLeft, 'classIndex', vset.classIndex(cvLeft));
        temp = rtree.get(leftId);
        temp.cvData = childCvData;
        rtree = rtree.set(leftId, temp);
    end
    
    if ~isempty(cvRight)
        childCvData = struct('validationIndex', cvRight, 'classIndex', vset.classIndex(cvRight));
        temp = rtree.get(rightId);
        temp.cvData = childCvData;
        rtree = rtree.set(rightId, temp);
    end
end

end

