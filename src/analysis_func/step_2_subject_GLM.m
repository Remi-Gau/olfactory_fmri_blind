% (C) Copyright 2019 Remi Gau

clear;
clc;

run ../../initEnv.m;

opt = opt_stats();

% bidsFFX('specifyAndEstimate', opt);
bidsFFX('contrasts', opt);

bidsResults(opt);


% FOR INFO: old contrasts computed previously
% contrast_ls = {
%     'Euc-Left + Alm-Left + Euc-Right + Alm-Right > 0'
%     'Euc-Left + Alm-Left + Euc-Right + Alm-Right < 0'
%     'Alm-Left + Alm-Right > 0'
%     'Alm-Left + Alm-Right < 0'
%     'Euc-Left + Euc-Right > 0'
%     'Euc-Left + Euc-Right < 0'
%     'Euc-Right + Alm-Right > 0'
%     'Euc-Right + Alm-Right < 0'
%     'Euc-Left + Alm-Left > 0'
%     'Euc-Left + Alm-Left < 0'
%     'Euc-Left > 0'
%     'Euc-Left < 0'
%     'Alm-Left > 0'
%     'Alm-Left < 0'
%     'Euc-Right > 0'
%     'Euc-Right < 0'
%     'Alm-Right > 0'
%     'Alm-Right < 0'
%     'resp-03 + resp-12 > 0'
%     'resp-03 + resp-12 < 0'};