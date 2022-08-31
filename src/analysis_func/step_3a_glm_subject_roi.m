%
% Runs ROI level GLM
%
% (C) Copyright 2021 Remi Gau

%% Olfactory and frontal regions use default model (number 1)

close all;
clear;
clc;

run ../../initEnv.m;

opt = opt_stats_subject_level();

opt.glm.roibased.do = true;
opt.fwhm.func =  0;

opt.bidsFilterFile.roi.space = {'MNI'};

opt.verbosity = 0;

opt.model.file = fullfile(fileparts(mfilename('fullpath')), ...
                          'models', ...
                          'model-default_smdl.json');

opt.model.bm = BidsModel('file', opt.model.file);

opt.space = opt.model.bm.Input.space;
opt.taskName = opt.model.bm.Input.task;

% ROIs = {'Broadmann28Ento'
%             'Broadmann34Piriform'
%             'Hippocampus'
%             'Insula'
%             'OFCant'
%             'OFClat'
%             'OFCmed'
%             'OFCpost'};
%

ROIs = {'ACC'
        'Thalamus'
        'Amygdala'};

opt.roi.name = {['^.*space-.*(', strjoin(ROIs, '|') ')']};

% to check
roiList = getROIs(opt);

%
% bidsFFX('specify', opt);
bidsRoiBasedGLM(opt);

return

%% All other regions use model 3

close all;
clear;
clc;

run ../../initEnv.m;

opt = opt_stats_subject_level();

opt.glm.roibased.do = true;
opt.fwhm.func =  0;

opt.bidsFilterFile.roi.space = {'MNI'};

opt.verbosity = 0;

opt.model.file = fullfile(fileparts(mfilename('fullpath')), ...
                          'models', ...
                          'model-TissueConfounds_smdl.json');

% ROIs = {'V1'
%             'V2'
%             'V3'
%             'hV4'
%             'hMT'
%             'VO1'
%             'VO2'
%             'LO2'
%             'LO1'
%             'auditory'
%             'hand'};

ROIs = {'S1'
        'IPS'
        'pons'
        'midbrain'};

opt.roi.name = {['^.*space-.*(', strjoin(ROIs, '|') ')']};

% to check
roiList = getROIs(opt);

% bidsFFX('specify', opt);
bidsRoiBasedGLM(opt);
