function [ image, class, imageSuperpixels, superpixelIndex ] = sampleRandomSuperpixel( superpixelFolder, classes )
%sampleRandomSuperpixel Returns a random superpixel from a random image
%form a random class

% Generate random class index
classIndex = randi([1 size(classes, 1)], 1);
class = num2str(cell2mat(classes(classIndex)));

% Select randomly an image name for which to get the superpixel
listing = dir([superpixelFolder class '/*.mat']);
imageIndex = randi([1 size(listing, 1)], 1);
segments = listing(imageIndex).name;

% Randomly select a superpixel for the image chosen
load(segments);
imageSuperpixels = seg;
numSuperpixels = max(max(imageSuperpixels));
superpixelIndex = randi([1 numSuperpixels], 1);

% Also return the original image
image = imread([segments(1:end-4) '.jpg']);

end

