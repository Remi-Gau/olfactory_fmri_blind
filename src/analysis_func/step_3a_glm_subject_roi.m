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

opt.subjects = {'.*'};
model = 'default';
% model = 'TissueConfounds';

hemi = '.*';

ROIs = return_rois(model);

opt = opt_stats_subject_level(opt);

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
roi_list = getROIs(opt);
disp(roi_list);

skipped = bidsRoiBasedGLM(opt);

save(fullfile(pwd, 'skipped_ctrl_TissueConfounds.mat'), 'skipped');
