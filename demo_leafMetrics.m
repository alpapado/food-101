% clear all
% Load tree/forest
% load('rtree5k.mat');

% Load validation set
load('trees.mat');
leaves = cell2mat(extractfield(trees, 'leaves'));
load('validationSet');

% base = 'data/';
fid = fopen('data/meta/classes.txt');
classes = textscan(fid, '%s', 'Delimiter', '\n');
classes = classes{1};
numComponents = 20;
numClasses = length(classes);

clear fid

numTrees = 10;

params = struct('numTrees', numTrees, 'numClasses', numClasses, 'numComponents', numComponents);

[classConf, classDist, delta] = classConfidence(leaves, params);
% Compute distinctivess measure for all leaves
distinct = distinctiveness(leaves, classConf, delta, params);

models = mineComponents( trees, validationSet, numComponents, numClasses );