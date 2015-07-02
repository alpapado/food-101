clc
clear

% Read class labels from file
fid = fopen('data/meta/classes.txt');
classes = textscan(fid, '%s', 'Delimiter', '\n');
classes = classes{1};

% base = 'data/';
superpixelsPath = 'data/superpixels/';
imagesPath = 'data/images/';

% Segment the dataset and save the results
c = parcluster;
matlabpool(c);
% parpool(c);
segmentDataset(imagesPath, classes, superpixelsPath);