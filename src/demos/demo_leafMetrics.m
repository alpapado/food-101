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

%models = mineComponents( trees, metrics, vset, params); 
