function opt = blind_olf_get_option()
  %
  % returns a structure that contains the options chosen by the user to run
  % slice timing correction, pre-processing, FFX, RFX.
  %
  % (C) Copyright 2021 Remi Gau

  if nargin < 1
    opt = [];
  end

  % task to analyze
  opt.taskName = 'rest';

  opt.pipeline.type = 'preproc';
  opt.pipeline.name = 'cpp_spm-rshrf';

  opt.space = 'MNI152NLin2009cAsym';

  % The directory where the data are located
  opt.dir.input = '/home/remi/gin/olfaction_blind/derivatives/fmriprep';

  %% DO NOT TOUCH
  opt = checkOptions(opt);
  saveOptions(opt);

end
