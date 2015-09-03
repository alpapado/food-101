function segmentDataset(datasetPath, classes)
%segmentDataset Performs segmentation on the food-101 dataset and saves
%the result
%   datasetPath: Path to location of dataset
%   classes: Class labels of the dataset

numClasses = size(classes, 1);
spTargetPath = 'data/superpixels';
encTargetPath = 'data/encoded';
mkdir(spTargetPath);
mkdir(encTargetPath); 

for c = 1:numClasses
    currentClass = num2str(cell2mat(classes(c)));
    fprintf('Current class = %s \n', currentClass);
    imageFolder = [datasetPath currentClass]
    classImages = dir([imageFolder '/*jpg']);
    classSpTarget = [spTargetPath '/' currentClass];
    classEncTarget = [encTargetPath '/' currentClass];
    mkdir(classSpTarget);
    mkdir(classEncTarget);

    parfor i = 1:size(classImages, 1)
        fprintf('Segment and encode %s %d/%d\n', currentClass, i, size(classImages,1));
        spSaveLocation = [classSpTarget '/' classImages(i).name(1:end-4)]; % Remove .jpg extension from name
        encSaveLocation = [classEncTarget '/' classImages(i).name(1:end-4)];

        pathToImage = [imageFolder '/' classImages(i).name];
        image = imread(pathToImage, 'jpg');
        
        try
            segments = segmentImage(image);
            [features, validSegments] = extractImageFeatures(image, segments);
            parSave(spSaveLocation, segments);
            parSave(encSaveLocation, features);
        catch ME
            fprintf('%s \n', ME.identifier);       
        end

    end

end

end
