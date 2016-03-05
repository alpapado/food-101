function trset = sampleTrainingData(m, n, v)
%sampleTrainingData Samples n random superpixels to be used for training
%set in the growth of a tree.
%   Samples n random entries from the data structure that contains the
%   entire dataset's superpixels in fisher encoding

fprintf('Generating training set...');
N = size(m, 'classIndex');
randInd = randperm(N(1), n);

while ~isempty(intersect(randInd,v))
    [~, IA, ~] = intersect(randInd, v);
    for i = 1:length(IA)
        while ismember(randInd(IA(i)), v)
            randInd(IA(i)) = randi([1 N(1)], 1, 1);
        end    
    end
end

features = m.features;
classIndex = m.classIndex;
X = features(randInd, :);
y = classIndex(randInd, :);

trset = struct('features', X, 'classIndex', y);

fprintf(' done\n');

end

