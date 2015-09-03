function scores = imageScore(models, features )
%imageClassify Returns the score matrix for every superpixel in the
%image
%   Each superpixel in the image is scored using the previously trained
%   component models. This leads to a score matrix of KxN component
%   confidence scores for K classes and N components for each superpixel
%   Each invididual score matrix is stored in the 3d matrix, scores.

% scores[numSuperpixels x numClasses x numComponents] score array

[numSuperpixels, ~] = size(features); % Ignore too small superpixels
[numClasses, numComponents] = size(models);

scores = zeros(numSuperpixels, numClasses, numComponents);
X = features;
y = randi([0 1], numSuperpixels, 1); % not important

parfor k = 1:numClasses
    for n = 1:numComponents          
        model = models(k, n).svm;
        [~, ~, prob_estimates] = predict(y, sparse(X), model, '-q');
        scores(:, k, n) = prob_estimates;
    end
end

end

