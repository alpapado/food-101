function [ distinct] = distinctiveness( leaves, classConf, delta, params )
%distinctiveness Calculates the distintiveness measuere for each
%combination of leaf - class
%   The distinctiveness measure for a leaf class combination shows how
%   many discriminative samples for the particular class are contained in
%   the particular leaf. Leaves with high distinctiveness are those which
%   collect many discriminative samples i.e those that have a high class
%   confidence score.

numLeaves = size(leaves, 2);
numClasses = params.numClasses;

distinct = zeros(numLeaves, numClasses);

fprintf('Calculating distinctiveness\n');
for y = 1:numClasses
    for l = 1:numLeaves
        distinct(l,y) = sum( delta(l,:) .* classConf(y,:) );
    end 
end

end

