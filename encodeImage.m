function [ encoding, segments, validSegments ] = encodeImage(imagePath)
%encodeImage Extracts features from every superpixel of a an image
%   Detailed explanation goes here

% Segment the image into superpixels
segments = segmentImage(imread(imagePath));

% Fucking sp indexing starts from fucking zero for some fucking reason
numSuperpixels = max(max(segments)) + 1; 

% For every superpixels in the image call extractSuperpixelFeatures
encoding = zeros(numSuperpixels, 8576);

validSegments = ones(numSuperpixels, 1);

for s = 1:numSuperpixels
    try
        features = extractSuperpixelFeatures(imagePath, segments, s);
        encoding(s, :) = features;
    catch ME
        validSegments(s) = 0;
%         msgString = getReport(ME);
%         disp(msgString);
    end
end

% Remove zero lines
% encoding( ~any(encoding, 2), : ) = []; 
end

