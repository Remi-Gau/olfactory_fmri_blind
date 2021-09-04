function explicit_mask = create_mask(subj_dir, folder_subj, space)
  % creates an inclusive mask based on the fmriprep brain mask for all the tasks of this subject
  %
  % (C) Copyright 2021 Remi Gau
  if strcmp(space, 'T1w')
    space_suffix = 'T1w';
  else
    space_suffix = 'MNI152NLin2009cAsym';
  end

  explicit_mask = spm_select('FPList', ...
                             subj_dir, ...
                             ['^' folder_subj ...
                              '.*task-olf.*space-' space_suffix '_desc-brain_mask.nii$']);

  hdr = spm_vol(explicit_mask);
  mask = any(spm_read_vols(hdr), 4);

  hdr =  hdr(1);
  hdr.fname = fullfile(subj_dir, ...
                       [folder_subj '_task-olf_space-' space_suffix '_brainmask.nii']);
  spm_write_vol(hdr, mask);

  explicit_mask = hdr.fname;

end
