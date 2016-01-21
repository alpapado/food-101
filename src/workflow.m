load('classes.mat', 'classes');
params = matfile('params.mat', 'Writable', true);
params.classes = classes;
params.nTrees = 20;
params.treeSamples = 200000;
params.nComponents = 20;
params.nClasses = 101;
params.featureType = 'sift';
params.gridStep = 5;
params.pyramidLevels = 3;
params.datasetPath = 'data/images';
params.numBases = 512;

if strcmp(params.featureType, 'sift')
    params.featureLength = 128;
    params.modes = 32;
elseif strcmp(params.featureType, 'surf')
    params.featureLength = 64;
    params.modes = 64;
end

params.encodingLength = 2*params.featureLength*params.modes + 2*3*params.modes;
params.encodingLength = params.numBases;
% encParams = calcGlobalParams(params);
% save('params.mat', '-append', '-struct', 'encParams');

params = load('params.mat');
params

total = segmentDataset(params);
trees = randomForest(params);

load('trees.mat');
load('vset', 'vset');

leaves = cell2mat(extractfield(trees, 'leaves'));

metrics = leafMetrics( leaves, params );
save('metrics.mat', 'metrics');

models = mineComponents(leaves, metrics, vset, params);
params.models = models;
save('components.mat', 'models');

trainFinalClassifier(params);
clear;

load('train.mat');
model = train(double(y), sparse(double(X)), '-s 2 -n 64');
save('model.mat', 'model');
clear;

load('test.mat');
load('model');
p = predict(double(y), sparse(double(X)), model);
