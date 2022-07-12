%% plots PSC as "spagheti plot" for each group
%
%
% (C) Copyright 2022 Remi Gau

% TODO "regular" contrasts for visual and posterior ROIs

%% Model 3 : visual, auditory, hand regions

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

roi_names = {'V1', ...
             'V2', ...
             'V3', ...
             'hV4', ...
             'VO1', ...
             'VO2', ...
             'LO1', ...
             'LO2'};

opt.roi.name = {['^space-.*(', strjoin(roi_names, '|') ')']};
roi_list = getROIs(opt);

input_file = fullfile(opt.dir.stats, 'derivatives', 'cpp_spm-groupStats', 'group_model-3_psc.tsv');

close all;

% plot_psc(opt, roi_list, input_file); % TODO
plot_identification(opt, roi_list, input_file);
plot_localization(opt, roi_list, input_file);

%% Model 1 : olfactory regions

clc;
clear;

run ../../initEnv.m;

opt.pipeline.type = 'stats';

opt = opt_dir(opt);
opt = get_options(opt);

opt.verbosity = 2;
opt.glm.roibased.do = true;
opt.fwhm.func =  0;

opt.bidsFilterFile.roi.space = 'MNI';

roi_names = {'Broadmann28Ento'
             'Broadmann34Piriform'
             'Hippocampus'
             'Insula'
             'OFCant'
             'OFClat'
             'OFCmed'
             'OFCpost'};

opt.roi.name = {['^.*space-.*(', strjoin(roi_names, '|') ')']};
roi_list = getROIs(opt);

input_file = fullfile(opt.dir.stats, 'derivatives', 'cpp_spm-groupStats', 'group_model-1_psc.tsv');

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
