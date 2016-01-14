function [B, S, stat] = demo_fast_sc(opt_choice)
% opt_choice = 1: use epslion-L1 penalty
% opt_choice = 2: use L1 penalty

if ~exist('opt_choice', 'var')
    opt_choice = 1; 
end

% natural image data
load ../data/IMAGES.mat
X = getdata_imagearray(IMAGES, 14, 1000);

% sparse coding parameters
num_bases = 256;
beta = 0.4;
batch_size = 1000;
num_iters = 100;
if opt_choice==1
    sparsity_func= 'epsL1';
    epsilon = 0.01;
elseif opt_choice==2
    sparsity_func= 'L1';
    epsilon = [];
end

Binit = [];
fname_save = sprintf('../results/sc_%s_b%d_beta%g_%s', sparsity_func, num_bases, beta, datestr(now, 30));	

% run fast sparse coding
% win_size = [10 12 14 16];
% T = zeros(length(num_bases), 1);

% for i = 1:length(win_size)
%     t1 = tic;
%     X = getdata_imagearray(IMAGES, win_size(i), 1000);
[B, S, stat] = sparse_coding(X, num_bases, beta, sparsity_func, epsilon, num_iters, batch_size, fname_save, Binit);
%     T(i) = toc(t1);
% end
