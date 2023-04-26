%% plots PSC as "spagheti plot" for each group
%
%
% (C) Copyright 2022 Remi Gau

clc;
close all;
clear;

run ../../initEnv.m;

opt.pipeline.type = 'stats';

opt = opt_dir(opt);
opt = get_options(opt);

opt.verbosity = 0;
opt.glm.roibased.do = true;
opt.fwhm.func =  0;

opt.dispersion_estimator = 'ci'; % std sem

opt.bidsFilterFile.roi.space = 'MNI';

hemi = ''; % '.*'

only_rois_for_figure = true;

% roi for figures
rois_for_figure = {'Broadmann28Ento'
                   'Insula'
                   'Hippocampus'
                   'Thalamus'
                   'V2'
                   'V3'
                   'hV4'
                   'hMT'};

model = 'TissueConfounds'; % Model 3 : visual, auditory, hand regions
% model = 'default'; % Model 1 : olfactory regions

ROIs = return_rois(model);
disp('Found ROIs');
disp(ROIs);

if only_rois_for_figure
  rois_to_remove = ~ismember(ROIs, rois_for_figure);
  ROIs(rois_to_remove) = [];
end
disp('Keeping ROIs');
disp(ROIs);

opt.roi.name = {['^' hemi 'space-.*(', strjoin(ROIs, '|') ')']};
roi_list = getROIs(opt);
disp('ROIs list');
disp(roi_list);

input_dir = fullfile(opt.dir.stats, 'derivatives', 'bidspm-groupStats');

switch model
  case 'default'
    input_file =  fullfile(input_dir, 'group_model-1_psc.tsv');
  case 'TissueConfounds'
    input_file = fullfile(input_dir, 'group_model-3_psc.tsv');
end

if ~only_rois_for_figure
  plot_psc(opt, roi_list, input_file);
  close all;

  plot_identification(opt, roi_list, input_file);
  close all;

  plot_localization(opt, roi_list, input_file);
  close all;

else

  opt.main_title_prefix = '';
  opt.main_titles = return_main_titles(roi_list);

  if strcmp(model, 'TissueConfounds')
    contrasts = {'all_olfloc'};
    xTickLabel = {''};

    plot_psc(opt, roi_list, input_file, contrasts, xTickLabel);

  elseif  strcmp(model, 'default')
    contrasts = {'all_olfid'};
    xTickLabel = {''};
    plot_psc(opt, roi_list, input_file, contrasts, xTickLabel);

  end

end

%%
function plot_identification(opt, roi_list, input_file)
  contrasts = {'olfid_eucalyptus_left',  'olfid_almond_left'
               'olfid_eucalyptus_right', 'olfid_almond_right'};
  xTickLabel = {'id - euc - left',       'id - alm - left'
                'id - euc - right',      'id - alm - right'};

  opt.main_title_prefix = 'identification';
  plot_psc(opt, roi_list, input_file, contrasts, xTickLabel);
end

function plot_localization(opt, roi_list, input_file)
  contrasts = {'olfloc_eucalyptus_left',  'olfloc_eucalyptus_right'
               'olfid_almond_left',       'olfloc_almond_right'};
  xTickLabel = {'loc - euc - left',       'loc - euc - right'
                'loc - alm - left',       'loc - alm - right'};

  opt.main_title_prefix = 'localization';
  plot_psc(opt, roi_list, input_file, contrasts, xTickLabel);
end

function main_titles = return_main_titles(roi_list)

  main_titles = {};
  for i_roi = 1:numel(roi_list)
    bf = bids.File(roi_list{i_roi});
    switch bf.entities.label
      case 'Broadmann28Ento'
        main_titles{end + 1} = 'Entorhinal cortex'; %#ok<*AGROW>
      otherwise
        main_titles{end + 1} = bf.entities.label;
    end
  end

end
