function opt = opt_dir(opt)
  %
  % returns a structure that contains directories where to get the data
  %
  % (C) Copyright 2022 Remi Gau

  if nargin == 0
    opt = [];
  end

  % The directory where the data are located
  opt.dir.dataset_root = fullfile(fileparts(mfilename('fullpath')), '..', '..', '..');
  opt.dir.raw = fullfile(opt.dir.dataset_root, 'inputs', 'raw');
  opt.dir.derivatives = fullfile(opt.dir.dataset_root, 'outputs', 'derivatives');
  opt.dir.preproc = fullfile(opt.dir.derivatives, 'cpp_spm-preproc');
  opt.dir.stats = fullfile(opt.dir.derivatives, 'cpp_spm-stats');
  opt.dir.roi = fullfile(opt.dir.derivatives, 'cpp_spm-roi');

  opt.dir.input = fullfile(opt.dir.dataset_root, 'inputs', 'fmriprep');

end
