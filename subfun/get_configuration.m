function cfg = get_configuration(all_GLMs, opt, iGLM)
% Get the GLM configuration for the iGLM and given the options and the list
% of the GLMs we want to try 

cfg.explicit_mask = opt.explicit_mask(all_GLMs(iGLM,1));

cfg.inc_mask_thres  = opt.inc_mask_thres(all_GLMs(iGLM,2));

cfg.HPF = opt.HPF(all_GLMs(iGLM,3));

cfg.time_der = opt.time_der(all_GLMs(iGLM,4));
cfg.disp_der = opt.disp_der(all_GLMs(iGLM,5));

cfg.confounds = opt.confounds(all_GLMs(iGLM,6));

cfg.FD_censor.do = opt.FD_censor.do(all_GLMs(iGLM,7));
cfg.FD_censor.thres = opt.FD_censor.thres(all_GLMs(iGLM,8));

cfg.spher_cor = opt.spher_cor(all_GLMs(iGLM,9));

if isfield(opt, 'prefix')
    cfg.prefix = opt.prefix;
end

end

