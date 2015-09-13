function [ encoding ] = ivfEncode( data, modes )
%ivfEncode Performs Imprvode Fisher Vector encoding on the given data

% Fit a Gaussian Mixture Model to the data
[means, covariances, priors] = vl_gmm(data', modes);

% Perform the fisher encoding
% Spcifying the improved option, is equivalent to to specifying the
% normalized and square root options.
encoding = vl_fisher(data', means, covariances, priors, 'Improved', 'Fast');

end

