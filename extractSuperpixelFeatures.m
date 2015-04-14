function [ features, validPoints, labValues ] = extractSuperpixelFeatures( image, imageSuperpixels, superpixelIndex)
%extractSuperpixelFeatures Extracts SURFs and Lab values from superpixel

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

% TODO Keep grid points that fall within superpixel area
numGridPoints = size(gridLocations, 1);
indexes = 1:numGridPoints;
superpixelLocation = (imageSuperpixels == superpixelIndex);
tic
for i = 1:numGridPoints
    if superpixelLocation(gridLocations(i,1), gridLocations(i,2)) ~= 1
        % Dont keep the feature
        indexes(i) = 0;
    end
end
toc

indexes(indexes == 0) = [];
spGridLocations = gridLocations(indexes, :);

gridPoints = SURFPoints(spGridLocations);

% Extract all SURFs for the image
[allSurfs, allValidPoints] = extractFeatures(gray, gridPoints);

% Keep those SURFs that fall within the region of the superpixel
% numPoints = size(allValidPoints, 1);
% superpixelLocation = (imageSuperpixels == superpixelIndex);
% indexes = 1:numPoints;
% allLocations = allValidPoints.Location;
% 
% tic
% for i = 1:numPoints
%     if superpixelLocation(allLocations(i,1), allLocations(i,2)) ~= 1
%         % Dont keep the feature
%         indexes(i) = 0;
%     end
% end
% toc
% 
% indexes(indexes == 0) = [];
% surfs = allSurfs(indexes, :);
% validPoints = allValidPoints(indexes);

surfs = allSurfs;
validPoints = allValidPoints;

% Get lab values
validPointsLocation = validPoints.Location;
numValidPoints = size(validPointsLocation, 1);
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


end

