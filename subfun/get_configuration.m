function cfg = get_configuration(all_GLMs, opt, iGLM)
% Get the GLM configuration for the iGLM and given the options and the list
% of the GLMs we want to try 

cfg.explicit_mask = opt.explicit_mask(all_GLMs(iGLM,1));

cfg.inc_mask_thres  = opt.inc_mask_thres(all_GLMs(iGLM,2));

cfg.HPF = opt.HPF(all_GLMs(iGLM,3));

cfg.design = opt.design(all_GLMs(iGLM,4));
cfg.duration = opt.duration(all_GLMs(iGLM,5));
cfg.RT_correction = opt.RT_correction(all_GLMs(iGLM,6));

cfg.model_button_press = opt.model_button_press(all_GLMs(iGLM,7));
cfg.rm_unresp_trials.do = opt.rm_unresp_trials.do(all_GLMs(iGLM,8));
cfg.rm_unresp_trials.thres = opt.rm_unresp_trials.thres(all_GLMs(iGLM,9));

cfg.time_der = opt.time_der(all_GLMs(iGLM,10));
cfg.disp_der = opt.disp_der(all_GLMs(iGLM,11));

cfg.confounds = opt.confounds(all_GLMs(iGLM,12));

cfg.FD_censor.do = opt.FD_censor.do(all_GLMs(iGLM,13));
cfg.FD_censor.thres = opt.FD_censor.thres(all_GLMs(iGLM,14));

cfg.spher_cor = opt.spher_cor(all_GLMs(iGLM,15));

if isfield(opt, 'prefix')
    cfg.prefix = opt.prefix;
end

end

