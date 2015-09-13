function total = segmentDataset(datasetPath, classes)
%segmentDataset Performs segmentation on the food-101 dataset and saves
%the results
% INPUTS:
%   datasetPath: Path to location of dataset
%   classes: Class labels of the dataset
% OUTPUTS:
% total: Total number of superpixels in dataset

numClasses = size(classes, 1);
targetPath = 'data/encoded';
% mkdir(targetPath); 
total = 0;

for c = 1:numClasses
    currentClass = num2str(cell2mat(classes(c)));
    fprintf('Current class = %s \n', currentClass);
    imageFolder = [datasetPath '/' currentClass];
    classImages = dir([imageFolder '/*jpg']);
    classTarget = [targetPath '/' currentClass];
%     mkdir(classTarget);

    for i = 1:size(classImages, 1)
        fprintf('Segment and encode %s %d/%d\n', currentClass, i, size(classImages,1));  
        
        saveLocation = [classTarget '/' classImages(i).name(1:end-4)]; % Remove .jpg extension from name
        pathToImage = [imageFolder '/' classImages(i).name];
        image = imread(pathToImage, 'jpg');
        
        try                     
            segments = segmentImage(image);
            features = extractImageFeatures(image, segments, pathToImage);
            total = total + size(features, 1);
%             parSave(saveLocation, segments, single(features));          
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
