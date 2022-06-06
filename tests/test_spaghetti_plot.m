%% crash test
%
%
% (C) Copyright 2022 Remi Gau

close all;
clear;

nb_cols = 4;
n_subjects = 30;
use_spaghetti = true;

for i_group = 1:2

  factor = 1;

  data{i_group}(:, 1) = randn(n_subjects, 1) - ...
                        factor * 3 + ...
                        randn(n_subjects, 1) * 0.4 * factor; %#ok<*SAGROW>

  for i = 2:nb_cols
    data{i_group}(:, i) = data{i_group}(:, 1) + ...
                          randn * 0.4 * factor + ...
                          randn(n_subjects, 1) * 0.4 * factor;
  end

  % we switch several subjects to nan to test robustness
  nb_nan = randi([1 floor(n_subjects / 4)]);
  switch_to_nan = randi([1 n_subjects], nb_nan, 1);
  data{i_group}(switch_to_nan, :) = nan;

end

figure('name', 'Both tasks', 'position', [50 50 1300 700], 'visible', 'on');

opt = get_options();

Colors(1, :) = opt.blnd_color;
Colors(2, :) = opt.sighted_color;

Groups = {'congenital blind', 'control'};

yLabel = {'percent signal change', ''};

for i_group = 1:2

  subplot(1, 2, i_group);

  yMin = min(cellfun(@(x) min(x(:)), data));
  yMax = max(cellfun(@(x) max(x(:)), data));

  spaghetti_plot(data{i_group}, ...
                 'spaghetti', use_spaghetti, ...
                 'fontSize', 12, ...
                 'xTickLabel', {'condition 1', 'condition 2'}, ...
                 'xLabel', 'conditions', ...
                 'yLabel', yLabel{i_group}, ...
                 'yMin', yMin, ...
                 'yMax', yMax, ...
                 'title', Groups{i_group}, ...
                 'markerSize', 8, ...
                 'color', Colors(i_group, :));

end

mtit(sprintf('Mean number of responses during stim epoch '), ....
     'fontsize', 16, 'xoff', 0, 'yoff', 0.05);
