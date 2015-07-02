clc
clear

% run('vlfeat/toolbox/vl_setup.m');
base = 'data/';

% Read class labels from file
classFile = [base 'meta/classes.txt'];
fid = fopen(classFile);
classes = textscan(fid, '%s', 'Delimiter', '\n');
classes = classes{1};

superpixelsPath = [base 'superpixels/'];
datasetPath = [base 'images/'];

c = parcluster;
matlabpool(c);
%parpool(c);
encoded = encodeDataset(datasetPath, superpixelsPath, classes);
save('data_encoded.mat', 'encoded');
