% clear; clc;
imgSet = imageSet('data/images', 'recursive');
fid = fopen('data/meta/train.txt');
trImages = textscan(fid, '%s', 'Delimiter', '\n');
trImages = trImages{1};
% numTrImages = length(trImages);
numTrImages = 10000;

load('quickndirty');
[numClasses, numComponents] = size(models);
pyramidLevels = 3;
numCells = sum(4 .^ (0:pyramidLevels-1)); % Num of cells in pyramid grid
d = numClasses * numComponents * numCells; % Dimensionality of feature vec

X = single(zeros(numTrImages, d));
y = single(zeros(numTrImages, 1));

for i = 1:numTrImages
    fprintf('%d/%d\n', i, numTrImages);
    str = num2str(cell2mat(trImages(i)));
    split = strsplit(str, '/');
    class = num2str(cell2mat(split(1)));
    
    randClass = randi([1 101],1,1);
    imgPath = num2str(cell2mat(imgSet(randClass).ImageLocation(randi([1 1000], 1, 1))));
    image = imread(imagePath);
    while size(image, 3) == 1
        imgPath = num2str(cell2mat(imgSet(randClass).ImageLocation(randi([1 1000], 1, 1))));
        image = imread(imagePath);
    end
%     imgPath = ['data/images/' str '.jpg'];
    try
        X(i,:) = extractImageFeatureVector(imgPath, models, pyramidLevels);
        y(i) = randClass;
    catch
        continue;
    end
%     spPath = ['data/superpixels/' str '.mat'
%     encPath = ['data/done/' class '.mat']
end
