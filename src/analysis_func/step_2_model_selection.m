% (C) Copyright 2019 Remi Gau

% Comments:
%
% cvLME could not run for
% - ctrl-02
%
% Unsure why we only get 2 images in
% outputs/derivatives/cpp_spm-modelSelection/derivatives/cpp_spm-modelSelection/group/MS_SMM_BMS_10:
%
% - MS_SMM_map_pos_01_mod_03_No Derivative With Tissue Confounds No Scrubbing.nii
% - MS_SMM_map_pos_02_mod_01_No Derivative No Tissue Confounds No Scrubbing.nii
%

clear;
clc;

run ../../initEnv.m;

subjects = '.*[^ctrl02]';

models_files = list_models_files();

opt = opt_stats_subject_level();
opt.verbosity = 2;
opt.subjects = subjects;

% TODO: probably should not have to be that heavy handed to save things in a
% different directory
% - getFFXDir seems to always create things in opt.dir.stats and not opt.dir.output
opt.dir.output = spm_file(fullfile(opt.dir.stats, '..', 'cpp_spm-modelSelection'), 'cpath');
opt.dir.stats = opt.dir.output;

for i = 1:numel(models_files)

  opt.toolbox.MACS.model.files{end + 1} = fullfile(fileparts(mfilename('fullpath')), ...
                                                   'models', ...
                                                   models_files{i});

end

% to run all steps at once
%
% bidsModelSelection(opt, 'action', 'cvLME');

% or one by one
%
% bidsModelSelection(opt, 'action', 'cvLME');
bidsModelSelection(opt, 'action', 'BMS');
