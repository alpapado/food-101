function F = extractImageFeatureVector_smallmem(I, params)
%extractImageFeatureVector_smallmem Extract the image feature vector for final
%classification
%   extractImageFeatureVector_smallmem(I, params) returns the final feature 
% vector for the image I, that can be used in classification. Firstly, the 
% image is segmented into superpixels. For these superpixels features over
% a grid are computed. The features of each superpixels are sparse encoded
% and a step of max pooling is applied leading to a 1-numBases sparse 
% vector representing the superpixel. The superpixel vectors are then
% scored by the components trained in the previous steps leading to a score
% matrix of numClasses-numComponents size for each image superpixel. The
% score matrices of each superpixel in the image are further aggregated
% using a slightly altered spatial pyramid scheme, leading to a final image
% feature vector of numCells*numClasses*numComponents, where numCells is
% the total number of all the cells at all leves of the spatial pyramid 
% (a spatial pyramid with 3 levels yields 21 cells in total).

pyramidLevels = params.pyramidLevels;
numCells = sum(4 .^ (0:pyramidLevels-1));
models = params.models;
[nClasses, nComponents] = size(models);

% Segment the image into superpixels
L = segmentImage(I);

% Compute the features for all superpixels
[features, badSegments] = extractImageFeatures(I, L, params, false);

% Calculate the score matrix
% scores = imageScore(models, features);
scores = features * params.W;

% Calculate the spatial pyramid grid
grid = spatialPyramid(pyramidLevels, I, L, badSegments);

% Preallocation
F = single(zeros(nClasses * nComponents * numCells, 1));

i = 0;
for gridCell = grid
    ind = gridCell.spixelsToAverage;
    X = scores(ind, :);
    
    av = mean(X, 1);
    
    iStart = i * nClasses * nComponents + 1;
    iEnd = iStart + nClasses * nComponents - 1;
    F(iStart : iEnd) = av;
    i = i + 1;
end

end