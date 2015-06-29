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

    % Train model
    SVMModel = fitcsvm(X',y,'KernelScale','auto', 'Cost', cost, 'KernelFunction', 'linear');
    
     % The full svm model is too large to save, considering that about 2000
     % such models will be saved. So, it must be shrunk
    compactModel = compact(SVMModel); % Discard training data
    
    try
        % **** R2015 only compatible ****
        reducedModel = discardSupportVectors(compactModel); % Discard support vectors
        % **** --------------------- ****
        models(i).svm = reducedModel;
%         p = predict(reducedModel, X');
    catch
        fprintf('exception \n');
        models(i).svm = compactModel;
%         p = predict(compactModel, X');
    end
       
%     pos = sum(y==1);
%     neg = sum(y==0);
%     acc = sum(p==y') ./ length(y);
    eval = evaluateModel(models(i).svm, X', y);
    fprintf('Examples = %d Accuracy = %s\n', length(y), num2str(eval(1)));
    
    % TODO Hard negative mining
end

end

