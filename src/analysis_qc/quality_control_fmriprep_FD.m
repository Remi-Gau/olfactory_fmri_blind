%  This script uses the report from fmriprep to estimate the number of
%  timepoints in framewise displacement timeseries with values superior to
%  threshold.
% https://fmriprep.readthedocs.io/en/stable/outputs.html
%
% (C) Copyright 2021 Remi Gau

% Plots the proportion of timepoints per run (to identidy runs with that goes above a limit)
% also plots the sum of the proportion of timepoints over the 4 runs to
% identify who move a lot but for whom no run goes above the threshold

% This script also estimates how many points are lost through scrubbing
% depending on the framewise displacement threshold and the number of
% points to scrub after an outlier

clear;
clc;

%%
thresh = [.5 .9]; % FD threshold to "censor" timepoints
nb_2_scrub = [0 2 4]; % number of additional time points to scrub after an outlier

%% Load fMRIprep confound reports
% stores only the FD values and separates them into 2 groups

machine_id = 2;
[data_dir, code_dir, output_dir, fMRIprep_DIR] = set_dir(machine_id);

out_dir = fullfile(pwd, 'output', 'figures', 'fmriprep_qc');
mkdir(out_dir);

% Get which participant is in which group
participants_file = fullfile(data_dir, 'raw', 'participants.tsv');
participants = spm_load(participants_file);
group_id = ~cellfun(@isempty, strfind(participants.participant_id, 'ctrl'));

% [participants, group_id] = ...
%     rm_subjects(participants, group_id, [], 0);

% initialize
FramewiseDisplacement = cell(2, 1);
NbVol = cell(2, 1);

for i_group = 0:1 % loop through each group

  group_idx = find(group_id == i_group); % index of each subject

  col = 1;

  for i_subj = 1:numel(group_idx)

    % get data for each subject
    subject = participants.participant_id{ group_idx(i_subj) }; % ID

    % list all the confounds files
    files_2_load = spm_select('FPListrec', ...
                              fullfile(data_dir, 'derivatives', 'fmriprep', subject), ...
                              ['^' subject '.*confounds_regressors.tsv$']);

    if ~isempty(files_2_load)
      for i_file = 1:4 % size(files_2_load) % we skip the 5th file as it is the resting state run

        % load each event file
        data = spm_load(deblank(files_2_load(i_file, :)));

        % collect the FD for each run / subject
        fd = data.framewise_displacement;
        NbVol{i_group + 1}(1, col) = numel(fd);
        FramewiseDisplacement{i_group + 1}(1:numel(fd), col) =  fd;

        col = col + 1;

      end
    end

  end

end

%%  plot proportion datapoint with Framewise Displacement > threshold
% for each group
close all;

visible = 'on';

for i_thres = thresh

  for i_nb_2_scrub = nb_2_scrub

    for i_group = 1:2

      if i_group == 1
        group_name = 'blind';
      else
        group_name = 'control';
      end

      % identify all the points to scrub
      scrub = FramewiseDisplacement{i_group} > i_thres;

      % for each run of each participants
      for iCol = 1:size(scrub, 2)

        scrub_idx = find(scrub(:, iCol));

        % scrub the next i_nb_2_scrub time points too
        if ~isempty(scrub_idx)
          for scrub_more = 1:i_nb_2_scrub
            scrub_idx(end + 1, :) = scrub_idx(end, :) + 1; %#ok<*SAGROW>
          end
        end
        % remove duplicates and change values in original variable
        scrub_idx = unique(scrub_idx);
        scrub(scrub_idx, iCol) = 1;
      end

      proportion = sum(scrub) ./ NbVol{i_group};

      summed_proportion = sum(reshape(proportion, [4, size(proportion, 2) / 4]));

      %%
      fig_name = ['Scrubbing_Group-' group_name '_FD-thres' num2str(i_thres) 'scrub' num2str(i_nb_2_scrub + 1)];
      figure('name', ['Framewise Displacement - ' group_name], 'position', [50 50 1300 700], 'visible', visible);

      hold on;

      bar(1.5:numel(proportion) + .5, proportion);
      plot([1.5 numel(proportion) + .5], [.1 .1], '--r'); % plot limit at 10% of time points

      title(group_name);
      ylabel(sprintf('proportion time points scrubbed per run (FD > %0.1f mm ; %i timepoints)', ...
                     i_thres, i_nb_2_scrub + 1));
      xlabel('subject');

      x_tick_label = char(participants.participant_id(group_id == (i_group - 1)));
      x_tick_label = x_tick_label(:, 5:end);

      set(gca, 'xtick', 1:4:size(FramewiseDisplacement{1}, 2), ...
          'xticklabel', x_tick_label, ...
          'ytick', 0:.05:.5, ...
          'yticklabel', 0:.05:.5, ...
          'fontsize', 8);

      axis([1 numel(proportion) 0 0.25]);

      print(gcf, fullfile(out_dir, [fig_name '.jpeg']), '-djpeg');

      %%
      fig_name = ['Scrubbing_Group-' group_name '_FD-thres' num2str(i_thres) 'scrub' num2str(i_nb_2_scrub + 1) '_sum'];
      figure('name', ['Framewise Displacement - ' group_name], 'position', [50 50 1300 700], 'visible', visible);

      hold on;

      bar(1:numel(summed_proportion), summed_proportion);
      plot([1 numel(summed_proportion)], [.1 .1], '--r'); % plot limit at 10% of time points

      title(group_name);
      ylabel(sprintf('summed of proportions per run of time points scrubbed (FD > %0.1f mm ; %i timepoints)', ...
                     i_thres, i_nb_2_scrub + 1));
      xlabel('subject');

      x_tick_label = char(participants.participant_id(group_id == (i_group - 1)));
      x_tick_label = x_tick_label(:, 5:end);

      set(gca, 'xtick', 1:size(FramewiseDisplacement{1}, 2), ...
          'xticklabel', x_tick_label, ...
          'ytick', 0:.05:.5, ...
          'yticklabel', 0:.05:.5, ...
          'fontsize', 8);

      axis([.5 numel(summed_proportion) + .5 0 0.25]);

      print(gcf, fullfile(out_dir, [fig_name '.jpeg']), '-djpeg');

    end

  end
end
