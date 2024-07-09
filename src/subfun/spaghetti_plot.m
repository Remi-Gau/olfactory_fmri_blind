function spaghetti_plot(varargin)
  %
  % Plots distributions side by side. The spaghetti plot can be used to plot
  % paired data.
  %
  % USAGE::
  %
  % spaghetti_plot(data, ...
  %               'spaghetti', true, ...
  %               'fontSize', 12, ...
  %               'xTickLabel', 1:2, ...
  %               'xLabel', 'x label', ...
  %               'yLabel', 'y label', ...
  %               'yMin', [], ...
  %               'yMax', [], ...
  %               'title', 'TITLE', ...
  %               'markerSize', 5, ...
  %               'color', [0 0 255]);
  %
  %
  % :param data: Data to plot. If number of colums <= 2 the mean of each column
  %              will be plotted.
  % :type data: n X m numeric data
  %
  % :param spaghetti: To use spaghetti plot or just a side by side scatter plot.
  %                   If ``false``, it requires ``shadedErrorBar`` from Matlab
  %                   Exhange.
  % :type spaghetti: logical
  %
  % :param fontSize: Default to 12
  % :type fontSize: numeric
  %
  % :param xTickLabel: Default to ``[1 2]``
  % :type xTickLabel:
  %
  % :param xLabel: defaults to ``'x label'``
  % :type xLabel: char
  %
  % :param yLabel: defaults to ``'y label'``
  % :type yLabel: char
  %
  % :param yMin: defaults to ``[]`` and will be adapted to the data
  % :type yMin: scalar
  %
  % :param yMax: defaults to ``[]`` and will be adapted to the data
  % :type yMax: scalar
  %
  % :param title: defaults to ``'TITLE'``
  % :type title: char
  %
  % :param markerSize: Default to 5
  % :type markerSize: numeric
  %
  % :param color: Defaults to ``'b'``
  % :type color:
  %
  %
  % (C) Copyright 2022 Remi Gau

  args = inputParser;
  args.CaseSensitive = false;

  addOptional(args, 'data', [], @isnumeric);
  addParameter(args, 'spaghetti', true, @islogical);
  addParameter(args, 'fontSize', 12, @isnumeric);
  addParameter(args, 'xTickLabel', 1:2);
  addParameter(args, 'xLabel', 'x label', @ischar);
  addParameter(args, 'yLabel', 'y label', @ischar);
  addParameter(args, 'yMin', [], @isnumeric);
  addParameter(args, 'yMax', [], @isnumeric);
  addParameter(args, 'title', 'TITLE', @ischar);
  addParameter(args, 'markerSize', 5, @isnumeric);
  addParameter(args, 'color', [0 0 255]);
  addParameter(args, 'dispersion_estimator', 'std', @ischar);

  parse(args, varargin{:});

  data = args.Results.data;
  spaghetti = args.Results.spaghetti;
  fontSize = args.Results.fontSize;
  markerSize = args.Results.markerSize;
  dispersion_estimator = args.Results.dispersion_estimator;

  % dummy data for standalone testing
  if isempty(data)

    close all;

    figure;

    data = randn(30, 1);
    data(:, 2) = data + randn * 0.4 + randn(30, 1) * 0.4;

  end

  % any line with a nan is skipped;
  rows_to_keep = all(~isnan(data), 2);
  data = data(rows_to_keep, :);
  if isempty(data)
    error('no data left after cleaning');
  end

  %%
  nb_cols = size(data, 2);

  yMin = get_yMin(args, data);
  yMax = get_yMax(args, data);
  range = yMax - yMin;

  x_values_for_data = 1:nb_cols;
  xMin = 0.6;
  xMax = nb_cols + 0.4;

  if nb_cols <= 2
    x_values_for_mean = [1, 2];
    x_values_for_data = [1.3, 1.7];
    xMin = x_values_for_mean(1) - 0.2;
    xMax = x_values_for_mean(nb_cols) + 0.2;
  end

  if nb_cols == 1
    spaghetti = false;
    xMax = 1.6;
  end

  %%
  hold on;

  plot([0 nb_cols + 1], [0 0], 'k');

  for i_col = 1:nb_cols

    to_plot = data(:, i_col);

    color_to_use = get_color(args, i_col);

    if ~spaghetti
      h = plotSpread(to_plot, 'distributionIdx', ones(1, numel(to_plot)), ...
                     'distributionMarkers', {'o'}, ...
                     'distributionColors', color_to_use, ...
                     'xValues', x_values_for_data(i_col), ...
                     'showMM', 0, ...
                     'binWidth', range * 0.2, ...
                     'spreadWidth', 0.5);

      set(h{1}, ...
          'markerSize', markerSize, ...
          'MarkerEdgeColor', 'k', ...
          'MarkerFaceColor', color_to_use, ...
          'LineWidth', 2);

    end

    % plot means
    if nb_cols <= 2

      dispersion = std(to_plot, 'omitnan');
      switch dispersion_estimator
        case 'sem'
          dispersion = dispersion / (sum(~isnan(to_plot)))^0.5;
        case 'ci'
          ci = spm_invNcdf(1 - 0.05);
          dispersion = ci * dispersion / (sum(~isnan(to_plot)))^0.5;
      end

      errorbar(x_values_for_mean(i_col), ...
               mean(to_plot, 'omitnan'), ...
               dispersion, ...
               'o', ...
               'color', color_to_use, ...
               'linewidth', 2, ...
               'markerSize', markerSize * 1.5, ...
               'MarkerEdgeColor', 'k', ...
               'MarkerFaceColor', color_to_use);

    end

  end

  set_sphagetti_lines(spaghetti, color_to_use, x_values_for_data, data, markerSize);

  axis([xMin, xMax,  yMin, yMax]);

  abs_max = round(max(abs([yMin yMax])) * 100);
  yTickLabel = round(-2 * abs_max:abs_max / 6:abs_max * 2) / 100;

  xTickLabel = get_xTickLabel(args);

  set(gca, ...
      'fontSize', fontSize, ...
      'ytick', yTickLabel, 'yTickLabel', yTickLabel, ...
      'xtick', 1:nb_cols, 'xTickLabel', xTickLabel, ...
      'tickLength', [.02 .02], ...
      'tickDir', 'out');

  t = xlabel(args.Results.xLabel);
  set(t, 'fontSize', fontSize + 2);
  t = ylabel(args.Results.yLabel);
  set(t, 'fontSize', fontSize + 2);

  if ~isempty(args.Results.title)
    n = size(data, 1);
    t = title(sprintf('%s (n=%i)', ...
                      args.Results.title, ...
                      n));
    set(t, 'fontSize', fontSize + 4);
  end

