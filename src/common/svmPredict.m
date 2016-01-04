function [predictions, scores] = svmPredict(models, X)
%SVMPREDICT returns a vector of predictions using a trained LINEAR SVM model
%(svmTrain). 
%   pred = SVMPREDICT(model, X) returns a vector of predictions using a 
%   trained SVM model (svmTrain). X is a mxn matrix where there each 
%   example is a row. model is a svm model returned from train.
%   predictions pred is a m x 1 column of predictions of {0, 1} values.
%

% Check if we are getting a column vector, if so, then assume that we only
% need to do prediction for a single example
% if (size(X, 2) == 1)
%     % Examples should be in rows
%     X = X';
% end

nModels = length(models);
m = size(X, 1);

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
    predictions(p >= 0) =  1;
    predictions(p <  0) =  0;
else 
    % If we have multiple models, we can perform prediction for all of them
    % efficiently using again matrix multiplication
    W = reshape(extractfield(models, 'w'), [2*128*32 + 2*3*32 nModels]);
    p = X * W;
    scores = p;
    predictions = zeros(m, nModels);
    predictions(p >= 0) =  1;
    predictions(p <  0) =  0;
end

end

