function prunedLeaves = pruneLeaves(sortedLeaves, class)
%pruneLeaves Removes the leaves whose samples consist of more than half of
%the same superpixels as any better scoring leaf.
%   leaves: List that contains the leaves of the trees sorted
%   descendingly based on score. So for every leaf, we just need to check
%   only those before (that is with better score) it in the list

fprintf('Pruning leaves\n');
tic;
nLeaves = length(sortedLeaves);
toRemove = zeros(nLeaves, 1);

% For every leaf
for l = 2:nLeaves
    current = sortedLeaves(l);
    better = sortedLeaves(l-1:-1:1);
    classSamples = current.cvData.validationIndex(current.cvData.classIndex==class);
    
    % Compare current leaf with every better scoring leaf
    % If it consists of more than half of the sample spixels as any leaf in
    % that list, mark it for removal.
    for i = 1:length(better)     
        [~, IA, ~] = intersect(classSamples, better(i).cvData.validationIndex(better(i).cvData.classIndex == class));
        if IA / length(classSamples) > 0.5
            toRemove(l) = 1;
            break;
        end
    end
end

prunedLeaves = sortedLeaves(~toRemove);
toc;

end


