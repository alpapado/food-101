function [ segments ] = segmentImage( image )
%segmentImage Performs segmentation on an image using the SLIC algorithm
%   image: The image to be segmented
%   segments: The produced segments by the SLIC algorithm

% Calculate region size
regionSize = round(max(size(image)) * 0.3);

% Calculate regularizer
regularizer = 0.01;

% Convert input image to L*a*b
imlab = vl_xyz2lab(vl_rgb2xyz(image));

% Compute the segmentation
segments = vl_slic(single(imlab), regionSize, regularizer) ;

end

