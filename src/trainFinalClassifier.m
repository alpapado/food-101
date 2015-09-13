 clear; clc;
 
% Read class labels from file
fid = fopen('data/meta/classes.txt');
classes = textscan(fid, '%s', 'Delimiter', '\n');
classes = classes{1};
imgSet = imageSet('data/images', 'recursive');
fid = fopen('data/meta/train.txt');
trImages = textscan(fid, '%s', 'Delimiter', '\n');
trImages = trImages{1};
% numTrImages = length(trImages);
numTrImages = 1500;

load('quickndirty');
[numClasses, numComponents] = size(models);
pyramidLevels = 3;
numCells = sum(4 .^ (0:pyramidLevels-1)); % Num of cells in pyramid grid
d = numClasses * numComponents * numCells; % Dimensionality of feature vec

X = single(zeros(numTrImages, d));
y = single(zeros(numTrImages, 1));

for i = 1:numTrImages
    try
        fprintf('%d/%d\n', i, numTrImages);
        str = num2str(cell2mat(trImages(i)));
        split = strsplit(str, '/');
        class = num2str(cell2mat(split(1)));

%         randClass = randi([1 2],1,1);
%         imgPath = num2str(cell2mat(imgSet(randClass).ImageLocation(randi([1 1000], 1, 1))));
%         while size(image, 3) == 1
%             imgPath = num2str(cell2mat(imgSet(randClass).ImageLocation(randi([1 1000], 1, 1))));
%             image = imread(imgPath);
%         end
        imgPath = ['data/images/' str '.jpg']
        image = imread(imgPath);
        
        X(i,:) = extractImageFeatureVector(image, models, pyramidLevels);
        y(i) = find(strcmp(classes, class));
    catch ME
        disp(ME.message);
        continue;
    end
%     spPath = ['data/superpixels/' str '.mat'
%     encPath = ['data/done/' class '.mat']
end
