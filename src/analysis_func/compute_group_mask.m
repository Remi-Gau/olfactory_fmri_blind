% create a group mask that only inlcudes the voxels that are present in the
% masks of at least 80% the subjects' GLMs masks
%
% (C) Copyright 2021 Remi Gau

clear;
clc;

run ../../initEnv.m;

opt = opt_stats_group_level();

opt.dir.output = fullfile(opt.dir.stats, 'derivatives', 'cpp_spm-groupStats');

spm_mkdir(opt.dir.output);

p = struct( ...
           'suffix', 'mask', ...
           'entities', struct( ...
                              'sub', 'group', ...
                              'space', 'MNI152NLin2009cAsym', ...
                              'desc', 'brain'), ...
           'ext', '.nii');

bf = bids.File(p, false);

mask_file = fullfile(opt.dir.output, bf.filename);

%% get all the GLM masks
preproc = bids.layout(opt.dir.preproc, false);

%%
mask_files = bids.query(preproc, 'data', ...
                        'modality', 'func', ...
                        'suffix', 'mask', ...
                        'desc', 'brain', ...
                        'space', 'MNI152NLin2009cAsym', ...
                        'extension', '.nii');

% open all the masks
hdr = spm_vol(char(mask_files));
vol = spm_read_vols(hdr);

% only includes voxels that are present in >50% subjects / runs
vol = sum(vol, 4) / size(vol, 4) > 0.5;

hdr = hdr(1);
hdr.fname = mask_file;

spm_write_vol(hdr, vol);
