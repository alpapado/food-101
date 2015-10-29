load('classes.mat');
load('components.mat');
load('predict_pca.mat');
load('model.mat');
params = load('encoding_params.mat');

param.components = models;
params.model = model;
params.pyramidLevels = 3;
params.classes = classes;
params.pcaU = U_reduce;
params.pcaAvg = avg;

I = imread(num2str(cell2mat(imgSet(50).ImageLocation(847))));
label = imagePredict(image, params);
