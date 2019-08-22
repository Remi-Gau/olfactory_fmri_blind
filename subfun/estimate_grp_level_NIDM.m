function matlabbatch = estimate_grp_level_NIDM(matlabbatch, cmp, cdts, scans)

p = 0.01;
k = 0;


%% estimate design
matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = ...
    cfg_dep('Factorial design specification: SPM.mat File', ...
    substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), ...
    substruct('.','spmmat'));
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;


%% set contrasts
matlabbatch{3}.spm.stats.con.spmmat(1) = ...
    cfg_dep('Model estimation: SPM.mat File', ...
    substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), ...
    substruct('.','spmmat'));

% design contrast vectors
for iCmp = 1:numel(cmp)
    [name, weights] = name_weight_contrast(cmp{iCmp}, cdts, scans);
    matlabbatch{3}.spm.stats.con.consess{iCmp}.tcon.name = name;
    matlabbatch{3}.spm.stats.con.consess{iCmp}.tcon.weights = weights;
    matlabbatch{3}.spm.stats.con.consess{iCmp}.tcon.sessrep = 'none';
end

matlabbatch{3}.spm.stats.con.delete = 0;


%% save contrasts as NIDM results
matlabbatch{4}.spm.stats.results.spmmat(1) = ...
    cfg_dep('Contrast Manager: SPM.mat File', ...
    substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}), ...
    substruct('.','spmmat'));

for iCmp = 1:numel(cmp)
    name = name_weight_contrast(cmp{iCmp}, cdts, scans);
    matlabbatch{4}.spm.stats.results.conspec(iCmp).titlestr = name;
    matlabbatch{4}.spm.stats.results.conspec(iCmp).contrasts = iCmp;
    matlabbatch{4}.spm.stats.results.conspec(iCmp).threshdesc = 'none';
    matlabbatch{4}.spm.stats.results.conspec(iCmp).thresh = p;
    matlabbatch{4}.spm.stats.results.conspec(iCmp).extent = k;
    matlabbatch{4}.spm.stats.results.conspec(iCmp).conjunction = 1;
    matlabbatch{4}.spm.stats.results.conspec(iCmp).mask.none = 1;
    
%     matlabbatch{1}.spm.stats.results.conspec.mask.image.name = '<UNDEFINED>';
%     matlabbatch{1}.spm.stats.results.conspec.mask.image.mtype = 0;
end

matlabbatch{4}.spm.stats.results.units = 1;
matlabbatch{4}.spm.stats.results.export{1}.ps = true;
matlabbatch{4}.spm.stats.results.export{2}.nidm.modality = 'FMRI';
matlabbatch{4}.spm.stats.results.export{2}.nidm.refspace = 'icbm';
matlabbatch{4}.spm.stats.results.export{2}.nidm.group.nsubj = numel(scans);
matlabbatch{4}.spm.stats.results.export{2}.nidm.group.label = 'ctrl';


end

function [name, weights] = name_weight_contrast(cmp, cdts, scans)


%% set design
if size(scans,1) == 2
    test_type = 'two-sample';
elseif numel(cdts)==1
    test_type = 'ttest';
elseif numel(cdts)==2
    test_type = 'paired';
else
    test_type = 'anova';
end

switch test_type
    
    case 'two-sample'
        
        cdt_1 = cdts{1};
        cdt_2 = '';
    
    case 'ttest'
        cdt_1 = cdts{1};
        cdt_2 = 'baseline';
        
    case 'paired'
        cdt_1 = cdts{1};
        cdt_2 = cdts{2};

    case 'anova'
        
        if strcmp(cmp{2},'>')
            
            name = cmp{4};
            weights = [];
            weights(cmp{1}) = 1;
            weights(cmp{3}) = -1;
            weights = [weights zeros(1, numel(scans))];
            
        end
end

% for ttest
if ~strcmp(test_type, 'anova')
    
    switch cmp
        
        % applied to groups as
        % for condition  1 > condition 2
        case '>'
            name = [cdt_1 ' > ' cdt_2];
            weights = [1 -1 zeros(1, numel(scans))];
            
        % for condition 2 > condition 1
        case '<'
            name = [cdt_1 ' < ' cdt_2];
            weights = [-1 1 zeros(1, numel(scans))];
            
        % for condition 1 + 2 > baseline
        case '+>'
            name = [cdt_1 ' + ' cdt_2 ' > baseline'];
            weights = [0.5 0.5 ones(1, numel(scans))/numel(scans) ];
    end

end

% adjust weight vector length in case it is a ttest
if strcmp(test_type, 'ttest')
    weights(2:end) = [];
end

% adjust weight vector length in case it is a ttest
if strcmp(test_type, 'two-sample')
    weights(3:end) = [];
end


end