function opt = options()
  %
  % (C) Copyright 2021 Remi Gau

  opt = opt_dir();

  opt.baseline_dur = 20;
  opt.pre_stim = 16;
  opt.stim_dur = 16;
  opt.post_stim = 16;

  % offset time courses by the pre stimulus baseline level of response
  opt.rm_baseline = 0;

  opt.visible = 'on';

  % just to prevent label_your_axes from trying to give a meaningful scale
  % opt.norm_resp = 1;

  opt = get_options(opt);

end
