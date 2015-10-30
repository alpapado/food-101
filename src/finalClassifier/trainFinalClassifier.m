function trainFinalClassifier()
% Read class labels from file
load('classes.mat', 'classes');
load('components.mat');
params = load('encoding_params.mat');
pyramidLevels = 3;
params.pyramidLevels = pyramidLevels;
params.classes = classes; 

%[X, y] = createTraining(components, params);
%save('train.mat', 'X', 'y');
%clear X y

[X, y] = createTest(components, params);
save('test.mat', 'X', 'y');
clear X y

end

function [X,y] = createTraining(components, params)
fid = fopen('data/meta/train.txt');
trainImages = textscan(fid, '%s', 'Delimiter', '\n');
trainImages = trainImages{1};

[X, y] = encodeImageSet(trainImages, components, params);
end

function [X,y] = createTest(components, params)
fid = fopen('data/meta/test.txt');
testImages = textscan(fid, '%s', 'Delimiter', '\n');
testImages = testImages{1};

[X, y] = encodeImageSet(testImages, components, params);
end


function [X,y] = encodeImageSet(imgSet, components, params)

pyramidLevels = params.pyramidLevels;
classes = params.classes;
numImages = length(imgSet);

[numClasses, numComponents] = size(components);
numCells = sum(4 .^ (0:pyramidLevels-1)); % Num of cells in pyramid grid
d = numClasses * numComponents * numCells; % Dimensionality of feature vec

X = single(zeros(numImages, d));
y = uint8(zeros(numImages, 1));

for i = 1:numImages
    try
        tic
        fprintf('%d/%d ', i, numImages);
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
