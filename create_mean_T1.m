% script to create mean structural (normalized smoothed and masked)

% TO DO:
% make one for each group???

%% parameters
clear;
clc;

debug_mode = 0;

machine_id = 1; % 0: container ;  1: Remi ;  2: Beast

%% setting up
% setting up directories
[data_dir, code_dir, output_dir, fMRIprep_DIR] = set_dir(machine_id);

%% get and read files
anat_files = spm_select('FPListRec', output_dir, '^sub.*_T1w.nii$');

target_file = fullfile(code_dir, 'output', 'images', 's8_group_T1.nii');

mask_file = fullfile(code_dir, 'output', 'images', 'group_mask.nii');

mkdir(fullfile(code_dir, 'output', 'images'));

hdr = spm_vol(anat_files);
vol = spm_read_vols(hdr);

hdr_mask = spm_vol(mask_file);
mask = spm_read_vols(hdr_mask);

% average and smooth
vol = mean(vol, 4);
spm_smooth(vol, vol, 8);

% save
hdr = hdr(1);
hdr.fname = target_file;
spm_write_vol(hdr, vol);

% reslice to mask resolution
flag.which = 1;
flag.mean = false;
flag.prefix = '';
spm_reslice({mask_file;target_file}, flag);

% mask mean image
hdr = spm_vol(target_file);
vol = spm_read_vols(hdr);
vol(mask == 0) = 0;
spm_write_vol(hdr, vol);
