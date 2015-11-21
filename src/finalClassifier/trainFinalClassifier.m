function trainFinalClassifier()
% Read class labels from file
load('classes.mat', 'classes');
load('components.mat');
params = load('encoding_params.mat');
pyramidLevels = 3;
params.pyramidLevels = pyramidLevels;
params.classes = classes; 

[X, y] = encodeImageSet('train', components, params);
save('train.mat', 'X', 'y');
clear X y

[X, y] = encodeImageSet('test', components, params);
save('test.mat', 'X', 'y');
clear X y

end

function [X, y] = encodeImageSet(type, components, params)

if strcmp(type,'train')
  fid = fopen('data/meta/train.txt');
elseif strcmp(type,'test');
  fid = fopen('data/meta/test.txt');
end

images = textscan(fid, '%s', 'Delimiter', '\n');
imgSet = images{1};

pyramidLevels = params.pyramidLevels;
classes = params.classes;
nImages = length(imgSet);

[nClasses, nComponents] = size(components);
numCells = sum(4 .^ (0:pyramidLevels-1)); % Num of cells in pyramid grid
d = nClasses * nComponents * numCells; % Dimensionality of feature vec

X = single(zeros(nImages, d));
y = uint8(zeros(nImages, 1));

for i = 1:nImages
    try
        tic
        fprintf('%d/%d ', i, nImages);
        str = num2str(cell2mat(imgSet(i)));
        split = strsplit(str, '/');
        class = num2str(cell2mat(split(1)));
        imgPath = ['data/images/' str '.jpg'];
        image = imread(imgPath);
        X(i,:) = extractImageFeatureVector(image, components, params);
        y(i) = find(strcmp(classes, class));
        toc
    catch ME
        disp(getReport(ME,'extended'));
    end

end

end
