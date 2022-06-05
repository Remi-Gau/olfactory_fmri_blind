% This script uses the report from fMRIprep (bold) identify maximum value
% for several metrics for each run / subject and then uses robust
% statistics (interquartile range) to flag outliers.
% https://fmriprep.readthedocs.io/en/stable/outputs.html
%
% (C) Copyright 2021 Remi Gau

close all;
clear;
clc;

run ../../initEnv.m;

% get options
opt =  opt_dir();
opt = get_options(opt);

opt.verbosity = 2;

%% Load fMRIprep confound reports
% stores only the FD values and separates them into 2 groups

BIDS_fmriprep = bids.layout(opt.dir.input, 'use_schema', false);

out_dir = fullfile(opt.dir.beh, 'derivatives', 'fmriprep_qc');
spm_mkdir(out_dir);

%% collect data

% Get which participant is in which group
participants_file = fullfile(opt.dir.raw, 'participants.tsv');
participants = spm_load(participants_file);

group_names = {'blnd', 'ctrl'};

group_id = ~cellfun(@isempty, strfind(participants.participant_id, 'ctrl'));

file_lists = struct('blnd', {{}}, 'ctrl', {{}});
maximums = [];

for i_group = 0:1

  group_idx = find(group_id == i_group);

  col = 1;

  for i_subj = 1:numel(group_idx)

    % get data for each subject
    subject_label = participants.participant_id{ group_idx(i_subj) };
    subject_label = strrep(subject_label, 'sub-', '');

    printProcessingSubject(i_subj, subject_label, opt);

    confounds_file = bids.query(BIDS_fmriprep, 'data', ...
                                'sub', subject_label, ...
                                'task', {'olfid', 'olfloc'}, ...
                                'desc', 'confounds', ...
                                'suffix', 'regressors');

    if ~isempty(confounds_file)
      for i_file = 1:numel(confounds_file)

        file_lists.(group_names{i_group + 1}){end + 1, 1} = confounds_file{i_file};

        % load each event file
        disp(confounds_file{i_file});
        data = spm_load(confounds_file{i_file});

        maximums(i_group + 1, 1).FD(col, 1) =  ...
            nanmax(data.framewise_displacement); %#ok<*SAGROW>
        maximums(i_group + 1, 1).std_dvars(col, 1) =  ...
            nanmax(abs(1 - data.std_dvars));

        col = col + 1;

      end

    end

  end

end

%%  plot maximum of each run/subject for each metric for each group
close all;

out_dir = fullfile(opt.dir.beh, 'derivatives', 'fmriprep_qc');
spm_mkdir(out_dir);

metrics = fieldnames(maximums);

for i_group = 1:2

  if i_group == 1
    group_name = 'blind';
  else
    group_name = 'control';
  end

  all_outliers = [];

  for metric = 1:numel(metrics)

    clear max_2_plot outliers;

    metric_name = metrics{metric};
    max_2_plot = maximums(i_group).(metric_name);

    outliers = iqr_method(max_2_plot, 0);
    all_outliers(:, end + 1) = outliers;

    fig_name = ['group-' group_name '_desc-max_'   metric_name];
    figure('name', fig_name, 'position', [50 50 2000 2000]);

    hold on;

    bar(1.5:numel(max_2_plot) + .5, max_2_plot);
    plot(find(outliers), max_2_plot(logical(outliers)), ' or', ...
         'MarkerSize', 12, ...
         'MarkerFaceColor', 'r');

    title(group_name);
    xlabel('subject');
    ylabel(metric_name);

    x_tick_label = char(participants.participant_id(group_id == (i_group - 1)));
    x_tick_label = x_tick_label(:, 5:end);

    set(gca, 'xtick', 1:4:size(max_2_plot, 1), ...
        'xticklabel', x_tick_label, 'xgrid', 'on', ...
        'fontsize', 8);

    fig_name = [fig_name '.jpeg'];
    print(gcf, fullfile(out_dir, fig_name), '-djpeg');

  end

  file_lists.(group_names{i_group})(any(all_outliers, 2), :);
end
