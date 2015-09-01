function [ superpixel, scores] = imageScore(models, encoding )
%imageClassify Calculates the score matrix for every superpixel in the
%image
%   Each superpixel in the image is scored using the previously trained
%   component models. This leads to a score matrix of KxN component
%   confidence scores for K classes and N components for each superpixel

[numSuperpixels, ~] = size(encoding); % Ignore too small superpixels
[numClasses, numComponents] = size(models);

% tic;
% superpixel(numSuperpixels) = struct('scores', zeros(numClasses, numComponents));
% 
% % TODO Remove outer for loop
% for s = 1:numSuperpixels
%     scores = zeros(numClasses, numComponents);
%     X = encoding(s, :);
%     y = randi([0 1], 1, 1); % not important
%     
%     for k = 1:numClasses
%         for n = 1:numComponents          
%             model = models(k, n).svm;
%             [~, ~, prob_estimates] = predict(y, sparse(X), model, '-q');
%             scores(k, n) = prob_estimates;
%         end
%     end
%     superpixel(s).scores = scores;
%     
% end
% 
% toc;
tic
scores = zeros(numSuperpixels, numClasses, numComponents);
X = encoding;
y = randi([0 1], numSuperpixels, 1); % not important

for k = 1:numClasses
    for n = 1:numComponents          
        model = models(k, n).svm;
        [~, ~, prob_estimates] = predict(y, sparse(X), model, '-q');
        scores(:, k, n) = prob_estimates;
    end
end
% superpixel(s).scores = scores;
toc
end

