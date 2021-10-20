% Plots the average number of response during stimulus period
% 
% 
% Some subjects have weird onsets for some stimuli so we replace them by
% the average onset from the rest of the group
%
% Assumes a fixed 16 seconds stimulation duration
%
%
% (C) Copyright 2021 Remi Gau

close all;
clear;
clc;

run ../../initEnv.m;

opt = options();

out_dir = fullfile(opt.dir.output_dir, 'beh', 'figures', 'beh_avg');
spm_mkdir(out_dir);

% some settings for the figures
max_y_axis = 25;
fontsize = 12;

[~, stim_epoch, ~, group, tasks] = get_and_epoch_data(opt.dir.data, opt);

%% Plots the average number of response during stimulus period

stim_legend = opt.stim_legend;
Colors(1, :) = opt.blnd_color;
Colors(2, :) = opt.sighted_color;
Colors = Colors / 255;

figure('name', 'Both tasks', 'position', [50 50 1300 700], 'visible', opt.visible);

for iTask = 1:2

  %% prepare data

  for iGroup = 1:2

    switch tasks{iTask}
      case 'olfid'

        % Good responses
        temp_1 = cat(2, ...
                     stim_epoch{1, iGroup, iTask}(:, :, [1, 3]), ... % left finger for eucalyptus
                     stim_epoch{2, iGroup, iTask}(:, :, [2, 4])); % right finger for almond

        % Bad responses
        temp_2 = cat(2, ...
                     stim_epoch{2, iGroup, iTask}(:, :, [1, 3]), ... % right finger for eucalyptus
                     stim_epoch{1, iGroup, iTask}(:, :, [2, 4])); % left finger for almond

      case 'olfloc'

        % Good responses (left finger for left nostril)
        temp_1 = cat(2, ...
                     stim_epoch{1, iGroup, iTask}(:, :, [1, 2]), ... % left finger for left nostril
                     stim_epoch{2, iGroup, iTask}(:, :, [3, 4])); % right finger for right nostril

        % Bad responses
        temp_2 = cat(2, ...
                     stim_epoch{2, iGroup, iTask}(:, :, [1, 2]), ... % left finger for right nostril
                     stim_epoch{1, iGroup, iTask}(:, :, [3, 4])); % right finger for left nostril

    end

    good_responses{iGroup} = sum(sum(temp_1, 3), 2);
    bad_responses{iGroup} = sum(sum(temp_2, 3), 2);

  end

  subplot(1, 2, iTask);
  hold on;

  for iGroup = 1:2

    to_plot = good_responses{iGroup} - bad_responses{iGroup};

    h = plotSpread(to_plot, 'distributionIdx', ones(size(to_plot)), ...
                   'distributionMarkers', {'o'}, ...
                   'distributionColors', Colors(iGroup, :), ...
                   'xValues', iGroup, ...
                   'showMM', 0, ...
                   'binWidth', .1, 'spreadWidth', 1);

    set(h{1}, 'MarkerSize', 7, 'MarkerEdgeColor', 'k', ...
        'MarkerFaceColor', Colors(iGroup, :), ...
        'LineWidth', 2);

    h = errorbar(iGroup - .5, ...
                 nanmean(to_plot), ...
                 nanstd(to_plot) / numel(to_plot)^.5, ...
                 'o', ...
                 'color', Colors(iGroup, :), 'linewidth', 2, ...
                 'MarkerSize', 5, ...
                 'MarkerEdgeColor', 'k', ...
                 'MarkerFaceColor', Colors(iGroup, :));

  end

  plot([0 3], [0 0], 'k');

  set(gca, 'fontsize', fontsize, ...
      'ytick', -25:5:25, 'yticklabel', -25:5:25, ...
      'xtick', 1:2, 'xticklabel', {group.name}, ...
      'ticklength', [.02 .02], 'tickdir', 'out');

  title(['task: ' tasks{iTask}]);

  axis([0.2 2.5 -max_y_axis max_y_axis]);

  subplot(1, 2, 1);
  t = ylabel(sprintf( ...
                     ['     (Good response  - Bad response) ; [A U]\n\n', ...
                      'More bad responses <--      --> More good responses\n\n']));
  set(t, 'fontsize', fontsize);

end

mtit(sprintf('Mean number of responses during stim epoch '), ....
     'fontsize', 14, 'xoff', 0, 'yoff', 0.05);

print(gcf, fullfile(out_dir, ...
                    ['grp-AvgResp_rmbase-' num2str(opt.rm_baseline) ...
                     '_plot.jpg']), '-djpeg');
