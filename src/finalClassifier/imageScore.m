function scores = imageScore(models, features)
%imageClassify Returns the score matrix for every superpixel in the
%image
%   Each superpixel in the image is scored using the previously trained
%   component models. This leads to a score matrix of KxN component
%   confidence scores for K classes and N components for each superpixel
%   Each invididual score matrix is stored in the 3d matrix, scores.

% scores[numSuperpixels x numClasses x numComponents] score array

[nSuperpixels, ~] = size(features);
[nClasses, nComponents] = size(models);

scores = zeros(nSuperpixels, nClasses, nComponents);
X = features;

%TODO Maybe do this without loops
for k = 1:nClasses
    for n = 1:nComponents          
        model = models(k, n).svm;        
        [~, svmScore] = svmPredict(model, X);
        scores(:, k, n) = svmScore;
    end
end

end

