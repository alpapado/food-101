load('classes.mat', 'classes');
params = matfile('params.mat', 'Writable', true);
params.classes = classes;
params.nTrees = 30;
params.treeSamples = 200000;
params.nComponents = 20;
params.nClasses = 101;
params.descriptorType = 'surf';
params.gridStep = 8;
params.pyramidLevels = 3;
params.datasetPath = 'data/images';
params.descriptorBases = 512;
params.colorBases = 64;
params.pooling = 'max';
params.encoding = 'fisher';

if strcmp(params.descriptorType, 'sift')
    params.descriptorLength = 128;
    params.modes = 32;
elseif strcmp(params.descriptorType, 'surf')
    params.descriptorLength = 64;
    params.modes = 64;
end

if strcmp(params.encoding, 'sparse')
    params.encodingLength = params.descriptorBases + params.colorBases;
else
    params.encodingLength = 2 * params.modes * params.descriptorLength + 2 * params.modes * 3;
end

params = load('params.mat');

if ~isfield(params, 'featureGmm') && strcmp(params.encoding, 'fisher')
    encParams = calcGlobalParams(params);
    save('params.mat', '-append', '-struct', 'encParams');
end

params.ompParam.eps = 0.01;
params.ompParam.L = 10;
params.ompParam.numThreads = -1;

params.lassoParam.pos = 1;
params.lassoParam.lambda = 0.15;
params.lassoParam.numThreads = -1;
params.lassoParam.L = 20;
save('params.mat', '-struct', 'params');
disp(params);

% Generate random seed
rng('shuffle');

% Compute bases
if ~isfield(params, 'Bd') || ~isfield(params, 'Bc')
    [Xd, Xc] = getFeatureSample(500, params.descriptorType, false);
    [Bd, Bc] = computeBases(Xd, Xc, params.descriptorBases, params.colorBases);
    params.Bd = Bd;
    params.Bc = Bc;
    save('params.mat', '-struct', 'params');
end

% return;

% Segment and encode dataset
if ~exist('data.mat', 'file')
    segmentDataset(params);
end
return;
% Grow forest
if ~exist('./trees.mat', 'file')
   trees = randomForest(params);
else
   load('trees.mat');
end

if ~exist('vset', 'var')
    load('vset', 'vset');
end

leaves = cell2mat(extractfield(trees, 'leaves'));
clear trees;

if ~exist('metrics.mat', 'file')
    metrics = leafMetrics( leaves, params );
    save('metrics.mat', '-struct', 'metrics');
end
 
if ~exist('metrics', 'var')
    metrics = load('metrics');
end
 
% repo = load('data.mat');
models = mineComponents(leaves, metrics, vset, params);
params.models = models;
save('params.mat', '-struct', 'params');

%clear vset trset data

trainFinalClassifier(params);
clear;
% 
% load('train.mat');
% model = train(double(y), sparse(double(X)), '-s 2 -n 64');
% save('model.mat', 'model');
% clear;
% 
% load('test.mat');
% load('model');
% p = predict(double(y), sparse(double(X)), model);
