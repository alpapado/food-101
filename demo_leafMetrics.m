load('tree.mat');

base = 'data/';
fid = fopen([base 'meta/classes.txt']);
classes = textscan(fid, '%s', 'Delimiter', '\n');
classes = classes{1};
superpixelsPath = [base 'superpixels/'];

leafIndx = rTree.findleaves();
numLeaves = size(leafIndx, 2);
field1 = 'trData'; field2 = 'cvData'; field3 = 'svm';
leaves = struct(field1, [], field2, [], field3, []);

for i = 1:numLeaves
    leaves(i) = rTree.get(leafIndx(i));
end

load('s1k.mat');
distinct = distinctiveness(leaves, s, size(classes,1));