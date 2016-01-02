function features = extractImageFeatures(image, segments, params)
%extractSuperpixelFeatures Extracts SURFs and Lab values for every 
% superpixel in image

% Preallocate space for result
spIndices = unique(segments); % Superpixel indices are not always sequential
numSuperpixels = length(spIndices);
features = zeros(numSuperpixels, 2*128*32 + 2*3*32);

% Get image dimensions
% Height is first ;( ;( ;(
[height, width, channels] = size(image);

% Create grayscale version of input image
if channels > 1
    Igray = im2single(rgb2gray(image));
else
    Igray = image;
end

% SIFT
binSize = 8;
[frames, descriptors] = vl_dsift(Igray, 'size', binSize, 'fast', 'step', 8, 'FloatDescriptors');

% Get valid points' locations
validPointsLocation = frames;
numValidPoints = size(frames, 2);

% For every superpixel
for i = 1:numSuperpixels
    s = spIndices(i); % Superpixel index
    % Find spixel points and encode the surfs along with the lab values in
    % these points   
    points = uint32(zeros(numValidPoints, 1)); % Indexes into validPointsLocation matrix
    k = 1;
    for j = 1:numValidPoints
        if segments(validPointsLocation(2, j), validPointsLocation(1, j)) == s
            points(k) = j;
            k = k + 1;
        end
    end
    points(points == 0) = [];

    modes = 32;
    if length(points) >= modes
        
        % Order of calculations:
        % 0) SURFs are transformed using signed square rooting
        % 1) Data is pca whitened
        % 2) PCA whitened data is ifv encoded
        
        % Step 0
        SIFTs = descriptors(:, points);
        
        poi = uint8(zeros(length(points), 3)); % Image region whose lab values to compute
        for j = 1:length(points)
            poi(j,:) = image(validPointsLocation(2, points(j)), validPointsLocation(1, points(j)), :);
        end
        LABs = rgb2lab(poi);
        
        % Step 1 and 2
        siftsEncoding = ifvEncode(pcaw(SIFTs', params.siftPca), params.siftGmm);
        labEncoding = ifvEncode(pcaw(LABs, params.labPca), params.labGmm);
%         whos
        features(i, :) = [siftsEncoding; labEncoding];
    else
%         markerInserter = vision.MarkerInserter('Shape','Circle','BorderColor','black');
%         J = step(markerInserter, label2rgb(segments==s), int32(validPointsLocation(points,:)));
%         imshow(J);
%         pause
       fid = fopen('error.txt', 'a');
%        fprintf(fid, 'Image %s\n', imname);
       fprintf(fid,'Superpixel %d has %d points \n', s, sum(sum(segments==s)));
       fprintf(fid,'Superpixel %d has %d valid points \n', s, length(points));
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

