clear

clc


% Set up the SPM defaults, just in case
spm('defaults', 'fmri');

addpath(...
    fullfile(spm('dir'), 'toolbox', 'marsbar') )

% Start marsbar to make sure spm_get works
marsbar('on')

machine_id = 1;% 0: container ;  1: Remi ;  2: Beast
% setting up directories
[data_dir, code_dir, output_dir, fMRIprep_DIR] = set_dir(machine_id);

space = 'T1w';

% get data info
bids =  spm_BIDS(fullfile(data_dir, 'raw'));

% get subjects
folder_subj = get_subj_list(output_dir);
folder_subj = cellstr(char({folder_subj.name}')); % turn subject folders into a cellstr
nb_subjects = numel(folder_subj);


% see what GLM to run
opt = struct();
[sets] = get_cfg_GLMS_to_run();
[opt, all_GLMs] = set_all_GLMS(opt, sets);


% event specification for getting fitted event time-courses
contrast_idx = 1 ;
event_session_no = repmat(1:4, 1, 4);
event_type_no = repmat([1:4]', 1, 4)';
event_spec = [event_session_no; event_type_no(:)'];
event_duration = 16; % default SPM event duration

%% for each subject

for isubj = 1%:nb_subjects
    
    fprintf('running %s\n', folder_subj{isubj})
    
    subj_dir = fullfile(output_dir, [folder_subj{isubj}])
    
    roi_src_folder = fullfile(data_dir, 'derivatives', 'ANTs', folder_subj{isubj}, 'roi');
    
    roi_tgt_folder = fullfile(subj_dir, 'roi');
    mkdir(roi_tgt_folder)
    
    % list ROIs
    roi_ls =  spm_select('FPList', ...
        roi_src_folder, ...
        '^ROI.*_space-T1w.nii$');
    roi_ls = cellstr(roi_ls);

    
    fprintf(' running GLMs\n')
    for iGLM = 1:size(all_GLMs)
        
        cfg = get_configuration(all_GLMs, opt, iGLM);
        
        % directory for this specific analysis
        analysis_dir = name_analysis_dir(cfg, space);
        analysis_dir = fullfile ( ...
            output_dir, ...
            folder_subj{isubj}, 'stats', analysis_dir );
        
        SPM = load(fullfile(analysis_dir, 'SPM.mat'));
        
        for roi_no = 1%:size(roi_array,1)
            
            roi = roi_ls{roi_no};
            [path, file] = spm_fileparts(roi);

            % create ROI object for Marsbar and convert to matrix format to avoid delicacies of image format
            roi_obj = maroi_image(struct('vol', spm_vol(roi), 'binarize',1,...
                'func', []));
            roi_obj = maroi_matrix(roi_obj);
            % give it a label
            label(roi_obj, strrep(file, 'ROI-', ''));
            saveroi(roi_obj, fullfile(roi_tgt_folder, [file '_roi.mat']));
            
            D = mardo(SPM);
            
            % Extract data
            Y = get_marsy(roi_obj, D, 'mean');
            
            % MarsBaR estimation
            E = estimate(D, Y);

            % Get, store statistics
            stat_struct = compute_contrasts(E, contrast_idx);
            
            % And fitted time courses
            [tc, dt] = event_fitted(E, event_spec, event_duration);
            
            %
            psc = event_signal(E, event_spec, event_duration, 'abs max')
            
            % Make fitted time course into ~% signal change
            tc = tc / block_means(E) * 100;
            
            %             % Show calculated t statistics and contrast values
            %             % NB this next line only works when we have only one stat/contrast
            %             % value per analysis
            %             vals = [ [1 3]; [stat_struct(:).con]; [stat_struct(:).stat]; ];
            %             fprintf('Statistics for %s\n', label(roi));
            %             fprintf('Session %d; contrast value %5.4f; t stat %5.4f\n', vals);
            
            % Show fitted event time courses
            figure
            secs = [0:length(tc) - 1] * dt;
            plot(secs, tc)
            title(['Time courses for ' label(roi_obj)], 'Interpreter', 'none');
            xlabel('Seconds')
            ylabel('% signal change');
        end
    end
    
    
end
