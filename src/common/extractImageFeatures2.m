function [features, badSegments, goodSegments] = extractImageFeatures2(I, L, params, ignoreSmallSegments)
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

% Create grid on which the SURFs will be calculated
gridX = 1:gridStep:width;
gridY = 1:gridStep:height;
[x, y] = meshgrid(gridX, gridY);
gridLocations = [x(:), y(:)];

gridPoints = SURFPoints(gridLocations, 'Scale', 1.6);
[descriptors, validPoints] = extractFeatures(Igray, gridPoints);
frames = validPoints.Location;


badSegments = [];
Xd = transpose(ssrt(descriptors));

if strcmp(params.pooling, 'max')
    S = full(mexLasso(Xd, params.Bd, params.lassoParam));
elseif strcmp(params.pooling, 'mean')
    S = full(mexOMP(Xd, params.Bd, params.ompParam));
end

% -------------------Compute color values--------------------------
poi = uint8(zeros(size(frames, 1), 3)); 
for j = 1:size(frames, 1)          
    poi(j,:) = I(frames(j, 2), frames(j, 1), :);
end
LABs = rgb2lab(poi);

Xcolor = transpose(LABs);

% Compute the sparse codes for the color values of current
% superpixel       
if strcmp(params.pooling, 'max')
    Scolor = full(mexLasso(Xcolor, params.Bc, params.lassoParam));
elseif strcmp(params.pooling, 'mean')
    Scolor = full(mexOMP(Xcolor, params.Bc, params.ompParam));
end

% For every superpixel
for i = 1:numSuperpixels
    
    try
        % Superpixel index
        s = spIndices(i);

        % Compute superpixel bounding box
        bbox = regionprops(L==s, 'BoundingBox');
        xv = [bbox.BoundingBox(1); bbox.BoundingBox(1) + bbox.BoundingBox(3)];
        yv = [bbox.BoundingBox(2); bbox.BoundingBox(2) + bbox.BoundingBox(4)];
        roi = inpolygon(frames(:,1), frames(:,2), xv, yv);
        spPoints = find(roi==1);
        
        % Get sparse codes
        Sc = Scolor(:, spPoints);
        Sd = S(:, spPoints);
                   
        % Max pool and concatenate
        d = params.descriptorBases;

        if strcmp(params.pooling, 'max')
            yd = max(Sd, [], 2);
            yc = max(Sc, [], 2);
        elseif strcmp(params.pooling, 'mean')
            yd = mean(Sd, 2);
            yc = mean(Sc, 2);
        end

        % L2 normalize
        if norm(yc) ~= 0
            yc = yc ./ norm(yc);
        end
        
        if norm(yd) ~= 0
            yd = yd ./ norm(yd);
        end
        
        features(i, 1:d) = yd;
        features(i, d+1:end) = yc;
        
    catch ME        
       disp(getReport(ME,'extended'));
    end
   
end

if ignoreSmallSegments == true
    features( ~any(features,2), : ) = [];
end
    
end

