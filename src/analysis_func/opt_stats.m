function opt = opt_stats()
  %
  % returns a structure that contains the options chosen by the user to run
  % slice timing correction, pre-processing, FFX, RFX...
  %
  % (C) Copyright 2021 Remi Gau

  opt = [];

  %   opt.dryRun = true;
  %   opt.model.designOnly = true;

  % The directory where the data are located
  opt.dir.dataset_root = fullfile(fileparts(mfilename('fullpath')), '..', '..', '..');
  opt.dir.raw = fullfile(opt.dir.dataset_root, 'inputs', 'raw');
  opt.dir.derivatives = fullfile(opt.dir.dataset_root, 'outputs', 'derivatives');
  opt.dir.preproc = fullfile(opt.dir.derivatives, 'cpp_spm-preproc');
  opt.dir.stats = fullfile(opt.dir.derivatives, 'cpp_spm-stats');
  opt.dir.roi = fullfile(opt.dir.derivatives, 'cpp_spm-roi');
  opt.dir.input = opt.dir.preproc;

  % task to analyze
  opt.taskName = {'olfid', 'olfloc'};

  opt.verbosity = 1;

  opt.space = {'MNI152NLin2009cAsym'};

  opt.fwhm.func = 6;

  opt.pipeline.type = 'stats';

  opt.model.file = fullfile(fileparts(mfilename('fullpath')), ...
                            'models', ...
                            'model-defaultOlfidOlfloc_smdl.json');
  opt.QA.glm.do = false;

  % Specify the result to compute
  opt.result.Nodes(1) = returnDefaultResultsStructure();

  opt.result.Nodes(1).Level = 'subject';

  opt.result.Nodes(1).Contrasts(1).Name = 'listening';

  % For each contrats, you can adapt:
  %  - voxel level (p)
  %  - cluster (k) level threshold
  %  - type of multiple comparison:
  %    - 'FWE' is the defaut
  %    - 'FDR'
  %    - 'none'
  %
  %   opt.result.Nodes(1).Contrasts(2).Name = 'listening_inf_baseline';
  %   opt.result.Nodes(1).Contrasts(2).MC =  'none';
  %   opt.result.Nodes(1).Contrasts(2).p = 0.01;
  %   opt.result.Nodes(1).Contrasts(2).k = 0;

  % Specify how you want your output (all the following are on false by default)
  opt.result.Nodes(1).Output.png = true();

  opt.result.Nodes(1).Output.csv = false();
  opt.result.Nodes(1).Output.thresh_spm = false();
  opt.result.Nodes(1).Output.binary = false();

  % MONTAGE FIGURE OPTIONS
  opt.result.Nodes(1).Output.montage.do = false();
  opt.result.Nodes(1).Output.montage.slices = -0:2:16; % in mm
  % axial is default 'sagittal', 'coronal'
  opt.result.Nodes(1).Output.montage.orientation = 'axial';
  % will use the MNI T1 template by default but the underlay image can be changed.
  opt.result.Nodes(1).Output.montage.background = ...
      fullfile(spm('dir'), 'canonical', 'avg152T1.nii,1');

  opt.result.Nodes(1).Output.NIDM_results = false();

  %% DO NOT TOUCH

  raw = bids.layout(opt.dir.raw);
  opt.subjects = bids.query(raw, 'subjects');

  opt.subjects = cellstr("blnd01");

  opt = get_options(opt);

  opt.subjects = rm_subjects(opt.subjects, opt);

  % opt = createDefaultStatsModel(raw, opt);

  opt = checkOptions(opt);
  saveOptions(opt);

end
