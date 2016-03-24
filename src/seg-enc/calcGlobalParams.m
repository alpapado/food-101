function params = calcGlobalParams(params)
%calcGlobalParams Calculate a gmm and a pca representation of the data
%   Detailed explanation goes here
[~, w] = unix('find data/images -name "*jpg"');
list = strsplit(w, '\n'); % list of image encodings
list(end) = []; % last is empty

ind = randi([1 length(list)], 1000, 1);
allFeatures = [];
allLabs = [];

featureGmm = struct('means', [], 'covariances', [], 'priors', []);
labGmm = struct('means', [], 'covariances', [], 'priors', []);
featurePca = struct('avg', [], 'U', [], 'S', []);
labPca = struct('avg', [], 'U', [], 'S', []);
% gridStep = params.gridStep;
gridStep = 8;

parfor i = 1:length(ind)
    i
    I = imread(num2str(cell2mat(list(ind(i)))));
      
    % Get image dimensions
    [height, width, channels] = size(I);

    % Create grayscale version of input im
    if channels > 1
        Igray = rgb2gray(I);
%         Ilab = rgb2lab(I);
        Ilab = vl_xyz2lab(vl_rgb2xyz(I));
    else
        continue;
    end     
    
    % SIFT
    if strcmp(params.descriptorType, 'sift')
        binSize = 8;
        [frames, descriptors] = vl_dsift(single(Igray), 'size', binSize, 'fast', 'step', gridStep, 'FloatDescriptors');
        frames = transpose(frames);
        descriptors = transpose(descriptors);
        numGridPoints = size(frames, 1);
        
    elseif strcmp(params.descriptorType, 'surf')
        % Create grid on which the SURFs will be calculated
        gridX = 1:gridStep:width;
        gridY = 1:gridStep:height;
        [x, y] = meshgrid(gridX, gridY);
        gridLocations = [x(:), y(:)];

        gridPoints = SURFPoints(gridLocations, 'Scale', 1.6);
        [descriptors, validPoints] = extractFeatures(Igray, gridPoints);

        % Get valid points' locations
        frames = validPoints.Location;
        numGridPoints = size(validPoints, 1);
        
    end

    labs = zeros(numGridPoints, 3);

    for j = 1:numGridPoints
        labs(j,:) = Ilab(frames(j,2), frames(j,1), :);
    end
    allLabs = [allLabs; labs];  
    allFeatures = [allFeatures; descriptors];

end

delete(gcp);
whos

% Order of calculations:
% 0) SURFs are transformed using signed square rooting
% 1) PCA is computed 
% 2) Data is projected to pca space
% 3) Projected data is whitened using pca whitening
% 4) GMMs are computed on data from 3)

% Step 0
allFeatures = ssrt(allFeatures);
modes = params.modes;

% Step 1
% Compute pca for surfs
fprintf('Computing pca for features\n');
tic;
[U, S, avg] = pca(allFeatures);
toc;
featurePca.avg = avg;
featurePca.U = U;
featurePca.S = S;

% Compute pca for labs
fprintf('Computing pca for labs\n');
tic;
[U, S, avg] = pca(allLabs);
toc;
labPca.avg = avg;
labPca.U = U;
labPca.S = S;

% Step 2 and 3
allFeatures = pcaw(allFeatures, featurePca);
allLabs = pcaw(allLabs, labPca);

% Step 4
% Fit gmm to surfs
fprintf('Fitting gmm to features\n');
tic;[means, covariances, priors] = vl_gmm(allFeatures', modes);toc;
featureGmm.means = means;
featureGmm.covariances = covariances;
featureGmm.priors = priors;
clear allSurfs;

% Fit gmm to labs
fprintf('Fitting gmm to labs\n');
tic;[means, covariances, priors] = vl_gmm(allLabs', modes);toc;
labGmm.means = means;
labGmm.covariances = covariances;
labGmm.priors = priors;
clear allLabs;

params = struct('labGmm', labGmm, 'labPca', labPca, 'featureGmm', featureGmm, 'featurePca', featurePca);

end
