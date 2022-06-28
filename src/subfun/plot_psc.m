function plot_psc(opt, roi_list, input_file, contrasts, xTickLabel)
  %
  % (C) Copyright 2022 Remi Gau

  if nargin < 4
    contrasts = {'all_olfid', 'all_olfloc'};
    xTickLabel = {'identification', 'localization'};
  end

  group_tsv = bids.util.tsvread(input_file);

  Colors(1, :) = opt.blnd_color;
  Colors(2, :) = opt.sighted_color;

  groups = {'blind', 'control'};

  yLabel = {'percent signal change', ''};

  for i_roi = 1:numel(roi_list)

    data = [];

    bf = bids.File(roi_list{i_roi});

    roi_filter = strcmp(group_tsv.roi, bf.entities.label);

    main_title = bf.entities.label;

    if isfield(bf.entities, 'hemi')
      main_title = [main_title ' - hemi: ' bf.entities.hemi];
      hemi_filter = strcmp(group_tsv.hemi, bf.entities.hemi);
    else
      hemi_filter = strcmp(group_tsv.hemi, 'NaN');
    end

    if isfield(bf.entities, 'desc')
      main_title = [main_title ' - ' bf.entities.desc];
      desc_filter = strcmp(group_tsv.desc, bf.entities.desc);
    else
      desc_filter = true(size(group_tsv.desc));
    end

    figure('name', 'Both tasks', 'position', [50 50 1300 700], 'visible', 'on');

    for i_group = 1:numel(groups)

      for row = 1:size(contrasts, 1)

        for col = 1:size(contrasts, 2)

          con_filter = strcmp(group_tsv.contrast, contrasts{row, col});

          group_filter = strcmp(group_tsv.group, groups{i_group});

          filter = all([roi_filter, hemi_filter, desc_filter, group_filter, con_filter], 2);

          data{row, i_group}(:, col) = group_tsv.psc_abs_max(filter, 1); %#ok<*SAGROW>

        end

      end

    end

    yMin = min(min(cellfun(@(x) min(x(:)), data)));
    yMax = max(max(cellfun(@(x) max(x(:)), data)));

    i_subplot = 1;

    for row = 1:size(data, 1)

      for col = 1:size(data, 2)

        subplot(size(data, 1), size(data, 2), i_subplot);

        if row == 1
          subplot_title = groups{col};
        else
          subplot_title = '';
        end

        spaghetti_plot(data{row, col}, ...
                       'spaghetti', true, ...
                       'fontSize', 10, ...
                       'xTickLabel', xTickLabel(row, :), ...
                       'xLabel', 'conditions', ...
                       'yLabel', yLabel{col}, ...
                       'yMin', yMin, ...
                       'yMax', yMax, ...
                       'title', subplot_title, ...
                       'markerSize', 8, ...
                       'color', Colors(col, :));

        i_subplot = i_subplot + 1;

      end

    end

    mtit(sprintf('ROI: %s', main_title), ...
         'fontsize', 16, ...
         'xoff', 0, ...
         'yoff', 0.04);

  end

end
