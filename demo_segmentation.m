clc
clear

% Read class labels from file
fid = fopen('data/meta/classes.txt');
classes = textscan(fid, '%s', 'Delimiter', '\n');
classes = classes{1};

base = 'food-101/';
superpixelsPath = [base 'superpixels/'];

% Segment the dataset and save the results
imagesPath = 'food-101/images/';
c = parcluster;
matlabpool(c);
% parpool(c);
segmentDataset(imagesPath, classes, superpixelsPath);