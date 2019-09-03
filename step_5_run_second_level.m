% runs group level on the olf blind data and export the results corresponding to those
% published in the NIDM format



%% parameters
clear
clc

debug_mode = 0;

machine_id = 2;% 0: container ;  1: Remi ;  2: Beast

%% setting up
% setting up directories
[data_dir, code_dir, output_dir, fMRIprep_DIR] = set_dir(machine_id);


% listing subjects
folder_subj = get_subj_list(output_dir);
folder_subj = cellstr(char({folder_subj.name}')); % turn subject folders into a cellstr

opt = [];

% Get which participant is in which group
participants_file = fullfile(data_dir, 'raw' ,'participants.tsv');
participants = spm_load(participants_file);
group_id = ~cellfun(@isempty, strfind(participants.participant_id, 'ctrl'));

% remove excluded subjects
[participants, group_id, folder_subj] = rm_subjects(participants, group_id, folder_subj, true);

folder_subj

nb_subj = numel(folder_subj);


%% figure out which GLMs to run
% set up all the possible of combinations of GLM possible given the
% different analytical options we have
[sets] = get_cfg_GLMS_to_run();
[opt, all_GLMs] = set_all_GLMS(opt, sets);


%%
%%
contrast_ls = {
    'Euc-Left + Alm-Left + Euc-Right + Alm-Right > 0';
    'Euc-Left + Alm-Left + Euc-Right + Alm-Right < 0'
    'Euc-Left > 0';
    'Euc-Left < 0';
    'Alm-Left > 0';
    'Alm-Left < 0';
    'Euc-Right > 0';
    'Euc-Right < 0';
    'Alm-Right > 0';
    'Alm-Right < 0';
    'resp-03 > 0';
    'resp-03 < 0';
    'resp-12 > 0';
    'resp-12 < 0'};


%%
for iGLM = 1:size(all_GLMs)
    
    %% get configuration for this GLM
    cfg = get_configuration(all_GLMs, opt, iGLM);
    
    
    % set output dir for this GLM configutation
    analysis_dir = name_analysis_dir(cfg);
    grp_lvl_dir = fullfile (output_dir, 'group', analysis_dir );
    mkdir(grp_lvl_dir)
    
    contrasts_file_ls = struct('con_name', {}, 'con_file', {});
    
    
    %% list the fields
    for isubj = 1:nb_subj
        
        subj_lvl_dir = fullfile ( ...
            output_dir, folder_subj{isubj}, 'stats', analysis_dir);
        
        fprintf('\nloading SPM.mat %s',  folder_subj{isubj})
        load(fullfile(subj_lvl_dir, 'SPM.mat'))
        
        %% Stores names of the contrast images
        for iCtrst = 1:numel(contrast_ls)
            
            contrasts_file_ls(isubj).con_name{iCtrst,1} = ...
                SPM.xCon(iCtrst).name;
            
            contrasts_file_ls(isubj).con_file{iCtrst,1} = ...
                fullfile(subj_lvl_dir, SPM.xCon(iCtrst).Vcon.fname);
            
            if ~exist(contrasts_file_ls(isubj).con_file{iCtrst,1}, 'file')
                error('file not found')
            end
            
        end
        
    end
    
    
    %% ttest
    for i_ttest = 1:2
        
        switch i_ttest
            case 1
                % Motor responses
                cdts = {'resp-03 > 0'}; %#ok<*NASGU>
                ctrsts = {'resp-03 > 0'};
                subdir_name = 'resp-03';
            case 2
                % Motor responses
                cdts = {'resp-12 > 0'}; %#ok<*NASGU>
                ctrsts = {'resp-12 > 0'};
                subdir_name = 'resp-12';
                
        end
        
        ctrsts %#ok<*NOPTS>
        
        for iGroup = 1:2
            
            if iGroup==1
                grp_name = 'blnd';
                subj_to_include = find(group_id(1:nb_subj)==0);
            else
                grp_name = 'ctrl';
                subj_to_include = find(group_id(1:nb_subj)==1);
            end
            
            grp_name
            
            % identify the right con images for each subject to bring to
            % the grp lvl as summary stat
            
            [scans, con_names]= scans_for_grp_lvl(contrast_ls, ctrsts, contrasts_file_ls, subj_to_include)
            
            con_names
            
            scans'
            
            matlabbatch = [];
            matlabbatch = set_ttest_batch(matlabbatch, ...
                fullfile(grp_lvl_dir, grp_name), ...
                scans, ...
                {subdir_name}, ...
                {'>'});
            
            spm_jobman('run', matlabbatch)
        end
        
    end
    
    %% two sample ttest
    
    % Equal range vs. equal indifference:
    %
    % Greater positive response to losses in amygdala for equal range condition vs. equal indifference condition.
    
    %     % Positive effect
    %     cdts = {' gamble_trialxloss^1*bf(1) > 0'};
    %     ctrsts = {'gamble_trialxloss>0'};
    %     subdir_name = 'loss_sup_baseline_range_sup_indiff';
    %
    %     % identify the right con images for each subject to bring to
    %     % the grp lvl as summary stat
    %     subj_to_include = find(group_id(1:nb_subj)==1);
    %     scans1 = scans_for_grp_lvl(contrast_ls, ctrsts, contrasts_file_ls, subj_to_include)
    %
    %     subj_to_include = find(group_id(1:nb_subj)==0);
    %     scans2 = scans_for_grp_lvl(contrast_ls, ctrsts, contrasts_file_ls, subj_to_include)
    %
    %     scans{1,1} =  scans1;
    %     scans{2,1} =  scans2;
    %
    %     matlabbatch = [];
    %     matlabbatch = set_ttest_batch(matlabbatch, ...
    %         fullfile(grp_lvl_dir), ...
    %         scans, ...
    %         {subdir_name}, ...
    %         {'>'});
    %
    %     spm_jobman('run', matlabbatch)
    
end
