% create a group mask that only inlcudes the voxels that are present in the
% masks of at least 80% the subjects' GLMs masks

clear;
clc;

%% set up
machine_id = 2;% 0: container ;  1: Remi ;  2: Beast
[data_dir, code_dir, output_dir] = set_dir(machine_id);

target_file = fullfile(code_dir, 'output', 'images', 'group_mask.nii');

%%
mkdir(fullfile(code_dir, 'output', 'images'));

% get all the GLM masks
mask_files = spm_select('FPListRec', output_dir, '^mask.nii$');

% remove the group level GLM masks
to_rm = strfind(cellstr(mask_files), 'group');
to_rm = ~cellfun(@isempty, to_rm); %#ok<*STRCLFH>
mask_files(to_rm, :) = [];

% open all the masks
hdr = spm_vol(mask_files);
vol = spm_read_vols(hdr);

% only includes voxels that are present in more than 80% of the subjects
vol = any(sum(vol, 4) / size(vol, 4) > .8, 4);

hdr = hdr(1);
hdr.fname = target_file;

spm_write_vol(hdr, vol);
