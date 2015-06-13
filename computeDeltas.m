function [ delta ] = computeDeltas( leaves, cvSet )
%computeDeltas Summary of this function goes here
%   Detailed explanation goes here
numLeaves = size(leaves, 2);
numSamples = size(cvSet, 2);
delta = zeros(numLeaves, numSamples);

for l = 1:numLeaves
    if isempty(leaves(l).cvData)
        continue
    end
    
    sampleIds = leaves(l).cvData.id;
    
    for s = 1:numSamples
        if any(sampleIds == s)
            delta(l, s) = 1;
        end
    end
end


end

