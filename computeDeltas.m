function [ delta ] = computeDeltas(leaves, numTrees)
%computeDeltas Calculates the deltas for all combinations of samples and
%leaves
%   The deltas are a simple auxilliary variable that show whether or not a
%   particular sample reaches a particular leaf in the forest. i.e
%   delta(l,s) is defined as follows:
%                { 1, if the sample s has reached the leaf l
%   delta(l,s) = {
%                { 0, otherwise

fprintf('Computing deltas\n');

numLeaves = length(leaves);
numSamples = length(extractfield(cell2mat(extractfield(leaves, 'cvData')), 'validationIndex')) / numTrees;
delta = zeros(numLeaves, numSamples);

for l = 1:numLeaves
    fprintf('Leaf %d/%d\n', l, numLeaves);
    
    sampleIds = extractfield(leaves(l).cvData, 'validationIndex');
    
    parfor s = 1:numSamples
        if any(sampleIds == s)
            delta(l, s) = 1;
        end
    end
end

% for s = 1:numSamples
%     for l = 1:numLeaves
%         sampleIds = extractfield(leaves(l).cvData, 'validationIndex');
%         
%         if any(sampleIds == s)
%             delta(l, s) = 1;
%         end
%     end
% end

end

