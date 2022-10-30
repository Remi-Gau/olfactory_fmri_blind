% Can either:
%
% - specify the models for different BIDS stats model to prepare for model
%   selection (specify only)
% - specify and estimate run the subject and dataset levels models
%
% (C) Copyright 2019 Remi Gau

clear;
clc;

dryRun = false;

%%
run ../../initEnv.m;

models_files = list_models_files();

% Model selection of the next step does not need model to be estimated
specify_only = true;

for i = 1:numel(models_files)

  model_file = fullfile(fileparts(mfilename('fullpath')), 'models', models_files{i});

  opt = opt_stats_subject_level();

  opt.dryRun = dryRun;

  % TODO: putting this might include subjects that have been excluded in the options
  % opt.subjects = subjects;

  opt.model.file = model_file;

  if specify_only

    if specify_only
      opt.subjects = '.*[^ctrl02]';
    end

    % TODO: probably should not have to be that heavy handed to save things in a
    % different directory
    % - getFFXDir seems to always create things in opt.dir.stats and not opt.dir.output
    opt.dir.output = spm_file(fullfile(opt.dir.stats, '..', 'bidspm-modelSelection'), 'cpath');
    opt.dir.stats = opt.dir.output;

    opt.glm.useDummyRegressor = true;

    bidsFFX('specify', opt);

  else

    bidsFFX('specifyAndEstimate', opt); %#ok<*UNRCH>
    bidsFFX('contrasts', opt);
    bidsResults(opt);

    % opt = opt_stats_group_level();
    % opt.subjects = subjects;

    % opt.model.file = model_file;

    % bidsRFX('RFX', opt);
    % bidsResults(opt);

  end

end
