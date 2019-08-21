function matlabbatch = set_t_contrasts(analysis_dir, contrast_ls)
% set batch to estimate the following contrasts (> baseline and < baseline)

cdt_ls = cell(size(contrast_ls));

% add the suffix '*bf(1)' to look for regressors that are convolved
% with canonical HRF
for iCdt = 1:numel(contrast_ls)
    cdt_name_ls{iCdt,1} = [];
    for iSubcdt = 1:numel(contrast_ls{iCdt,1})
        cdt_ls{iCdt,1}{iSubcdt} = [contrast_ls{iCdt}{iSubcdt} '*bf(1)']; %#ok<*AGROW>
        cdt_name_ls{iCdt,1} = [cdt_name_ls{iCdt,1} ' + ' contrast_ls{iCdt}{iSubcdt}];
    end
    cdt_name_ls{iCdt,1}(1:3) = [];
end

load(fullfile(analysis_dir, 'SPM.mat'), 'SPM');

matlabbatch{1}.spm.stats.con.spmmat{1} = fullfile(analysis_dir, 'SPM.mat');
matlabbatch{end}.spm.stats.con.delete = 1;

con_idx = 1;

for iCdt = 1:numel(cdt_ls)

    idx = [];
    
    for iSubcdt = 1:numel(cdt_ls{iCdt,1})
        cdt_name = cdt_ls{iCdt,1}{iSubcdt}; %#ok<*AGROW>
        tmp = strfind(SPM.xX.name', cdt_name);
        tmp = ~cellfun('isempty', tmp); %#ok<*STRCL1>
        idx = [idx ; find(tmp)];
    end

    
    % do X > baseline
    weight_vec = init_weight_vector(SPM);
    weight_vec(idx) = 1;
    [weight_vec, cdt_name] = warning_dummy_contrast(weight_vec, [cdt_name_ls{iCdt,1} ' > 0']);
    matlabbatch = set_cdt_contrast_batch(matlabbatch, cdt_name, weight_vec, con_idx);
    con_idx = con_idx + 1;
    
    % do X < baseline
    weight_vec = init_weight_vector(SPM);
    weight_vec(idx) = -1;
    [weight_vec, cdt_name] = warning_dummy_contrast(weight_vec, [cdt_name_ls{iCdt,1} ' < 0']);
    matlabbatch = set_cdt_contrast_batch(matlabbatch, cdt_name, weight_vec, con_idx);
    con_idx = con_idx + 1;
    
end

end

function weight_vec = init_weight_vector(SPM)
weight_vec = zeros(size(SPM.xX.X,2),1);
end

function [weight_vec, cdt_name] = warning_dummy_contrast(weight_vec, cdt_name)

if sum(weight_vec)~=0
    % we normalize by the number of sessions this condition was present in.
    weight_vec = norm_weight_vector(weight_vec);
else
    warning('no regressor was found for condition %s, creating a dummy contrast', ...
        cdt_name)
    cdt_name = 'dummy_contrast';
    weight_vec = zeros(size(weight_vec));
    weight_vec(end) = 1;
end

end

function weight_vec = norm_weight_vector(weight_vec)
weight_vec =  weight_vec/abs(sum(weight_vec));
end

function matlabbatch = set_cdt_contrast_batch(matlabbatch, cdt_name, weight_vec, iCdt)
matlabbatch{end}.spm.stats.con.consess{iCdt}.tcon.name = cdt_name;
matlabbatch{end}.spm.stats.con.consess{iCdt}.tcon.weights = weight_vec;
matlabbatch{end}.spm.stats.con.consess{iCdt}.tcon.sessrep = 'none';
end