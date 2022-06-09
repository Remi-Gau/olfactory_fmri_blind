%
% Runs ROI level GLM
%
% (C) Copyright 2021 Remi Gau

close all;
clear;
clc;

run ../../initEnv.m;

%%

opt = opt_stats_subject_level();

opt.glm.roibased.do = true;
opt.fwhm.func =  0;

opt.bidsFilterFile.roi.space = {'MNI'};

opt.verbosity = 2;

%% Olfactory and frontal regions use default model (number 1)

opt.model.file = fullfile(fileparts(mfilename('fullpath')), ...
                          'models', ...
                          'model-default_smdl.json');

opt.model.bm = BidsModel('file', opt.model.file);

roi_list = {'olfactory.*GM', ...
            'Orbitofrontal'};

opt.roi.name = {['^space-.*(', strjoin(roi_list, '|') ')']};

% to check
% roiList = getROIs(opt);

bidsFFX('specify', opt);
bidsRoiBasedGLM(opt);

%% All other regions use model 3

opt.model.file = fullfile(fileparts(mfilename('fullpath')), ...
                          'models', ...
                          'model-TissueConfounds_smdl.json');

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
            'hand'};

opt.roi.name = {['^space-.*(', strjoin(roi_list, '|') ')']};

% to check
% roiList = getROIs(opt);

bidsFFX('specify', opt);
bidsRoiBasedGLM(opt);
