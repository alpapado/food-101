function [ distinct, classConf, classDist, delta ] = distinctiveness( leaves, cvSet, numClasses )
%distinctiveness Summary of this function goes here
%   Detailed explanation goes here
numLeaves = size(leaves, 2);
distinct = zeros(numLeaves, numClasses);
[classConf, classDist, delta] = classConfidence(leaves, cvSet, numClasses);

for y = 1:numClasses
    for l = 1:numLeaves
        distinct(l,y) = sum( delta(l,:) .* classConf(y,:) );
    end 
end

end

