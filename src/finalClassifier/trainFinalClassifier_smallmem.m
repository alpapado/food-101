function trainFinalClassifier_smallmem(params)

components = params.models;
encodeImageSet('train', components, params);
encodeImageSet('test', components, params);

end

function encodeImageSet(type, components, params)

if strcmp(type,'train')
  fid = fopen('data/meta/train.txt');
  m = matfile('./train.mat', 'Writable', true);
elseif strcmp(type,'test');
  fid = fopen('data/meta/test.txt');
  m = matfile('./test.mat', 'Writable', true);
end

images = textscan(fid, '%s', 'Delimiter', '\n');
imgSet = images{1};

pyramidLevels = params.pyramidLevels;
classes = params.classes;
nImages = length(imgSet);

[nClasses, nComponents] = size(components);
numCells = sum(4 .^ (0:pyramidLevels-1)); % Num of cells in pyramid grid
d = nClasses * nComponents * numCells; % Dimensionality of feature vec

m.X = single(zeros(1, d));
m.y = uint8(zeros(1, 1));

for i = 1:nImages
    try
        tic
        fprintf('%d/%d ', i, nImages);
        str = num2str(cell2mat(imgSet(i)));
        split = strsplit(str, '/');
        class = num2str(cell2mat(split(1)));
        imgPath = ['data/images/' str '.jpg'];
        I = imread(imgPath);
        
        m.X(i,:) = transpose(extractImageFeatureVector_smallmem(I, params));
        m.y(i,1) = uint8(find(strcmp(classes, class)));
        toc
    catch ME
        disp(getReport(ME,'extended'));
    end

end

end