function scores = imageScore(models, X)
%imageClassify Returns the score matrix for every superpixel in the
%image
%   Each superpixel in the image is scored using the previously trained
%   component models. This leads to a score matrix of KxN component
%   confidence scores for K classes and N components for each superpixel
%   Each invididual score matrix is stored in the 3d matrix, scores.

% scores[numSuperpixels x numClasses x numComponents] score array

models = models';
models = cell2mat(extractfield(models(:), 'svm'));
[~, scores, ~] = svmPredict(models, X);

end