function [ label ] = imagePredict( image, params )
%imageClassify Summary of this function goes here
%   Detailed explanation goes here
% Read class labels from file
fprintf('Predicting...');
tic;
image = imresize(image, [NaN 512]);
size(image)
X = extractImageFeatureVector(image, params.components, params);
Z = projectData(X', params.pcaAvg, params.pcaU);
y = predict(0, sparse(double(Z)), params.model, '-q');
label = params.classes(y);
toc;

%[top, ind] = sort(prob_estimates, 'descend');
%fprintf('Top possibilities:\n');
%for i = 1:5
%  fprintf('%d %s\n', i, num2str(cell2mat(params.classes(ind(i))))); 
%end
%
end

