function folder_subj = get_subj_list(folder_path)
% List all the subjects in a BIDS like data structure (could be a
% derivative folder)

% subjects list given by the NARPS project: to send a warning if we are
% missing subjects
subj_ls = [...
    1:6, 8:11, 13:22, 24:27, 29:30, 32:33, 35:41, 43:47, 49:64, ...
    66:77, 79:85, 87:90, 92:96, 98:100, 102:110, 112:121, 123:124];

% Get a list of all files and folders in this folder.
folder_main = dir(folder_path);
% Remove . and ..
folder_main(ismember( {folder_main.name}, {'.', '..'})) = [];
% Get a logical vector that tells which is a directory.
dir_flags = [folder_main.isdir];
% Extract only those that are directories.
folder_subj = folder_main(dir_flags);
% Extract only those that are subj folders.
folder_subj(~strncmp( {folder_subj.name}, {'sub'}, 3)) = [];

if numel(folder_subj)~=numel(subj_ls)
    warning('We seem to be missing some subjects')
end

end

