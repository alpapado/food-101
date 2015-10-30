function prunedLeaves = pruneLeaves(leaves)
%pruneLeaves Removes the leaves whose samples consist of more than half of
%the same superpixels as any better scoring leaf.
%   leaves: List that contains the leaves of the trees sorted
%   descendingly based on score. So for every leaf, we just need to check
%   only those before (that is with better score) it in the list

fprintf('Pruning leaves\n');
tic;
nLeaves = length(leaves);
prunedLeaves = struct('trData', [], 'cvData', []);
toRemove = zeros(nLeaves, 1);

% leafSamples = struct('samples', []);
% for iLeaf = 1:nLeaves
%     leafSamples(iLeaf).samples = extractfield(leaves(iLeaf).cvData, 'validationIndex');
% end

% For every leaf
for iLeaf = 1:nLeaves
    
    % Compare current leaf with every better scoring leaf
    % If it consists of more than half of the sample spixels as any leaf in
    % that list, mark it for removal.
    for r = 1:iLeaf-1
        if toRemove(r) == 1
            continue;
        end
        
        commonSamples = length(intersect(leaves(iLeaf).cvData.validationIndex, leaves(r).cvData.validationIndex));
        s = commonSamples / length(leaves(iLeaf).cvData.validationIndex);
        if s > 0.5
           fprintf('s = %d\n', s);
           toRemove(r) = 1; 
        end
    end
    
    if toRemove(iLeaf) == 0
        prunedLeaves(iLeaf) = leaves(iLeaf);
    end
end

toc
end

% function  s = similarity( a, b )
% %similarity Returns the similarity s, of a vector a in regards to a vector
% %b
% % Similarity of a to b is defined as how many elements of a also appear in
% % b, divided by the number of elemnents in a.
% lenA = length(a);
% s = 0;
% 
% for i = 1:lenA
%     if sum(b == a(i)) == 1
%         s = s + 1;
%     end 
% end
% 
% s = s / lenA;
% 
% end

