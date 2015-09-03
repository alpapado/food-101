clc
clear

% Read class labels from file
fid = fopen('data/meta/classes.txt');
classes = textscan(fid, '%s', 'Delimiter', '\n');
classes = classes{1};

base = 'data/';
superpixelsPath = [base 'superpixels/'];

% Generate random seed
[~, seed] = system('od /dev/urandom --read-bytes=4 -tu | awk ''{print $2}''');
seed = str2double(seed);

% Seed the generator
rng(seed);

clear fid
clear base
clear seed