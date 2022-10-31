% Collects percent signal change for each:
%
% - ROI
% - subject
% - contrast
%
% and save the collected data in a TSV
%
% (C) Copyright 2021 Remi Gau

clc;
clear;

run ../../initEnv.m;

model = 'TissueConfounds'; % Model 3 : visual, auditory, hand regions
% model = 'default'; % Model 1 : olfactory regions

opt = opt_stats_subject_level();

opt.fwhm.func =  0;

opt.glm.roibased.do = true;

opt.verbosity = 2;

opt.pipeline.type = 'stats';

opt.bidsFilterFile.roi.space = 'MNI';

for i = 1:numel(opt.results.name)
  contrasts(i).name = opt.results.name{i}; %#ok<*SAGROW>
end

opt.model.file = fullfile(fileparts(mfilename('fullpath')), ...
                          'models', ...
                          ['model-' model '_smdl.json']);
opt.model.bm = BidsModel('file', opt.model.file);
opt.space = opt.model.bm.Input.space;
opt.taskName = opt.model.bm.Input.task;

ROIs = return_rois(model);

opt.roi.name = {['^.*space-.*(', strjoin(ROIs, '|') ')']};
roi_list = getROIs(opt);
disp(roiList);

output_dir = fullfile(opt.dir.stats, 'derivatives', 'bidspm-groupStats');

switch model
  case 'default'
    output_file =  fullfile(output_dir, 'group_model-1_psc.tsv');
  case 'TissueConfounds'
    output_file = fullfile(output_dir, 'group_model-3_psc.tsv');
end

collect_psc(opt, contrasts, roi_list, output_file);
