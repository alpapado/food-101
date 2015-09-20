function [ allFeatures, allClasses ] = sampleTrainingData(n)
%sampleTrainingData Samples n random superpixels to be used for training
%set in the growth of a tree.
%   Samples n random entries from the data structure that contains the
%   entire dataset's superpixels in fisher encoding

% Preallocate space for result
allFeatures = single(zeros(n, 8576));
allClasses = uint8(zeros(n, 1));

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

[s, w] = unix('find data -name "*mat"');
list = strsplit(w, '\n'); % list of image encodings
list(end) = []; % last is empty

parfor i = 1:n
    try
        %fprintf('%d / %d', i, n);
        ind = randi([1 length(list)], 1);
        randImgEnc = num2str(cell2mat(list(ind)));

        temp = load(randImgEnc, 'features');
        split = strsplit(randImgEnc, '/');
        classLabel = split(3);
        c = find(ismember(classes, classLabel));

        randSp = randi([1 size(temp.features, 1)], 1);
        allFeatures(i,:) = temp.features(randSp, :);
        allClasses(i) = c;  
    catch ME
        fprintf('img = %s\n', randImgEnc);
        disp(getReport(ME,'extended'));
    end
end

% while sampled < n
    % Load random class encoded file
    
    
%     try
%         randomClass = classes(randi([1 length(classes)], 1));
%         load(['done/' num2str(cell2mat(randomClass))]); % Loads encoded data for class in a variable called encoded
%     catch
%         continue;
%     end
%     
%     % Sample random number of superpixels
%     numSamples = randi([minStep maxStep], 1);
    
    % Trim number of new samples, so that no more than n superpixels will
    % be sampled in total
%     if sampled + numSamples > n
%         numSamples = n - sampled;
%     end
    
    % Create numSamples random indexes
%     randomIndexes = randi([1 length(encoded)], numSamples, 1); 
%     trainingData(sampled+1:sampled+numSamples) = encoded(randomIndexes);
    
    % Update counter
%     sampled = sampled + numSamples;
%     fprintf('Sampled %d/%d\n', sampled, n);
    
    % Unload from memory
%     clear encoded
% end

% Randomly shuffle sampled data
% permutation = randperm(length(trainingData));
% shuffledTrainingData = trainingData(permutation);

end

