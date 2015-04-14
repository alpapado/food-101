clc
clear

% Read class labels from file
fid = fopen('food-101/meta/classes.txt');
classes = textscan(fid, '%s', 'Delimiter', '\n');
classes = classes{1};

base = 'food-101/';
images_path = 'food-101/images/';
superpixels_path = [base 'superpixels/'];

% Segment the dataset and save the results
% segmentDataset(images_path, classes, superpixels_path);
clear fid
clear base

[image, class, superpixels, index] = sampleRandomSuperpixel(superpixels_path, classes);
[features, points, labValues] = extractSuperpixelFeatures(image, superpixels, index);