function segmentDataset(params)
%segmentDataset Performs segmentation on the food-101 dataset and saves
%the results

classes = params.classes;

% Read image paths from here
fid = fopen('data/meta/all.txt');
images = textscan(fid, '%s', 'Delimiter', '\n');
imgSet = images{1};
fclose(fid);

% The file where all the superpixel representations will be saved
all = matfile('data.mat', 'Writable', true);
all.features = single(zeros(1, params.encodingLength));
all.classIndex = uint8(zeros(1, 1));

% Auxilliary file to avoid recomputing the features later on
index = matfile('index.mat', 'Writable', true);
index.map = zeros(1, 2);

s = 1;

for i = 1:length(imgSet)
    fprintf('%d/%d \n', i, length(imgSet));
    str = num2str(cell2mat(imgSet(i)));
    imgPath = ['data/images/' str '.jpg'];
    I = imread(imgPath);
    split = strsplit(str, '/');
    class = num2str(cell2mat(split(1)));
    c = find(strcmp(classes, class));
    
    try 
        L = segmentImage(I);
        [F, ~, goodSegments] = extractImageFeatures(I, L, params);
        
        all.features(s:s+size(F,1)-1, :) = F;
        all.classIndex(s:s+size(F,1)-1, 1) = uint8(zeros(size(F,1),1) + c);

        spixels = unique(L);       
        index.map(s:s+size(F,1)-1, 1) = i;
        index.map(s:s+size(F,1)-1, 2) = double(spixels(logical(goodSegments)));
        s = s + size(F, 1);
    catch ME          
        disp(getReport(ME,'extended'));       
    end
    
end

end


