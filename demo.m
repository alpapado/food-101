clc
clear

% Read class labels from file
fid = fopen('food-101/meta/classes.txt');
classes = textscan(fid, '%s', 'Delimiter', '\n');
classes = classes{1};

% Segment the dataset and save the results
base = 'food-101/';
images_path = 'food-101/images/';
superpixels_path = [base 'superpixels/'];
segment_dataset(images_path, classes, superpixels_path);