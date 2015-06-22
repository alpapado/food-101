function [ prunedLeaves] = pruneLeaves( sortedLeaves )
%pruneLeaves Remove the leaves whose samples consist of more than half of
%the same superpixels as any better scoring leaf.
%   Detailed explanation goes here
numLeaves = length(sortedLeaves);
field1 = 'trData'; field2 = 'cvData'; field3 = 'svm';
prunedLeaves = struct(field1, [], field2, [], field3, []);
toRemove = zeros(numLeaves, 1);

field4 = 'samples'; value4 = [];
leafSamples = struct(field4, value4);
for l = 1:numLeaves
    leafSamples(l).samples = extractfield(sortedLeaves(l).cvData, 'id');
end

for l = 1:numLeaves
%     score = scores(l);
    current = sortedLeaves(l);
%     bestOfTheRest = sortedLeaves(1:l-1);
    % Compare current sample with every sample in the bestOfTheRest list
    % If it consists of more than half of the sample spixels as any leaf in
    % that list, mark it for removal.
    for r = 1:l-1
        if toRemove(r) == 1
            continue;
        end
        if similarity(leafSamples(l).samples, leafSamples(r).samples ) > 0.5
            fprintf('Similar leaves found\n');
            toRemove(l) = 1;
            break;
        end
    end
    
    if toRemove(l) == 0
        prunedLeaves(l) = current;
    end
    
end

end

