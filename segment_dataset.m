function [segments ] = segment_dataset( datasetPath, classes, targetPath )
%segment_dataset Performs segmentation on the food-101 dataset and saves
%the result
%   datasetPath: Path to location of dataset
%   classes: Class labels of the dataset

numClasses = size(classes, 1);
mkdir(targetPath);

for c = 1:numClasses
    currentClass = num2str(cell2mat(classes(c)));
    fprintf('Current class = %s', currentClass);
    pathToImageFolder = [datasetPath currentClass];
    classImages = dir([pathToImageFolder '/*jpg']);
    pathToSuperpixels = [targetPath currentClass];
    mkdir(pathToSuperpixels);
    
    for i = 1:size(classImages, 1)
        saveLocation = [pathToSuperpixels '/' classImages(i).name(1:end-4)]; % Remove .jpg extension from name
        
        if exist([saveLocation '.mat'], 'file') == 2
            fprintf('Image has already been segmented... skipping... \n');
            continue
        end
        
        pathToImage = [pathToImageFolder '/' classImages(i).name] 
        img = imread(pathToImage, 'jpg');
        segments = segment_image(img);
        save(saveLocation);
%         fprintf('superpixels = %d \n', max(max(segments)) );
    end

end


end

