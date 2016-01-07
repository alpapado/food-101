load('classes.mat', 'classes');
params = matfile('params.mat', 'Writable', true);
params.classes = classes;
params.nTrees = 1;
params.treeSamples = 100000;
params.nComponents = 20;
params.nClasses = 101;
params.featureType = 'sift';
params.gridStep = 5;
params.pyramidLevels = 3;

if strcmp(params.featureType, 'sift')
    params.featureLength = 128;
    params.modes = 32;
elseif strcmp(params.featureType, 'surf')
    params.featureLength = 64;
    params.modes = 64;
end

params.encodingLength = 2*params.featureLength*params.modes + 2*3*params.modes;

encParams = calcGlobalParams(params);
save('params.mat', '-append', '-struct', 'encParams');

params = load('params.mat');
params

total = segmentDataset('data/images', classes, params);
trees = randomForest(params);

load('trees.mat');
load('vset', 'vset');

leaves = cell2mat(extractfield(trees, 'leaves'));

metrics = leafMetrics( leaves, params );
save('metrics.mat', 'metrics');

models = mineComponents(leaves, metrics, vset, params); 
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
