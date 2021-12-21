% (C) Copyright 2019 Remi Gau

clear;
clc;

run ../../initEnv.m;

opt = opt_stats_subject_level();

bidsFFX('specifyAndEstimate', opt);

bidsFFX('contrasts', opt);

bidsResults(opt);

% FOR INFO: old contrasts computed previously
% contrast_ls = {
%     'Alm-Left + Alm-Right > 0'
%     'Euc-Left + Euc-Right > 0'
%     'Euc-Right + Alm-Right > 0'
%     'Euc-Left + Alm-Left > 0'
%     'Euc-Left > 0'
%     'Alm-Left > 0'
%     'Euc-Right > 0'
%     'Alm-Right > 0'
