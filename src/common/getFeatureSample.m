function [Xd, Xc] = getFeatureSample(nImages)
%GETFEATURESAMPLE Return sample of descriptors and color values
%   getFeatureSample computes descriptor and color values from a number of
%   images defined by nImages. The descriptor to use is defined by the
%   descriptorType variable and can be either 'sift' or 'surf'. The color
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

%   Add a singleton dimension to be able convert to lab using vlfeat instead of matlab
    poi = uint8(zeros(size(frames, 1), 3)); % Image region whose lab values to compute

    for j = 1:size(frames,1)
        poi(j,:) = I(frames(j, 2), frames(j, 1), :);
    end

%   Now squeeze out the singleton
    color = rgb2lab(poi);
    
    Xd = [Xd; descriptors];
    Xc = [Xc; color];

end

whos
delete(gcp);

Xd = Xd(randperm(size(Xd,1)), :);
Xc = Xc(randperm(size(Xc,1)), :);

Xd = ssrt(Xd);

end

