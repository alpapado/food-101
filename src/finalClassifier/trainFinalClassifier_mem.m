function trainFinalClassifier_mem(params)
%trainFinalClassifier_mem Faster version of trainFinalClassifier for
%systems with huge memory
% This version of the function is much faster than the original because it
% avoids recomputing the image encodings since they have already been
% computed once during the segmentation phase. In order to produce same
% results as the original it is imperative that no bad superpixels exist.

components = params.models;
data = load('data');
% data = matfile('data.mat');
encodeImageSet('train', components, params, data);
encodeImageSet('test', components, params, data);

end

function encodeImageSet(type, components, params, data)

if strcmp(type,'train')
  fid = fopen('data/meta/train.txt');
elseif strcmp(type,'test');
  fid = fopen('data/meta/test.txt');
end

images = textscan(fid, '%s', 'Delimiter', '\n');
fclose(fid);
imgSet = images{1};

fid = fopen('data/meta/all.txt');
images = textscan(fid, '%s', 'Delimiter', '\n');
allSet = images{1};
fclose(fid);

pyramidLevels = params.pyramidLevels;
classes = params.classes;
nImages = length(imgSet);
[nClasses, nComponents] = size(components);
numCells = sum(4 .^ (0:pyramidLevels-1)); % Num of cells in pyramid grid
d = nClasses * nComponents * numCells; % Dimensionality of feature vec

load('index.mat');
load('segments');

step = 1;
X = single(zeros(nImages/step, d));
y = uint8(zeros(nImages/step, 1));
s = 1;

for i = 1:step:nImages
    try
        tic
        fprintf('%d/%d ', i, nImages);
        str = num2str(cell2mat(imgSet(i)));
        split = strsplit(str, '/');
        class = num2str(cell2mat(split(1)));
        imgPath = ['data/images/' str '.jpg'];
        I = imread(imgPath);
              
        [~, indexC] = ismember(allSet, imgSet(i));
        index = find(indexC ~= 0);
        
        istart = find(map(:,1)==index, 1 );
        iend = find(map(:,1)==index, 1, 'last' );
        F = data.features(istart:iend, :);
        
        X(s,:) = extractImageFeatureVector_mem(I, segments(index).L, F, params);
        y(s) = uint8(find(strcmp(classes, class)));
        s = s + 1;
        toc
    catch ME
        disp(getReport(ME,'extended'));
    end

end

if strcmp(type,'train')
    save('train.mat', 'X', 'y', '-v7.3');
elseif strcmp(type,'test');
    save('test.mat', 'X', 'y', '-v7.3');
end

end
