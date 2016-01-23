function trset = sampleTrainingData(m, n, l, v)
%sampleTrainingData Samples n random superpixels to be used for training
%set in the growth of a tree.
%   Samples n random entries from the data structure that contains the
%   entire dataset's superpixels in fisher encoding

fprintf('Generating training set...');

features = m.features;
classIndex = m.classIndex;
randInd = zeros(n, 1);

for i = 1:n
    try
        randInd(i) = randi([1 length(classIndex)], 1, 1);
        while ismember(randInd(i), v)
            randInd(i) = randi([1 length(classIndex)], 1, 1);
        end
    catch
        disp(getReport(ME,'extended'));
    end
    
end

X = features(randInd, :);
y = classIndex(randInd, :);

% Preallocate space for result
% features = single(zeros(n, l));
% classIndex = uint8(zeros(n, 1));

% % Generate n random indices
% info = whos(m, 'classIndex');
% 
% fprintf('Generating training set...');
% parfor i = 1:n
%     try
%         randInd = randi([1 info.size(1)], 1, 1);
%         while ismember(randInd, v)
%             randInd = randi([1 info.size(1)], 1, 1);
%         end
% 
%         features(i,:) = m.features(randInd, :);
%         classIndex(i) = m.classIndex(randInd, 1);
%     catch ME 
%         disp(getReport(ME,'extended'));
%     end
% end
% delete(gcp);

trset = struct('features', X, 'classIndex', y);

fprintf(' done\n');

end

