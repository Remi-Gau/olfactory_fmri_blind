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

  alpha = 0.01;
  minimum_cluster_size = 50;

  % Specify the result to compute
  opt.results(1) = default_output(opt);
  opt.results(1).nodeName = 'dataset_level';
  opt.results(1).name = {'Responses', 'all_olf', 'all_olfloc', 'all_olfid', 'all_olf_lt_baseline'};
  opt.results(1).MC =  'none';
  opt.results(1).p = alpha;
  opt.results(1).k = minimum_cluster_size;
  opt.results(1).montage.background = fullfile(opt.dir.stats, ...
                                               'derivatives', ...
                                               'cpp_spm-groupStats', ...
                                               'space-MNI152NLin2009cAsym_desc-maskedMean_T1w.nii');

  %   opt.results(2) = opt.results(1);
  opt.results(1).nodeName = 'between_groups';

  % post setup
  raw = bids.layout(opt.dir.raw);
  opt.subjects = bids.query(raw, 'subjects');

  opt = get_options(opt);

  opt.subjects = rm_subjects(opt.subjects, opt);

  opt = checkOptions(opt);
  saveOptions(opt);

end
