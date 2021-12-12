function opt = opt_preproc()
  %
  % returns a structure that contains the options chosen by the user to run
  % slice timing correction, pre-processing, FFX, RFX...
  %
  % (C) Copyright 2019 Remi Gau

  opt = [];

  % The directory where the data are located
  opt.dir.dataset_root = fullfile(fileparts(mfilename('fullpath')), '..', '..', '..');
  opt.dir.raw = fullfile(opt.dir.dataset_root, 'inputs', 'raw');
  opt.dir.input = fullfile(opt.dir.dataset_root, 'inputs', 'fmriprep');
  opt.dir.derivatives = fullfile(opt.dir.dataset_root, 'outputs', 'derivatives');

  % task to analyze
  opt.taskName = {'olfid', 'olfloc'};

  opt.verbosity = 1;

  opt.space = {'MNI152NLin2009cAsym'};

  opt.fwhm.func = 6;

  raw = bids.layout(opt.dir.raw);
  opt.subjects = bids.query(raw, 'subjects');

  opt = get_options(opt);

  opt.subjects = rm_subjects(opt.subjects, opt);

  %% DO NOT TOUCH
  opt = checkOptions(opt);
  saveOptions(opt);

end
