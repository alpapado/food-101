function [ featureVec ] = extractImageFeatureVector( image, models, params )
%extractImageFeatureVector Summary of this function goes here
%   Detailed explanation goes here

pyramidLevels = params.pyramidLevels;
numCells = sum(4 .^ (0:pyramidLevels-1));
[nClasses, nComponents] = size(models);

% Segment the image into superpixels
segments = segmentImage(image);

% Compute the features for all superpixels
features = extractImageFeatures2(image, segments, params);

% Calculate the score matrix
scores = imageScore(models, features);

% Calculate the spatial pyramid grid
grid = spatialPyramid(pyramidLevels, image, segments);

% Preallocation
featureVec = single(zeros(nClasses * nComponents * numCells, 1));

i = 0;
for gridCell = grid
    ind = gridCell.spixelsToAverage;
    X = scores(ind, :, :);
    av = mean(X, 1);

    iStart = i * nClasses * nComponents + 1;
    iEnd = iStart + nClasses * nComponents - 1;
    featureVec(iStart : iEnd) = av(:);
    i = i + 1;
end

end

