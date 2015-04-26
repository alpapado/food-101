function [ infoGain ] = informationGain( data, dataLeft, dataRight )
%informationGain Computes the information gain when the input data (class
%labels) is split in two parts: dataLeft and dataRight
%   Detailed explanation goes here
type = 'shannon';
entropyLeft = numel(dataLeft) * wentropy(dataLeft, type) / numel(data);
entropyRight = numel(dataRight) * wentropy(dataRight, type) / numel(data);
initialEntropy = wentropy(data, type);
infoGain = initialEntropy - entropyLeft - entropyRight;

end

