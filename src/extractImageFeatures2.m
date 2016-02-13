function [features, badSegments] = extractImageFeatures2(I, L, params, ignoreSmallSegments)
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
ompParam = params.ompParam;
% S = full(mexOMP(Xd, params.Bd, ompParam));

ompParam.pos = 1;
ompParam.lambda = 0.15;
S = full(mexLasso(Xd, params.Bd, ompParam));

% Xhat = params.Bd * S;
% X = Xd;
% for i = 1:size(X, 2)
%    plot(1:size(X,1), X(:,i), 'r', 1:size(X,1), Xhat(:,i), 'b');
%    title(sprintf('%d non zero activations', ompParam.L));
%    legend('X', 'Xhat');
%    pause;
% end

nFrames = size(frames, 1);

% For every superpixel
for i = 1:numSuperpixels
    
    try
        % Superpixel index
        s = spIndices(i);

        % Find spixel points
        spPoints = uint32(zeros(nFrames, 1));
        k = 1;

        for j = 1:nFrames
            if L(frames(j,2), frames(j,1)) == s
                spPoints(k) = j;
                k = k + 1;
            end
        end
        spPoints(spPoints == 0) = [];

        if isempty(spPoints) || length(spPoints) == 1
            badSegments = [badSegments; s];
            continue;
        end
        
        % -------------------Compute color values--------------------------
        poi = uint8(zeros(length(spPoints), 3)); 
        
        for j = 1:length(spPoints)           
            poi(j,:) = I(frames(spPoints(j), 2), frames(spPoints(j), 1), :);
        end
        LABs = rgb2lab(poi);

        Xc = transpose(LABs);
        
        %------------------------------------------------------------------
        
        % Compute the sparse codes for the color values of current
        % superpixel
        ompParam.L = 3;
%         Sc = full(mexOMP(Xc, params.Bc, ompParam));
        Sc = full(mexLasso(Xc, params.Bc, ompParam));

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
               
%         yd = [max(Sd, [], 2); max(Sc, [], 2)];
%         yd2 = [mean(Sd, 2); mean(Sc, 2)];
%         
%         subplot(3,1,1);    
%         scatter(1:length(yd), [Sd(:,1); Sc(:,1)]); axis([1 length(yd) 0 1]) 
%         title('Unpooled');
%         hold on
%         for j = 2:size(Sd, 2)
%             scatter(1:length(yd), [Sd(:,j); Sc(:,j)]);
%         end
%         hold off
%         subplot(3,1,2);
%         scatter(1:length(yd), yd);axis([1 length(yd) 0 1]) 
%         title(sprintf('Max pool, sparsity=%f', sum(yd~=0)/length(yd)));
%         
%         subplot(3,1,3); 
%         scatter(1:length(yd), yd2);axis([1 length(yd) 0 1]) 
%         title(sprintf('Mean pool, sparsity=%f', sum(yd2~=0)/length(yd2)));
%         
%         pause
              
         
        % PROBLEM Sc sometimes is 0 and produces NaN
        if ~any(yc) && sum(any(Xc))
%             Xc
%             whos Xc
%             whos Sc
%             subplot(2,1,1); 
%             plot(Xc);
%             subplot(2,1,2); plot(Sc);
%             pause
            msgID = 'myComponent:inputError';
            msgtext = 'All zeros';

            ME = MException(msgID,msgtext);
            throw(ME);
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

