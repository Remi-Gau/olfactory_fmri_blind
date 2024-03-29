% sums number of response during stimulus period
% and saves to a TSV for ANOVA
%
%
% (C) Copyright 2021 Remi Gau

close all;
clear;
clc;

run ../../initEnv.m;

opt = options();

out_dir = fullfile(opt.dir.beh, 'derivatives', 'beh', 'group');
spm_mkdir(out_dir);

opt.avg_run = false;
[~, stim_epoch, ~, group, tasks] = get_and_epoch_data(opt.dir.beh, opt);

output = struct('group_id', {''}, ...
                'sub_id', {''}, ...
                'task_id', {''}, ...
                'run_id', [], ...
                'trial_id', {''}, ...
                'good_response', [], ...
                'bad_response', []);

row = 1;

for iTask = 1:2

  task_id = tasks{iTask};

  for iGroup = 1:2

    group_id = group(iGroup).name;

    for iSub = 1:numel(group(iGroup).subjects)

      sub_id = group(iGroup).subjects{iSub};

      for run_id = 1:2

        for trial_nb = 1:4

          % finger for responses
          right = 2;
          left = 1;

          if strcmp(tasks{iTask}, 'olfid')

            % trials
            eucalyptus = [1, 3];
            is_eucalyptus = ismember(trial_nb, eucalyptus);

            if is_eucalyptus
              trial_id = 'eucalyptus';
              % good: left finger for eucalyptus
              % bad: right finger for eucalyptus
              good_response = stim_epoch{left, iGroup, iTask}(iSub, :, trial_nb, run_id);
              bad_response = stim_epoch{right, iGroup, iTask}(iSub, :, trial_nb, run_id);
            else
              trial_id = 'almond';
              % good: right finger for almond
              % bad: left finger for almond
              good_response = stim_epoch{right, iGroup, iTask}(iSub, :, trial_nb, run_id);
              bad_response = stim_epoch{left, iGroup, iTask}(iSub, :, trial_nb, run_id);
            end

          elseif strcmp(tasks{iTask}, 'olfloc')

            % trials
            left_nostril = [1, 2];
            is_left_nostril = ismember(trial_nb, left_nostril);

            if is_left_nostril
              trial_id = 'left_nostril';
              % good: left finger for left_nostril
              % bad: right finger for left_nostril
              good_response = stim_epoch{left, iGroup, iTask}(iSub, :, trial_nb, run_id);
              bad_response = stim_epoch{right, iGroup, iTask}(iSub, :, trial_nb, run_id);
            else
              trial_id = 'right_nostril';
              % good: right finger for right_nostril
              % bad: left finger for right_nostril
              good_response = stim_epoch{right, iGroup, iTask}(iSub, :, trial_nb, run_id);
              bad_response = stim_epoch{left, iGroup, iTask}(iSub, :, trial_nb, run_id);
            end

          end

          output.group_id{row} = group_id;
          output.sub_id{row} = sub_id;
          output.task_id{row} = task_id;
          output.run_id(row) = run_id;
          output.trial_id{row} = trial_id;
          output.good_response(row) = sum(good_response);
          output.bad_response(row) = sum(bad_response);

          row = row + 1;

        end

      end

    end

  end

end

bids.util.tsvwrite(fullfile(out_dir, ...
                            ['sum_responses_over_stim_epoch_rmbase-' num2str(opt.rm_baseline) '.tsv']), ...
                   output);
