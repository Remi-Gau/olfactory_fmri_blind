% runs subject level on the olf blind data:
% This pipeline should allow to run all the possible combinations of options
% for the GLM: this is currentlyy defined in the set_all_GLMS.m subfunction
% but should eventually be partly moved out of it.
% (C) Copyright 2021 Remi Gau

% Garden of forking paths: GoFP
% for the possible options of subject level GLM see the functions:
%  - set_all_GLMS.m: that lists all the possible options of GLM to run
%  - get_cfg_GLMS_to_run.m: sets the GLM that will actually be run

%% parameters
clear;
clc;

debug_mode = 0;

space = 'MNI';

if ~exist('machine_id', 'var')
  machine_id = 1; % 0: container ;  1: Remi ;  2: Beast
end

% 'MNI' or  'T1w' (native)
if ~exist('space', 'var')
  space = 'MNI';
end

if ~exist('estimate_GLM', 'var')
  estimate_GLM = 1;
end

if debug_mode
  space = 'MNI';
  estimate_GLM = 1;
end

switch space
  case 'MNI'
    smoothing_prefix = 's-8_'; %#ok<*NASGU>
    filter =  '.*space-MNI152NLin2009cAsym_desc-preproc.*.nii$';
  case 'T1w'
    smoothing_prefix = 's-6_';
    filter =  '.*space-T1w_desc-preproc.*.nii$'; % for the files in native space
end

%% set options
opt.task = {'olfid' 'olfloc'};
opt.nb_vol = 295;

%% setting up
% setting up directories
[data_dir, code_dir, output_dir, fMRIprep_DIR] = set_dir(machine_id);

% get date info
bids =  spm_BIDS(fullfile(data_dir, 'raw'));

data_dir; %#ok<*NOPTS>
code_dir;
output_dir;

% listing subjects
folder_subj = get_subj_list(output_dir);
folder_subj = cellstr(char({folder_subj.name}')); % turn subject folders into a cellstr
[~, ~, folder_subj] = rm_subjects([], [], folder_subj, 1);
nb_subjects = numel(folder_subj);

if debug_mode
  nb_subjects = 1;
end

% get metadata from BIDS
metadata = spm_BIDS(bids, 'metadata', ...
                    'type', 'bold');
opt.nb_slices = numel(unique(metadata{1}.SliceTiming));
opt.TR = metadata{1}.RepetitionTime;
opt.slice_reference = round(opt.nb_slices / 2);

% manually specify prefix of the images to use
opt.prefix = smoothing_prefix;
opt.suffix = filter;

%% figure out which GLMs to run
% set up all the possible of comb   inations of GLM possible given the
% different analytical options we have
[sets] = get_cfg_GLMS_to_run();
[opt, all_GLMs] = set_all_GLMS(opt, sets);

%% for each subject

for isubj = 1 % 3:nb_subjects

  fprintf('running %s\n', folder_subj{isubj});

  subj_dir = fullfile(output_dir, [folder_subj{isubj}], 'func');

  %% get explicit mask
  fprintf(' getting mask\n');

  if strcmp(space, 'T1w')
    explicit_mask = create_mask(subj_dir, folder_subj{isubj}, space);
  else
    explicit_mask = fullfile(spm('dir'), 'tpm', 'mask_ICV.nii');
  end

  %%  get data onsets and confounds for each run
  fprintf(' getting data, onsets and confounds\n');

  iSes = 1;

  for iTask = 1:numel(opt.task)

    runs = spm_BIDS(bids, 'runs', ...
                    'type', 'events', ...
                    'sub', folder_subj{isubj}, ...
                    'task', opt.task(iTask));

    for iRun = 1:numel(runs)

      source_data_file = spm_BIDS(bids, 'data', ...
                                  'type', 'bold', ...
                                  'sub', folder_subj{isubj}, ...
                                  'task', opt.task(iTask), ...
                                  'run', runs{iRun});
      [~, bold_filename] = spm_fileparts(source_data_file{1});
      bold_filename = strrep(bold_filename, '_bold', '');
      data{iSes, 1} = spm_select('FPList', ...
                                 subj_dir, ...
                                 ['^' opt.prefix bold_filename opt.suffix]); %#ok<*SAGROW>

      source_event_file = spm_BIDS(bids, 'data', ...
                                   'type', 'events', ...
                                   'sub', folder_subj{isubj}, ...
                                   'task', opt.task(iTask), ...
                                   'run', runs{iRun});
      [path, filename] = spm_fileparts(source_event_file{1});
      % get onsets for all the conditions and blocks as well as each trial caracteristics
      events{iSes, 1} = spm_select('FPList', ...
                                   subj_dir, ...
                                   ['^'  filename '.mat$']);

      % list realignement parameters and other fMRIprep data for each run
      confound_file = spm_select('FPList', ...
                                 subj_dir, ...
                                 ['^' bold_filename '.*confounds.*.tsv$']);
      confounds{iSes, 1} = spm_load(confound_file); %#ok<*SAGROW>

      iSes = iSes + 1;
    end

  end

  disp(data);
  disp(events);
  disp(confounds);

  %% now we specify the batch and run the GLMs
  % or just a subset of GLMs ; see set_all_GLMS.m for more info
  fprintf(' running GLMs\n');
  for iGLM = 1:size(all_GLMs)

    tic;

    % get configuration for this GLM
    cfg = get_configuration(all_GLMs, opt, iGLM);

    disp(cfg);

    % create the directory for this specific analysis
    analysis_dir = name_analysis_dir(cfg, space);
    analysis_dir = fullfile ( ...
                             output_dir, ...
                             folder_subj{isubj}, 'stats', analysis_dir);
    [~, ~, ~] = mkdir(analysis_dir);
    mkdir(fullfile(analysis_dir, 'jobs'));

    % to remove any previous analysis so that the whole thing does not
    % crash
    delete(fullfile(analysis_dir, 'SPM.mat'));

    matlabbatch = [];

    % define the explicit mask for this GLM if specified
    if cfg.explicit_mask
      cfg.explicit_mask = explicit_mask;
    else
      cfg.explicit_mask = '';
    end

    % set the basic batch for this GLM
    matlabbatch = ...
        subject_level_GLM_batch(matlabbatch, 1, analysis_dir, opt, cfg);

    % for each run
    for iRun = 1:size(data, 1)

      % adds run specific parameters
      matlabbatch = ...
          set_session_GLM_batch(matlabbatch, 1, data, events, iRun, cfg, opt);

      % adds extra regressors (RT param mod, movement, ...) for this
      % run
      matlabbatch = ...
          set_extra_regress_batch(matlabbatch, 1, iRun, cfg, confounds, opt);

    end

    % estimate design
    if estimate_GLM
      matlabbatch{end + 1}.spm.stats.fmri_est.spmmat{1, 1} = fullfile(analysis_dir, 'SPM.mat');
      matlabbatch{end}.spm.stats.fmri_est.method.Classical = 1;
      if  strcmp(space, 'MNI')
        matlabbatch{end}.spm.stats.fmri_est.write_residuals = 1;
      end
    end

    save(fullfile(analysis_dir, 'jobs', 'GLM_matlabbatch.mat'), 'matlabbatch');

    spm_jobman('run', matlabbatch);

    if estimate_GLM
      if  strcmp(space, 'MNI')
        plot_power_spectra_of_GLM_residuals( ...
                                            analysis_dir, ...
                                            opt.TR, 1 / cfg.HPF, 12, 24);
      end
    end

    toc;

  end

end
