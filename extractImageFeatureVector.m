function [ featureVec ] = extractImageFeatureVector( imagePath, models )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

levels = 3;
numCells = sum(4 .^ (0:levels-1));
[numClasses, numComponents] = size(models);

% Calculate the encodings (ivf) of all the superpixels in the image
[encoding, segments, validSegments] = encodeImage(imagePath);

% Calculate the score matrix
superpixel = imageScore(models, encoding);

% Calculate the spatial pyramid grid
grid = spatialPyramid(levels, imread(imagePath), segments, validSegments);

% Preallocation
featureVec = zeros(numClasses * numComponents * numCells, 1);

i = 0;
for gridCell = grid
    ind = gridCell.spixelsToAverage;
    X = reshape(extractfield(superpixel(ind+1), 'scores'), [numClasses numComponents length(ind)]);
    av = mean(X, 3);
    iStart = i * numClasses * numComponents + 1;
    iEnd = iStart + numClasses * numComponents - 1;
    featureVec(iStart : iEnd) = av(:);
    i = i + 1;
end

end

