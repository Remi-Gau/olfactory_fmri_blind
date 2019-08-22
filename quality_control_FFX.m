%% parameters
clear
clc

debug_mode = 0;

machine_id = 2;% 0: container ;  1: Remi ;  2: Beast


%% setting up
% setting up directories
[data_dir, code_dir, output_dir, fMRIprep_DIR] = set_dir(machine_id);

spm('defaults','fmri')

% get date info
bids =  spm_BIDS(fullfile(data_dir, 'raw'));

% listing subjects
folder_subj = get_subj_list(output_dir);
folder_subj = cellstr(char({folder_subj.name}')); % turn subject folders into a cellstr
nb_subjects = numel(folder_subj);

% get metadate from BIDS
metadata = spm_BIDS(bids, 'metadata', ...
            'type', 'bold');
opt.TR = metadata{1}.RepetitionTime;


%% figure out which GLMs to run
% set up all the possible of comb   inations of GLM possible given the
% different analytical options we have
[sets] = get_cfg_GLMS_to_run();
[opt, all_GLMs] = set_all_GLMS(opt, sets);


for isubj = 1%:nb_subjects
    
    fprintf('running %s\n', folder_subj{isubj})
    
%     subj_dir = fullfile(output_dir, [folder_subj{isubj}], 'func')
    
    %% now we specify the batch and run the GLMs
    % or just a subset of GLMs ; see set_all_GLMS.m for more info
    fprintf(' running GLMs\n')
    for iGLM = 1:size(all_GLMs)
        
        % get configuration for this GLM
        cfg = get_configuration(all_GLMs, opt, iGLM);
        
        disp(cfg)
        
        % create the directory for this specific analysis
        analysis_dir = name_analysis_dir(cfg);
        analysis_dir = fullfile ( ...
            output_dir, ...
            folder_subj{isubj}, 'stats', analysis_dir );
        [~, ~, ~] = mkdir(analysis_dir);
        
        plot_power_spectra_of_GLM_residuals(...
            analysis_dir, ...
            opt.TR, 1/cfg.HPF, 12, 24)
        
        
    end
end

