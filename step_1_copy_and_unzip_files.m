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

machine_id = 1;% 0: container ;  1: Remi ;  2: Beast

% 'MNI' or  'T1w' (native)
space = 'T1w';

subj_to_do = [1]; % to only try on a couple of subjects; comment out to run on all

switch space
    case 'MNI'
        filter =  'sub-.*space-MNI152NLin2009cAsym_desc-'; % to unzip only the files in MNI space
    case 'T1w'
        filter =  'sub-.*space-T1w_desc-'; % to unzip only the files in native space
end

%% setting up
% setting up directories
[data_dir, code_dir, output_dir, fMRIprep_DIR] = set_dir(machine_id);
spm('defaults','fmri')

% creating output sub-dirs in derivatives/spm12
[~, ~, ~] = mkdir(output_dir);
folder_subj = get_subj_list(fMRIprep_DIR);
folder_subj = cellstr(char({folder_subj.name}')); % turn subject folders into a cellstr

if ~exist('subj_to_do', 'var')
    subj_to_do = 1:numel(folder_subj);
end


%% copy files of interest to another folder ('derivatives/spm12')
sub_folders = {'anat', 'func'};

for i_subj = subj_to_do
    
    fprintf('\n%s', folder_subj{i_subj});
    
    sub_source_folder = fullfile(fMRIprep_DIR, folder_subj{i_subj});
    
    spm_mkdir(output_dir, folder_subj{i_subj}, {'anat','func'});
    
    for i_folder = 1:numel(sub_folders)
        
        fprintf('\n copying files from %s', sub_folders{i_folder});
        
        % files to copy
        if strcmp(sub_folders{i_folder}, 'func')
            filter_ls = {...
                [filter '.*brain_mask.*$']; ...
                [filter '.*preproc_bold.*$']};
        else
            filter_ls = {...
                [filter '.*brain_mask.*$']; ...
                [filter '.*T1w.*$']};
        end
        
        % choose and copy files
        for iFilter = 1:numel(filter_ls)
            tmp_filter = filter_ls{iFilter};
            file_list = spm_select('FPList', ...
                fullfile(sub_source_folder, sub_folders{i_folder}), ...
                tmp_filter);
            
            
            for i_file = 1:size(file_list,1)
                spm_copy(file_list(i_file,:), ...
                    fullfile(output_dir, folder_subj{i_subj}, sub_folders{i_folder}), ...
                    'nifti', true);
            end
        end
        
    end
    
    % copy *.txt and *.h5 files from anat (in case we want to do some normalization)
    copyfile(...
        fullfile(sub_source_folder, 'anat', '*.txt'), ...
        fullfile(output_dir, folder_subj{i_subj}, 'anat'));
    copyfile(...
        fullfile(sub_source_folder, 'anat', '*.h5'), ...
        fullfile(output_dir, folder_subj{i_subj}, 'anat'));
    
    % copy confound*.tsv files from func
    copyfile(...
        fullfile(sub_source_folder, 'func', '*.tsv'), ...
        fullfile(output_dir, folder_subj{i_subj}, 'func'));
    
    % copy *events.tsv files from func
    copyfile(...
        fullfile(data_dir, 'raw', folder_subj{i_subj}, 'func', '*.tsv'), ...
        fullfile(output_dir, folder_subj{i_subj}, 'func'));
    
    % copy *physio.tsv.gz files from func
    copyfile(...
        fullfile(data_dir, 'raw', folder_subj{i_subj}, 'func', '*physio.tsv.gz'), ...
        fullfile(output_dir, folder_subj{i_subj}, 'func'));
    
    
    fprintf('\n')
    
end

fprintf('\n Files transferred\n')

%% unzipping
unzip_fmriprep(output_dir, [filter '.*.nii.gz$'])
