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

out_dir = fullfile(opt.dir.output_dir, 'beh', 'data', 'beh_avg');
spm_mkdir(out_dir);

opt.avg_run = false;
[~, stim_epoch, ~, group, tasks] = get_and_epoch_data(opt.dir.data, opt);

output = struct('group_id', {''}, 'sub_id', {''}, 'task_id', {''}, 'run_id', [], 'trial_id', [], ...
                'good_response', [], 'bad_response', []);

row = 1;

for iTask = 1:2

  %% reorganize data

  % structure stim_epoch
  %
  % stim_epoch{iResp, iGroup, iTask}(iSubj, :, iTrialtype, iRun)

  task_id = tasks{iTask};

  for iGroup = 1:2

    group_id = group(iGroup).name;

    for iSub = 1:numel(group(iGroup).subjects)

      sub_id = group(iGroup).subjects{iSub};

      for run_id = 1:2

        for trial_id = 1:4

          output.group_id{row} = group_id;
          output.sub_id{row} = sub_id;
          output.task_id{row} = task_id;
          output.run_id(row) = run_id;
          output.trial_id(row) = trial_id;
          output.good_response(row) = nan;
          output.bad_response(row) = nan;

          row = row + 1;

        end

      end

    end

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

  end

end
