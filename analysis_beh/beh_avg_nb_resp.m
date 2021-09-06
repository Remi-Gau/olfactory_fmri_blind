% behavioral results

% Plots the average number of response during stimulus period

% some subjects have weird onsets for some stimuli so we replace them by
% the average onset from the rest of the group

% assumes a fixed 16 seconds stimulation duration

close all;
clear;
clc;

if ~exist('machine_id', 'var')
  machine_id = 1; % 0: container ;  1: Remi ;  2: Beast
end
% setting up directories
[data_dir, code_dir] = set_dir(machine_id);

% mention where the BIDS data set is (can get the behavioral from OSF)
tgt_dir = fullfile(data_dir, 'raw');

out_dir = fullfile(pwd, 'output', 'figures', 'beh_avg');
mkdir(out_dir);

opt.baseline_dur = 20;
opt.pre_stim = 16;
opt.stim_dur = 16;
opt.post_stim = 16;

% offset time courses by the pre stimulus baseline level of response
opt.rm_baseline = 0;

% some settings for the figures
max_y_axis = 25;

opt.visible = 'on';

fontsize = 12;

% just to prevent label_your_axes from trying to give a meaningful scale
% opt.norm_resp = 1;

opt = get_option(opt);

[~, stim_epoch, ~, group, tasks] = get_and_epoch_data(tgt_dir, opt);

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
                    ['Avg_Resp_' ...
                     group(iGroup).name ...
                     '_task-' tasks{iTask} ...
                     '_rmbase-' num2str(opt.rm_baseline) ...
                     '.jpg']), '-djpeg');
