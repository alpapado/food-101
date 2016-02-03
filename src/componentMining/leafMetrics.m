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

function [classConf, classDist, delta] = classConfidence(leaves, params)
%classConfidence Calculates the class confidence scores for each sample in
%the validation set
%   The class confidence score for a sample s belonging in class y is 
% defined as the products of delta(l,s) with p(y,l), sumed over every
% leaf in the forest and divided by the number of trees in the forest.

% classConf(y,s) : Confidence that sample s belongs to class y
% classDist(y,l) : Empirical distribution of the class y in leaf l
% delta(l,s) : Auxilliary variable that indicates presence or not of sample
% s in leaf l

nTrees = params.nTrees;
nClasses = params.nClasses;

% nSamples = length(extractfield(cell2mat(extractfield(leaves, 'cvData')), 'validationIndex')) ./ nTrees;
nSamples = params.treeSamples;
classConf = single(zeros(nClasses, nSamples));

classDist = classDistribution(leaves, nClasses);
delta = computeDeltas(leaves, nTrees, params.treeSamples);

fprintf('Calculating class confidence...');

tic;
for y = 1:nClasses
    classConf(y,:) = classDist(y,:) * single(delta);
end
toc;

classConf = classConf ./ nTrees;


end

function classDist = classDistribution( leaves, nClasses )
%classDistribution Returns the distributions of all classes in all the
%leaves of the forest
%  leaves : All the leaves in the forest
%  nClasses : The number of the different food classes

%  classDist : The class distributions of all the leaves
fprintf('Calculating class distributions...');
tic;
nLeaves = length(leaves);
classDist = single(zeros(nClasses, nLeaves));

for l = 1:nLeaves
    
    if isempty(leaves(l).trData)
        continue
    end
    
    leafClasses = extractfield(leaves(l).trData, 'classIndex');

    for y = 1:nClasses
        classDist(y,l) = sum(leafClasses == y) / length(leafClasses);
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

nLeaves = size(leaves, 2);
nClasses = params.nClasses;

distinct = single(zeros(nLeaves, nClasses));

fprintf('Calculating distinctiveness...');
tic;

for y = 1:nClasses
    distinct(:,y) = classConf(y,:) * single(delta)';
end

toc;
end

function delta = computeDeltas(leaves, nTrees, nSamples)
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
nLeaves = length(leaves);


% Number of samples in validation set
% nSamples = length(extractfield(cell2mat(extractfield(leaves, 'cvData')), 'validationIndex')) ./ nTrees
delta = uint8(zeros(nLeaves, nSamples));

for l = 1:nLeaves
    sampleIds = leaves(l).cvData.validationIndex;  
    delta(l, sampleIds) = 1;
end

toc;
end
