function opt = option_preproc()
  %
  % returns a structure that contains the options chosen by the user to run
  % slice timing correction, pre-processing, FFX, RFX.
  %
  % (C) Copyright 2019 Remi Gau

  opt = [];

  % task to analyze
  opt.subjects = {'blnd01', 'ctrl01'};
  opt.taskName = {'olfid', 'olfloc'};
  opt.verbosity = 1;

  opt.space = {'MNI152NLin2009cAsym'};

  opt.dir.dataset_root = fullfile(fileparts(mfilename('fullpath')), '..', '..', '..');

  % The directory where the data are located
  opt.dir.raw = fullfile(opt.dir.dataset_root, 'inputs', 'raw');
  opt.dir.input = fullfile(opt.dir.dataset_root, 'inputs', 'fmriprep');
  opt.dir.derivatives = fullfile(opt.dir.dataset_root, 'derivatives');

  %% DO NOT TOUCH
  opt = checkOptions(opt);
  saveOptions(opt);

end
