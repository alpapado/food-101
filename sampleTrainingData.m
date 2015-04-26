function [ trainingStruct ] = sampleTrainingData(nData )
%sampleTrainingData Samples n random superpixels, extracts features on them
%and returns them in a struct.
%   Detailed explanation goes here
fid = fopen('food-101/meta/classes.txt');
classes = textscan(fid, '%s', 'Delimiter', '\n');
classes = classes{1};

base = 'food-101/';
superpixelsPath = [base 'superpixels/'];

field1 = 'features'; value1 = zeros(8576, 1);
field2 = 'classLabel'; value2 = '';
field3 = 'classIndex'; value3 = 0;
trainingStruct = struct(field1, value1, field2, value2, field3, value3);
i = 1;

while i <= nData 
    try
        [image, classLabel, superpixels, spIndex, classIndex] = sampleRandomSuperpixel(superpixelsPath, classes);
        [features] = extractSuperpixelFeatures(image, superpixels, spIndex);
        trainingStruct(i).features = features;
        trainingStruct(i).classLabel = classLabel;
        trainingStruct(i).classIndex = classIndex;
        i = i + 1;
    catch ME
        fprintf('%s \n', ME.identifier); 
    end
end

end

