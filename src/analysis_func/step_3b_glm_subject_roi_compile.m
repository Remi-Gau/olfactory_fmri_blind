%% to recompile the results without recomputing them
%
% (C) Copyright 2022 Remi Gau

close all;
clear;
clc;

run ../../initEnv.m;

model = 'TissueConfounds'; % Model 3 : visual, auditory, hand regions
% model = 'default'; % Model 1 : olfactory regions

opt = opt_stats_subject_level();

opt.glm.roibased.do = true;
opt.fwhm.func =  0;

opt.bidsFilterFile.roi.space = {'MNI'};

opt.verbosity = 1;

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

opt.model.file = fullfile(fileparts(mfilename('fullpath')), ...
                          'models', ...
                          ['model-' model '_smdl.json']);
opt.model.bm = BidsModel('file', opt.model.file);
opt.space = opt.model.bm.Input.space;
opt.taskName = opt.model.bm.Input.task;

ROIs = return_rois(model);

opt.roi.name = {['^.*space-.*(', strjoin(ROIs, '|') ')']};

roiList = getROIs(opt);

for iSub = 1:numel(opt.subjects)
  saveRoiGlmSummaryTable(opt, opt.subjects{iSub}, roiList, eventSpec);
end
