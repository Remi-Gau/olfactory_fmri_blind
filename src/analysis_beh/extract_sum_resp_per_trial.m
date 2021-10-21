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

out_dir = fullfile(opt.dir.output_dir, 'beh', 'group');
spm_mkdir(out_dir);

opt.avg_run = false;
[~, stim_epoch, ~, group, tasks] = get_and_epoch_data(opt.dir.data, opt);

output = struct( ...
                'group_id', {''}, ...
                'sub_id', {''}, ...
                'task_id', {''}, ...
                'run_id', [], ...
                'trial_id', [], ...
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

        for trial_id = 1:4

          % finger for responses
          right = 1;
          left = 2;

          if strcmp(tasks{iTask}, 'olfid')

            % trials
            eucalyptus = [1, 3];
            almond = [2, 4];

            % good: left finger for eucalyptus
            good.resp(1) = right;
            good.trials{1} = eucalyptus;
            % good: right finger for almond
            good.resp(2) = left;
            good.trials{2} = almond;

            % bad: right finger for eucalyptus
            bad.resp(1) = right;
            bad.trials{1} = eucalyptus;
            % bad: left finger for almond
            bad.resp(2) = left;
            bad.trials{2} = almond;

          elseif strcmp(tasks{iTask}, 'olfloc')

            % trials
            left_nostril = [1, 2];
            right_nostril = [3, 4];

            % good responses
            good.resp(1) = right;
            good.trials{1} = right_nostril;

            good.resp(2) = left;
            good.trials{2} = left_nostril;

            % bad responses
            bad.resp(1) = right;
            bad.trials{1} = left_nostril;

            bad.resp(2) = left;
            bad.trials{2} = right_nostril;

          end

          %% reorganize data

          % Good responses
          temp_1 = cat(2, ...
                       stim_epoch{good.resp(1), iGroup, iTask}(iSub, :, good.trials{1}, run_id), ...
                       stim_epoch{good.resp(2), iGroup, iTask}(iSub, :, good.trials{2}, run_id));

          % Bad responses
          temp_2 = cat(2, ...
                       stim_epoch{bad.resp(1), iGroup, iTask}(iSub, :, bad.trials{1}, run_id), ...
                       stim_epoch{bad.resp(2), iGroup, iTask}(iSub, :, bad.trials{2}, run_id));

          good_response = sum(temp_1(:));
          bad_response = sum(temp_2(:));

          output.group_id{row} = group_id;
          output.sub_id{row} = sub_id;
          output.task_id{row} = task_id;
          output.run_id(row) = run_id;
          output.trial_id(row) = trial_id;
          output.good_response(row) = good_response;
          output.bad_response(row) = bad_response;

          row = row + 1;

        end

      end

    end

  end

end

bids.util.tsvwrite(fullfile(out_dir, 'sum_responses_over_stim_epoch_.tsv'), ...
                   output);
