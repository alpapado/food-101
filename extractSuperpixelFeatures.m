function [ features] = extractSuperpixelFeatures( image, imageSuperpixels, superpixelIndex)
%extractSuperpixelFeatures Extracts SURFs and Lab values from superpixel
% tic
% Auxilliary variables
[width, height, channels] = size(image);

% Create grayscale version of input image
if channels > 1
    gray = rgb2gray(image);
else
    gray = image;
end

% Convert input image to L*a*b
lab = vl_xyz2lab(vl_rgb2xyz(image));

% Create grid on which the SURFs will be calculated
gridStep = 4;
gridX = 1:gridStep:width;
gridY = 1:gridStep:height;
[x ,y] = meshgrid(gridX, gridY);
gridLocations = [x(:), y(:)];

% Keep grid points that fall within superpixel area
numGridPoints = size(gridLocations, 1);
indexes = 1:numGridPoints;
superpixelLocation = (imageSuperpixels == superpixelIndex);

for i = 1:numGridPoints
    if superpixelLocation(gridLocations(i,1), gridLocations(i,2)) ~= 1
        % Dont sample at this point
        indexes(i) = 0;
    end
end

indexes(indexes == 0) = [];
spGridLocations = gridLocations(indexes, :);
gridPoints = SURFPoints(spGridLocations);


% Extract all SURFs for the image
[surfs, validPoints] = extractFeatures(gray, gridPoints);

% Get lab values
validPointsLocation = validPoints.Location;
numValidPoints = size(validPoints, 1);
labValues = zeros(numValidPoints, 3);

for i = 1:numValidPoints
    labValues(i, :) = lab(validPointsLocation(i,1), validPointsLocation(i,2), :);
end

% Fisher encoding
modes = 64;
surfsEncoding = ivfEncode(surfs, modes);
labEncoding = ivfEncode(labValues, modes);

% Concatenate the two vectors
features = [surfsEncoding; labEncoding];
% toc
end

