load trees35
%trees = trees(1:5);
leaves = cell2mat(extractfield(trees, 'leaves'));
params = load('params');
params.nTrees = length(trees);
metrics = leafMetrics( leaves, params );
load vset
load index
% d = matfile('data.mat');

y = 1;
distScore = metrics.distinct(:, y);
[dists, indexes] = sort(distScore, 'descend');
sortedLeaves = leaves(indexes);
top = sortedLeaves(1:20);
l = 1;
dists(l)
posInd = find(top(l).cvData.classIndex==y);
pos = top(l).cvData.validationIndex(posInd); % Indexes to vset

fid = fopen('data/meta/all.txt');
images = textscan(fid, '%s', 'Delimiter', '\n');
imgSet = images{1};
fclose(fid);

conf = metrics.classConf(y, pos);
[sconf, ia] = sort(conf, 'descend');
pos = pos(ia);

for j = 1:length(pos)
i = map(vind(pos(j)),1);
s = map(vind(pos(j)),2);
str = num2str(cell2mat(imgSet(i)));
imgPath = ['data/images/' str '.jpg'];

I = imread(imgPath);
L=segmentImage(I);
Iseg = vl_imseg(im2double(I), L);
% F = d.features(s, :);

[r, c]= find(L==s);
J = insertMarker(Iseg, int32([c r]), 'color', 'red');
subplot(2,1,1); subimage(I);
title(sprintf('Class confidence = %f\n', metrics.classConf(y, pos(j))));
subplot(2,1,2); subimage(J);
% subplot(2,2,[3 4]); scatter(1:length(F), F);
pause
end
