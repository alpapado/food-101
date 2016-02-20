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

if strcmp(params.encoding, 'sparse')
    encoding = 1;
elseif strcmp(params.encoding, 'fisher')
    encoding = 0;
end

features = [];
classIndex = [];

parfor i = 1:length(imgSet)
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
            F = extractImageFeatures(I, L, params);
        end

        features = [features; F];
        classIndex = [classIndex; uint8(zeros(size(F,1),1) + c)];
    catch ME          
        disp(getReport(ME,'extended'));       
    end
end

% Write to file
save('data.mat', 'features', 'classIndex');

end


