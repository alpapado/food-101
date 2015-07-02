function [ trainingData ] = sampleTrainingData(n, data)
%sampleTrainingData Samples n random superpixels to be used for training
%set in the growth of a tree.
%   Samples n random entries from the data structure that contains the
%   entire dataset's superpixels in fisher encoding

randomIndexes = randi([1 length(data)], n, 1);
trainingData = data(randomIndexes);

end

