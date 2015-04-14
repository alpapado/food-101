function [ encoding ] = ivfEncode( data, modes )
%ivfEncode Performs Imprvode Fisher Vector encoding on the given data

% Fit a Gaussian Mixture Model to the data
[means, covariances, priors] = vl_gmm(data', modes);

% Perform the fisher encoding
encoding = vl_fisher(data', means, covariances, priors, 'Improved');

end

