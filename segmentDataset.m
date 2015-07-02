function segmentDataset( datasetPath, classes, targetPath )
%segmentDataset Performs segmentation on the food-101 dataset and saves
%the result
%   datasetPath: Path to location of dataset
%   classes: Class labels of the dataset

numClasses = size(classes, 1);
mkdir(targetPath);

for c = 1:numClasses
    currentClass = num2str(cell2mat(classes(c)));
    fprintf('Current class = %s \n', currentClass);
    pathToImageFolder = [datasetPath currentClass];
    classImages = dir([pathToImageFolder '/*jpg']);
    pathToSuperpixels = [targetPath currentClass];
    mkdir(pathToSuperpixels);
    
    parfor i = 1:size(classImages, 1)
        fprintf('Segmenting %s %d/%d\n', currentClass, i, size(classImages,1));
        saveLocation = [pathToSuperpixels '/' classImages(i).name(1:end-4)]; % Remove .jpg extension from name
        
        if exist([saveLocation '.mat'], 'file') == 2
            continue
        end
        
        pathToImage = [pathToImageFolder '/' classImages(i).name];
        img = imread(pathToImage, 'jpg');
        
        try
            segments = segmentImage(img);
            parSave(saveLocation, segments);
        catch ME
            fprintf('%s \n', ME.identifier);       
        end

    end

end


end

