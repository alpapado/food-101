function [ featureVec ] = extractImageFeatureVector( image, models, params )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

pyramidLevels = params.pyramidLevels;
numCells = sum(4 .^ (0:pyramidLevels-1));
[numClasses, numComponents] = size(models);

% Segment the image into superpixels
segments = segmentImage(image);

% Compute the features for all superpixels
features = extractImageFeatures(image, segments, params);

% Calculate the score matrix
scores = imageScore(models, features);

% Calculate the spatial pyramid grid
grid = spatialPyramid(pyramidLevels, image, segments);

% Preallocation
featureVec = single(zeros(numClasses * numComponents * numCells, 1));

i = 0;
for gridCell = grid
    ind = gridCell.spixelsToAverage; % sp indexing is not always sequential
    size(scores);
    X = scores(ind, :, :);
    av = mean(X, 1);
    iStart = i * numClasses * numComponents + 1;
    iEnd = iStart + numClasses * numComponents - 1;
    featureVec(iStart : iEnd) = av(:);
    i = i + 1;
end

end

