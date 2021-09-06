% quality_control_FD_beh()
% plots framewise displacement, stimuli and controls on the same figures
% for each runa nd subjects
% to check if scrubbed time points are not during stimuli period

clear;
clc;

machine_id = 2; % 0: container ;  1: Remi ;  2: Beast
[data_dir, code_dir, output_dir, fMRIprep_DIR] = set_dir(machine_id);

tgt_dir = fullfile(data_dir, 'raw');

out_dir = fullfile(code_dir, 'output', 'figures', 'fmriprep_qc');

visible = 'off';

% get options
opt = get_option;
nb_dummies = opt.nb_dummies;
RT = opt.RT;
samp_freq = opt.samp_freq;
trial_type = opt.trial_type;
stim_color = opt.stim_color;
Legend = opt.stim_legend;
Legend{end + 1} = 'resp_1';
Legend{end + 1} = 'resp_2';
Legend{end + 1} = 'respiration';

% get date info
bids =  spm_BIDS(tgt_dir);
subjects = spm_BIDS(bids, 'subjects');
tasks = spm_BIDS(bids, 'tasks');

subjects(ismember(subjects, 'blnd04')) = [];

% number of time points to remove from phsyio to align with beh
physio_crop = 1:RT * nb_dummies * samp_freq;

mkdir(out_dir);

%%

comments = {};
filenames = {};

for iSub = 1:numel(subjects)

  % list all the confounds files
  confounds_files = spm_select('FPListrec', ...
                               fullfile(data_dir, 'derivatives', 'fmriprep', ['sub-' subjects{iSub}]), ...
                               ['^' ['sub-' subjects{iSub}] '.*confounds_regressors.tsv$']);

  for iTasks = 1:2

    switch tasks{iTasks}
      case 'olfid'
        confound_2_load = [1:2];
      case 'olfloc'
        confound_2_load = [3:4];
    end

    physio_file = spm_BIDS(bids, 'data', ...
                           'sub', subjects{iSub}, ...
                           'task', tasks{iTasks}, ...
                           'type', 'physio');

    metadata = spm_BIDS(bids, 'metadata', ...
                        'sub', subjects{iSub}, ...
                        'task', tasks{iTasks}, ...
                        'type', 'physio');

    event_file = spm_BIDS(bids, 'data', ...
                          'sub', subjects{iSub}, ...
                          'task', tasks{iTasks}, ...
                          'type', 'events');

    for iRun = 1:numel(physio_file)

      close all;

      % collect the FD for each run
      fd = spm_load(deblank(confounds_files(confound_2_load(iRun), :)));
      fd = fd.framewise_displacement;

      % get physio data
      disp(physio_file{iRun});
      if ~exist(physio_file{iRun}(1:end - 3), 'file')
        gunzip(physio_file{iRun});
      end
      x = spm_load(physio_file{iRun}(1:end - 3), '', false(1));
      respiration = x(:, 1);
      respiration(physio_crop) = [];
      MAX = max(respiration);

      % Get stim and responses
      % get events file
      disp(event_file(iRun));
      trial_courses = get_trial_timecourse(event_file(iRun));

      % fill the onset and offset by durations
      for iTrialtype = 1:size(trial_courses, 1)
        onsets = find(trial_courses(iTrialtype, :) == 1);
        offsets = find(trial_courses(iTrialtype, :) == -1);
        % in case the offset was cropped out we make the stim end
        % at the end of the timecourse
        if isempty(offsets) && iTrialtype < 5
          offsets = size(trial_courses, 2);
        end
        if iTrialtype > 4
          trial_courses(iTrialtype, onsets) = 1;
        else
          trial_courses(iTrialtype, onsets:offsets) = 1;
        end

      end

      % trim trial course
      trial_courses(:, length(respiration) + 1:end) = [];

      %%
      % make figure
      figure('name', physio_file{iRun}, 'position', [50 50 1300 700], 'visible', visible);

      hold on;

      % plot stimuli
      for iStim = 1:4
        plot(trial_courses(iStim, :), stim_color{iStim}, 'linewidth', 2);
      end

      % plot responses
      plot(trial_courses(5, :) * .5, '--k', 'linewidth', 1.5);
      plot(trial_courses(6, :) * .5, 'k', 'linewidth', 1.5);

      % plot breathing
      % plot(respiration, 'b', 'linewidth', 2)

      set(gca, 'xtick', [],  'ytick', []);
      axis tight;

      legend(Legend);

      % plot framewise displacement on a different axis
      % (no resamling required as we have different number of times points)
      h_ax_1 = gca;
      h_ax_2 = axes('position', get(h_ax_1, 'position'));

      plot(1:numel(fd), fd, 'b', 'linewidth', 2);

      set(h_ax_2, 'color', 'none', 'YAxisLocation', 'right', ...
          'ytick', 0:.25:3, ...
          'yticklabel', 0:.25:3);

      axis tight;

      ax = axis;
      axis([ax(1) ax(2) 0 3]);

      %%
      file = deblank(confounds_files(confound_2_load(iRun), :));
      [~, file, ~] = fileparts(file(1:end - 3));
      print(gcf, fullfile(out_dir, [file '.jpeg']), '-djpeg');

      filenames{end + 1, 1} = [file '.jpeg']; %#ok<*SAGROW>

    end
  end
end
