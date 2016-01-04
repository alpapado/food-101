function params = calcGlobalParams(modes)
%calcGlobalParams Calculate a gmm and a pca representation of the data
%   Detailed explanation goes here
[~, w] = unix('find data/images -name "*jpg"');
list = strsplit(w, '\n'); % list of image encodings
list(end) = []; % last is empty

ind = randi([1 length(list)], 1000, 1);
allSifts = [];
allLabs = [];

siftGmm = struct('means', [], 'covariances', [], 'priors', []);
labGmm = struct('means', [], 'covariances', [], 'priors', []);
siftPca = struct('avg', [], 'U', [], 'S', []);
labPca = struct('avg', [], 'U', [], 'S', []);

parfor i = 1:length(ind)
    i
    I = imread(num2str(cell2mat(list(ind(i)))));
      
    % Get image dimensions
    [height, width, channels] = size(I);

    % Create grayscale version of input im
    if channels > 1
        Igray = im2single(rgb2gray(I));
        Ilab = rgb2lab(I);
    else
        continue;
    end
    
    % SIFT
    binSize = 8;
    [frames, descriptors] = vl_dsift(Igray, 'size', binSize, 'fast', 'step', 8, 'FloatDescriptors');
    
    numGridPoints = size(frames, 2);
    labs = zeros(numGridPoints, 3);
    
    for j = 1:numGridPoints
        labs(j,:) = Ilab(frames(2, j), frames(1, j), :);
    end
    
    allLabs = [allLabs; labs];  
    allSifts = [allSifts; descriptors'];
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
% allSifts = ssrt(allSifts);

% Step 1
% Compute pca for surfs
fprintf('Computing pca for sifts\n');
tic;
[U, S, avg] = pca(allSifts);
toc;
siftPca.avg = avg;
siftPca.U = U;
siftPca.S = S;

% Compute pca for labs
fprintf('Computing pca for labs\n');
tic;
[U, S, avg] = pca(allLabs);
toc;
labPca.avg = avg;
labPca.U = U;
labPca.S = S;

% Step 2 and 3
allSifts = pcaw(allSifts, siftPca);
allLabs = pcaw(allLabs, labPca);

% Step 4
% Fit gmm to surfs
fprintf('Fitting gmm to sifts\n');
tic;[means, covariances, priors] = vl_gmm(allSifts', modes);toc;
siftGmm.means = means;
siftGmm.covariances = covariances;
siftGmm.priors = priors;
clear allSurfs;

% Fit gmm to labs
fprintf('Fitting gmm to labs\n');
tic;[means, covariances, priors] = vl_gmm(allLabs', modes);toc;
labGmm.means = means;
labGmm.covariances = covariances;
labGmm.priors = priors;
clear allLabs;

params = struct('labGmm', labGmm, 'labPca', labPca, 'siftGmm', siftGmm, 'siftPca', siftPca);

end
