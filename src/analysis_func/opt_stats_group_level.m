function opt = opt_stats_group_level()
  %
  % returns a structure that contains the options chosen by the user to run RFX
  %
  % (C) Copyright 2021 Remi Gau

  if nargin == 0
    opt = [];
  end

  opt = opt_dir(opt);
  opt.dir.input = opt.dir.preproc;

  opt.verbosity = 1;

  opt.fwhm.func = 6;
  opt.fwhm.contrast = 0;

  opt.model.file = fullfile(fileparts(mfilename('fullpath')), ...
                            'models', ...
                            'model-TissueConfounds_smdl.json');

  alpha = 0.001;
  minimum_cluster_size = 50;

  % Specify the result to compute
  opt.results = default_output(opt);
  opt.results.nodeName = 'dataset_level';
  opt.results.name = {'Responses', 'all_olf', 'all_olfloc', 'all_olfid', 'all_olf_lt_baseline'};
  opt.results.MC =  'none';
  opt.results.p = alpha;
  opt.results.k = minimum_cluster_size;
  opt.results.montage.background = fullfile(opt.dir.stats, ...
                                            'derivatives', ...
                                            'cpp_spm-groupStats', ...
                                            'space-MNI152NLin2009cAsym_desc-maskedMean_T1w.nii');

  % post setup
  raw = bids.layout(opt.dir.raw);
  opt.subjects = bids.query(raw, 'subjects');

  opt = get_options(opt);

  opt.subjects = rm_subjects(opt.subjects, opt);

  opt = checkOptions(opt);
  saveOptions(opt);

end
