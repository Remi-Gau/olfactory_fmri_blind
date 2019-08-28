function matlabbatch = set_extra_regress_batch(matlabbatch, idx, irun, cfg, confounds)

extra_regress = 1;
% includes realignement parameters from the fMRIprep confounds
if ~isempty(cfg.confounds)
    target_fields = cfg.confounds{1};
    for iField = 1:numel(target_fields)
        
        name = target_fields{iField};
        
        % include all t_comp_cor regressors
        if strcmp(name,'t_comp_cor_*')
            
            field_names = fieldnames(confounds{irun});
            t_comp_cor_idx = strfind(field_names, 't_comp_cor_');
            t_comp_cor_idx = find(~cellfun(@isempty, t_comp_cor_idx));
            
            for i_t_com_cor = t_comp_cor_idx'
                name = field_names{i_t_com_cor};
                value = getfield(confounds{irun}, name);
                
                matlabbatch{idx}.spm.stats.fmri_spec.sess(1, irun).regress(1,extra_regress) = ...
                    struct(...
                    'name', name, ...
                    'val', value );
                
                extra_regress = extra_regress + 1;
            end
            
        else
            
            value = getfield(confounds{irun}, name);
            
            
            if isnan(value(1))
                value(1) = 0;
            end
            if any(isnan(value))
                warning('NaN values one of the extra regressors.')
            end
            
            matlabbatch{idx}.spm.stats.fmri_spec.sess(1, irun).regress(1,extra_regress) = ...
                struct(...
                'name', name, ...
                'val', value );
            
            extra_regress = extra_regress + 1;
        end
    end
else
    matlabbatch{idx}.spm.stats.fmri_spec.sess(1, irun).regress = struct(...
        'name', {''}, 'val', {''});
end

% compute scrubbing regressors
if cfg.FD_censor.do
    
    to_censor = ...
        confounds{irun}.framewise_displacement > cfg.FD_censor.thres;
    
    if any(to_censor)
        
        to_censor = find(to_censor);
        for extra_scrub = 1:cfg.FD_censor.nb-1
            to_censor(:,end+1) = to_censor(:,end)+1;
        end
        to_censor = unique(to_censor);
        
        
        for i_censor = 1:numel(to_censor)
            
            reg_name = sprintf('censor_%02.0f', i_censor);
            value = zeros(size(matlabbatch{idx}.spm.stats.fmri_spec.sess(1, irun).scans));
            value(to_censor(i_censor)) = 1;
            
            matlabbatch{idx}.spm.stats.fmri_spec.sess(1, irun).regress(1,extra_regress) = struct(...
                'name', reg_name, ...
                'val', value );
            
            extra_regress = extra_regress + 1;
        end
    end
    
end

matlabbatch{idx}.spm.stats.fmri_spec.sess(1,irun).multi_reg{1} = '';


end