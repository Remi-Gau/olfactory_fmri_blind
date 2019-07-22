function unzip_fmriprep(folder_path, filter)

% Function to unzip '.gz' files, tested on octave
% folder_path : path of the data set to browse through and unpack
% filter : string pattern to select specific files to unzip - must be
% regular expression compatible to work with spm_select
%
% written by mb, 23/01/2019
%
% history:
% 25/01/2019 - mb, add a sub function to unpack the files
% 27/01/2019 - mb, check if a path is provided and if exists

tic

% Check if a path is provided and if exists
if nargin == 0
    error('Please provide a folder path')
elseif ~exist(folder_path, 'dir')
    error('The path is not a folder, please insert a valid folder path')
end

% if no filter for spm_select is given we will select and unzip all .nii.gz
% files
if nargin < 2
    filter = '^*.nii.gz$';
end

folder_subj = get_subj_list(folder_path);

% Loop across folder and unpack .gz files
parfor k = 1 : length(folder_subj)
    fprintf('\nSub folder #%d = %s\n', k, folder_subj(k).name);
    % Anatomical data
    fprintf('\n Unpacking anat\n');
    % Build subj folder path
    folder_files = fullfile(folder_path, folder_subj(k).name, 'anat');
    % Check if there are .gz file, then unpack them
    unpack_gz(folder_files, filter)
    % Functional data
    fprintf('\n Unpacking func\n');
    % Build subj folder path
    folder_files = fullfile(folder_path, folder_subj(k).name, 'func');
    % Check if there are .gz file, then unpack them
    unpack_gz(folder_files, filter)
end

toc

end


function unpack_gz(folder_files, filter)

% Make a list of the file in it with '.gz' extension
file_list = spm_select('FPList', folder_files, filter);

if ~isempty(file_list)
    % Unzip the '.gz' files
    for ifile = 1:size(file_list,1)
        
        % Print the file name
        fprintf('\n  Unpacking file #%d of %d\n', ifile, size(file_list,1));
        file_name = strsplit(file_list(ifile,:), filesep);
        fprintf('  %s\n', cell2mat(file_name(size(file_name,2))));
        
        gunzip(file_list(ifile,:));
    end
else
    fprintf('\nno ".gz" files to unpack\n')
end

end
