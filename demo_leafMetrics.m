% clear all
% Load tree/forest
load('rtree5k.mat');

% Load validation set
load('s1k.mat');

% rTree = treeClassify(rTree,s);
base = 'data/';
fid = fopen([base 'meta/classes.txt']);
classes = textscan(fid, '%s', 'Delimiter', '\n');
classes = classes{1};

[ models ] = mineComponents( rTree, s, 5, length(classes) );