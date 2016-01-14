function total = segmentDataset(params)
%segmentDataset Performs segmentation on the food-101 dataset and saves
%the results
% INPUTS:
%   datasetPath: Path to location of dataset
%   classes: Class labels of the dataset
% OUTPUTS:
% total: Total number of superpixels in dataset

total = 0;

all = matfile('data.mat', 'Writable', true);
all.features = single(zeros(1, params.encodingLength));
all.classIndex = uint8(zeros(1, 1));
classes = params.classes;

for c = 1:length(classes)
    currentClass = num2str(cell2mat(classes(c)));
    imageFolder = [params.datasetPath '/' currentClass];
    classImages = dir([imageFolder '/*jpg']);
    tempFeatures = [];
    tempLabels = [];
    nImages = size(classImages, 1);
    
    parfor i = 1:nImages
        fprintf('Segment and encode %s %d/%d\n', currentClass, i, nImages);  
        
        pathToImage = [imageFolder '/' classImages(i).name];
        image = imread(pathToImage, 'jpg');
        
        try                     
            segments = segmentImage(image);        
            features = extractImageFeatures(image, segments, params);           
            tempFeatures = [tempFeatures; features];
            tempLabels = [tempLabels; zeros(length(unique(segments)),1) + c];
                   
        catch ME          
            disp(getReport(ME,'extended'));       
        end

    end
    
    % Write to file
    new = size(tempFeatures, 1);
    istart = total + 1;
    iend = istart + new - 1;
    total = total + new;

    all.features(istart:iend, :) = single(tempFeatures);
    all.classIndex(istart:iend, 1) = uint8(tempLabels);

end

end


