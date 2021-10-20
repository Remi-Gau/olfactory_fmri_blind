function [all_stim, task] = average_beh(BIDS, task, subjects)
  %
  % (C) Copyright 2021 Remi Gau
  
  fprintf(1, '\n\nGetting the data');

  opt = get_option;

  samp_freq = opt.samp_freq;
  timecourse_dur = opt.timecourse_dur;
  trial_type = opt.trial_type;

  % create template matrix to collect responses, stim, ...
  % seconds * sampling frequency
  template = zeros(numel(subjects), timecourse_dur * samp_freq);
  for iTrial_type = 1:numel(trial_type)
    all_stim{iTrial_type, 1} = template; %#ok<*AGROW>
    all_stim{iTrial_type, 2} = template;
  end

  % we take each event file from each subject for that task and we collect
  % onsets and offsets of all stim and responses
  for iSubjects = 1:numel(subjects)

    runs = bids.query(BIDS, 'runs', ...
                    'suffix', 'events', ...
                    'sub', subjects{iSubjects}, ...
                    'task', task);

    for iRun = 1:numel(runs)

      event_file = bids.query(BIDS, 'data', ...
                            'suffix', 'events', ...
                            'sub', subjects{iSubjects}, ...
                            'task', task, ...
                            'run', runs{iRun});

      if numel(event_file) > 1
        error('We should have only one file.');
      end

      % we collect the stim / resp onsets and offsets
      fprintf(1, '\n%s', event_file{1});
      trial_courses = get_trial_timecourse(event_file);
      for iTrial_type = 1:numel(trial_type)
        all_stim{iTrial_type, iRun}(iSubjects, :) = trial_courses(iTrial_type, :);
      end

    end
  end

end
