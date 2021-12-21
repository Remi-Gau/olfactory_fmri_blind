% script to create mean structural (normalized smoothed and masked)
% (C) Copyright 2021 Remi Gau

clear;
clc;

opt = opt_stats();

% reslice flags
flag.which = 1;
flag.mean = false;
flag.prefix = '';

spm_mkdir(fullfile(opt.dir.stats, 'group', 'images'));

T1w_mean_spec = struct( ...
                       'suffix', 'T1w', ...
                       'entities', struct( ...
                                          'sub', 'group', ...
                                          'space', 'MNI152NLin2009cAsym', ...
                                          'desc', 'mean'), ...
                       'ext', '.nii');

p = T1w_mean_spec;
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

hdr = hdr(1);

% average
vol = mean(vol, 4);

bf = bids.File(T1w_mean_spec, false);
T1w_average = fullfile(opt.dir.stats, 'group', 'images', bf.filename);
hdr.fname = T1w_average;

spm_write_vol(hdr, vol);
spm_reslice({mask_file; hdr.fname}, flag);

% smooth
vol = spm_read_vols(hdr);
vol = mean(vol, 4);
spm_smooth(vol, vol, opt.fwhm.func);

T1w_mean_spec.entities.desc = ['meanSmth' num2str(opt.fwhm.func)];
bf = bids.File(T1w_mean_spec, false);
hdr.fname = fullfile(opt.dir.stats, 'group', 'images', bf.filename);

spm_write_vol(hdr, vol);
spm_reslice({mask_file; hdr.fname}, flag);

% mask mean image
vol = spm_read_vols(hdr);
vol = mean(vol, 4);
spm_smooth(vol, vol, opt.fwhm.func);
vol(mask == 0) = 0;

T1w_mean_spec.entities.desc = ['meanSmth' num2str(opt.fwhm.func) 'Masked'];
bf = bids.File(T1w_mean_spec, false);
hdr.fname = fullfile(opt.dir.stats, 'group', 'images', bf.filename);

spm_write_vol(hdr, vol);
spm_reslice({mask_file; hdr.fname}, flag);
