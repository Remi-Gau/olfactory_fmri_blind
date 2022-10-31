%% plots PSC as "spagheti plot" for each group
%
%
% (C) Copyright 2022 Remi Gau

% TODO "regular" contrasts for visual and posterior ROIs

clc;
close all;
clear;

run ../../initEnv.m;

opt.pipeline.type = 'stats';

opt = opt_dir(opt);
opt = get_options(opt);

opt.verbosity = 2;
opt.glm.roibased.do = true;
opt.fwhm.func =  0;

opt.bidsFilterFile.roi.space = 'MNI';

model = 'TissueConfounds'; % Model 3 : visual, auditory, hand regions
% model = 'default'; % Model 1 : olfactory regions

ROIs = return_rois(model);

opt.roi.name = {['^.*space-.*(', strjoin(ROIs, '|') ')']};
roi_list = getROIs(opt);

input_dir = fullfile(opt.dir.stats, 'derivatives', 'bidspm-groupStats');

switch model
  case 'default'
    input_file =  fullfile(input_dir, 'group_model-1_psc.tsv');
  case 'TissueConfounds'
    input_file = fullfile(input_dir, 'group_model-3_psc.tsv');
end

close all;

plot_psc(opt, roi_list, input_file);
plot_identification(opt, roi_list, input_file);
plot_localization(opt, roi_list, input_file);

%%
function plot_identification(opt, roi_list, input_file)
  contrasts = {'olfid_eucalyptus_left',  'olfid_almond_left'
               'olfid_eucalyptus_right', 'olfid_almond_right'};
  xTickLabel = {'id - euc - left',       'id - alm - left'
                'id - euc - right',      'id - alm - right'};

  plot_psc(opt, roi_list, input_file, contrasts, xTickLabel, 'identification');
end

function plot_localization(opt, roi_list, input_file)
  contrasts = {'olfloc_eucalyptus_left',  'olfloc_eucalyptus_right'
               'olfid_almond_left',       'olfloc_almond_right'};
  xTickLabel = {'loc - euc - left',       'loc - euc - right'
                'loc - alm - left',       'loc - alm - right'};

  plot_psc(opt, roi_list, input_file, contrasts, xTickLabel, 'localization');
end
