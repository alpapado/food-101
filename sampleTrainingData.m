function [ shuffledTrainingData ] = sampleTrainingData(n, minStep, maxStep)
%sampleTrainingData Samples n random superpixels to be used for training
%set in the growth of a tree.
%   Samples n random entries from the data structure that contains the
%   entire dataset's superpixels in fisher encoding
field1 = 'features'; value1 = zeros(8576, 1);
field2 = 'classLabel'; value2 = '';
field3 = 'classIndex'; value3 = 0;
field4 = 'image'; value4 = '';

% Preallocate space for result
trainingData(n) = struct(field1, value1, field2, value2, field3, value3, field4, value4);

% Generate random seed
[~, seed] = system('od /dev/urandom --read-bytes=4 -tu | awk ''{print $2}''');
seed = str2double(seed);

% Seed the generator
rng(seed);

% Read class labels from file
base = 'data/';
classFile = [base 'meta/classes.txt'];
fid = fopen(classFile);
classes = textscan(fid, '%s', 'Delimiter', '\n');
classes = classes{1};

sampled = 0;

while sampled < n
    % Load random class encoded file
    try
        randomClass = classes(randi([1 length(classes)], 1));
        load(['done/' num2str(cell2mat(randomClass))]); % Loads encoded data for class in a variable called encoded
    catch
        continue;
    end
    
    % Sample random number of superpixels
    numSamples = randi([minStep maxStep], 1);
    
    % Trim number of new samples, so that no more than n superpixels will
    % be sampled in total
    if sampled + numSamples > n
        numSamples = n - sampled;
    end
    
    % Create numSamples random indexes
    randomIndexes = randi([1 length(encoded)], numSamples, 1); 
    trainingData(sampled+1:sampled+numSamples) = encoded(randomIndexes);
    
    % Update counter
    sampled = sampled + numSamples;
    fprintf('Sampled %d/%d\n', sampled, n);
    
    % Unload from memory
    clear encoded
end

% Randomly shuffle sampled data
permutation = randperm(length(trainingData));
shuffledTrainingData = trainingData(permutation);

end

