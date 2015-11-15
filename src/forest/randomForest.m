function trees = randomForest(numTrees, n)
%randomForest Grows a random forest
%   numTrees : Number of trees in forest
%   n : Number of training data for a tree
trees(numTrees) = struct('tree', [], 'leaves', []);
m = matfile('data.mat');

% [vset, vind] = sampleValidationSet(m, n); 
% save('vset.mat', 'vset', 'vind');
% clear vset
load('vset.mat', 'vind');

for i = 1:numTrees
    fprintf('Tree %d\n', i);
    
    % Sample training set
    trset = sampleTrainingData(m, n, vind);
    
    % Train tree
    % Root node contains the entire training set
    rootTrData = struct('trainingIndex', 1:n, 'classIndex', extractfield(trset, 'classIndex'));
    root = struct('trData', rootTrData, 'cvData', [], 'svm', []); % Set root node
    rtree = tree(root);
    rtree = randomTree(rtree, 1, trset); % Grow starting from 2nd node
    clear trset
    
    % Classify validation set using previously trained tree
    load('vset.mat', 'vset');
    fprintf('Classifing validation set using tree\n');
    rtree = treeClassify(rtree, vset);
    clear vset;
    
    % Extract leaves
    leafIndices = rtree.findleaves();
    leaves = struct('trData', [], 'cvData', []);
    
    for l = 1:length(leafIndices)
        leaf = rtree.get(leafIndices(l));
        leaves(l).trData = leaf.trData;
        leaves(l).cvData = leaf.cvData;
    end
    
    trees(i).tree = rtree;
    trees(i).leaves = leaves;
    
    save('trees', 'trees');
end


end

