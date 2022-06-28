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

  opt.model.file = fullfile(fileparts(mfilename('fullpath')), ...
                            'models', ...
                            'model-TissueConfounds_smdl.json');

  % post setup we remove the excluded participants to avoid including them
  % at the group level
  raw = bids.layout(opt.dir.raw);
  opt.subjects = bids.query(raw, 'subjects');

  opt = get_options(opt);

  opt.subjects = rm_subjects(opt.subjects, opt);

end
