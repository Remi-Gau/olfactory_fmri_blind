% runs subject level on the olf blind data:
% This pipeline should allow to run all the possible combinations of options
% for the GLM: this is currentlyy defined in the set_all_GLMS.m subfunction
% but should eventually be partly moved out of it.

% Garden of forking paths: GoFP
% for the possible options of subject level GLM see the functions:
%  - set_all_GLMS.m: that lists all the possible options of GLM to run
%  - get_cfg_GLMS_to_run.m: sets the GLM that will actually be run

% TO DO:


%% parameters
clear
clc

debug_mode = 1;

machine_id = 1;% 0: container ;  1: Remi ;  2: Marco
smoothing_prefix = '';
filter =  '.*.nii$'; % to unzip only the files in MNI space

if debug_mode
    smoothing_prefix = '';
    filter =  '.*.nii$';
end

%% set options
opt.task = {'olfid' 'olfloc'};


%% setting up
% setting up directories
[data_dir, code_dir, output_dir, fMRIprep_DIR] = set_dir(machine_id);

spm('defaults','fmri')

% get date info
bids =  spm_BIDS(data_dir);

if debug_mode
    output_dir = data_dir;
end

data_dir
code_dir
output_dir

% listing subjects
folder_subj = get_subj_list(output_dir);
folder_subj = cellstr(char({folder_subj.name}')); % turn subject folders into a cellstr
nb_subjects = numel(folder_subj);

if debug_mode
    nb_subjects = 3;
end


% get metadate from BIDS
metadata = spm_BIDS(bids, 'metadata', ...
            'type', 'bold');
opt.nb_slices = numel(metadata{1}.SliceTiming);
opt.TR = metadata{1}.RepetitionTime;
opt.slice_reference = round(opt.nb_slices/2);






% manually specify prefix of the images to use
opt.prefix = smoothing_prefix;
opt.suffix = filter;

%% figure out which GLMs to run
% set up all the possible of comb   inations of GLM possible given the
% different analytical options we have
[sets] = get_cfg_GLMS_to_run();
[opt, all_GLMs] = set_all_GLMS(opt, sets);


%% for each subject

for isubj = 1:nb_subjects
    
    fprintf('running %s\n', folder_subj{isubj})
    
    subj_dir = fullfile(output_dir, [folder_subj{isubj}], 'func')
    
    
    %%  get data onsets and confounds for each run
    fprintf(' getting data, onsets and confounds\n')
    
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
            [~, filename] = spm_fileparts(source_data_file{1});
            data{iSes,1} = spm_select('FPList', ...
                subj_dir, ...
                ['^' opt.prefix filename opt.suffix ] ); %#ok<*SAGROW>
            
            
            source_event_file = spm_BIDS(bids, 'data', ...
                'type', 'events', ...
                'sub', folder_subj{isubj}, ...
                'task', opt.task(iTask), ...
                'run', runs{iRun});
            [path, filename] = spm_fileparts(source_event_file{1});
            % get onsets for all the conditions and blocks as well as each trial caracteristics
            events{iSes,1} = spm_select('FPList', ...
                path, ...
                ['^' filename '.mat$'] );

            
            %         % list realignement parameters and other fMRIprep data for each run
            %         confounds_file = strrep( source_file, ...
            %             '_space-MNI152NLin2009cAsym_preproc.nii', ...
            %             '_confounds.tsv');
            %         confounds{iRun} = spm_load(confounds_file); %#ok<*SAGROW>
            if debug_mode
                confounds{iSes, 1} = '';
            end
            
            iSes = iSes +1;
        end
        
    end
    
    disp(data)
    disp(events)
    disp(confounds)
    
    
    %% now we specify the batch and run the GLMs
    % or just a subset of GLMs ; see set_all_GLMS.m for more info
    fprintf(' running GLMs\n')
    for iGLM = 1:size(all_GLMs)
        
        tic
        
        % get configuration for this GLM
        cfg = get_configuration(all_GLMs, opt, iGLM);
        cfg.confounds = {[]};
        disp(cfg)
        
        % create the directory for this specific analysis
        analysis_dir = name_analysis_dir(cfg);
        analysis_dir = fullfile ( ...
            output_dir, ...
            folder_subj{isubj}, 'stats', analysis_dir );
        [~, ~, ~] = mkdir(analysis_dir);
        
        % to remove any previous analysis so that the whole thing does not
        % crash
        delete(fullfile(analysis_dir,'SPM.mat'))

        matlabbatch = [];
        
        % set the basic batch for this GLM
        matlabbatch = ...
            subject_level_GLM_batch(matlabbatch, 1, analysis_dir, opt, cfg);
        
        % for each run
        for iRun = 1:size(data,1)
            
            % adds run specific parameters
            matlabbatch = ...
                set_session_GLM_batch(matlabbatch, 1, data, events, iRun, cfg);
            
            % adds extra regressors (RT param mod, movement, ...) for this
            % run
            matlabbatch = ...
                set_extra_regress_batch(matlabbatch, 1, iRun, cfg, confounds);
            
        end
        
        % estimate design
        matlabbatch{end+1}.spm.stats.fmri_est.spmmat{1,1} = fullfile(analysis_dir, 'SPM.mat');
        matlabbatch{end}.spm.stats.fmri_est.method.Classical = 1;
        
        save(fullfile(analysis_dir,'GLM_matlabbatch.mat'), 'matlabbatch')
        
        spm_jobman('run', matlabbatch)
        
        % estimate contrasts
%         matlabbatch = [];
%         matlabbatch = set_t_contrasts(analysis_dir);
%         
%         spm_jobman('run', matlabbatch)
%         
%         save(fullfile(analysis_dir,'contrast_matlabbatch.mat'), 'matlabbatch')
%         
%         toc
        
    end
    
    
end
