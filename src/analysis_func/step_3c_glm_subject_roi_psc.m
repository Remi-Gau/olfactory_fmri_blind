% Collects percent signal change for each:
%
% - ROI
% - subject
% - contrast
%
% and save the collected data in a TSV
%
% (C) Copyright 2021 Remi Gau

% Warning: No data for sub-ctrl11 / roi V1

%% Model 3 : visual, auditory, hand regions

clc;
clear;

run ../../initEnv.m;

opt = opt_stats_subject_level();

opt.fwhm.func =  0;

opt.glm.roibased.do = true;

opt.verbosity = 2;

opt.pipeline.type = 'stats';

opt.bidsFilterFile.roi.space = 'MNI';

for i = 1:numel(opt.results.name)
  contrasts(i).name = opt.results.name{i}; %#ok<*SAGROW>
end

opt.model.bm = BidsModel('file', opt.model.file);

opt.space = opt.model.bm.Input.space;
opt.taskName = opt.model.bm.Input.task;

ROIs = {'V1', ...
        'V2', ...
        'V3', ...
        'hV4', ...
        'hMT', ...
        'VO1', ...
        'VO2', ...
        'LO2', ...
        'LO1', ...
        'auditory', ...
        'hand', ...
        'S1', ...
        'IPS', ...
        'pons', ...
        'midbrain'};

opt.roi.name = {['^.*space-.*(', strjoin(ROIs, '|') ')']};
roi_list = getROIs(opt);

output_file = fullfile(opt.dir.stats, 'derivatives', 'bidspm-groupStats', 'group_model-3_psc.tsv');

%
collect_psc(opt, contrasts, roi_list, output_file);

return

%% Model 1 : olfactory regions

% missing results
%
% Broadmann34Piriform
%
% sub-blnd05
% sub-blnd13
% sub-blnd14
% sub-blnd17
% sub-ctrl03
% sub-ctrl09
% sub-ctrl18
%
%
% OFCpost
%
% sub-blnd06
%
%
% ThalamusMDm
%   blnd 05
%
% ACCsup
%   blnd 09
%
% ThalamusMDl
%   blnd16
%   ctrl02
%
% ThalamusMD
%   ctrl11

clc;
clear;

run ../../initEnv.m;

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
                          'model-default_smdl.json');

opt.model.bm = BidsModel('file', opt.model.file);

opt.space = opt.model.bm.Input.space;
opt.taskName = opt.model.bm.Input.task;

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

opt.roi.name = {['^.*space-.*(', strjoin(ROIs, '|') ')']};
roi_list = getROIs(opt);

output_file = fullfile(opt.dir.stats, 'derivatives', 'bidspm-groupStats', 'group_model-1_psc.tsv');

collect_psc(opt, contrasts, roi_list, output_file);

return
