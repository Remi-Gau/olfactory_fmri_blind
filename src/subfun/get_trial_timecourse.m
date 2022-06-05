function trial_courses = get_trial_timecourse(event_file)
  % trial_courses = get_trial_timecourse(event_file)
  %
  % returns time course
  % trial_courses  of size [numel(trial_type), timecourse_dur * samp_freq]
  %
  % onsets are equal to 1 and offet to -1
  %
  % (C) Copyright 2021 Remi Gau

  opt = get_options;

  samp_freq = opt.samp_freq;
  timecourse_dur = opt.timecourse_dur;
  trial_type = opt.trial_type;

  trial_courses = zeros(numel(trial_type), timecourse_dur * samp_freq);

  % get events file
  x = spm_load(event_file{1});

  % we collect the stim / resp onsets and offsets
  for iTrial_type = 1:numel(trial_type)

    idx = strcmp(x.channel, trial_type{iTrial_type});

    event_onsets = x.onset(idx);
    event_offsets = event_onsets + x.duration(idx);

    % we round as we need to use those values as indices in a time course
    event_onsets = round(event_onsets * samp_freq);
    event_offsets = round(event_offsets * samp_freq);
    if any(event_onsets < 0)
      event_onsets(event_onsets < 0) = 1;
      warning('some values are below 0 and they should not be.');
    end

    % we take onset and offsets for stimuli
    if iTrial_type < 5
      trial_courses(iTrial_type, event_onsets) = 1;
      trial_courses(iTrial_type, event_offsets) = -1;
      % we only take onset for responses
    else
      trial_courses(iTrial_type, event_onsets) = 1;
    end
  end

end
