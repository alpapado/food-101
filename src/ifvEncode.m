function [ encoding ] = ifvEncode( data, gmm )
%ifvEncode Performs Imprvode Fisher Vector encoding on the given data

% Perform the fisher encoding
% Spcifying the improved option, is equivalent to specifying the
% normalized and square root options.
means = gmm.means;
covariances = gmm.covariances;
priors = gmm.priors;

encoding = vl_fisher(data', means, covariances, priors, 'Improved', 'Fast');

end

