function [predictions, scores, probs] = svmPredict(models, X)
%SVMPREDICT returns a vector of predictions using a trained LINEAR SVM model
%(svmTrain). 
%   pred = SVMPREDICT(model, X) returns a vector of predictions using a 
%   trained SVM model (svmTrain). X is a mxn matrix where there each 
%   example is a row. model is a svm model returned from train.
%   predictions pred is a m x 1 column of predictions of {0, 1} values.
%
% NOTE svmPredict does not always produce correct predictions because the
% class labels in the model struct, as returned by liblinear train, are
% sometimes reversed. Use it only to calculate the svm scores efficiently.

nModels = length(models);
m = size(X,1); % Instances
n = size(X,2); % Features

if nModels == 1
    % If we have only one model
    predictions = zeros(m, 1);

    % We can use the weights and bias directly if working with the 
    % linear kernel
    if models.bias ~= -1
        p = X * transpose(models.w) + models.bias;
    else
        p = X * transpose(models.w);
    end

    % Convert predictions into 0 / 1
    scores = p;
        
    if isequal(models.Label, [0; 1])
        predictions(p >= 0) =  0;
        predictions(p <  0) =  1;
    else
        predictions(p >= 0) =  1;
        predictions(p <  0) =  0;
    end
    
    % probs [2, m]
    probs(1,:) = 1 ./ (1 + exp(-scores));
    probs(2,:) = 1 - probs(1,:);
    
else
    
    % If we have multiple models, we can perform prediction for all of them
    % efficiently using again matrix multiplication
    W = reshape(extractfield(models, 'w'), [n nModels]);
    p = X * W;
    scores = p;
    
    % probs [2, m, nModels]
    probs(1,:,:) = 1 ./ (1 + exp(-scores));
    probs(2,:,:) = 1 - probs(1,:,:);

    predictions = zeros(m, nModels);
    predictions(p >= 0) =  1;
    predictions(p <  0) =  0;
end

end

