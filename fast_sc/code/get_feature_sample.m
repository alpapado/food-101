function [ X ] = get_feature_sample(featureType)
[~, w] = unix('find data/images -name "*jpg"');
list = strsplit(w, '\n'); % list of image encodings
list(end) = []; % last is empty

ind = randi([1 length(list)], 1000, 1);
X = [];

gridStep = 8;

parfor i = 1:length(ind)
    i
    I = imread(num2str(cell2mat(list(ind(i)))));
      
    % Get image dimensions
    [height, width, channels] = size(I);

    % Create grayscale version of input im
    if channels > 1
        Igray = rgb2gray(I);
%         Ilab = rgb2lab(I);
        Ilab = vl_xyz2lab(vl_rgb2xyz(I));
    else
        continue;
    end     
    
    if strcmp(featureType, 'sift')
        binSize = 8;
        [frames, descriptors] = vl_dsift(single(Igray), 'size', binSize, 'fast', 'step', gridStep, 'FloatDescriptors');
        frames = transpose(frames);
        descriptors = transpose(descriptors);
        
    elseif strcmp(featureType, 'surf')
        % Create grid on which the SURFs will be calculated
        gridX = 1:gridStep:width;
        gridY = 1:gridStep:height;
        [x, y] = meshgrid(gridX, gridY);
        gridLocations = [x(:), y(:)];

        gridPoints = SURFPoints(gridLocations, 'Scale', 1.6);
        [descriptors, validPoints] = extractFeatures(Igray, gridPoints);
        
    end  

    X = [X; descriptors];

end

delete(gcp);
whos
end

