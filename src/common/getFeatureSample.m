function [Xd, Xc] = getFeatureSample(nImages)
%GETFEATURESAMPLE Return sample of descriptors and color values
%   getFeatureSample computes descriptor and color values from a number of
%   images defined by nImages. The descriptor to use  the 'surf'. The color
%   values are computed in the lab color space.

[~, w] = unix('find data/images -name "*jpg"');
list = strsplit(w, '\n'); % list of image encodings
list(end) = []; % last is empty

ind = randi([1 length(list)], nImages, 1);
Xd = [];
Xc = [];

gridStep = 8;

parfor i = 1:length(ind)
    I = imread(num2str(cell2mat(list(ind(i)))));
      
    % Get image dimensions
    [height, width, channels] = size(I);

    % Create grayscale version of input im
    if channels > 1
        Igray = rgb2gray(I);
    else
        continue;
    end     
    
    gridX = 1:gridStep:width;
    gridY = 1:gridStep:height;
    [x, y] = meshgrid(gridX, gridY);
    gridLocations = [x(:), y(:)];
    gridPoints = SURFPoints(gridLocations, 'Scale', 1.6);
    [descriptors, validPoints] = extractFeatures(Igray, gridPoints);
    frames = validPoints.Location;

    % Image region whose lab values to compute
    poi = uint8(zeros(size(frames, 1), 3)); 

    for j = 1:size(frames,1)
        poi(j,:) = I(frames(j, 2), frames(j, 1), :);
    end

    color = rgb2lab(poi);
    
    Xd = [Xd; descriptors];
    Xc = [Xc; color];

end

delete(gcp);

% Transform SURF to RootSURF
Xd = ssrt(Xd);

end

