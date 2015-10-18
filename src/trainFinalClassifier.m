%  clear; clc;
 
% Read class labels from file
load('matlab.mat');
fid = fopen('data/meta/train.txt');
trImages = textscan(fid, '%s', 'Delimiter', '\n');
trImages = trImages{1};
% numTrImages = length(trImages);
numTrImages = 10;

load('models.mat');
load('params.mat');

pyramidLevels = 3;
params.pyramidLevels = pyramidLevels;

[numClasses, numComponents] = size(models);
numCells = sum(4 .^ (0:pyramidLevels-1)); % Num of cells in pyramid grid
d = numClasses * numComponents * numCells; % Dimensionality of feature vec

X = single(zeros(numTrImages, d));
y = single(zeros(numTrImages, 1));

for i = 1:numTrImages
    try
        tic
        fprintf('%d/%d ', i, numTrImages);
        str = num2str(cell2mat(trImages(i)));
        split = strsplit(str, '/');
        class = num2str(cell2mat(split(1)));
        imgPath = ['data/images/' str '.jpg'];
        image = imread(imgPath);
        X(i,:) = extractImageFeatureVector(image, models, params);
        y(i) = find(strcmp(classes, class));
        toc
    catch ME
        disp(getReport(ME,'extended'));
    end

end
