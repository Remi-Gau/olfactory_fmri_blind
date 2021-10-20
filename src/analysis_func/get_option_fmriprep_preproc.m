function opt = get_option_fmriprep_preproc()
  %
  % returns a structure that contains the options chosen by the user to run
  % slice timing correction, pre-processing, FFX, RFX.
  %
  % (C) Copyright 2019 Remi Gau

  opt = [];

  % task to analyze
  opt.subjects = {'blnd01', 'ctrl01'};
  opt.taskName = {'rest', 'olfid', 'olfloc'};
  opt.verbosity = 1;

  opt.space = {'MNI152NLin2009cAsym'};

  % The directory where the data are located
  WD = fullfile(fileparts(mfilename('fullpath')), '..', '..', '..', '..');
  opt.dir.raw = fullfile(WD, 'raw');
  opt.dir.input = fullfile(WD, 'derivatives', 'fmriprep');
  opt.dir.derivatives = fullfile(WD, 'derivatives');

  %% DO NOT TOUCH
  opt = checkOptions(opt);
  saveOptions(opt);

end
