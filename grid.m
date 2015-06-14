clc
clear

untar('food-101.tar.gz');

% Read class labels from file
fid = fopen('food-101/meta/classes.txt');
classes = textscan(fid, '%s', 'Delimiter', '\n');
classes = classes{1};

base = 'food-101/';
superpixelsPath = [base 'superpixels/'];
datasetPath = [base 'images'];

encoded = encodeDataset(datasetPath, superpixelsPath);
save('data_encoded.mat', 'encoded');