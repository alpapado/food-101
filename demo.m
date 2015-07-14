clc
clear

% Read class labels from file
fid = fopen('data/meta/classes.txt');
classes = textscan(fid, '%s', 'Delimiter', '\n');
classes = classes{1};

base = 'datas/';
superpixelsPath = [base 'superpixels/'];

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