function opt = opt_stats_subject_level(opt)
  %
  % returns a structure that contains the options chosen by the user to run FFX
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
  opt.QA.glm.do = false;

  opt.glm.maxNbVols = 300;

  alpha = 0.01;
  minimum_cluster_size = 10;

  % Specify the result to compute
  results = default_output(opt);
  results.nodeName = 'subject_level';

  results.name = {'olfid_eucalyptus_left'
                  'olfid_eucalyptus_right'
                  'olfid_almond_left'
                  'olfid_almond_right'
                  'olfloc_eucalyptus_left'
                  'olfloc_eucalyptus_right'
                  'olfloc_almond_left'
                  'olfloc_almond_right'
                  'Responses'
                  'all_olfid'
                  'all_olfloc'
                  'all_olf'};
  results.MC =  'none';
  results.p = alpha;
  results.k = minimum_cluster_size;
  results.montage.background = struct('desc', 'preproc', ...
                                      'suffix', 'T1w');

  opt.results(1) = results;

  % post setup
  raw = bids.layout(opt.dir.raw);

  if isfield(opt, 'subjects')
    opt.subjects = bids.query(raw, 'subjects', 'sub', opt.subjects);
  else
    opt.subjects = bids.query(raw, 'subjects');
  end

  opt = get_options(opt);

  opt.subjects = rm_subjects(opt.subjects, opt);

  opt = checkOptions(opt);
  saveOptions(opt);

end
