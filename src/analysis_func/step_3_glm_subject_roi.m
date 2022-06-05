% (C) Copyright 2021 Remi Gau

% TODO
% adapt model depending the ROI
% most of the current one should be fine with the current model

close all;
clear;
clc;

run ../../initEnv.m;

opt = opt_stats_subject_level();

opt.glm.roibased.do = true;
opt.fwhm.func =  0;

opt.bidsFilterFile.roi.space = {'MNI'};

roi_list = {'V1', ...
            'V2', ...
            'V3', ...
            'hV4', ...
            'hMT', ...
            'MST', ...
            'VO1', ...
            'VO2', ...
            'LO2', ...
            'LO1', ...
            'auditory', ...
            'olfactory', ...
            'hand'};

roi_list = {'auditory.*GM', ...
            'olfactory.*GM', ...
            'hand.*GM'};

opt.roi.name = {['^space-.*(', strjoin(roi_list, '|') ')']};

roiList = getROIs(opt);

opt.verbosity = 2;

opt.subjects = {'blnd01'};

% bidsFFX('specify', opt);
bidsRoiBasedGLM(opt);
