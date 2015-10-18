function errorCheck( rtree )
%errorCheck Summary of this function goes here
%   Detailed explanation goes here

checkSpliting(rtree);
checkLeaves(rtree);

end


function checkSpliting(rtree)
iterator = rtree.depthfirstiterator;

for i = 1:size(iterator, 2);
    nodeId = iterator(i);
    node = rtree.get(nodeId);
    
    if rtree.isleaf(nodeId)
        continue;
    end
    
    children = rtree.getchildren(nodeId);
    leftId = children(1);
    rightId = children(2);
   
    current = node.cvData.validationIndex;
    left = rtree.get(leftId).cvData.validationIndex;
    right = rtree.get(rightId).cvData.validationIndex;
    
    if length(current) ~= length(left) + length(right)
        fprintf('Wrong split -> Node size = %d - Left = %d - Right = %d\n', nodeSize, leftSize, rightSize);
    end
    
    if ~isempty(intersect(left, right))
        fprintf('Left and right have common points\n');
    end
    
    if ~isequal(union(left,right),current)
        fprintf('Fuck\n');
    end
    
end

end


function checkLeaves(rtree)
% Extract leaves
leafIndices = rtree.findleaves();

t2 = length(rtree.get(1).cvData.classIndex);
t1 = length(rtree.get(1).trData.classIndex);

s1 = 0;
s2 = 0;

for l = 1:length(leafIndices)
    leaf = rtree.get(leafIndices(l));
    s1 = s1 + length(leaf.trData.classIndex);
    s2 = s2 + length(leaf.cvData.classIndex);
end

if s1 ~= t1
    fprintf('Uneven partitioning from root tr data to leaves\n'); 
end

if s2 ~= t2
   fprintf('Uneven partitioning from root cv data to leaves\n'); 
end

end