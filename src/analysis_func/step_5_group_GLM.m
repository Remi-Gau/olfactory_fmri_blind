% (C) Copyright 2019 Remi Gau

clear;
clc;

run ../../initEnv.m;

opt = opt_stats_group_level();

% bidsRFX('RFX', opt);

bidsResults(opt);


% TODO
% 2 samples ttest

% % contrast name / directory name / ROI for inclusive mask
% opt.ctrsts = { ...
%               'Euc-Left + Alm-Left + Euc-Right + Alm-Right > 0', 'all (in visual ROIS)', 'ROI-AllVisual_space-MNI.nii'; ...
%               'Euc-Left + Alm-Left + Euc-Right + Alm-Right > 0', 'all (in olfactory ROIS)', 'ROI-olfactory_Z_.1_k_10_space-MNI.nii'
%              };
% 
% %%
% contrast_ls = {
%                'Euc-Left + Alm-Left + Euc-Right + Alm-Right > 0'
%                'Euc-Left + Alm-Left + Euc-Right + Alm-Right < 0'
%                'Alm-Left + Alm-Right > 0'

%                'Euc-Left + Euc-Right > 0'
%                'Euc-Right + Alm-Right > 0'
%                'Euc-Right + Alm-Right < 0'
%                'Euc-Left + Alm-Left > 0'
%                'Euc-Left > 0'
%                'Alm-Left > 0'
%                'Euc-Right > 0'
%                'Alm-Right > 0'