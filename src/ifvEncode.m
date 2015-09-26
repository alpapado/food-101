function [ encoding ] = ifvEncode( data, params )
%ivfEncode Performs Improved Fisher Vector encoding on the given data

means = params.means;
covariances = params.covariances;
priors = params.priors;

% Perform the fisher encoding
% Spcifying the improved option, is equivalent to to specifying the
% normalized and square root options.
encoding = vl_fisher(data', means, covariances, priors, 'Improved', 'Fast');

end

