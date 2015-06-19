function [ models ] = mineComponents( rTree, cvSet, numComponents, numClasses )
%mineComponents Summary of this function goes here
%   Detailed explanation goes here
leafIndx = rTree.findleaves();
numLeaves = size(leafIndx, 2);
field1 = 'trData'; field2 = 'cvData'; field3 = 'svm';
leaves = struct(field1, [], field2, [], field3, []);
models = zeros(numClasses, numComponents);

for i = 1:numLeaves
    leaves(i) = rTree.get(leafIndx(i));
end

distinct = distinctiveness(leaves, cvSet, numClasses);

% For a single class y, evaluate how many discriminative samples are
% located in each leaf by considering distinct(l,c)
for y = 1:numClasses
    fprintf('class %d -->', y);
    classLeavesDistinct = distinct(:, y);
    [sortedDistinct, indexes] = sort(classLeavesDistinct, 'descend');
    sortedLeaves = leaves(indexes);
    topLeaves = sortedLeaves(1:numComponents);
    temp = topLeaves.cvData;
    fprintf('best leaves score = %s\n', num2str(sortedDistinct(1:numComponents) ) );
end

end

