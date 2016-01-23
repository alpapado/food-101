load('classes.mat', 'classes');
params = matfile('params.mat', 'Writable', true);
params.classes = classes;
params.nTrees = 30;
params.treeSamples = 200000;
params.nComponents = 20;
params.nClasses = 101;
params.featureType = 'sift';
params.gridStep = 8;
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

% Segment and encode dataset
total = segmentDataset(params);

% Generate random seed
[~, seed] = system('od /dev/urandom --read-bytes=4 -tu | awk ''{print $2}''');
seed = str2double(seed);

% Seed the generator
rng(seed);

% Grow forest
trees = randomForest(params);

if ~exist('trees', 'var')
    load('trees.mat');
end

if ~exist('vset', 'var')
    load('vset', 'vset');
end
 
leaves = cell2mat(extractfield(trees, 'leaves'));

metrics = leafMetrics( leaves, params );
save('metrics.mat', 'metrics');

if ~exist('metrics', 'var')
    load metrics;
end

models = mineComponents(leaves, metrics, vset, params);
params.models = models;
save('components.mat', 'models');
save('params.mat', '-struct', 'params');

clear vset trees

trainFinalClassifier(params);
clear;

%load('train.mat');
%model = train(double(y), sparse(double(X)), '-s 2 -n 64');
%save('model.mat', 'model');
%clear;

%load('test.mat');
%load('model');
%p = predict(double(y), sparse(double(X)), model);
