% (C) Copyright 2021 Remi Gau

% -----------------------------------------------------------------------
% Job saved on 22-Apr-2021 09:47:31 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7487)
% cfg_basicio BasicIO - Unknown
% -----------------------------------------------------------------------
folder = '/home/remi/gin/olfaction_blind/derivatives/cpp_spm-rshrf';
factorial_design.dir = {fullfile(folder, 'stats', 'FWHM')};
factorial_design.des.t2.scans1 = {
                                  fullfile(folder, 'sub-blnd01/func/deconv_sub-blnd01_task-rest_run-01_space-MNI152NLin2009cAsym_desc-preproc_bold_Height.nii,1')
                                  fullfile(folder, 'sub-blnd02/func/deconv_sub-blnd02_task-rest_run-01_space-MNI152NLin2009cAsym_desc-preproc_bold_Height.nii,1')
                                 };
factorial_design.des.t2.scans2 = {
                                  fullfile(folder, 'sub-ctrl01/func/deconv_sub-ctrl01_task-rest_run-01_space-MNI152NLin2009cAsym_desc-preproc_bold_Height.nii,1')
                                  fullfile(folder, 'sub-ctrl02/func/deconv_sub-ctrl02_task-rest_run-01_space-MNI152NLin2009cAsym_desc-preproc_bold_Height.nii,1')
                                 };
factorial_design.des.t2.dept = 0;
factorial_design.des.t2.variance = 1;
factorial_design.des.t2.gmsca = 0;
factorial_design.des.t2.ancova = 0;
factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
factorial_design.masking.tm.tm_none = 1;
factorial_design.masking.im = 1;
factorial_design.masking.em = {fullfile(folder, 'group/task-rest_run-01_space-MNI152NLin2009cAsym_desc-brain_mask.nii,1')};
factorial_design.globalc.g_omit = 1;
factorial_design.globalm.gmsca.gmsca_no = 1;
factorial_design.globalm.glonorm = 1;

matlabbatch{1}.spm.stats.factorial_design = factorial_design;
