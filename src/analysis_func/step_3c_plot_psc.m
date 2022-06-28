%% plots PSC as "spagheti plot" for each group
%
%
% (C) Copyright 2022 Remi Gau

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
             'auditory', ...
             'hand'};

opt.roi.name = {['^space-.*(', strjoin(roi_names, '|') ')']};
roi_list = getROIs(opt);

input_file = fullfile(opt.dir.stats, 'derivatives', 'cpp_spm-groupStats', 'group_model-3_psc.tsv');

plot_psc(opt, roi_list, input_file);

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

roi_names = {'olfactory.*GM', ...
             'Orbitofrontal'};

opt.roi.name = {['^.*space-.*(', strjoin(roi_names, '|') ')']};
roi_list = getROIs(opt);

input_file = fullfile(opt.dir.stats, 'derivatives', 'cpp_spm-groupStats', 'group_model-1_psc.tsv');

%%

close all;

% contrasts = {'all_olfid', 'all_olfloc'};
% xTickLabel = {'identification', 'localization'};

%
contrasts = {'olfid_eucalyptus_left',  'olfid_almond_left'
             'olfid_eucalyptus_right', 'olfid_almond_right'};
xTickLabel = {'id - euc - left',       'id - alm - left'
              'id - euc - right',      'id - alm - right'};

plot_psc(opt, roi_list, input_file, contrasts, xTickLabel);

%
contrasts = {'olfloc_eucalyptus_left',  'olfloc_eucalyptus_right'
             'olfid_almond_left',       'olfloc_almond_right'};
xTickLabel = {'loc - euc - left',       'loc - euc - right'
              'loc - alm - left',       'loc - alm - right'};

plot_psc(opt, roi_list, input_file, contrasts, xTickLabel);
