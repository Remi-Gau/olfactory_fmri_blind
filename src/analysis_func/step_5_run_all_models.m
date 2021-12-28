% (C) Copyright 2019 Remi Gau

clear;
clc;

run ../../initEnv.m;

models = {'Hrf'; 'HrfTemp'; 'HrfTempDisp'};
% models = {'HrfNoTissueConfounds'; 'HrfTempNoTissueConfounds'; 'HrfTempDispNoTissueConfounds'};

for i = 1:numel(models)

  model_file = fullfile(fileparts(mfilename('fullpath')), ...
                        'models', ...
                        ['model-' models{i} '_smdl.json']);

  opt = opt_stats_subject_level();

  opt.model.file = model_file;

  bidsFFX('specifyAndEstimate', opt);
  bidsFFX('contrasts', opt);
  bidsResults(opt);

  opt = opt_stats_group_level();

  opt.model.file = model_file;

  bidsRFX('RFX', opt);
  bidsResults(opt);

end

return

%% parameters

%% figure out which GLMs to run
% set up all the possible of comb   inations of GLM possible given the
% different analytical options we have
opt =  struct();
[sets] = get_cfg_GLMS_to_run();
[opt, all_GLMs] = set_all_GLMS(opt, sets);

%% Set batch

matlabbatch{1}.spm.tools.MACS.MA_model_space.dir = {output_dir};

% matlabbatch{1}.spm.tools.MACS.MA_model_space.names = {
%     'GLM_FD-whi-CSF'
%     'GLM_trans-rot'
%     'GLM_FD-whi-CSF-trans-rot'
%     'GLM_FD-whi-CSF-trans-rot-tcomcor'}
matlabbatch{1}.spm.tools.MACS.MA_model_space.names = {
                                                      'GLM_FD-whi-CSF'
                                                      'GLM_trans-rot'
                                                      'GLM_FD-whi-CSF-trans-rot'};

for isubj = 1:nb_subjects

  subj_dir = fullfile(output_dir, [folder_subj{isubj}], 'func');

  for iGLM = 1:size(all_GLMs)

    % get configuration for this GLM
    cfg = get_configuration(all_GLMs, opt, iGLM);

    % create the directory for this specific analysis
    analysis_dir = name_analysis_dir(cfg, space);
    analysis_dir = fullfile ( ...
                             output_dir, ...
                             folder_subj{isubj}, 'stats', analysis_dir);

    matlabbatch{1}.spm.tools.MACS.MA_model_space.models{1, isubj}{1, iGLM} = ...
        {fullfile(analysis_dir, 'SPM.mat')};

  end
end

matlabbatch{2}.spm.tools.MACS.MA_cvLME_auto.MS_mat(1) = ...
    cfg_dep('MA: define model space: model space (MS.mat file)', ...
            substruct('.', 'val', '{}', {1}, '.', 'val', '{}', {1}, '.', 'val', '{}', {1}, '.', 'val', '{}', {1}), substruct('.', 'MS_mat'));
matlabbatch{2}.spm.tools.MACS.MA_cvLME_auto.AnC = 0;

matlabbatch{3}.spm.tools.MACS.MS_PPs_group_auto.MS_mat(1) = ...
    cfg_dep('MA: define model space: model space (MS.mat file)', ...
            substruct('.', 'val', '{}', {1}, '.', 'val', '{}', {1}, '.', 'val', '{}', {1}, '.', 'val', '{}', {1}), substruct('.', 'MS_mat'));
matlabbatch{3}.spm.tools.MACS.MS_PPs_group_auto.LME_map = 'cvLME';

matlabbatch{4}.spm.tools.MACS.MS_BMS_group_auto.MS_mat(1) = ...
    cfg_dep('MA: define model space: model space (MS.mat file)', ...
            substruct('.', 'val', '{}', {1}, '.', 'val', '{}', {1}, '.', 'val', '{}', {1}, '.', 'val', '{}', {1}), substruct('.', 'MS_mat'));
matlabbatch{4}.spm.tools.MACS.MS_BMS_group_auto.LME_map = 'cvLME';
matlabbatch{4}.spm.tools.MACS.MS_BMS_group_auto.inf_meth = 'RFX-VB';
matlabbatch{4}.spm.tools.MACS.MS_BMS_group_auto.EPs = 0;

matlabbatch{5}.spm.tools.MACS.MS_SMM_BMS.BMS_mat(1) = ...
    cfg_dep('MS: perform BMS (automatic): BMS results (BMS.mat file)', ...
            substruct('.', 'val', '{}', {4}, '.', 'val', '{}', {1}, '.', 'val', '{}', {1}, '.', 'val', '{}', {1}), substruct('.', 'BMS_mat'));
matlabbatch{5}.spm.tools.MACS.MS_SMM_BMS.extent = 10;

spm_jobman('run', matlabbatch);
