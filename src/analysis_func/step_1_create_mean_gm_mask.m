% (C) Copyright 2021 Remi Gau

clear;
clc;

run ../../initEnv.m;

opt = opt_preproc();

opt.pipeline.type = 'preproc';

opt.query.label = {'GM'};
opt.query.suffix = {'probseg'};
opt.query.space = 'MNI152NLin2009cAsym';
opt.query.modality = 'anat';

bidsCopyInputFolder(opt);

%% grab all GM probseg and average

BIDS = bids.layout(opt.dir.preproc, 'use_schema', false);
files =  bids.query(BIDS, 'data', 'label', 'GM');

hdr = spm_vol(char(files));

output_file = fullfile(opt.dir.roi, 'group', 'space-MNI152NLin2009cAsym_label-GM_probseg.nii');
output_hdr = hdr(1);
output_hdr.fname = output_file;

vols =  spm_read_vols(hdr);
vol = mean(vols, 4);

spm_write_vol(output_hdr, vol);

%%
p_threshold = 0.2;

gm_mask = thresholdToMask(output_file, p_threshold);

disp('Done');
