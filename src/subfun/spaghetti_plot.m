function spaghetti_plot(varargin)
  %
  % Plots 2 distributions side by side. The spaghetti plot can be used to plot
  % paired data.
  %
  % USAGE::
  %
  % spaghetti_plot(data, ...
  %             'spaghetti', true, ...
  %             'fontSize', 12, ...
  %             'xTickLabel', 1:2, ...
  %             'xLabel', 'x label', ...
  %             'yLabel', 'y label', ...
  %             'title', 'TITLE', ...
  %             'markerSize', 5, ...
  %             'color', [0 0 255]);
  %
  %
  % :param data: data to plot
  % :type data: n X 2 numeric data
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

  x_values_for_mean = [0.6, 2.4];
  x_values_for_data = [1.1, 1.9];

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
  addParameter(args, 'color', [0 0 255], @isnumeric);

  parse(args, varargin{:});

  data = args.Results.data;
  spaghetti = args.Results.spaghetti;
  fontSize = args.Results.fontSize;
  markerSize = args.Results.markerSize;
  color = args.Results.color;

  color = color / 255;

  if isempty(data)

    close all;

    figure;

    data = randn(30, 1);
    data(:, 2) = data + randn * 0.4 + randn(30, 1) * 0.4;

  end

  yMin = args.Results.yMin;

  if isempty(yMin)
    yMin = min(data(:)) * 1.2;
  end
  if yMin > 0
    yMin = 0;
  end

  yMax = args.Results.yMax;
  if isempty(yMax)
    yMax = max(data(:)) * 1.2;
  end
  if yMax  < 0
    yMax = 0;
  end

  range = yMax - yMin;

  %%
  hold on;

  plot([0 3], [0 0], 'k');

  for i_col = 1:2

    to_plot = data(:, i_col);

    if ~spaghetti
      h = plotSpread(to_plot, 'distributionIdx', ones(1, numel(to_plot)), ...
                     'distributionMarkers', {'o'}, ...
                     'distributionColors', color, ...
                     'xValues', x_values_for_data(i_col), ...
                     'showMM', 0, ...
                     'binWidth', range * 0.2, ...
                     'spreadWidth', 0.5);

      set(h{1}, ...
          'markerSize', markerSize, ...
          'MarkerEdgeColor', 'k', ...
          'MarkerFaceColor', color, ...
          'LineWidth', 2);

    end

    errorbar(x_values_for_mean(i_col), ...
             mean(to_plot, 'omitnan'), ...
             std(to_plot, 'omitnan'), ...
             'o', ...
             'color', color, ...
             'linewidth', 2, ...
             'markerSize', markerSize * 1.5, ...
             'MarkerEdgeColor', 'k', ...
             'MarkerFaceColor', color);

  end

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

  axis([x_values_for_mean(1) - 0.2, x_values_for_mean(2) + 0.2,  yMin, yMax]);

  abs_max = round(max(abs([yMin yMax])) * 100);
  yTickLabel = round(-2 * abs_max:abs_max / 8:abs_max * 2) / 100;

  xTickLabel = args.Results.xTickLabel;
  if isnumeric(xTickLabel)
    xTickLabel = num2cell(xTickLabel);
    xTickLabel = cellfun(@(x) num2str(x), xTickLabel, 'UniformOutput', false);
  end

  xTickLabel = strrep(xTickLabel, '_', ' ');

  set(gca, ...
      'fontSize', fontSize, ...
      'ytick', yTickLabel, 'yTickLabel', yTickLabel, ...
      'xtick', 1:2, 'xTickLabel', xTickLabel, ...
      'tickLength', [.02 .02], ...
      'tickDir', 'out');

  t = xlabel(args.Results.xLabel);
  set(t, 'fontSize', fontSize + 2);
  t = ylabel(args.Results.yLabel);
  set(t, 'fontSize', fontSize + 2);

  t = title(args.Results.title);
  set(t, 'fontSize', fontSize + 4);

end
