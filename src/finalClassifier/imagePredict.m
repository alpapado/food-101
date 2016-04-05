function label = imagePredict( I, model, params)
%imageClassify Summary of this function goes here
%   Detailed explanation goes here
% Read class labels from file
fprintf('Predicting...');
tic;
I = imresize(I, [NaN 512]);
X = extractImageFeatureVector(I, params);
size(X)
y = predict(0, sparse(double(X')), model, '-q');
label = params.classes(y);
toc;
end

