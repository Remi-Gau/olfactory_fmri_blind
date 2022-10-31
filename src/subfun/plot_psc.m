function plot_psc(opt, roi_list, input_file, contrasts, xTickLabel, main_title_prefix)
  %
  % (C) Copyright 2022 Remi Gau

  if nargin < 4
    contrasts = {'all_olfid', 'all_olfloc'};
    xTickLabel = {'identification', 'localization'};
  end
  if nargin < 6
    main_title_prefix = '';
  end

  group_tsv = bids.util.tsvread(input_file);

  output_dir = fullfile(fileparts(input_file), 'figures');
  spm_mkdir(output_dir);

  Colors(1, :) = opt.blnd_color;
  Colors(2, :) = opt.sighted_color;

  groups = {'blind', 'control'};

  yLabel = {'percent signal change', ''};

  visible = 'off';
  if  opt.verbosity > 0 && ~spm_get_defaults('cmdline')
    visible = 'on';
  end

  for i_roi = 1:numel(roi_list)

    data = [];

    bf = bids.File(roi_list{i_roi});

    roi_filter = strcmp(group_tsv.roi, bf.entities.label);

    if isempty(main_title_prefix)
      main_title = ['label-' bf.entities.label];
    else
      main_title = [main_title_prefix ' - label-' bf.entities.label];
    end
    if isfield(bf.entities, 'hemi')
      main_title = [main_title ' - hemi-' bf.entities.hemi];
      hemi_filter = strcmp(group_tsv.hemi, bf.entities.hemi);
    else
      hemi_filter = strcmp(group_tsv.hemi, 'NaN');
    end

    if isfield(bf.entities, 'desc')
      main_title = [main_title ' - desc-' bf.entities.desc];
      desc_filter = strcmp(group_tsv.desc, bf.entities.desc);
    else
      desc_filter = true(size(group_tsv.desc));
    end

    columns = fieldnames(group_tsv);
    for i = 1:numel(columns)
      data_to_save.(columns{i}) = [];
    end

    figure('name', main_title, ...
           'position', [50 50 1300 700], ...
           'visible', visible);

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

    mtit(sprintf('%s', main_title), ...
         'fontsize', 16, ...
         'xoff', 0, ...
         'yoff', 0.04);

    output_file = fullfile(output_dir, [strrep(main_title, ' - ', '_'), '.png']);
    print(gcf, '-dpng', output_file);
    output_file = fullfile(output_dir, [strrep(main_title, ' - ', '_'), '.svg']);
    print(gcf, '-dsvg', output_file);
    output_file = fullfile(output_dir, [strrep(main_title, ' - ', '_'), '.tsv']);
    bids.util.tsvwrite(output_file, data_to_save);

  end

end
