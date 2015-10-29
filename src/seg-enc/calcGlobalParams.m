function params = calcGlobalParams()
%calcGlobalParams Calculate a gmm and a pca representation of the data
%   Detailed explanation goes here
[~, w] = unix('find data/images -name "*jpg"');
list = strsplit(w, '\n'); % list of image encodings
list(end) = []; % last is empty

ind = randi([1 length(list)], 1000, 1);
allSurfs = [];
allLabs = [];

surfGmm = struct('means', [], 'covariances', [], 'priors', []);
labGmm = struct('means', [], 'covariances', [], 'priors', []);
surfPca = struct('avg', [], 'U', [], 'S', []);
labPca = struct('avg', [], 'U', [], 'S', []);

parfor i = 1:length(ind)
    i
    im = imread(num2str(cell2mat(list(ind(i)))));
      
    % Get image dimensions
    [height, width, channels] = size(im);

    % Create grayscale version of input im
    if channels > 1
        gray = rgb2gray(im);
        imlab = rgb2lab(im);
    else
        continue;
    end
    
    % Create grid on which the SURFs will be calculated
    gridStep = 5;
    gridX = 1:gridStep:width;
    gridY = 1:gridStep:height;
    [x, y] = meshgrid(gridX, gridY);
    gridLocations = [x(:), y(:)];
    
    numGridPoints = size(gridLocations, 1);
    labs = zeros(numGridPoints, 3);
    
    for j = 1:numGridPoints
        labs(j,:) = imlab(gridLocations(j,2), gridLocations(j,1), :);
    end
    
    allLabs = [allLabs; labs];
    
    % Extract all SURFs for the image
    gridPoints = SURFPoints(gridLocations, 'Scale', 1.6);
    surfs = extractFeatures(gray, gridPoints);
    allSurfs = [allSurfs; surfs];
end

delete(gcp);
size(allSurfs)
size(allLabs)
modes = 64;

% Order of calculations:
% 0) SURFs are transformed using signed square rooting
% 1) PCA is computed 
% 2) Data is projected to pca space
% 3) Projected data is whitened using pca whitening
% 4) GMMs are computed on data from 3)

% Step 0
allSurfs = ssrt(allSurfs);

% Step 1
% Compute pca for surfs
fprintf('Computing pca for surfs\n');
tic;
[U, S, avg] = pca(allSurfs);
toc;
surfPca.avg = avg;
surfPca.U = U;
surfPca.S = S;

% Compute pca for labs
fprintf('Computing pca for labs\n');
tic;
[U, S, avg] = pca(allLabs);
toc;
labPca.avg = avg;
labPca.U = U;
labPca.S = S;

% Step 2 and 3
allSurfs = pcaw(allSurfs, surfPca);
allLabs = pcaw(allLabs, labPca);

% Step 4
% Fit gmm to surfs
fprintf('Fitting gmm to surfs\n');
tic;[means, covariances, priors] = vl_gmm(allSurfs', modes);toc;
surfGmm.means = means;
surfGmm.covariances = covariances;
surfGmm.priors = priors;
clear allSurfs;

% Fit gmm to labs
fprintf('Fitting gmm to labs\n');
tic;[means, covariances, priors] = vl_gmm(allLabs', modes);toc;
labGmm.means = means;
labGmm.covariances = covariances;
labGmm.priors = priors;
clear allLabs;

params = struct('labGmm', labGmm, 'labPca', labPca, 'surfGmm', surfGmm, 'surfPca', surfPca);

end


function [U, S, avg] = pca(X)
%PCA Run principal component analysis on the dataset X
%   [U, S] = pca(X) computes eigenvectors of the covariance matrix of X
%   Returns the eigenvectors U, the eigenvalues (on diagonal) in S
%

% Useful values
m = size(X, 1);

% Center X
avg = mean(X, 1);
X = X - repmat(avg, m, 1);


Sigma = 1 / m * (X' * X);
[U, S, ~] = svd(Sigma);

end
