function [ classConf, classDist, delta ] = classConfidence( leaves, cvSet, numClasses )
%classConfidence Summary of this function goes here
%   Detailed explanation goes here
% classConf(s, c) : Confidence that sample s belongs to class y

% numLeaves = size(leaves, 2);
numSamples = size(cvSet, 2);
classConf = zeros(numClasses, numSamples);

% CHANGE THIS OR DIE VIOLENTLY
numTrees = 1;
% ----------------------------

classDist = classDistribution(leaves, numClasses);
delta = computeDeltas(leaves, cvSet);

for y = 1:numClasses
    for s = 1:numSamples
        classConf(y, s) = sum( delta(:,s) .* classDist(y,:)' );
    end
end

classConf = classConf ./ numTrees;

end

