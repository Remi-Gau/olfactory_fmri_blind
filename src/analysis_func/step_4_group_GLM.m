% (C) Copyright 2019 Remi Gau

clear;
clc;

run ../../initEnv.m;

opt = opt_stats_group_level();

% bidsRFX('meanAnatAndMask', opt);
bidsRFX('RFX', opt);
bidsResults(opt);


% TODO
% 2 samples ttest

% 
% %%
% contrast_ls = {
%                'Alm-Left + Alm-Right > 0'
%                'Euc-Left + Euc-Right > 0'
%                'Euc-Right + Alm-Right > 0'
%                'Euc-Left + Alm-Left > 0'
%                'Euc-Left > 0'
%                'Alm-Left > 0'
%                'Euc-Right > 0'
%                'Alm-Right > 0'