function [ encoding ] = encodeImage(image)
%encodeImage Extracts features from every superpixel of a an image
%   Detailed explanation goes here

% Segment the image into superpixels
segments = segmentImage(imread(image));
numSuperpixels = max(max(segments));

% For every superpixels in the image call extractSuperpixelFeatures
encoding = zeros(numSuperpixels, 8576);

for s = 1:numSuperpixels
    try
        features = extractSuperpixelFeatures(image, segments, s);
        encoding(s, :) = features;
    catch ME
%         msgString = getReport(ME);
%         disp(msgString);
    end
end

% Remove zero lines
encoding( ~any(encoding, 2), : ) = []; 
end

