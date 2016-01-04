params = matfile('params.mat', 'Writable', true);
params.nTrees = 10;
params.treeSamples = 100000;
params.nComponents = 20;
params.nClasses = 101;
params.modes = 32;
params.featureType = 'sift';
params.encodingLength = 2*128*params.modes + 2*3*params.modes;

% encParams = calcGlobalParams(params.modes);
% save('params.mat', '-append', '-struct', 'encParams');

params = load('params.mat');

load('classes.mat', 'classes');
total = segmentDataset('data/images', classes, params);
trees = randomForest(params);

load('trees.mat');
load('vset', 'vset');

leaves = cell2mat(extractfield(trees, 'leaves'));

metrics = leafMetrics( leaves, params );
save('metrics.mat', 'metrics');

models = mineComponents(leaves, metrics, vset, params); 
save('components.mat', 'models');

trainFinalClassifier();
clear;

load('train.mat');
model = train(double(y), sparse(double(X)), '-s 2 -n 64');
save('model.mat', 'model');
clear;

load('test.mat');
load('model');
p = predict(double(y), sparse(double(X)), model);
