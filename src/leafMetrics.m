function metrics = leafMetrics( leaves, params )
%leafMetrics Computes all the leaf metrics 
%   The function computes the leaf metrics, classDistribution,
%   classConfidence, delta and distinctiveness for set of leaves as defined
%   by the first input for forest parameters given by the second input.
metrics = struct('classDist', [], 'classConf', [], 'delta', [], 'distinct', []);

[classConf, classDist, delta] = classConfidence(leaves, params);
distinct = distinctiveness(leaves, classConf, delta, params);

metrics.classConf = classConf;
metrics.classDist = classDist;
metrics.delta = delta;
metrics.distinct = distinct;

end

function [classConf, classDist, delta] = classConfidence( leaves, params )
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

numSamples = length(extractfield(cell2mat(extractfield(leaves, 'cvData')), 'validationIndex')) ./ numTrees;
classConf = single(zeros(numClasses, numSamples));

classDist = classDistribution(leaves, numClasses);
delta = computeDeltas(leaves, numTrees);

fprintf('Calculating class confidence...');
tic;
for y = 1:numClasses
    parfor s = 1:numSamples
        classConf(y,s) = sum( single(delta(:,s)) .* classDist(y,:)' );
    end
end

classConf = classConf ./ numTrees;
toc;

end

function classDist = classDistribution( leaves, numClasses )
%classDistribution Returns the distributions of all classes in all the
%leaves of the forest
%  leaves : All the leaves in the forest
%  numClasses : The number of the different food classes

%  classDist : The class distributions of all the leaves
fprintf('Calculating class distributions...');
tic;
numLeaves = size(leaves, 2);
classDist = single(zeros(numClasses, numLeaves));

for l = 1:numLeaves
    
    if isempty(leaves(l).trData)
        continue
    end
    
    leafClasses = extractfield(leaves(l).trData, 'classIndex');
    for y = 1:numClasses
        classDist(y,l) = sum(leafClasses == y) / numel(leafClasses);
    end
end
toc;

end

function distinct = distinctiveness(leaves, classConf, delta, params)
%distinctiveness Calculates the distintiveness measuere for each
%combination of leaf - class
%   The distinctiveness measure for a leaf class combination shows how
%   many discriminative samples for the particular class are contained in
%   the particular leaf. Leaves with high distinctiveness are those which
%   collect many discriminative samples i.e those that have a high class
%   confidence score.

numLeaves = size(leaves, 2);
numClasses = params.numClasses;

distinct = single(zeros(numLeaves, numClasses));

fprintf('Calculating distinctiveness...');
tic;

for y = 1:numClasses
    parfor l = 1:numLeaves
        distinct(l,y) = sum( single(delta(l,:)) .* classConf(y,:) );
    end 
end

toc;
end

function delta = computeDeltas(leaves, numTrees)
%computeDeltas Calculates the deltas for all combinations of samples and
%leaves
%   The deltas are a simple auxilliary variable that show whether or not a
%   particular sample reaches a particular leaf in the forest. i.e
%   delta(l,s) is defined as follows:
%                { 1, if the sample s has reached the leaf l
%   delta(l,s) = {
%                { 0, otherwise

fprintf('Computing deltas...');
tic;
numLeaves = length(leaves);
numSamples = length(extractfield(cell2mat(extractfield(leaves, 'cvData')), 'validationIndex')) ./ numTrees;
delta = uint8(zeros(numLeaves, numSamples));

for l = 1:numLeaves
    sampleIds = leaves(l).cvData.validationIndex;
    [C, IA, IB] = intersect(sampleIds, 1:numSamples);
    delta(l, IB) = 1;
end

toc;
end
