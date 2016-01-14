function [ X ] = getdata( IMAGES )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
[height, width, nImages] = size(IMAGES);
gridStep = 8;
gridX = 1:gridStep:width;
gridY = 1:gridStep:height;
[x, y] = meshgrid(gridX, gridY);
gridLocations = [x(:), y(:)];
X = [];

for i=1:nImages
    gridPoints = SURFPoints(gridLocations, 'Scale', 1.6);    
    [descriptors, ~] = extractFeatures(IMAGES(:,:,i), gridPoints);
    X = [X; descriptors];
end

end

