params = calcGlobalParams();
total = segmentDataset('data/images', classes, params);
trees = randomForest(10, 100000);

load('trees.mat');
load('vset', 'vset');
load('classes.mat', 'classes');
load('metrics');

leaves = cell2mat(extractfield(trees, 'leaves'));
numComponents = 20;
numClasses = length(classes);
numTrees = length(trees);

params = struct('numTrees', numTrees, 'numClasses', numClasses, 'numComponents', numComponents);
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
