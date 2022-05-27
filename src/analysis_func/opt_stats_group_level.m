function opt = opt_stats_group_level()
  %
  % returns a structure that contains the options chosen by the user to run
  % slice timing correction, pre-processing, FFX, RFX...
  %
  % (C) Copyright 2021 Remi Gau

  opt = [];

  % The directory where the data are located
  opt.dir.dataset_root = fullfile(fileparts(mfilename('fullpath')), '..', '..', '..');
  opt.dir.raw = fullfile(opt.dir.dataset_root, 'inputs', 'raw');
  opt.dir.derivatives = fullfile(opt.dir.dataset_root, 'outputs', 'derivatives');
  opt.dir.preproc = fullfile(opt.dir.derivatives, 'cpp_spm-preproc');
  opt.dir.stats = fullfile(opt.dir.derivatives, 'cpp_spm-stats');
  opt.dir.roi = fullfile(opt.dir.derivatives, 'cpp_spm-roi');
  opt.dir.input = opt.dir.preproc;

  opt.verbosity = 1;

  opt.fwhm.func = 6;
  opt.fwhm.contrast = 0;

  opt.model.file = fullfile(fileparts(mfilename('fullpath')), ...
                            'models', ...
                            'model-defaultOlfidOlfloc_smdl.json');

  alpha = 0.05;
  minimum_cluster_size = 10;

  % Specify the result to compute

  opt.results = default_output(opt);
  opt.results.nodeName = 'subject_level';
  opt.results.name = {'Responses', 'all_olf'};
  opt.results.MC =  'none';
  opt.results.p = alpha;
  opt.results.k = minimum_cluster_size;

  opt.results = default_output(opt);
  opt.results.nodeName = 'dataset_level';
  opt.results.name = {'Responses', 'all_olf'};
  opt.results.MC =  'none';
  opt.results.p = alpha;
  opt.results.k = minimum_cluster_size;

  % post setup
  raw = bids.layout(opt.dir.raw);
  opt.subjects = bids.query(raw, 'subjects');

  opt = get_options(opt);

  opt.subjects = rm_subjects(opt.subjects, opt);

  opt = checkOptions(opt);
  saveOptions(opt);

end