end

function color = get_color(args, i_col)
  color = args.Results.color;
  if isnumeric(color)
    color = color / 255;
    return
  end

  if iscell(color)
    for i = 1:numel(color)
      color{i} = color{i} / 255;
    end
    color = color{i_col};
    return
  end

  error('color must be numeric or cell');
end

function yMin = get_yMin(args, data)
  yMin = args.Results.yMin;
  if isempty(yMin)
    yMin = min(data(:)) * 1.2;
  end
  if yMin > 0
    yMin = 0;
  end
end

function yMax = get_yMax(args, data)
  yMax = args.Results.yMax;
  if isempty(yMax)
    yMax = max(data(:)) * 1.2;
  end
  if yMax  < 0
    yMax = 0;
  end
end

function set_sphagetti_lines(spaghetti, color, x_values_for_data, data, markerSize)
  if spaghetti
    lineColor = color * 1.3;
    lineColor(lineColor > 1) = 1;
    h = plot(x_values_for_data, data, 'o-');
    for i = 1:numel(h)
      set(h(i), ...
          'color', lineColor, ...
          'linewidth', 1, ...
          'MarkerSize', markerSize, ...
          'MarkerEdgeColor', 'k', ...
          'MarkerFaceColor', color);
    end
  end
end

function xTickLabel = get_xTickLabel(args)
  xTickLabel = args.Results.xTickLabel;
  if isnumeric(xTickLabel)
    xTickLabel = num2cell(xTickLabel);
    xTickLabel = cellfun(@(x) num2str(x), xTickLabel, 'UniformOutput', false);
  end
  xTickLabel = strrep(xTickLabel, '_', ' ');
end
