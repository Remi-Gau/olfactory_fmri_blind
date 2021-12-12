function opt = options()
  %
  % (C) Copyright 2021 Remi Gau

  % The directory where the data are located
  opt.dir.dataset_root = fullfile(fileparts(mfilename('fullpath')), '..', '..', '..');
  opt.dir.raw = fullfile(opt.dir.dataset_root, 'inputs', 'raw');
  opt.dir.input = fullfile(opt.dir.dataset_root, 'inputs', 'fmriprep');
  opt.dir.derivatives = fullfile(opt.dir.dataset_root, 'outputs', 'derivatives');

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
