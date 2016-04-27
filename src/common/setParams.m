function params = setParams()

load('classes.mat', 'classes');
params = matfile('params.mat', 'Writable', true);
params.classes = classes;
params.nTrees = 15;
params.treeSamples = 200000;
params.nComponents = 20;
params.nClasses = 101;
params.descriptorType = 'surf';
params.gridStep = 4;
params.pyramidLevels = 3;
params.datasetPath = 'data/images';
params.descriptorBases = 5000;
params.colorBases = 1024;
params.pooling = 'max';
params.encoding = 'fisher';

if strcmp(params.descriptorType, 'sift')
    params.descriptorLength = 128;
    params.modes = 32;
elseif strcmp(params.descriptorType, 'surf')
    params.descriptorLength = 64;
    params.modes = 64;
end

if strcmp(params.encoding, 'sparse')
    params.encodingLength = params.descriptorBases + params.colorBases;
else
    params.encodingLength = 2 * params.modes * params.descriptorLength + 2 * params.modes * 3;
end

params = load('params.mat');

if ~isfield(params, 'featureGmm') && strcmp(params.encoding, 'fisher')
    encParams = calcGlobalParams(params);
    save('params.mat', '-append', '-struct', 'encParams');
end

params.ompParam.eps = 0.01;
params.ompParam.L = 10;
params.ompParam.numThreads = -1;

params.lassoParam.pos = 1;
params.lassoParam.lambda = 0.15;
params.lassoParam.numThreads = -1;
params.lassoParam.L = 20;
save('params.mat', '-struct', 'params');

% Generate random seed
rng('shuffle');

% Compute bases
if ~isfield(params, 'Bd') || ~isfield(params, 'Bc') && strcmp(params.encoding, 'sparse')
    [Xd, Xc] = getFeatureSample(500);
    [Bd, Bc] = computeBases(Xd, Xc, params.descriptorBases, params.colorBases);
    params.Bd = Bd;
    params.Bc = Bc;
    save('params.mat', '-struct', 'params');
end

disp(params);

end
