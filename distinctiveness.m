function [ distinct ] = distinctiveness( leaves, cvSet, numClasses )
%distinctiveness Summary of this function goes here
%   Detailed explanation goes here
numLeaves = size(leaves, 2);
distinct = zeros(numLeaves, numClasses);
[classConf, delta] = classConfidence(leaves, cvSet, numClasses);

for c = 1:numClasses
    for l = 1:numLeaves
        distinct(l,c) = sum( delta(l,:) .* classConf(c,:) );
    end 
end

end

