function trset = sampleTrainingData(m, n, v)
%sampleTrainingData Samples n random superpixels to be used for training
%set in the growth of a tree.
%   Samples n random entries from the data structure that contains the
%   entire dataset's superpixels in fisher encoding

% Preallocate space for result
features = single(zeros(n, 8576));
classIndex = uint8(zeros(n, 1));

% Generate random seed
[~, seed] = system('od /dev/urandom --read-bytes=4 -tu | awk ''{print $2}''');
seed = str2double(seed);

% Seed the generator
rng(seed);

% Generate n random indices
info = whos(m, 'classIndex');

fprintf('Generating training set...');
parfor i = 1:n
    randInd = randi([1 info.size(1)], 1, 1);
    while ismember(randInd, v)
        randInd = randi([1 info.size(1)], 1, 1);
    end
    
    features(i,:) = m.features(randInd, :);
    classIndex(i) = m.classIndex(randInd, 1);
end
delete(gcp);
trset = struct('features', features, 'classIndex', classIndex);

fprintf(' done\n');

end

