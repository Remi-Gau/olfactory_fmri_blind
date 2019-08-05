function matlabbatch = subject_level_GLM_batch(matlabbatch, idx, analysis_dir, opt, cfg)
% set the general option for this subject level GLM
% - directory
% - timing parameters (TR, slices...)
% - basis function used
% - explicit mask
% - implicit mask threshold
% - autocorrelation correction method


matlabbatch{idx}.spm.stats.fmri_spec.dir = {analysis_dir};

matlabbatch{idx}.spm.stats.fmri_spec.timing.units = 'secs';
matlabbatch{idx}.spm.stats.fmri_spec.timing.RT = opt.TR;
matlabbatch{idx}.spm.stats.fmri_spec.timing.fmri_t = opt.nb_slices;
matlabbatch{idx}.spm.stats.fmri_spec.timing.fmri_t0 = opt.slice_reference;

matlabbatch{idx}.spm.stats.fmri_spec.fact = struct('name',{},'levels',{});

matlabbatch{idx}.spm.stats.fmri_spec.bases.hrf.derivs = ...
    [cfg.time_der, cfg.disp_der]; % First is time derivative, Second is dispersion

matlabbatch{idx}.spm.stats.fmri_spec.volt = 1;

matlabbatch{idx}.spm.stats.fmri_spec.global = 'None';

matlabbatch{idx}.spm.stats.fmri_spec.mthresh = cfg.inc_mask_thres;

matlabbatch{idx}.spm.stats.fmri_spec.mask = {cfg.explicit_mask};

matlabbatch{idx}.spm.stats.fmri_spec.cvi = cfg.spher_cor{1};
end