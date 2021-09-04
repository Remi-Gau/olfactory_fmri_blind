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
clc;

debug_mode = 0;

space = 'MNI';

if ~exist('machine_id', 'var')
  machine_id = 2; % 0: container ;  1: Remi ;  2: Beast
end

% 'MNI' or  'T1w' (native)
if ~exist('space', 'var')
  space = 'MNI';
end

%%
opt.contrast_ls = {
                   {'Euc-Left', 'Alm-Left', 'Euc-Right', 'Alm-Right'}; ...
                   {'Alm-Left', 'Alm-Right'}; ...
                   {'Euc-Left', 'Euc-Right'}; ...
                   {'Euc-Right', 'Alm-Right'}; ...
                   {'Euc-Left', 'Alm-Left'}; ...
                   {'Euc-Left'}; ...
                   {'Alm-Left'}; ...
                   {'Euc-Right'}; ...
                   {'Alm-Right'}; ...
                   {'resp-03', 'resp-12'}};

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

%% figure out which GLMs to run
% set up all the possible of comb   inations of GLM possible given the
% different analytical options we have
[sets] = get_cfg_GLMS_to_run();
[opt, all_GLMs] = set_all_GLMS(opt, sets);

%% for each subject

for isubj = 1:nb_subjects

  fprintf('running %s\n', folder_subj{isubj});

  subj_dir = fullfile(output_dir, [folder_subj{isubj}], 'func');

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

    %  estimate contrasts
    matlabbatch = [];
    matlabbatch = set_t_contrasts(analysis_dir, opt.contrast_ls);

    spm_jobman('run', matlabbatch);

    save(fullfile(analysis_dir, 'jobs', 'contrast_matlabbatch.mat'), 'matlabbatch');

  end

end
