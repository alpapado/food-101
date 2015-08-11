function [ trees ] = growRandomForest(numTrees, n)
%growRandomForest Grows a random forest
%   numTrees : Number of trees in forest
%   n : Number of training data for a tree
trees(numTrees) = struct('leaves', []);

for i = 1:numTrees
    fprintf('Tree %d\n', i);
    
    % Load training set
    mfile = matfile(['tree' num2str(i) '.mat']);
    trSet = mfile.trainingSet(1, 1:n);
          
    % Train tree
    % Root node contains the entire training set
    rootTrData = struct('trainingIndex', 1:n, 'classIndex', extractfield(trSet, 'classIndex'));
    root = struct('trData', rootTrData, 'cvData', [], 'svm', []); % Set root node
    rTree = tree(root);
    rTree = growRandomTree(rTree, 1, trSet); % Grow starting from 2nd node
    clear trSet
    
    % Classify validation set using previously trained tree
    % TODO: Maybe move cross validating somewhere else because of its heavy
    % memory requirements
    load('validationSet');
    rTree = treeClassify(rTree, validationSet(1:n));
    clear validationSet
    
    % Extract leaves
    leafIndices = rTree.findleaves();
    leaves = struct('trData', [], 'cvData', []);
    
    for l = 1:length(leafIndices)
        leaf = rTree.get(leafIndices(l));
        leaves(l).trData = leaf.trData;
        leaves(l).cvData = leaf.cvData;
%         leaves(l).cvData = leaf.cvData;
%         leaves(l).classIndex = extractfield(validationSet(leaf.cvData.validationIndexes), 'classIndex');
%         leaves(l).classLabel = extractfield(validationSet(leaf.cvData), 'classLabel');
    end
    trees(i).leaves = leaves;
    
end


end

