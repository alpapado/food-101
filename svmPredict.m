function pred = svmPredict(model, X)
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

% Dataset 
m = size(X, 1);
pred = zeros(m, 1);

% We can use the weights and bias directly if working with the 
% linear kernel
if model.bias ~= -1
    p = X * transpose(model.w) + model.b;
else
    p = X * transpose(model.w);
end

% Convert predictions into 0 / 1
pred(p >= 0) =  1;
pred(p <  0) =  0;

end

