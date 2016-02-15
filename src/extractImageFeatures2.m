function [features, badSegments] = extractImageFeatures3(I, L, params, ignoreSmallSegments)
%extractSuperpixelFeatures Extracts SURFs and Lab values for every 
% superpixel in image

if ~exist('ignoreSmallSegments', 'var')
    ignoreSmallSegments = true;
end

% Preallocate space for result
spIndices = unique(L); % Superpixel indices are not always sequential
numSuperpixels = length(spIndices);
features = zeros(numSuperpixels, params.encodingLength);
badSegments = [];

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

% SIFT
if strcmp(params.descriptorType, 'sift')
    binSize = 8;
    [frames, descriptors] = vl_dsift(single(Igray), 'size', binSize, 'fast', 'step', gridStep, 'FloatDescriptors');

    frames = transpose(frames);
    descriptors = transpose(descriptors);  
    
elseif strcmp(params.descriptorType, 'surf')
    % Create grid on which the SURFs will be calculated
    gridX = 1:gridStep:width;
    gridY = 1:gridStep:height;
    [x, y] = meshgrid(gridX, gridY);
    gridLocations = [x(:), y(:)];

    gridPoints = SURFPoints(gridLocations, 'Scale', 1.6);
    [descriptors, validPoints] = extractFeatures(Igray, gridPoints);

    frames = validPoints.Location;
    
end

% Compute the sparse codes for the descriptors
Xd = descriptors';

if strcmp(params.pooling, 'max')
    S = full(mexLasso(Xd, params.Bd, params.lassoParam));
elseif strcmp(params.pooling, 'mean')
    S = full(mexOMP(Xd, params.Bd, params.ompParam));
end

% DEBUGGING
% Xhat = params.Bd * S;
% X = Xd;
% for i = 1:size(X, 2)
%    plot(1:size(X,1), X(:,i), 'r', 1:size(X,1), Xhat(:,i), 'b');
%    legend('X', 'Xhat');
%    pause;
% end

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

        % --------------------Find spixel points---------------------------
        linInd = sub2ind(size(L), frames(:,2), frames(:,1));
        spPoints = find(L(linInd) == s); % Linear indices to L

        if isempty(spPoints) || length(spPoints) == 1
            badSegments = [badSegments; s];
            continue;
        end
        
        Sc = Scolor(:, spPoints);        
        %------------------------------------------------------------------    
        % Extract descriptor sparse codes for current superpixel
        Sd = S(:, spPoints);
                   
        % Max pool and concatenate
        d = params.descriptorBases;
                     
        % Pool features
        if strcmp(params.pooling, 'max')
            yd = max(Sd, [], 2);
            yc = max(Sc, [], 2);
        elseif strcmp(params.pooling, 'mean')
            yd = mean(Sd, 2);
            yc = mean(Sc, 2);
        end
  
        % DEBUGGING        
%         subplot(2,1,1);    
%         scatter(1:length(yd), Sd(:,1)); 
%         axis([1 length(yd) 0 1]) 
%         title('Unpooled');
%         hold on
%         for j = 2:size(Sd, 2)
%             scatter(1:length(yd), Sd(:,j));
%         end
%         hold off
%         subplot(2,1,2);
%         scatter(1:length(yd), yd);
%         axis([1 length(yd) 0 1]) 
%         title(sprintf('Pool, sparsity=%f', sum(yd~=0)/length(yd)));
        
%         subplot(3,1,3); 
%         scatter(1:length(yd), yd2);axis([1 length(yd) 0 1]) 
%         title(sprintf('Mean pool, sparsity=%f', sum(yd2~=0)/length(yd2)));      
%         pause

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
%         Iseg = vl_imseg(im2double(I), L);
%         markerInserter = vision.MarkerInserter('Shape','Circle','BorderColor','black');
%         J = step(markerInserter, I, int32(frames(spPoints,:)));
%         subplot(1,2,1); subimage(J);
%         subplot(1,2,2); subimage(Iseg);
%         pause
    end
   
end

if ignoreSmallSegments == true
    features( ~any(features,2), : ) = [];
end
    
end

