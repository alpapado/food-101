load('trees.mat');
leaves = cell2mat(extractfield(trees, 'leaves'));
load('validationSet');

fid = fopen('data/meta/classes.txt');
classes = textscan(fid, '%s', 'Delimiter', '\n');
classes = classes{1};
numComponents = 20;
numClasses = length(classes);

clear fid

numTrees = length(trees);

params = struct('numTrees', numTrees, 'numClasses', numClasses, 'numComponents', numComponents);
[classConf, classDist, delta] = classConfidence(leaves, params);
distinct = distinctiveness(leaves, classConf, delta, params);

models = mineComponents( trees, validationSet, numComponents, numClasses );