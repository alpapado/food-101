function [ Bd, Bc ] = computeBases( Xd, Xc, descriptorBases, colorBases )
%COMPUTEBASES Summary of this function goes here
%   Detailed explanation goes here

param.lambda = 0.15;
param.iter = 100;

% Compute descriptor bases
fprintf('Computing descriptor bases...\n');
param.K = descriptorBases;
Bd = mexTrainDL_Memory(Xd, param);

% Compute color bases
fprintf('Computing color bases...\n');
param.K = colorBases;
Bc = mexTrainDL_Memory(Xc, param);

end

