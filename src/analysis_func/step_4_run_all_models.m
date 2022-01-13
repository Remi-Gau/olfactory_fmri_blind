% (C) Copyright 2019 Remi Gau

clear;
clc;

run ../../initEnv.m;

models = {'Hrf'; 'HrfTemp'; 'HrfTempDisp'; ...
          'HrfNoTissueConfounds'; 'HrfTempNoTissueConfounds'; 'HrfTempDispNoTissueConfounds'};

% Model selection of the next step does not need model to be estimated
specify_only = true;

for i = 1:numel(models)

  model_file = fullfile(fileparts(mfilename('fullpath')), ...
                        'models', ...
                        ['model-' models{i} '_smdl.json']);

  opt = opt_stats_subject_level();
  opt.subjects = '.*0[1-5]';

  opt.model.file = model_file;

  if specify_only

    opt.glm.useDummyRegressor = true;

    bidsFFX('specify', opt);

  else

    bidsFFX('specifyAndEstimate', opt); %#ok<*UNRCH>
    bidsFFX('contrasts', opt);
    bidsResults(opt);

    opt = opt_stats_group_level();
    opt.subjects = '.*0[1-5]';

    opt.model.file = model_file;

    bidsRFX('RFX', opt);
    bidsResults(opt);

  end

end
