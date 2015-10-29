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


function total = acumData( classes )
%acumData Accumulates all encodings into a single file
%   Detailed explanation goes here

sourcePath = 'data/encoded';
all = matfile('data.mat', 'Writable', true);
all.features = single(zeros(1, 8576));
all.classIndex = uint8(zeros(1, 1));

tempFeatures = [];
tempClInd = [];

total = 0;
classCounter = 0;

for c = 1:length(classes)
	c
    currentClass = num2str(cell2mat(classes(c)));
    encFolder = [sourcePath '/' currentClass];
    classImages = dir([encFolder '/*mat']);

    for i = 1:size(classImages, 1)
        file = [encFolder '/' classImages(i).name];
        load(file);

        newFeatures = size(features, 1);
        tempFeatures(end+1:end+1+newFeatures-1,:) = features;
        tempClInd(end+1:end+1+newFeatures-1) = c;
 
        if classCounter == 1 || (c == 101 && i == size(classImages,1))

          fprintf('Writing to file\n');
          
          % Write to file
          new = size(tempFeatures, 1);
          istart = total + 1;
          iend = istart + new - 1;
          total = total + new;
                 
          all.features(istart:iend, :) = single(tempFeatures);
          all.classIndex(istart:iend, 1) = uint8(tempClInd');
          
          fprintf('Written = %d\n', total);
          
          clear tempFeatures;
          clear tempClInd;
          tempFeatures = [];
          tempClInd = [];

          classCounter = 0;
        end
    end
   classCounter = classCounter + 1;

end


end

