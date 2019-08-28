% model comparison using the SPM MACs toolbox


%% parameters
clc
clear

 space = 'MNI';

if ~exist('machine_id', 'var')
    machine_id = 2;% 0: container ;  1: Remi ;  2: Beast
end

% 'MNI' or  'T1w' (native)
if ~exist('space', 'var')
    space = 'T1w';
end


%% setting up
% setting up directories
[data_dir, code_dir, output_dir, fMRIprep_DIR] = set_dir(machine_id);

spm('defaults','fmri')

% get date info
bids =  spm_BIDS(fullfile(data_dir, 'raw'));

data_dir %#ok<*NOPTS>
code_dir
output_dir

% listing subjects
folder_subj = get_subj_list(output_dir);
folder_subj = cellstr(char({folder_subj.name}')); % turn subject folders into a cellstr
[~, ~, folder_subj] = rm_subjects([], [], folder_subj, 1)
nb_subjects = numel(folder_subj);


%% figure out which GLMs to run
% set up all the possible of comb   inations of GLM possible given the
% different analytical options we have
opt =  struct();
[sets] = get_cfg_GLMS_to_run();
[opt, all_GLMs] = set_all_GLMS(opt, sets);


%% Set batch

matlabbatch{1}.spm.tools.MACS.MA_model_space.dir = {output_dir};

matlabbatch{1}.spm.tools.MACS.MA_model_space.names = {
    'GLM_FD-whi-CSF'
    'GLM_trans-rot'
    'GLM_FD-whi-CSF-trans-rot'
    'GLM_FD-whi-CSF-trans-rot-tcomcor'}
matlabbatch{1}.spm.tools.MACS.MA_model_space.names = {
    'GLM_FD-whi-CSF-trans-rot-tcomcor'}

for isubj = 1:nb_subjects

    subj_dir = fullfile(output_dir, [folder_subj{isubj}], 'func')
    
    
    for iGLM = 1:size(all_GLMs)

        % get configuration for this GLM
        cfg = get_configuration(all_GLMs, opt, iGLM);

        % create the directory for this specific analysis
        analysis_dir = name_analysis_dir(cfg, space);
        analysis_dir = fullfile ( ...
            output_dir, ...
            folder_subj{isubj}, 'stats', analysis_dir );
        
        matlabbatch{1}.spm.tools.MACS.MA_model_space.models{1,isubj}{1,iGLM} = ...
            {fullfile(analysis_dir, 'SPM.mat')};
        
    end
end

matlabbatch{2}.spm.tools.MACS.MA_cvLME_auto.MS_mat(1) = ...
    cfg_dep('MA: define model space: model space (MS.mat file)', ...
    substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','MS_mat'));
matlabbatch{2}.spm.tools.MACS.MA_cvLME_auto.AnC = 0;

matlabbatch{3}.spm.tools.MACS.MS_PPs_group_auto.MS_mat(1) = ...
    cfg_dep('MA: define model space: model space (MS.mat file)', ...
    substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','MS_mat'));
matlabbatch{3}.spm.tools.MACS.MS_PPs_group_auto.LME_map = 'cvLME';

matlabbatch{4}.spm.tools.MACS.MS_BMS_group_auto.MS_mat(1) = ...
    cfg_dep('MA: define model space: model space (MS.mat file)', ...
    substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','MS_mat'));
matlabbatch{4}.spm.tools.MACS.MS_BMS_group_auto.LME_map = 'cvLME';
matlabbatch{4}.spm.tools.MACS.MS_BMS_group_auto.inf_meth = 'RFX-VB';
matlabbatch{4}.spm.tools.MACS.MS_BMS_group_auto.EPs = 0;

matlabbatch{5}.spm.tools.MACS.MS_SMM_BMS.BMS_mat(1) = ...
    cfg_dep('MS: perform BMS (automatic): BMS results (BMS.mat file)', ...
    substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','BMS_mat'));
matlabbatch{5}.spm.tools.MACS.MS_SMM_BMS.extent = 10;


spm_jobman('run', matlabbatch)