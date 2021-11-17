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

input_file = fullfile(opt.dir.output_dir, ...
                      'beh', ...
                      'group', ...
                      ['sum_responses_over_stim_epoch_rmbase-' num2str(opt.rm_baseline) '.tsv']);

output_tsv_file = fullfile(opt.dir.output_dir, ...
                           'beh', ...
                           'group', ...
                           ['summary_responses_over_stim_epoch_rmbase-' num2str(opt.rm_baseline) '.tsv']);

out_dir = fullfile(opt.dir.output_dir, 'beh', 'figures', 'beh_avg');
spm_mkdir(out_dir);

% some settings for the figures
max_y_axis = [-4, 6];

x_values_for_mean = [0.75, 2.25];

fontsize = 12;

spaghetti_plot =  true;

Colors(1, :) = opt.blnd_color;
Colors(2, :) = opt.sighted_color;
Colors = Colors / 255;

stim_legend = opt.stim_legend;

%% Create summary table

data = bids.util.tsvread(input_file);

tasks = unique(data.task_id);
groups = unique(data.group_id);

summary = struct();
row = 1;

for iTask = 1:2

  is_task = ismember(data.task_id,  tasks(iTask));

  for iGroup = 1:2

    is_in_group = ismember(data.group_id,  groups(iGroup));

    rows_to_keep = all([is_task, is_in_group], 2);

    subjects = unique(data.sub_id(rows_to_keep));

    subjects = rm_subjects(subjects, opt);

    for iSubject = 1:numel(subjects)

      is_subject = ismember(data.sub_id,  subjects(iSubject));

      rows_to_keep = all([is_task, is_in_group, is_subject], 2);

      % we mean over trials and runs
      good_responses{iGroup}(iSubject) = mean(data.good_response(rows_to_keep)); %#ok<*SAGROW>
      bad_responses{iGroup}(iSubject) = mean(data.bad_response(rows_to_keep));

      summary.sub_id(row) = subjects(iSubject);
      summary.group_id(row) = groups(iGroup);
      summary.task_id(row) = tasks(iTask);
      summary.good_minus_bad(row) = mean(data.good_response(rows_to_keep)) - ...
          mean(data.bad_response(rows_to_keep));

      row = row + 1;

    end

  end

end

bids.util.tsvwrite(output_tsv_file, summary);

%% Plots the average number of response during stimulus period
clear data;

data = bids.util.tsvread(output_tsv_file);

figure('name', 'Both tasks', 'position', [50 50 1300 700], 'visible', opt.visible);

tasks = unique(data.task_id);
groups = unique(data.group_id);

for iGroup = 1:2

  subplot(1, 2, iGroup);
  hold on;

  spaghetti = [];

  for iTask = 1:2

    is_task = ismember(data.task_id,  tasks(iTask));
    is_in_group = ismember(data.group_id,  groups(iGroup));

    rows_to_keep = all([is_task, is_in_group], 2);

    to_plot = data.good_minus_bad(rows_to_keep);

    if ~spaghetti_plot
      h = plotSpread(to_plot, 'distributionIdx', ones(size(to_plot)), ...
                     'distributionMarkers', {'o'}, ...
                     'distributionColors', Colors(iGroup, :), ...
                     'xValues', iTask, ...
                     'showMM', 0, ...
                     'binWidth', .1, 'spreadWidth', 1);

      set(h{1}, 'MarkerSize', 7, 'MarkerEdgeColor', 'k', ...
          'MarkerFaceColor', Colors(iGroup, :), ...
          'LineWidth', 2);
    else
      spaghetti(iTask, :) = to_plot;

    end

    errorbar(x_values_for_mean(iTask), ...
             nanmean(to_plot), ...
             nanstd(to_plot) / numel(to_plot)^.5, ...
             'o', ...
             'color', Colors(iGroup, :), 'linewidth', 2, ...
             'MarkerSize', 5, ...
             'MarkerEdgeColor', 'k', ...
             'MarkerFaceColor', Colors(iGroup, :));

  end

  if spaghetti_plot
    h = plot(1:2, spaghetti, 'o-');
    for i = 1:numel(h)
      set(h(i), 'color', Colors(iGroup, :), 'linewidth', 1, ...
          'MarkerSize', 5, ...
          'MarkerEdgeColor', 'k', ...
          'MarkerFaceColor', 'k');
    end
  end

  plot([0 3], [0 0], 'k');

  set(gca, 'fontsize', fontsize, ...
      'ytick', -25:2.5:25, 'yticklabel', -25:2.5:25, ...
      'xtick', 1:2, 'xticklabel', tasks, ...
      'ticklength', [.02 .02], 'tickdir', 'out');

  title(groups(iGroup));

  axis([x_values_for_mean(1) - 0.2, x_values_for_mean(2) + 0.2,  max_y_axis]);

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
