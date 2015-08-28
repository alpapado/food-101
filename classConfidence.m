function [ classConf, classDist, delta ] = classConfidence( leaves, params )
%classConfidence Calculates the class confidence scores for each sample in
%the validation set
%   The class confidence score for a sample s belonging in class y is 
% defined as the products of delta(l,s) with p(y,l), sumed over every
% leaf in the forest and divided by the number of trees in the forest.

% classConf(y,s) : Confidence that sample s belongs to class y
% classDist(y,l) : Empirical distribution of the class y in leaf l
% delta(l,s) : Auxilliary variable that indicates presence or not of sample
% s in leaf l

numTrees = params.numTrees;
numClasses = params.numClasses;

numSamples = length(extractfield(cell2mat(extractfield(leaves, 'cvData')), 'validationIndex')) / numTrees;
classConf = zeros(numClasses, numSamples);


classDist = classDistribution(leaves, numClasses);
delta = computeDeltas(leaves, numTrees);

fprintf('Calculating class confidence\n');
for y = 1:numClasses
    for s = 1:numSamples
        classConf(y,s) = sum( delta(:,s) .* classDist(y,:)' );
    end
end

classConf = classConf ./ numTrees;

end

