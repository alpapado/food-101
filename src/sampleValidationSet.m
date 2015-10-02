function [ vset, vind ] = sampleValidationSet( m, n )
%sampleValidationSet Samples n samples from file m, to be used as
%validation
%   vset: Validation set
%   vind: Indices of total dataset, that belong to vset

fprintf('Generating validation set...');
info = whos(m, 'classIndex');
vind = uint32(randi([1 info.size(1)], n, 1));
features = single(zeros(n, 8576));
classIndex = uint8(zeros(n, 1));

parfor i = 1:length(vind)
   features(i,:) = m.features(i,:);
   classIndex(i) = m.classIndex(i,1);
end

% delete(gcp);
vset = struct('features', features, 'classIndex', classIndex);
fprintf(' done\n\n');

end


