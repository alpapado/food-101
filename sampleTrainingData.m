function [ trainingData ] = sampleTrainingData(n, data)
%sampleTrainingData Samples n random superpixels to be used for training
%set in the growth of a tree.
%   Samples n random entries from the data structure that contains the
%   entire dataset's superpixels in fisher encoding

% Old way
% fid = fopen('food-101/meta/classes.txt');
% classes = textscan(fid, '%s', 'Delimiter', '\n');
% classes = classes{1};
% 
% base = 'food-101/';
% superpixelsPath = [base 'superpixels/'];


% field1 = 'features'; value1 = zeros(8576, 1);
% field2 = 'classLabel'; value2 = '';
% field3 = 'classIndex'; value3 = 0;
% field4 = 'id'; value4 = 0;
% trainingStruct(length(allData)) = struct(field1, value1, field2, value2, field3, value3, field4, value4);
% i = 1;

% while i <= n 
%     try
%         [image, classLabel, superpixels, spIndex, classIndex] = sampleRandomSuperpixel(superpixelsPath, classes);
%         [features] = extractSuperpixelFeatures(image, superpixels, spIndex);
%         trainingStruct(i).features = features;
%         trainingStruct(i).classLabel = classLabel;
%         trainingStruct(i).classIndex = classIndex; 
%         i = i + 1;
%     catch ME
%         fprintf('%s \n', ME.identifier); 
%     end
% end

% New more elegant way
randomIndexes = randi([1 length(data)], n, 1);
trainingData = data(randomIndexes);

end

