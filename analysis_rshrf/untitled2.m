% (C) Copyright 2021 CPP_SPM developers

% blind olfaction

clear;
clc;


run ../../initCppSpm.m;

%% Set options
opt = blind_olf_get_option();


BIDS = bids.layout(opt.dir.preproc, false);


%% create group mask
maskFiles = bids.query(BIDS, 'data', 'suffix', 'mask', 'extension', '.nii');
maskHdrs = spm_vol(char(maskFiles));
maskVol = spm_read_vols(maskHdrs);
maskVol = all(maskVol, 4);

outputHdr = maskHdrs(1);
name = renameFile(outputHdr.fname, struct('sub', ''), false);
outputHdr.fname = fullfile(opt.dir.preproc, 'group', name);

spm_mkdir(fullfile(opt.dir.preproc, 'group'));
spm_write_vol(outputHdr, maskVol);


%%

groups = {'blnd', 'ctrl'};
param = {'FWHM', 'Height', 'Time2peak'};

for iParam = 1:numel(param)
    
    matlabbatch = [];
    spm_mkdir(fullfile(opt.dir.preproc, 'stats', param{iParam}));
    
    for iGrp = 1:numel(groups)
        img{iGrp} = spm_select('FPlistrec', ...
            opt.dir.preproc, ...
            ['^deconv_sub-' groups{iGrp} '.*' param{iParam} '.nii$']);
    end
    
    matlabbatch = setBatchPairedTTest(matlabbatch, ...
        img{1}, ...
        img{2}, ...
        outputHdr.fname, ...
        fullfile(opt.dir.preproc, 'stats', param{iParam}));
    
    matlabbatch{end + 1}.spm.stats.fmri_est.method.Classical = 1;
    matlabbatch{end}.spm.stats.fmri_est.spmmat = cfg_dep( ...
                           'fMRI model specification SPM file', ...
                           substruct( ...
                                     '.', 'val', '{}', {1}, ...
                                     '.', 'val', '{}', {1}, ...
                                     '.', 'val', '{}', {1}), ...
                           substruct('.', 'spmmat'));    
                       
%     saveAndRunWorkflow(matlabbatch, ['paired_ttest_' param{iParam}] , opt);                       
    
end


%%

clear matlabbatch

matlabbatch{1}.spm.tools.rsHRF.display_HRF.underlay_nii = {'/home/remi/matlab/SPM/spm12/canonical/avg152T1.nii,1'};
matlabbatch{1}.spm.tools.rsHRF.display_HRF.stat_nii = {'/home/remi/gin/olfaction_blind/derivatives/cpp_spm-rshrf/stats/Height/spmT_0002.nii,1'};
matlabbatch{1}.spm.tools.rsHRF.display_HRF.HRF_mat = {
                                                      cellstr(spm_select('FPlistrec', ...
            opt.dir.preproc, ...
            '^deconv_sub-blnd.*.mat$'))
                                                      cellstr(spm_select('FPlistrec', ...
            opt.dir.preproc, ...
            '^deconv_sub-ctrl.*.mat$'))
                                                      }';
                                                  
                                                  
spm_jobman('run', matlabbatch);