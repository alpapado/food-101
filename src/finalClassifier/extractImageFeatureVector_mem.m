function F = extractImageFeatureVector_mem(I, L, features, params)
%extractImageFeatureVector_mem Faster version of extractImageFeatureVector

pyramidLevels = params.pyramidLevels;
numCells = sum(4 .^ (0:pyramidLevels-1));
models = params.models;
[nClasses, nComponents] = size(models);

% Segment the image into superpixels
%L = segmentImage(I);

badSegments = [];

% Calculate the score matrix
scores = imageScore(models, features);

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

