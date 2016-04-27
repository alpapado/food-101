function visualizeLeaves( leaves, metrics, params )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

nClasses = params.nClasses;
nComponents = params.nComponents;
distinct = metrics.distinct;

for y = 1:nClasses
    distScore = distinct(:, y);
    [~, indexes] = sort(distScore, 'descend');
    sorted = leaves(indexes);

    % Prune sortedLeaves
%     pruned = sorted;
    pruned = pruneLeaves(sorted,y);

    top = pruned;
    top2 = sorted;
    
    x = zeros(nComponents, 1);
    x2 = x;
    for i = 1:nComponents
        leaf = top(i);     
        x(i) = sum(leaf.cvData.classIndex==y); 
        leaf2 = top2(i);
        x2(i) = sum(leaf2.cvData.classIndex==y); 
    end
    
    if ~isequal(x,x2)
        subplot(1,2,1);
        bar(x2);
        title(sprintf('unpruned class %d', y));
        ylabel('Positive samples');
        xlabel('Top leaves');

        subplot(1,2,2);   
        bar(x);
        title(sprintf('pruned class %d', y));
        ylabel('Positive samples');
        xlabel('Top leaves');

        pause
    end
end

end

