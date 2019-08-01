function matlabbatch = set_t_contrasts(analysis_dir)
% set batch to estimate the following contrasts (> baseline and < baseline)
% (1) gamble_trial
% (2) gamble_trialxgain : parametric effect of gain,
% (3) gamble_trialxloss : parametric effect of loss,
% (4) gamble_trialxEV : effect of expected value,
% (5) missed_trial : effect of missed trials,
% (6) gamble_trial_button_press : effect button presses,
% (7) FramewiseDisplacement : effet of the FD regressor


% cdt_ls = {...
%     ' gamble_trial*bf(1)', ...
%     ' gamble_trialxgain^1*bf(1)', ...  
%     ' gamble_trialxloss^1*bf(1)', ...      
%     ' gamble_trialxEV^1*bf(1)', ...       
%     ' missed_trial*bf(1)', ...             
%     ' gamble_trial_button_press*bf(1)', ...
%     ' FramewiseDisplacement'};

cdt_ls = {...
    ' gamble_trial*bf(1)', ...
    ' gamble_trialxgain^1*bf(1)', ...  
    ' gamble_trialxloss^1*bf(1)', ...      
    ' gamble_trialxEV^1*bf(1)', ...       
    ' missed_trial*bf(1)', ...             
    ' gamble_trial_button_press*bf(1)'};

load(fullfile(analysis_dir, 'SPM.mat'), 'SPM');

matlabbatch{1}.spm.stats.con.spmmat{1} = fullfile(analysis_dir, 'SPM.mat');
matlabbatch{end}.spm.stats.con.delete = 1;

con_idx = 1;

for iCdt = 1:numel(cdt_ls)

    % add the suffix '*bf(1)' to look for regressors that are convolved
    % with canonical HRF
    idx = strfind(SPM.xX.name', cdt_ls{iCdt});
    idx = ~cellfun('isempty', idx); %#ok<STRCL1>
    
    % do X > baseline
    weight_vec = init_weight_vector(SPM);
    weight_vec(idx) = 1;
    [weight_vec, cdt_name] = warning_dummy_contrast(weight_vec, [cdt_ls{iCdt} ' > 0']);
    matlabbatch = set_cdt_contrast_batch(matlabbatch, cdt_name, weight_vec, con_idx);
    con_idx = con_idx + 1;
    
    % do X < baseline
    weight_vec = init_weight_vector(SPM);
    weight_vec(idx) = -1;
    [weight_vec, cdt_name] = warning_dummy_contrast(weight_vec, [cdt_ls{iCdt} ' < 0']);
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