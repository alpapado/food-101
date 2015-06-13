clc
clear

% Read class labels from file
fid = fopen('food-101/meta/classes.txt');
classes = textscan(fid, '%s', 'Delimiter', '\n');
classes = classes{1};

base = 'food-101/';
superpixelsPath = [base 'superpixels/'];

% Segment the dataset and save the results
% imagesPath = 'food-101/images/';
% segmentDataset(imagesPath, classes, superpixelsPath);

% Generate random seed
[~, seed] = system('od /dev/urandom --read-bytes=4 -tu | awk ''{print $2}''');
seed = str2double(seed);

% Seed the generator
rng(seed);

clear fid
clear base
clear seed

% nData = 10;
% s = sampleTrainingData(nData, superpixelsPath, classes);
load('s1k.mat');
field1 = 'trData'; field2 = 'cvData'; field3 = 'svm';
root = struct(field1, s, field2, [], field3, []);
rTree = tree(root);
rTree = growRandomTree(s, rTree, 1);

% nTrees = 10;
% forest = growRandomForest(nTrees);