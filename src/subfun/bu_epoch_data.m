function [prestim_e, stim_e, poststim_e] = epoch_data(tasks, group, all_time_courses, opt)
  %
  % avg_run: boolean to average across run
  %
  % (C) Copyright 2021 Remi Gau

  baseline_dur = opt.baseline_dur * opt.samp_freq;
  pre_stim = opt.pre_stim * opt.samp_freq;
  stim_dur = opt.stim_dur * opt.samp_freq;
  post_stim = opt.post_stim * opt.samp_freq;

  fprintf(1, '\n\nEpoching the data');

  for iTask = 1:numel(tasks)
    for iGroup = 1:numel(group)
      for iRun = 1:2

        % onset and offset of each stim
        for iTrialtype = 1:4
          data = all_time_courses{iTrialtype, iRun, iGroup, iTask};
          for iSubj = 1:size(data, 1)
            ON = find(data(iSubj, :) == 1);
            if isempty(ON)
              ON = 1;
            end
            onsets(iSubj, iTrialtype) = ON;
          end
        end

        % indices of baseline epoch
        baseline_idx = onsets(:, 1);

        % in case some subjects have messed up onsets
        bad_baseline = baseline_idx <= baseline_dur / 2;
        if any(bad_baseline)

          fprintf(1, '\n');
          warning('Filling in some bad onsets with average from onset from the rest of the group.');
          fprintf(1, 'Group: %s\n', ...
                  group(iGroup).name);
          fprintf(1, 'Subject: %s \n', ...
                  group(iGroup).subjects{bad_baseline});

          baseline_idx(bad_baseline, :) = ...
              repmat(round(mean(baseline_idx(~bad_baseline, :))), ...
                     [sum(bad_baseline), 1]);
        end

        % Do something similar for the other onsets
        for iTrialtype = 2:4
          tmp = onsets(:, iTrialtype) == 1;
          onsets(tmp, iTrialtype) = repmat(round(mean(onsets(~tmp, iTrialtype))), ...
                                           [sum(tmp), 1]);
        end

        % update onsets
        onsets(:, 1) = baseline_idx(:, 1);

        % create offsets using a fixed duration
        offsets = onsets + stim_dur;

        % create epoch index for baseline
        baseline_idx = [baseline_idx - baseline_dur, baseline_idx];

        % for each response
        for iResp = 1:2

          data = all_time_courses{iResp + 4, iRun, iGroup, iTask};

          % get baseline
          for iSubj = 1:size(data, 1)
            baseline(iSubj, iResp) = ...
                mean(data(iSubj, baseline_idx(iSubj, 1):baseline_idx(iSubj, 2)));
          end

          % slice the responses time courses for pre-stim epoch for each stim
          % and normalizes the data by the baseline (minus the
          % average number of responses per time point during the
          % baseline)
          for iTrialtype = 1:4
            for iSubj = 1:size(data, 1)

              ON = onsets(iSubj, iTrialtype);
              OFF = offsets(iSubj, iTrialtype);

              if opt.rm_baseline
                OFFSET = baseline(iSubj, iResp);
              else
                OFFSET = 0;
              end

              prestim_e{iResp, iGroup, iTask}(iSubj, :, iTrialtype, iRun) = ...
                  data(iSubj, ON - pre_stim:ON - 1) - OFFSET;
              stim_e{iResp, iGroup, iTask}(iSubj, :, iTrialtype, iRun) = ...
                  data(iSubj, ON:OFF) - OFFSET;
              poststim_e{iResp, iGroup, iTask}(iSubj, :, iTrialtype, iRun) = ...
                  data(iSubj, OFF + 1:OFF + post_stim) - OFFSET;

            end
          end
        end

      end

      % average across runs
      if isfield(opt, 'avg_run') && opt.avg_run
        for iResp = 1:2
          prestim_e{iResp, iGroup, iTask} = mean(poststim_e{iResp, iGroup, iTask}, 4);
          stim_e{iResp, iGroup, iTask} = mean(stim_e{iResp, iGroup, iTask}, 4);
          poststim_e{iResp, iGroup, iTask} = mean(poststim_e{iResp, iGroup, iTask}, 4);
        end
      end
    end

  end

  fprintf(1, '\nDone!\n\n');
end
