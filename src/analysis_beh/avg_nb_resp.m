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

output_dir = fullfile(opt.dir.beh, 'derivatives');

input_file = fullfile(output_dir, ...
                      'beh', ...
                      'group', ...
                      ['sum_responses_over_stim_epoch_rmbase-' num2str(opt.rm_baseline) '.tsv']);

output_tsv_file = fullfile(output_dir, ...
                           'beh', ...
                           'group', ...
                           ['summary_responses_over_stim_epoch_rmbase-' num2str(opt.rm_baseline) '.tsv']);

group_tsv_file = fullfile(output_dir, ...
                          'beh', ...
                          'group', ...
                          ['group_responses_over_stim_epoch_rmbase-' num2str(opt.rm_baseline) '.tsv']);

out_dir = fullfile(output_dir, 'beh', 'figures', 'beh_avg');
spm_mkdir(out_dir);

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

%% Plot
clear data;

Colors(1, :) = opt.blnd_color;
Colors(2, :) = opt.sighted_color;

source_data = bids.util.tsvread(output_tsv_file);

figure('name', 'Both tasks', 'position', [50 50 1300 700], 'visible', opt.visible);

tasks = unique(source_data.task_id);
groups = unique(source_data.group_id);

for i_group = 1:2

  is_in_group = ismember(source_data.group_id,  groups(i_group));

  for iTask = 1:2

    is_task = ismember(source_data.task_id,  tasks(iTask));

    rows_to_keep = all([is_task, is_in_group], 2);

    data{i_group}(:, iTask) = source_data.good_minus_bad(rows_to_keep);

  end

end

yMin = min(cellfun(@(x) min(x(:)), data));
yMax = max(cellfun(@(x) max(x(:)), data));

groups = {'blind', 'control'};

for i_group = 1:2

  subplot(1, 2, i_group);

  if i_group == 1
    yLabel = sprintf(['     (Good response  - Bad response) ; [A U]\n\n', ...
                      'More bad responses <--      --> More good responses\n\n']);
  else
    yLabel = '';
  end

  spaghetti_plot(data{i_group}, ...
                 'spaghetti', true, ...
                 'fontSize', 10, ...
                 'xTickLabel', {'identification', 'localization'}, ...
                 'xLabel', 'tasks', ...
                 'yLabel', yLabel, ...
                 'yMin', yMin, ...
                 'yMax', yMax, ...
                 'title', groups{i_group}, ...
                 'markerSize', 8, ...
                 'color', Colors(i_group, :));

end

print(gcf, fullfile(out_dir, ...
                    ['grp-AvgResp_rmbase-' num2str(opt.rm_baseline) ...
                     '_plot.jpg']), '-djpeg');

%% Plots the average number of response during stimulus period
clear data;

data = bids.util.tsvread(output_tsv_file);

tasks = unique(data.task_id);
groups = unique(data.group_id);

row = 1;

summary = struct();

for iGroup = 1:2

  for iTask = 1:2

    is_task = ismember(data.task_id,  tasks(iTask));

    is_in_group = ismember(data.group_id,  groups(iGroup));

    rows_to_keep = all([is_task, is_in_group], 2);

    to_plot = data.good_minus_bad(rows_to_keep);

    summary.group_id(row) = groups(iGroup);
    summary.task_id(row) = tasks(iTask);
    summary.mean(row) = nanmean(to_plot);
    summary.std(row) = nanstd(to_plot);

    row = row + 1;

  end

end

bids.util.tsvwrite(group_tsv_file, summary);
