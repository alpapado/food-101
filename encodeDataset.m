function [ encoded ] = encodeDataset( datasetPath, superpixelsPath )
%encodeDataset Calculates surfs and lab values and fisher encodes them, for
%the entire dataset
field1 = 'features'; value1 = zeros(8576, 1);
field2 = 'classLabel'; value2 = '';
field3 = 'classIndex'; value3 = 0;
field4 = 'image'; value4 = '';
encoded = struct(field1, value1, field2, value2, field3, value3, field4, value4);

% Read class labels from file
fid = fopen('food-101/meta/classes.txt');
classes = textscan(fid, '%s', 'Delimiter', '\n');
classes = classes{1};
numClasses = size(classes, 1);
j = 1;

for c = 1:numClasses
    classLabel = num2str(cell2mat(classes(c)));
    fprintf('Current class = %s \n', classLabel);
    imagesPath = [datasetPath classLabel '/'];
    classIndex = c;
    
    allSuprepixels = dir([superpixelsPath classLabel '/*.mat']);
    
    for i = 1:size(allSuprepixels, 1)
        % Load previously computed superpixels into variable segments
        load(allSuprepixels(i).name);
        
        % Also load image to which the superpixels correspond
        imageName = [imagesPath allSuprepixels(i).name(1:end-4) '.jpg'];
        image = imread(imageName);
        
        % For every superpixels in the image call extractSuperpixelFeatures
        for s = 1:max(max(segments))
            features = extractSuperpixelFeatures( image, segments, superpixelIndex);
            encoded(j).features = features;
            encoded(j).classLabel = classLabel;
            encoded(j).classIndex = classIndex;
            encoded(j).image = imageName;
        end

    end

end

end

