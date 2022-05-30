function opt = opt_preproc(opt)
  %
  % returns a structure that contains the options chosen by the user to run pre-processing
  %
  % (C) Copyright 2021 Remi Gau

  if nargin == 0
    opt = [];
  end

  opt = opt_dir(opt);

  % task to analyze
  opt.taskName = {'olfid', 'olfloc'};

  opt.verbosity = 1;

  opt.fwhm.func = 6;

  % post setup
  raw = bids.layout(opt.dir.raw);
  opt.subjects = bids.query(raw, 'subjects');

  opt = get_options(opt);

  opt.subjects = rm_subjects(opt.subjects, opt);

  opt = checkOptions(opt);
  saveOptions(opt);

end
