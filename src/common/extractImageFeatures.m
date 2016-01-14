function features = extractImageFeatures(image, segments, params)
%extractSuperpixelFeatures Extracts SURFs and Lab values for every 
% superpixel in image

% Preallocate space for result
spIndices = unique(segments); % Superpixel indices are not always sequential
numSuperpixels = length(spIndices);
features = zeros(numSuperpixels, params.encodingLength);

% Get image dimensions
% Height is first ;( ;( ;(
[height, width, channels] = size(image);

% Create grayscale version of input image
if channels > 1
    Igray = rgb2gray(image);
else
    Igray = image;
end

gridStep = params.gridStep;
modes = params.modes;

% SIFT
if strcmp(params.featureType, 'sift')
    binSize = 8;
    [frames, descriptors] = vl_dsift(single(Igray), 'size', binSize, 'fast', 'step', gridStep, 'FloatDescriptors');

    frames = transpose(frames);
    descriptors = transpose(descriptors);
    
elseif strcmp(params.featureType, 'surf')
    % Create grid on which the SURFs will be calculated
    gridX = 1:gridStep:width;
    gridY = 1:gridStep:height;
    [x, y] = meshgrid(gridX, gridY);
    gridLocations = [x(:), y(:)];

    gridPoints = SURFPoints(gridLocations, 'Scale', 1.6);
    [descriptors, validPoints] = extractFeatures(Igray, gridPoints);

    frames = validPoints.Location;
    
end

% whos

nFrames = size(frames, 1);

% For every superpixel
for i = 1:numSuperpixels
    s = spIndices(i); % Superpixel index
    % Find spixel points and encode the surfs along with the lab values in
    % these points
    spPoints = uint32(zeros(nFrames, 1)); % Indexes into validPointsLocation matrix
    k = 1;

    for j = 1:nFrames
        if segments(frames(j,2), frames(j,1)) == s
            spPoints(k) = j;
            k = k + 1;
        end
    end
    spPoints(spPoints == 0) = [];

    if length(spPoints) >= modes

        % Order of calculations:
        % 0) SURFs are transformed using signed square rooting
        % 1) Data is pca whitened
        % 2) PCA whitened data is ifv encoded

        % Step 0
        tempFeatures = descriptors(spPoints, :);

        % original code
%         poi = uint8(zeros(length(spPoints), 3)); 

%       Add a singleton dimension to be able convert to lab using vlfeat instead of matlab
        poi = uint8(zeros(length(spPoints), 1, 3)); % Image region whose lab values to compute
        
        for j = 1:length(spPoints)
            poi(j,1,:) = image(frames(spPoints(j), 2), frames(spPoints(j), 1), :);
            
            % original code
%             poi(j,:) = image(frames(spPoints(j), 2), frames(spPoints(j), 1), :);
        end
%         LABs = rgb2lab(poi);

%       Now squeeze out the singleton
        LABs = squeeze(vl_xyz2lab(vl_rgb2xyz(poi)));

        % Step 1 and 2
        featureEncoding = ifvEncode(pcaw(tempFeatures, params.featurePca), params.featureGmm);
        labEncoding = ifvEncode(pcaw(LABs, params.labPca), params.labGmm);
        features(i, :) = [featureEncoding; labEncoding];

    else
%         markerInserter = vision.MarkerInserter('Shape','Circle','BorderColor','black');
%         J = step(markerInserter, label2rgb(segments==s), int32(frames(spPoints,:)));
%         imshow(J);
%         pause
       fid = fopen('error.txt', 'a');
%        fprintf(fid, 'Image %s\n', imname);
       fprintf(fid,'Superpixel %d has %d points \n', s, sum(sum(segments==s)));
       fprintf(fid,'Superpixel %d has %d valid points \n', s, length(spPoints));
       fprintf(fid,'Too few valid points for superpixel %d\n', s);
       fclose(fid);
        continue;
    end
end
    
end

function encoding = ifvEncode(data, gmm)
%ivfEncode Performs Improved Fisher Vector encoding on the given data

means = gmm.means;
covariances = gmm.covariances;
priors = gmm.priors;

% Perform the fisher encoding
% Spcifying the improved option, is equivalent to to specifying the
% normalized and square root options.
encoding = vl_fisher(data', means, covariances, priors, 'Improved', 'Fast');

end

