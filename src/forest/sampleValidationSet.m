function [ vset, vind ] = sampleValidationSet( m, n)
%sampleValidationSet Samples n samples from file m, to be used as
%validation
%   vset: Validation set
%   vind: Indices of total dataset, that belong to vset

fprintf('Generating validation set...');
N = size(m, 'classIndex');
vind = uint32(randperm(N(1), n));
features = m.features;
classIndex = m.classIndex;

X = features(vind, :);
y = classIndex(vind);

vset = struct('features', X, 'classIndex', y);
fprintf(' done\n\n');

end


