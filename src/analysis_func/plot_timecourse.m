% (C) Copyright 2021 Remi Gau

%% Show fitted event time courses
Colors = [opt.blnd_color / 255; ...
          opt.sighted_color / 255];
Colors_desat = Colors + (1 - Colors) * (1 - .3);

black = [0 0 0];

close all;
figure;
hold on;

dt = 0.0561;
secs = [0:size(time_course{1}, 2) - 1] * dt;

for i_roi = 1:size(roi_ls, 1)

  figure('name', roi_ls{i_roi}, 'Position', [100 100 600 600]);
  hold on;

  for i_group = 0:1

    data = time_course{i_roi}(group_id == i_group, :);

    to_plot = nanmean(data);
    sem = nanstd(data) / size(data, 1)^.5;

    plot(secs, to_plot, 'color', Colors(i_group + 1, :), 'linewidth', 2);

  end

  plot(secs, zeros(size(secs)), '--k', 'linewidth', 1);

  for i_group = 0:1

    data = time_course{i_roi}(group_id == i_group, :);

    to_plot = nanmean(data);
    sem = nanstd(data) / size(data, 1)^.5;

    %         plot(secs, data, 'color', Colors_desat(i_group+1,:),
    %         'linewidth', .5);

    shadedErrorBar(secs, to_plot, sem, ...
                   {'color', Colors(i_group + 1, :), 'linewidth', 2}, 1);

  end

  legend({'blind', 'ctrl'});

  n_blind = sum(~isnan(percent_signal_change{i_GLM}(group_id == 0, i_roi)));
  n_ctrl = sum(~isnan(percent_signal_change{i_GLM}(group_id == 1, i_roi)));
  text(30, 0.07, sprintf('blind ; n = %i', n_blind));
  text(30, 0.05, sprintf('ctrl ; n = %i', n_ctrl));

  limit_axis = axis;
  axis([limit_axis(1:2) -0.13 0.13]);

  title(['Time courses for ' roi_ls{i_roi}], 'Interpreter', 'none');
  xlabel('Seconds');
  ylabel('% signal change');

  ax = gca;
  axPos = ax.Position;
  axPos(1) = axPos(1) + .5;
  axPos(2) = axPos(2) + .1;
  axPos(3) = axPos(3) * .3;
  axPos(4) = axPos(4) * .3;
  axes('Position', axPos);

  for i_group = 0:1

    to_plot = percent_signal_change{i_GLM}(group_id == i_group, i_roi);

    h = plotSpread(to_plot, 'distributionIdx', ones(size(to_plot)), ...
                   'distributionMarkers', {'o'}, ...
                   'distributionColors', Colors(i_group + 1, :), ...
                   'xValues', i_group + 1, ...
                   'showMM', 0, ...
                   'binWidth', .1, 'spreadWidth', 1);

    set(h{1}, 'MarkerSize', 5, 'MarkerEdgeColor', 'k', ...
        'MarkerFaceColor', Colors(i_group + 1, :), ...
        'LineWidth', 2);

    h = errorbar(i_group + .5, ...
                 nanmean(to_plot), ...
                 nanstd(to_plot) / numel(to_plot)^.5, ...
                 'o', ...
                 'color', Colors(i_group + 1, :), 'linewidth', 1, ...
                 'MarkerSize', 5, ...
                 'MarkerEdgeColor', 'k', ...
                 'MarkerFaceColor', Colors(i_group + 1, :));

  end

  plot([0 3], [0 0], 'k');

  MAX = max(abs(percent_signal_change{i_GLM}(:, i_roi)));

  axis([0.2 2.5 -MAX MAX]);

  set(gca, 'fontsize', 8, ...
      'ytick', -1:0.25:1, 'yticklabel', -1:0.25:1, ...
      'xtick', 1:2, 'xticklabel', {'blind', 'ctrl'}, ...
      'ticklength', [.02 .02], 'tickdir', 'out');

end
