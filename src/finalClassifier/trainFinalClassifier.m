function [Xtest, Ytest] = trainFinalClassifier()
% Read class labels from file
load('classes.mat', 'classes');
load('components.mat');
params = load('encoding_params.mat');
pyramidLevels = 3;
params.pyramidLevels = pyramidLevels;
params.classes = classes;

[Xtrain, Ytrain] = createTraining(models, params);
[Xtest, Ytest] = createTest(models, params);
% model = train(double(Ytrain), sparse(double(Xtrain)), '-s 3 -q');
% modelEval = evaluateModel(model, Xtest, Ytest);
% fprintf('Accuracy = %f\n', modelEval(1));
end

function [X,y] = createTraining(models, params)
fid = fopen('data/meta/train.txt');
trainImages = textscan(fid, '%s', 'Delimiter', '\n');
trainImages = trainImages{1};

[X, y] = encodeImageSet(trainImages, models, params);
end

function [X,y] = createTest(models, params)
fid = fopen('data/meta/test.txt');
testImages = textscan(fid, '%s', 'Delimiter', '\n');
testImages = testImages{1};

[X, y] = encodeImageSet(testImages, models, params);
end


function [X,y] = encodeImageSet(imgSet, models, params)

pyramidLevels = params.pyramidLevels;
classes = params.classes;
numImages = length(imgSet);

[numClasses, numComponents] = size(models);
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
        X(i,:) = extractImageFeatureVector(image, models, params);
        y(i) = find(strcmp(classes, class));
        toc
    catch ME
        disp(getReport(ME,'extended'));
    end

end
end