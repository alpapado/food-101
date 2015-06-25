function [ models ] = trainModels( topLeaves, class )
%trainModels For each leaf in the topLeaves list trains a SVM
%   The samples belonging to the given class in each leaf are used as
%   positive examples while a large repository of negative samples,
%   randomly selected from the entire trainingSet, is used as negative
%   samples. The training procedure is further refined using hard negative
%   mining.
numModels = length(topLeaves);
models(numModels) = struct('svm', []);
cost = struct('ClassNames', [0, 1], 'ClassificationCosts', [0 15; 30 0]);

for i = 1:numModels
    leaf = topLeaves(i);
    numData = length(leaf.cvData);
    leafClasses = extractfield(leaf.cvData, 'classIndex');
    X = reshape(extractfield(leaf.cvData, 'features'), [8576, numData]);
    y = double(leafClasses == class);

    SVMModel = fitcsvm(X',y,'KernelScale','auto', 'Cost', cost);
     % The full svm struct is too large to save, considering that about 2000 such structures
    % will be saved. So, it must be shrunk
    compactModel = compact(SVMModel);
    
    % TODO Hard negative mining
    models(i).svm = compactModel;
end

end

