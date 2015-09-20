function [ total ] = acumData( classes )
%UNTITLED Summary of this function goes here
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

