function folder_subj = get_subj_list(folder_path)
  % List all the subjects in a BIDS like data structure (could be a
  % derivative folder)

  % Get a list of all files and folders in this folder.
  folder_main = dir(folder_path);
  % Remove . and ..
  folder_main(ismember({folder_main.name}, {'.', '..'})) = [];
  % Get a logical vector that tells which is a directory.
  dir_flags = [folder_main.isdir];
  % Extract only those that are directories.
  folder_subj = folder_main(dir_flags);
  % Extract only those that are subj folders.
  folder_subj(~strncmp({folder_subj.name}, {'sub'}, 3)) = [];

end
