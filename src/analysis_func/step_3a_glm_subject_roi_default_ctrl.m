%
% Runs ROI level GLM
%
% (C) Copyright 2021 Remi Gau

warning('off', 'getEventSpecificationRoiGlm:notImplemented');
warning('off', 'convertOnsetTsvToMat:trialTypeNotFound');

close all;
clear;
clc;

run ../../initEnv.m;

opt.subjects = {'ctrl.*'};
model = 'default';
hemi = '.*';

switch model

  case 'TissueConfounds'

    % All other regions use model 3

    ROIs = {'V1'
            'V2'
            'V3'
            'hV4'
            'hMT'
            'VO1'
            'VO2'
            'LO2'
            'LO1'
            'auditory'
            'hand'
            'S1'
            'IPS'
            'pons'
            'midbrain'};

  case 'default'

    % Olfactory and frontal regions use default model (number 1)

    ROIs = {'Broadmann28Ento'
            'Broadmann34Piriform'
            'Hippocampus'
            'Insula'
            'OFCant'
            'OFClat'
            'OFCmed'
            'OFCpost'
            'ACC'
            'Thalamus'
            'Amygdala'};

end

opt = opt_stats_subject_level(opt);
disp(opt.subjects);

opt.glm.roibased.do = true;
opt.fwhm.func =  0;

opt.bidsFilterFile.roi.space = {'MNI'};

opt.verbosity = 0;

opt.model.file = fullfile(fileparts(mfilename('fullpath')), ...
                          'models', ...
                          ['model-', model, '_smdl.json']);

opt.model.bm = BidsModel('file', opt.model.file);

if strcmp(model, 'default')

  opt.space = opt.model.bm.Input.space;
  opt.taskName = opt.model.bm.Input.task;

end

% bidsFFX('specify', opt);

opt.roi.name = {['^' hemi 'space-.*(', strjoin(ROIs, '|') ')']};
roiList = getROIs(opt);
disp(roiList);

skipped = bidsRoiBasedGLM(opt);

save(fullfile(pwd, 'skipped_ctrl_default.mat'), 'skipped');
