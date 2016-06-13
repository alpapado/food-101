function top5 = imagePredict( I, W, params)
%imageClassify Summary of this function goes here
%   Detailed explanation goes here
% Read class labels from file
fprintf('Predicting...');
tic;

labels = 1:101;
N = 5;
% W = model.w;

I = imresize(I, [NaN 512]);
X = extractImageFeatureVector_smallmem(I, params);
whos
P = W*X;
[~, sortedP] = sort(P, 'descend');
topPredictions = labels(sortedP(1:N));

top5 = params.classes(topPredictions);

toc;
end

