function total = segmentDataset(datasetPath, classes)
%segmentDataset Performs segmentation on the food-101 dataset and saves
%the results
% INPUTS:
%   datasetPath: Path to location of dataset
%   classes: Class labels of the dataset
% OUTPUTS:
% total: Total number of superpixels in dataset

targetPath = 'data/encoded';
mkdir(targetPath); 
total = 0;

parfor c = 1:length(classes)
    currentClass = num2str(cell2mat(classes(c)));
    imageFolder = [datasetPath '/' currentClass];
    classImages = dir([imageFolder '/*jpg']);
    classTarget = [targetPath '/' currentClass];
    mkdir(classTarget);

    for i = 1:size(classImages, 1)
        fprintf('Segment and encode %s %d/%d\n', currentClass, i, size(classImages,1));  
        
        saveLocation = [classTarget '/' classImages(i).name(1:end-4)]; % Remove .jpg extension from name
        pathToImage = [imageFolder '/' classImages(i).name];
        image = imread(pathToImage, 'jpg');
        
        try                     
            segments = segmentImage(image);
            features = extractImageFeatures(image, segments, pathToImage);
            total = total + size(features, 1);
            parSave(saveLocation, segments, single(features));          
        catch ME          
            disp(getReport(ME,'extended'));       
        end

    end

end

end

function parSave( fname, segments, features)
%parSave Save from inside a parfor loop
save( fname, 'segments', 'features');
end
