function [ classConf ] = classConfidence( leaves, cvSet, numClasses )
%classConfidence Summary of this function goes here
%   Detailed explanation goes here
% classConf(s, c) : Confidence that sample s belongs to class c

numLeaves = size(leaves, 2);
numSamples = size(cvSet, 2);
classConf = zeros(numSamples, numClasses);

classDist = classDistribution(leaves, numClasses);
delta = computeDeltas(leaves, cvSet);

for c = 1:numClasses
    for s = 1:numSamples
        for l = 1:numLeaves        
            classConf(c,s) = classConf(c,s) + delta(l,s) * classDist(l,c);
        end
    end
    
end

end

