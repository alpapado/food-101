function [features] = extractSuperpixelFeatures( imageName, imageSuperpixels, superpixelIndex)
%extractSuperpixelFeatures Extracts SURFs and Lab values from superpixel
% tic
% Read image in order to compute lab values later
image = imread(imageName);

% Auxilliary variables
[width, height, channels] = size(image);

% Create grayscale version of input image
if channels > 1
    gray = rgb2gray(image);
else
    gray = image;
end

% Create grid on which the SURFs will be calculated
gridStep = 8;
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
% Convert to lab only the points of interest => computationally smarter
validPointsLocation = validPoints.Location; % Get valid points' locations
numValidPoints = size(validPoints, 1);
poi = uint8(zeros(numValidPoints, 3)); % Initialize points of interest

for i = 1:numValidPoints
    poi(i,:) = image(validPointsLocation(i,1), validPointsLocation(i,2), :);
end

% R2015a only compatible
labValues = rgb2lab(poi);

% fprintf('Error = %f\n', sum(sum(labValues - labValues2)));

% Fisher encoding
modes = 64;
surfsEncoding = ivfEncode(surfs, modes);
labEncoding = ivfEncode(labValues, modes);

% Concatenate the two vectors
features = [surfsEncoding; labEncoding];
% toc
end

