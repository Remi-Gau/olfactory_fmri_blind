%% script to unzip the fmriprep data

% example of docker command to run it
% docker run -it --rm \
% -v /c/Users/Remi/Documents/NARPS/:/data \
% -v /c/Users/Remi/Documents/NARPS/code/:/code/ \
% -v /c/Users/Remi/Documents/NARPS/derivatives/:/output \
% spmcentral/spm:octave-latest script '/code/step_1_copy_and_unzip_files.m'


%% parameters
clear
clc

machine_id = 1;% 0: container ;  1: Remi ;  2: Chris
filter =  'sub-.*space-MNI152NLin2009cAsym_desc-preproc'; % to unzip only the files in MNI space
% nb_subjects = 2; % to only try on a couple of subjects; comment out to run on all

%% setting up
% setting up directories
[data_dir, code_dir, output_dir, fMRIprep_DIR] = set_dir(machine_id);

% creating output sub-dirs in derivatives/spm12
[~, ~, ~] = mkdir(output_dir);
folder_subj = get_subj_list(fMRIprep_DIR);
folder_subj = cellstr(char({folder_subj.name}')); % turn subject folders into a cellstr
spm_mkdir(output_dir, folder_subj, {'anat','func'});

if ~exist('nb_subjects', 'var')
    nb_subjects = numel(folder_subj);
end

%% copy files of interest to another folder ('derivatives/spm12')
sub_folders = {'anat', 'func'};

for i_subj = 1:nb_subjects
    
    fprintf('\n%s', folder_subj{i_subj});
    
    sub_source_folder = fullfile(fMRIprep_DIR, folder_subj{i_subj});
    
    for i_folder = 1:numel(sub_folders)
        
        fprintf('\n copying files from %s', sub_folders{i_folder});
        
        % files to copy
        if strcmp(sub_folders{i_folder}, 'func')
            tmp_filter = [filter '.*bold.nii.gz$'];
        else
            tmp_filter = [filter '.*.nii.gz$'];
        end
        file_list = spm_select('FPList', ...
            fullfile(sub_source_folder, sub_folders{i_folder}), ...
            [tmp_filter]);
        
        % copy files
        for i_file = 1:size(file_list,1)
            spm_copy(file_list(i_file,:), ...
                fullfile(output_dir, folder_subj{i_subj}, sub_folders{i_folder}), ...
                'nifti', true);
        end
    end

    fprintf('\n')
    
end

fprintf('\n Files transferred\n')

%% unzipping
unzip_fmriprep(output_dir, filter)
