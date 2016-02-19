function trset = sampleTrainingData(m, n, v)
%sampleTrainingData Samples n random superpixels to be used for training
%set in the growth of a tree.
%   Samples n random entries from the data structure that contains the
%   entire dataset's superpixels in fisher encoding

fprintf('Generating training set...');
N = size(m, 'classIndex');
randInd = randi([1 N(1)], n, 1);

while ~isempty(intersect(randInd,v))
    [~, IA, ~] = intersect(randInd, v);
    for i = IA
        while ismember(randInd(i), v)
            randInd(i) = randi([1 N(1)], 1, 1);
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

