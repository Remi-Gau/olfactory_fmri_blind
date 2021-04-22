function matlabbatch = setBatchPairedTTest(matlabbatch, imgGrp1, imgGrp2, explicitMask, outputDir)

    factorial_design.dir = {outputDir};
    factorial_design.des.t2.scans1 = cellstr(imgGrp1);
    factorial_design.des.t2.scans2 = cellstr(imgGrp2);
    factorial_design.des.t2.dept = 0;
    factorial_design.des.t2.variance = 1;
    factorial_design.des.t2.gmsca = 0;
    factorial_design.des.t2.ancova = 0;
    factorial_design.cov = struct(...
        'c', {}, ...
        'cname', {}, ...
        'iCFI', {}, ...
        'iCC', {});
    factorial_design.multi_cov = struct(...
        'files', {}, ...
        'iCFI', {}, ...
        'iCC', {});
    factorial_design.masking.tm.tm_none = 1;
    factorial_design.masking.im = 1;
    factorial_design.masking.em = {explicitMask};
    factorial_design.globalc.g_omit = 1;
    factorial_design.globalm.gmsca.gmsca_no = 1;
    factorial_design.globalm.glonorm = 1;

matlabbatch{end+1}.spm.stats.factorial_design = factorial_design;

end
