edfunction [features, validSegments] = extractImageFeatures(image, segments)
%extractSuperpixelFeatures Extracts SURFs and Lab values for every 
% superpixel in image

% Preallocate space for result
numSuperpixels = max(max(segments));
features = zeros(numSuperpixels, 8576);
validSegments = ones(numSuperpixels, 1);

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

% Extract all SURFs for the image
gridPoints = SURFPoints(gridLocations);
[allSurfs, validPoints] = extractFeatures(gray, gridPoints);

% Get valid points' locations
validPointsLocation = validPoints.Location; 
numValidPoints = size(validPoints, 1);

% For every superpixel
for s = 1:max(max(segments))
    
    % Find its points and encode the surfs along with the lab values in
    % these points
    points = uint32(zeros(numValidPoints, 1));
    k = 1;
    for j = 1:numValidPoints
        if segments(validPointsLocation(j, 1), validPointsLocation(j, 2)) == s
            points(k) = j;
            k = k + 1;
        end
    end
    points(points == 0) = [];
    
    modes = 64;
    if length(points) > modes
        surfs = allSurfs(points, :);

        poi = uint8(zeros(length(points), 3));
        for j = 1:length(points)
            poi(j,:) = image(validPointsLocation(points(j), 1), validPointsLocation(points(j), 2), :);
        end
        labValues = rgb2lab(poi);

%         fprintf('Superpixel %d has %d valid points \n', s, length(points));
      
        surfsEncoding = ivfEncode(surfs, modes);
        labEncoding = ivfEncode(labValues, modes);
        features(s, :) = [surfsEncoding; labEncoding];
    else
%         fprintf('Too few valid points for superpixel %d\n', s);
        validSegments(s) = 0;
        continue;
    end
end

end

