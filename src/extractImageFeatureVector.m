function [ featureVec ] = extractImageFeatureVector( image, models, pyramidLevels )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


numCells = sum(4 .^ (0:pyramidLevels-1));
[numClasses, numComponents] = size(models);

% Segment the image into superpixels
segments = segmentImage(image);

% Compute the features for all superpixels
[features, validSegments] = extractImageFeatures(image, segments);

% Calculate the score matrix
scores = imageScore(models, features);

% Calculate the spatial pyramid grid
grid = spatialPyramid(pyramidLevels, image, segments, validSegments);

% Preallocation
featureVec = single(zeros(numClasses * numComponents * numCells, 1));

i = 0;
for gridCell = grid
    ind = gridCell.spixelsToAverage; % sometimes is empty
    X = scores(ind, :, :);
    av = mean(X, 1);
    iStart = i * numClasses * numComponents + 1;
    iEnd = iStart + numClasses * numComponents - 1;
    featureVec(iStart : iEnd) = av(:);
    i = i + 1;
end

end

