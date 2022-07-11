% (C) Copyright 2021 Remi Gau

clear;
clc;

run ../../initEnv.m;

opt = opt_stats_subject_level();

%% neurosynth maps

gunzip(fullfile(opt.dir.roi, 'group', '*.gz'));

% hand and auditory
cluster_threshold = 50;
z_threshold = 8;

zMaps = spm_select('FPlist', ...
                   fullfile(opt.dir.roi, 'group'), ...
                   'hand.*association-test.*.nii$');
threshold_and_split_hemisphere(zMaps, z_threshold, cluster_threshold);

zMaps = spm_select('FPlist', ...
                   fullfile(opt.dir.roi, 'group'), ...
                   'auditory.*association-test.*.nii$');
threshold_and_split_hemisphere(zMaps, z_threshold, cluster_threshold);

%% limit them to grey matter
%
% run step_1_create_mean_gm_mask before
%

gm_mask = spm_select('FPlist', ...
                     fullfile(opt.dir.roi, 'group'), ...
                     '^space.*GM.*_mask.nii$');

dryRun = true;
[gm_mask, matlabbatch] = resliceRoiImages(deblank(masks(1, :)), gm_mask, dryRun);
matlabbatch{1}.spm.spatial.coreg.write.roptions.interp = 0;
spm_jobman('run', matlabbatch);

gm_vol = spm_read_vols(spm_vol(gm_mask));

masks = spm_select('FPlist', ...
                   fullfile(opt.dir.roi, 'group'), ...
                   'atlas-neurosynth.*_mask.nii$');

for i = 1:size(masks, 1)

  file = deblank(masks(i, :));
  hdr = spm_vol(file);
  vol = spm_read_vols(hdr);

  hdr_output = hdr;
  bf = bids.File(hdr_output.fname);
  bf.entities.desc = [bf.entities.desc 'GM'];
  bf.update;
  hdr_output.fname = fullfile(opt.dir.roi, 'group', bf.filename);

  vol = cat(4, vol, gm_vol);
  vol = all(vol, 4);

  spm_write_vol(hdr_output, vol);

end

disp('Done');
