% script to create mean structural (normalized smoothed and masked)
% (C) Copyright 2021 Remi Gau

clear;
clc;

opt = opt_stats();

spm_mkdir(fullfile(opt.dir.stats, 'group', 'images'));

p = struct( ...
           'suffix', 'T1w', ...
           'entities', struct( ...
                              'sub', 'group', ...
                              'space', 'MNI152NLin2009cAsym', ...
                              'desc', 'mean'), ...
           'ext', '.nii');

bf = bids.File(p, false);
T1w_average = fullfile(opt.dir.stats, 'group', 'images', bf.filename);

p.suffix = 'mask';
p.entities.desc = 'brain';
bf = bids.File(p, false);
mask_file = fullfile(opt.dir.stats, 'group', 'images', bf.filename);

%% get all the GLM masks
preproc = bids.layout(opt.dir.preproc, false);

%%
anat_files = bids.query(preproc, 'data', ...
                        'modality', 'anat', ...
                        'suffix', 'T1w', ...
                        'desc', 'preproc', ...
                        'space', 'MNI152NLin2009cAsym', ...
                        'extension', '.nii');

%% get and read files
hdr = spm_vol(char(anat_files));
vol = spm_read_vols(hdr);

hdr_mask = spm_vol(mask_file);
mask = spm_read_vols(hdr_mask);

% average and smooth
vol = mean(vol, 4);
spm_smooth(vol, vol, opt.fwhm.func);

% save
hdr = hdr(1);
hdr.fname = T1w_average;
spm_write_vol(hdr, vol);

% reslice to mask resolution
flag.which = 1;
flag.mean = false;
flag.prefix = '';
spm_reslice({mask_file; T1w_average}, flag);

% mask mean image
hdr = spm_vol(T1w_average);
vol = spm_read_vols(hdr);
vol(mask == 0) = 0;
spm_write_vol(hdr, vol);
