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

roi_list = {'Broadmann28Ento'
            'Broadmann34Piriform'
            'Hippocampus'
            'Insula'
            'OFCant'
            'OFClat'
            'OFCmed'
            'OFCpost'};

opt.roi.name = {['^.*space-.*(', strjoin(roi_list, '|') ')']};

% to check
roiList = getROIs(opt);

%
% bidsFFX('specify', opt);
bidsRoiBasedGLM(opt);

return

%% to recompile the results without recomputing them
eventSpec = struct('name', {'olfid_eucalyptus_left'
                            'olfid_eucalyptus_right'
                            'olfid_almond_left'
                            'olfid_almond_right'
                            'olfloc_eucalyptus_left'
                            'olfloc_eucalyptus_right'
                            'olfloc_almond_left'
                            'olfloc_almond_right'
                            'Responses'
                            'all_olfid'
                            'all_olfloc'
                            'all_olf'});

for iSub = 1:numel(opt.subjects)
  saveRoiGlmSummaryTable(opt, opt.subjects{iSub}, roiList, eventSpec);
end

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

opt.verbosity = 2;

opt.model.file = fullfile(fileparts(mfilename('fullpath')), ...
                          'models', ...
                          'model-TissueConfounds_smdl.json');

roi_list = {'V1', ...
            'V2', ...
            'V3', ...
            'hV4', ...
            'hMT', ...
            'VO1', ...
            'VO2', ...
            'LO2', ...
            'LO1', ...
            'auditory', ...
            'hand'};

opt.roi.name = {['^.*space-.*(', strjoin(roi_list, '|') ')']};

% to check
% roiList = getROIs(opt);

% bidsFFX('specify', opt);
bidsRoiBasedGLM(opt);

return
