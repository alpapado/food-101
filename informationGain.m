function [ infoGain ] = informationGain( data, dataLeft, dataRight )
%informationGain Computes the information gain from partitioning data into
%dataLeft and dataRight
%   The information gain is computed, using the 'shannon' formula for
%   the entropy in a vector
type = 'shannon';

entropyLeft = numel(dataLeft) * wentropy(dataLeft, type) / numel(data);
entropyRight = numel(dataRight) * wentropy(dataRight, type) / numel(data);
initialEntropy = wentropy(data, type);
infoGain = initialEntropy - entropyLeft - entropyRight;

end

