%% crash test
%
%
% (C) Copyright 2022 Remi Gau

clear;

run ../../initEnv.m;

roi_names = {'V1', ...
             'V2', ...
             'V3', ...
             'hV4', ...
             'VO1', ...
             'VO2', ...
             'auditory', ...
             'olfactory', ...
             'hand'};

groups = {'blind', 'control'};

opt.pipeline.type = 'stats';

opt = opt_dir(opt);
opt = get_options(opt);

opt.bidsFilterFile.roi.space = 'MNI';
opt.roi.name = {['^space-.*(', strjoin(roi_names, '|') ')']};
roi_list = getROIs(opt);

opt.verbosity = 2;
opt.glm.roibased.do = true;
opt.fwhm.func =  0;

Colors(1, :) = opt.blnd_color;
Colors(2, :) = opt.sighted_color;

contrasts = {'all_olfid', 'all_olfloc'};

participants_tsv = bids.util.tsvread(fullfile(opt.dir.raw, 'participants.tsv'));

input_file = fullfile(opt.dir.stats, 'derivatives', 'cpp_spm-groupStats', 'group_psc.tsv');

group_tsv = bids.util.tsvread(input_file);

%%
clc;
close all;

yLabel = {'percent signal change', ''};

for i_roi = 1:numel(roi_list)

  data = [];

  bf = bids.File(roi_list{i_roi});

  roi_filter = strcmp(group_tsv.roi, bf.entities.label);

  main_title = bf.entities.label;
  if isfield(bf.entities, 'desc')
    main_title = [main_title ' - ' bf.entities.desc];
    desc_filter = strcmp(group_tsv.desc, bf.entities.desc);
  else
    desc_filter = true(size(group_tsv.desc));
  end

  figure('name', 'Both tasks', 'position', [50 50 1300 700], 'visible', 'on');

  for i_group = 1:2

    group_filter = strcmp(group_tsv.group, groups{i_group});

    for i_con = 1:numel(contrasts)
      con_filter = strcmp(group_tsv.contrast, contrasts{i_con});

      filter = all([roi_filter, desc_filter, group_filter, con_filter], 2);

      data{i_group}(:, i_con) = group_tsv.psc_abs_max(filter, 1); %#ok<*SAGROW>
    end

  end

  yMin = min(cellfun(@(x) min(x(:)), data));
  yMax = max(cellfun(@(x) max(x(:)), data));

  for i_group = 1:2

    subplot(1, 2, i_group);

    spaghetti_plot(data{i_group}, ...
                   'spaghetti', true, ...
                   'fontSize', 10, ...
                   'xTickLabel', contrasts, ...
                   'xLabel', 'conditions', ...
                   'yLabel', yLabel{i_group}, ...
                   'yMin', yMin, ...
                   'yMax', yMax, ...
                   'title', groups{i_group}, ...
                   'markerSize', 8, ...
                   'color', Colors(i_group, :));

  end

  mtit(sprintf('ROI: %s', main_title), ...
       'fontsize', 16, ...
       'xoff', 0, ...
       'yoff', 0.04);

end
