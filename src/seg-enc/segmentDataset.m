function segmentDataset(params)
%segmentDataset Performs segmentation on the food-101 dataset and saves
%the results
% INPUTS:
%   params: Param struct
% OUTPUTS:

classes = params.classes;

fid = fopen('data/meta/all.txt');
images = textscan(fid, '%s', 'Delimiter', '\n');
imgSet = images{1};
fclose(fid);

all = matfile('data.mat', 'Writable', true);
all.features = single(zeros(1, params.encodingLength));
all.classIndex = uint8(zeros(1, 1));
index = matfile('index.mat', 'Writable', true);
index.map = zeros(1, 2);

if strcmp(params.encoding, 'sparse')
    encoding = 1;
elseif strcmp(params.encoding, 'fisher')
    encoding = 0;
end

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

        if encoding
            F = extractImageFeatures2(I, L, params);
        else
            [F, ~, goodSegments] = extractImageFeatures(I, L, params);
        end
        
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

% Write to file
% save('data.mat', 'features', 'classIndex');

end


