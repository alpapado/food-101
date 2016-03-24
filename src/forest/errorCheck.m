function errorCheck( rtree )
%errorCheck Summary of this function goes here
%   Detailed explanation goes here

checkSpliting(rtree);
checkLeaves(rtree);
visualize(rtree);

end


function checkSpliting(rtree)
iterator = rtree.depthfirstiterator;
hasError = false;
for i = 1:size(iterator, 2);
    nodeId = iterator(i);
    node = rtree.get(nodeId);
    
    if rtree.isleaf(nodeId)
        continue;
    end
    
    children = rtree.getchildren(nodeId);
    leftId = children(1);
    rightId = children(2);
   
    try
        current = node.cvData.validationIndex;
    catch
        continue;
    end
    
    try
        left = rtree.get(leftId).cvData.validationIndex;
    catch
        left = [];
    end
    
    try
        right = rtree.get(rightId).cvData.validationIndex;
    catch
        right = [];
    end
    
    if length(current) ~= length(left) + length(right)
        hasError = true;
        fprintf('Wrong split -> Node size = %d - Left = %d - Right = %d\n', nodeSize, leftSize, rightSize);
    end
    
    if ~isempty(intersect(left, right))
        hasError = true;
        fprintf('Left and right have common points\n');
    end
    
    if ~isequal(union(left,right, 'legacy'),current)
        hasError = true;
        fprintf('Union of children does not equal parent\n');
    end
    
end

if ~hasError
   fprintf('No error in spliting\n'); 
end

end

function checkLeaves(rtree)
% Extract leaves
leafIndices = rtree.findleaves();

t2 = length(rtree.get(1).cvData.classIndex);
t1 = length(rtree.get(1).trData.classIndex);

s1 = 0;
s2 = 0;

hasError = false;

for l = 1:length(leafIndices)
    leaf = rtree.get(leafIndices(l));
    try
        s1 = s1 + length(leaf.trData.classIndex);
    catch

    end
    
    try
        s2 = s2 + length(leaf.cvData.classIndex);
    catch

    end
end

if s1 ~= t1
    hasError = true;
    fprintf('Uneven partitioning from root tr data to leaves\n'); 
end

if s2 ~= t2
   hasError = true;
   fprintf('Uneven partitioning from root cv data to leaves\n'); 
end

if ~hasError
   fprintf('No error in leaves\n'); 
end

end

function visualize(rtree)

iterator = rtree.depthfirstiterator;
hasError = false;

for i = 1:size(iterator, 2);
    nodeId = iterator(i);
    
    if rtree.isleaf(nodeId)
        continue;
    end
    
    children = rtree.getchildren(nodeId);
    leftId = children(1);
    rightId = children(2);
   
    left = histc(rtree.get(leftId).cvData.classIndex, (1:101)');
    right = histc(rtree.get(rightId).cvData.classIndex, (1:101)');
    dad = histc(rtree.get(nodeId).cvData.classIndex, (1:101)');
    if ~isequal(left+right, dad)
        hasError = true;
    end
    
%     subplot(2,2,[1,2]); histogram(rtree.get(nodeId).cvData.classIndex, 101);
%     subplot(2,2,3); histogram(rtree.get(leftId).cvData.classIndex, 101);
%     subplot(2,2,4); histogram(rtree.get(rightId).cvData.classIndex, 101);
%     
%     figure(2)
%     subplot(2,2,[1,2]); histogram(rtree.get(nodeId).trData.classIndex, 101);
%     subplot(2,2,3); histogram(rtree.get(leftId).trData.classIndex, 101);
%     subplot(2,2,4); histogram(rtree.get(rightId).trData.classIndex, 101);
%     pause
    
%     subplot(1,2,2); histogram(rtree.get(nodeId).trData.classIndex, 101); title('tr');
%     subplot(1,2,1); histogram(rtree.get(nodeId).cvData.classIndex, 101); title('cv');
%     isequal(histc(rtree.get(nodeId).trData.classIndex,101), histc(rtree.get(nodeId).cvData.classIndex,101))
%     pause
end

if hasError
    fprintf('SHit\n');
end
end