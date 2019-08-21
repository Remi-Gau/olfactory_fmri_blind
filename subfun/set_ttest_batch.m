function matlabbatch = set_ttest_batch(matlabbatch, directory, scans, cdts, cmp)


%% set design
if size(scans,1) == 2
    test_type = 'two-sample';
elseif numel(cdts)==1
    test_type = 'ttest';
elseif numel(cdts)==2
    test_type = 'paired';
end

switch test_type
    case 'ttest'
        directory = fullfile(directory, ['ttest_' cdts{1}]);
        % enter contrast image pairs for each subject
        for iSubj = 1:numel(scans)
            matlabbatch{1}.spm.stats.factorial_design.des.t1.scans{iSubj,1} = ...
                scans{iSubj};
        end
        
    case 'paired'
        directory = fullfile(directory, ['ttest-paired_' cdts{1} '_vs_' cdts{2}]);
        % enter contrast image pairs for each subject
        for iSubj = 1:numel(scans)
            matlabbatch{1}.spm.stats.factorial_design.des.pt.pair(iSubj).scans = ...
                cellstr(scans{iSubj});
        end
        
        matlabbatch{1}.spm.stats.factorial_design.des.pt.gmsca = 0;
        matlabbatch{1}.spm.stats.factorial_design.des.pt.ancova = 0;
        
    case 'two-sample'
        directory = fullfile(directory, 'two-sample_ttest');
        % enter contrast image pairs for each subject
        for iSubj = 1:numel(scans{1})
            matlabbatch{1}.spm.stats.factorial_design.des.t2.scans1{iSubj,1} = ...
                scans{1}{iSubj};
        end
        for iSubj = 1:numel(scans{2})
            matlabbatch{1}.spm.stats.factorial_design.des.t2.scans2{iSubj,1} = ...
                scans{2}{iSubj};
        end
        
        matlabbatch{1}.spm.stats.factorial_design.des.t2.dept = 0;
        matlabbatch{1}.spm.stats.factorial_design.des.t2.variance = 1;
        matlabbatch{1}.spm.stats.factorial_design.des.t2.gmsca = 0;
        matlabbatch{1}.spm.stats.factorial_design.des.t2.ancova = 0;
end

[~, ~, ~] = mkdir(directory);

delete(fullfile(directory, 'SPM.mat'))

matlabbatch{1}.spm.stats.factorial_design.dir = {directory};
matlabbatch{1}.spm.stats.factorial_design.cov = ...
    struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.multi_cov = ...
    struct('files', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;


matlabbatch = estimate_grp_level_NIDM(matlabbatch, cmp, cdts, scans);

save(fullfile(directory,'grp_lvl_matlabbatch.mat'), 'matlabbatch')

end

