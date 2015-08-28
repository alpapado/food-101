function [ superpixel] = imageScore( image, label, models )
%imageClassify Classifies an image using previously generated component
%models
%   Each superpixel in the image is scored using the previously trained
%   component models. This leads to a score vector of KxN component
%   confidence scores for K classes and N components for each superpixel

% Calculates the encodings (ivf) of all the superpixels in the image
spEncoding = encodeImage(image);

[numSuperpixels, numFeatures] = size(spEncoding);
[numClasses, numComponents] = size(models);

superpixel(numSuperpixels) = struct('scores', zeros(numClasses, numComponents));

for s = 1:numSuperpixels
    scores = zeros(numClasses, numComponents);
    X = spEncoding(s, :);
    y = randi([0 1], 1, 1); % not important
    
    for k = 1:numClasses
        for n = 1:numComponents          
            model = models(k, n).svm;
            [~, ~, prob_estimates] = predict(y, sparse(X), model, '-q');
            scores(k, n) = prob_estimates;
        end
    end
    superpixel(s).scores = mean(scores, 2);
    
end

end

