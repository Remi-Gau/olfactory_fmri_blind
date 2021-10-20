function [prestim, stim, poststim, group, tasks] = get_and_epoch_data(tgt_dir, opt)
  %
  % (C) Copyright 2021 Remi Gau

  %% get data
  BIDS =  bids.layout(tgt_dir);

  tasks = bids.query(BIDS, 'tasks');
  if numel(tasks) == 3
    tasks(3) = [];
  end

  group(1).name = 'blnd';
  group(2).name = 'ctrl';

  for iTask = 1:numel(tasks)

    for iGroup = 1:numel(group)

      subjects = bids.query(BIDS, 'subjects', ...
                          'task', tasks{iTask});

      idx = strfind(subjects, {group(iGroup).name});
      idx = find(~cellfun('isempty', idx)); %#ok<STRCL1>

      subjects(idx);

      group(iGroup).subjects = subjects(idx);

      all_stim = average_beh(BIDS, tasks{iTask}, subjects(idx));

      for iTrialType = 1:size(all_stim, 1)
        for iRun = 1:2
          all_time_courses{iTrialType, iRun, iGroup, iTask} = ...
              all_stim{iTrialType, iRun}; %#ok<*SAGROW>
        end
      end

    end
  end

  %% epoch the data
    
  [prestim, stim, poststim] = epoch_data(tasks, group, all_time_courses, opt);

end
