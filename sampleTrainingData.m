function [ trainingStruct ] = sampleTrainingData(nData, superpixelsPath, classes )
%sampleTrainingData Samples n random superpixels, extracts features on them
%and returns them in a struct.
%   Detailed explanation goes here
field1 = 'features'; value1 = zeros(8576, 1);
field2 = 'classLabel'; value2 = '';
trainingStruct = struct(field1, value1, field2, value2);
i = 1;

while i <= nData 
    try
        [image, class, superpixels, index] = sampleRandomSuperpixel(superpixelsPath, classes);
        [features] = extractSuperpixelFeatures(image, superpixels, index);
        trainingStruct(i).features = features;
        trainingStruct(i).class = class;
        i = i + 1;
    catch ME
        fprintf('%s \n', ME.identifier); 
    end
end

end

