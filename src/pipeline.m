params = setParams();

% Segment and encode dataset
if ~exist('data.mat', 'file')
%    segmentDataset(params);
end

% Grow forest
if ~exist('./trees.mat', 'file')
%   trees = randomForest(params);
else
%   load('trees.mat');
end

load trees
params.nTrees = length(trees);
if ~exist('vset', 'var')
    load('vset', 'vset');
end

leaves = cell2mat(extractfield(trees, 'leaves'));
clear trees;

metrics = leafMetrics( leaves, params );
save('metrics.mat', '-struct', 'metrics');
 
if ~exist('metrics', 'var')
    metrics = load('metrics');
end
 
models = mineComponents(leaves, metrics, vset, params);
params.W = reshape(extractfield(models, 'w'), [params.encodingLength length(models)]);
params.models = models;
save('params.mat', '-struct', 'params');

trainFinalClassifier_mem(params);
clear;
 
load('train.mat');

fprintf('Loaded training set\n');
whos
tic;
model = train(double(y), sparse(double(X)), '-s 2 -n 64 -q');
toc;
save('model', 'model');

clear X y
load('test.mat');
load('model');
fprintf('Loaded test set\n');
[pred, acc, prob] = predict(double(y), sparse(double(X)), model);
exit;
