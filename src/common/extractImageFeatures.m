function [features, badSegments, goodSegments] = extractImageFeatures(I, L, params, ignoreSmallSegments)
%extractSuperpixelFeatures Extracts SURFs and Lab values for every 
% superpixel in image

if ~exist('ignoreSmallSegments', 'var')
    ignoreSmallSegments = true;
end

% Preallocate space for result
spIndices = unique(L); % Superpixel indices are not always sequential
numSuperpixels = length(spIndices);
features = zeros(numSuperpixels, params.encodingLength);
goodSegments = ones(numSuperpixels, 1);

% Get image dimensions
% Height is first ;( ;( ;(
[height, width, channels] = size(I);

% Create grayscale version of input image
if channels > 1
    Igray = rgb2gray(I);
else
    Igray = I;
end

gridStep = params.gridStep;
modes = params.modes;
badSegments = [];

% Create grid on which the SURFs will be calculated
gridX = 1:gridStep:width;
gridY = 1:gridStep:height;
[x, y] = meshgrid(gridX, gridY);
gridLocations = [x(:), y(:)];

gridPoints = SURFPoints(gridLocations, 'Scale', 1.6);
[descriptors, validPoints] = extractFeatures(Igray, gridPoints);
frames = validPoints.Location;

Xd = ssrt(descriptors);

% -------------------Compute color values--------------------------
poi = uint8(zeros(size(frames, 1), 3)); 
for j = 1:size(frames, 1)          
    poi(j,:) = I(frames(j, 2), frames(j, 1), :);
end
Xcolor = rgb2lab(poi);

% For every superpixel
for i = 1:numSuperpixels       
    % Superpixel index
    s = spIndices(i);
    
    % Compute superpixel bounding box
    bbox = regionprops(L==s, 'BoundingBox');
    xv = [bbox.BoundingBox(1); bbox.BoundingBox(1) + bbox.BoundingBox(3)];
    yv = [bbox.BoundingBox(2); bbox.BoundingBox(2) + bbox.BoundingBox(4)];
    roi = inpolygon(frames(:,1), frames(:,2), xv, yv);
    spPoints = find(roi==1);
    
    if length(spPoints) >= modes

        % Order of calculations:
        % 0) SURFs are transformed using signed square rooting
        % 1) Data is pca whitened
        % 2) PCA whitened data is ifv encoded

        % Step 0
        tempFeatures = Xd(spPoints, :);

        LABs = Xcolor(spPoints,:);

        % Step 1 and 2
        featureEncoding = ifvEncode(pcaw(tempFeatures, params.featurePca), params.featureGmm);
        labEncoding = ifvEncode(pcaw(LABs, params.labPca), params.labGmm);
        features(i, :) = [featureEncoding; labEncoding];

    else
       badSegments = [badSegments; s];
       goodSegments(i) = 0;
%        fid = fopen('error.txt', 'a');
%        fprintf(fid, 'Image %s\n', imname);
%        fprintf(fid,'Superpixel %d has %d points \n', s, sum(sum(L==s)));
%        fprintf(fid,'Superpixel %d has %d valid points \n', s, length(spPoints));
%        fprintf(fid,'Too few valid points for superpixel %d\n', s);
%        fclose(fid);
        continue;
    end
end

if ignoreSmallSegments == true
    features( ~any(features,2), : ) = [];
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

