function params = setParams()

load('classes.mat', 'classes');
params = matfile('params.mat', 'Writable', true);
params.classes = classes;
params.nTrees = 15;
params.treeSamples = 200000;
params.nComponents = 20;
params.nClasses = 101;
params.gridStep = 4;
params.pyramidLevels = 3;
params.datasetPath = 'data/images';
params.descriptorBases = 5000;
params.colorBases = 1024;
params.descriptorLength = 64;
params.modes = 64;
params.encodingLength = 2 * params.modes * params.descriptorLength + 2 * params.modes * 3;
params = load('params.mat');

if ~isfield(params, 'featureGmm') && strcmp(params.encoding, 'fisher')
    encParams = calcGlobalParams(params);
    save('params.mat', '-append', '-struct', 'encParams');
end

save('params.mat', '-struct', 'params');

% Seed generator
rng('shuffle');

disp(params);

end
