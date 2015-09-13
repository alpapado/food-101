function features = extractImageFeatures(image, segments, imname)
%extractSuperpixelFeatures Extracts SURFs and Lab values for every 
% superpixel in image

% Preallocate space for result
spIndices = unique(segments); % Superpixel indices are not always sequential
numSuperpixels = length(spIndices);
features = zeros(numSuperpixels, 8576);

% Get image dimensions
% Height is first ;( ;( ;(
[height, width, channels] = size(image);

% Create grayscale version of input image
if channels > 1
    gray = rgb2gray(image);
else
    gray = image;
end

% Create grid on which the SURFs will be calculated
gridStep = 5;
gridX = 1:gridStep:width;
gridY = 1:gridStep:height;
[x ,y] = meshgrid(gridX, gridY);
gridLocations = [x(:), y(:)];

% Extract all SURFs for the image
gridPoints = SURFPoints(gridLocations, 'Scale', 1.6);
[allSurfs, validPoints] = extractFeatures(gray, gridPoints);

% Get valid points' locations
validPointsLocation = validPoints.Location;
numValidPoints = size(validPoints, 1);

% For every superpixel
for i = 1:numSuperpixels
    s = spIndices(i); % Superpixel index
    % Find spixel points and encode the surfs along with the lab values in
    % these points   
    points = uint32(zeros(numValidPoints, 1)); % Indexes into validPointsLocation matrix
    k = 1;
    for j = 1:numValidPoints
        if segments(validPointsLocation(j, 2), validPointsLocation(j, 1)) == s
            points(k) = j;
            k = k + 1;
        end
    end
    points(points == 0) = [];

    modes = 64;
    if length(points) >= modes
        surfs = allSurfs(points, :); 

        poi = uint8(zeros(length(points), 3)); % Image region whose lab values to compute
        for j = 1:length(points)
            poi(j,:) = image(validPointsLocation(points(j), 2), validPointsLocation(points(j), 1), :);
        end
        labValues = rgb2lab(poi);
        surfsEncoding = ivfEncode(surfs, modes);
        labEncoding = ivfEncode(labValues, modes);
        % Apply pca whitening - ok but when?
        features(i, :) = [surfsEncoding; labEncoding];
    else
%         markerInserter = vision.MarkerInserter('Shape','Circle','BorderColor','black');
%         J = step(markerInserter, label2rgb(segments==s), int32(validPointsLocation(points,:)));
%         imshow(J);
%         pause
%        fid = fopen('error.txt', 'a');
%        fprintf(fid, 'Image %s\n', imname);
%        fprintf(fid,'Superpixel %d has %d points \n', s, sum(sum(segments==s)));
%        fprintf(fid,'Superpixel %d has %d valid points \n', s, length(points));
%        fprintf(fid,'Too few valid points for superpixel %d\n', s);
%        fclose(fid);
        continue;
    end
end

end


function Xw = pcaw(X)
%pcaw Performs pca whitening on the input data X
%   PCA whitening is a preprocessing techique that causes the different
%   components in the input data X, to become uncorrelated and to have unit
%   variance.

% Perform pca - uncorrelate the features
% coeff: Principal component directions
% score: X transformed in the principal component space
% latent: Diagonal values of the covariance matrix of score.
% (non diagonal values of said matrix are zero)

[~, score, latent] = pca(X, 'Centered', true);

% Whiten the data - make each feature have unit variance
Xw = score ./ transpose(repmat(sqrt(latent), [1 size(X, 1)])); % Whitening

end

