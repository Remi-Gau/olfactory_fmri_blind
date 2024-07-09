function plot_psc(opt, roi_list, input_file, contrasts, xTickLabel)
  %
  % (C) Copyright 2022 Remi Gau

  if nargin < 4
    contrasts = {'all_olfid', 'all_olfloc'};
    xTickLabel = {'identification', 'localization'};
  end

  group_tsv = bids.util.tsvread(input_file);

  output_dir = fullfile(fileparts(input_file), 'figures');
  spm_mkdir(output_dir);

  colors(1, :) = opt.blnd_color;
  colors(2, :) = opt.sighted_color;
  if isfield(opt, 'merge_cols') && opt.merge_cols
    colors = {};
    colors{1} = opt.blnd_color;
    colors{2} = opt.sighted_color;
  end

  groups = {'blind', 'control'};

  yLabel = {'percent signal change', ''};

  opt = set_defaults(opt);

  for i_roi = 1:numel(roi_list)

    main_title = set_main_title(opt, roi_list, i_roi);

    columns = fieldnames(group_tsv);
    for i = 1:numel(columns)
      data_to_save.(columns{i}) = [];
    end

    bf = bids.File(roi_list{i_roi});
    [data, data_to_save] = get_data_to_plot(groups, contrasts, group_tsv, bf);

    yMin = min(min(cellfun(@(x) min(x(:)), data)));
    yMax = max(max(cellfun(@(x) max(x(:)), data)));

    figure('name', main_title, ...
           'position', [50 50 1300 700], ...
           'visible', opt.visible);

    i_subplot = 1;

    if isfield(opt, 'merge_cols') && opt.merge_cols

      tmp_data = {};

      for row = 1:size(data, 1)
        tmp_data_row = [];
        for col = 1:size(data, 2)
          tmp_data_row(:, col) = data{row, col}; %#ok<*AGROW>
        end
        tmp_data{row, 1} = tmp_data_row;
      end

      data = tmp_data;
    end

    for row = 1:size(data, 1)

      for col = 1:size(data, 2)

        subplot(size(data, 1), size(data, 2), i_subplot);

        subplot_title = '';
        if row == 1 && opt.add_subplot_title
          subplot_title = groups{col};
        end

        data_to_plot = data{row, col};
        colors_to_use = colors(:, col);
        xLabel = 'conditions';

        if isfield(opt, 'merge_cols') && opt.merge_cols
          colors_to_use = colors;
          xLabel = '';
        end

        spaghetti_plot(data_to_plot, ...
                       'spaghetti', opt.spaghetti, ...
                       'fontSize', 10, ...
                       'xTickLabel', xTickLabel(row, :), ...
                       'xLabel', xLabel, ...
                       'yLabel', yLabel{col}, ...
                       'yMin', yMin, ...
                       'yMax', yMax, ...
                       'title', subplot_title, ...
                       'markerSize', 8, ...
                       'color', colors_to_use, ...
                       'dispersion_estimator', opt.dispersion_estimator);

        i_subplot = i_subplot + 1;

      end

    end

    save_figure_and_data(output_dir, main_title, data_to_save);

  end

end

function opt = set_defaults(opt)

  opt.visible = 'off';
  if  opt.verbosity > 0 && ~spm_get_defaults('cmdline')
    opt.visible = 'on';
  end

  if ~isfield(opt, 'spaghetti')
    opt.spaghetti = true;
  end

  if ~isfield(opt, 'add_subplot_title')
    opt.add_subplot_title = true;
  end

end

function [data, data_to_save] = get_data_to_plot(groups, contrasts, group_tsv, bf)

  roi_filter = strcmp(group_tsv.roi, bf.entities.label);

  hemi_filter = strcmp(group_tsv.hemi, 'NaN');
  if isfield(bf.entities, 'hemi')
    hemi_filter = strcmp(group_tsv.hemi, bf.entities.hemi);
  end

  desc_filter = true(size(group_tsv.desc));
  if isfield(bf.entities, 'desc')
    desc_filter = strcmp(group_tsv.desc, bf.entities.desc);
  end

  data = [];

  columns = fieldnames(group_tsv);
  for i = 1:numel(columns)
    data_to_save.(columns{i}) = [];
  end

  for i_group = 1:numel(groups)

    for row = 1:size(contrasts, 1)

      for col = 1:size(contrasts, 2)

        con_filter = strcmp(group_tsv.contrast, contrasts{row, col});

        group_filter = strcmp(group_tsv.group, groups{i_group});

        filter = all([roi_filter, hemi_filter, desc_filter, group_filter, con_filter], 2);

        data{row, i_group}(:, col) = group_tsv.psc_abs_max(filter, 1); %#ok<*SAGROW>

        for i = 1:numel(columns)
          data_to_save.(columns{i}) = cat(1, ...
                                          data_to_save.(columns{i}), ...
                                          group_tsv.(columns{i})(filter, 1));
        end

      end

    end

  end
end

function main_title = set_main_title(opt, roi_list, i_roi)

  if isfield(opt, 'main_titles')
    main_titles = opt.main_titles;
    assert(numel(main_titles) == numel(roi_list));
    main_title = main_titles{i_roi};
    return
  end

  bf = bids.File(roi_list{i_roi});

  main_title = ['label-' bf.entities.label];

  main_title_prefix = '';
  if isfield(opt, 'main_title_prefix')
    main_title_prefix = opt.main_title_prefix;
  end
  if ~isempty(main_title_prefix)
    main_title = [main_title_prefix ' - ' main_title];
  end

  if isfield(bf.entities, 'hemi')
    main_title = [main_title ' - hemi-' bf.entities.hemi];
  end

  if isfield(bf.entities, 'desc')
    main_title = [main_title ' - desc-' bf.entities.desc];
  end
end
