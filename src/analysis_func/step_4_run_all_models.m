% Can either:
%
% - specify the models for different BIDS stats model to prepare for model selection
% - specify and estimate run the subject and dataset levels models
%
% (C) Copyright 2019 Remi Gau

clear;
clc;

dryRun = false;

%%
run ../../initEnv.m;

list_models_files = {'model-NoDerivativeNoTissueConfoundsNoScrubbing_smdl.json'
                     'model-NoDerivativeNoTissueConfoundsWithScrubbing_smdl.json'
                     'model-NoDerivativeWithTissueConfoundsNoScrubbing_smdl.json'
                     'model-NoDerivativeWithTissueConfoundsWithScrubbing_smdl.json'
                     'model-TemporalDerivativesNoTissueConfoundsNoScrubbing_smdl.json'
                     'model-TemporalDerivativesNoTissueConfoundsWithScrubbing_smdl.json'
                     'model-TemporalDerivativesWithTissueConfoundsNoScrubbing_smdl.json'
                     'model-TemporalDerivativesWithTissueConfoundsWithScrubbing_smdl.json'
                     'model-TemporalDispersionDerivativesNoTissueConfoundsNoScrubbing_smdl.json'
                     'model-TemporalDispersionDerivativesNoTissueConfoundsWithScrubbing_smdl.json'
                     'model-TemporalDispersionDerivativesWithTissueConfoundsNoScrubbing_smdl.json'
                     'model-TemporalDispersionDerivativesWithTissueConfoundsWithScrubbing_smdl.json'};

% subjects = '.*0[1-9]';

% Model selection of the next step does not need model to be estimated
specify_only = true;

for i = 5:numel(list_models_files)

  model_file = fullfile(fileparts(mfilename('fullpath')), 'models', list_models_files{i});

  opt = opt_stats_subject_level();
  
  opt.dryRun = dryRun;

  % TODO: putting this might include subjects that have been excluded in the options
  %   opt.subjects = subjects;

  opt.model.file = model_file;

  if specify_only

    % TODO: probably should not have to be that heavy handed to save things in a
    % different directory
    % - getFFXDir seems to always create things in opt.dir.stats and not opt.dir.output
    opt.dir.output = spm_file(fullfile(opt.dir.stats, '..', 'cpp_spm-modelSelection'), 'cpath');
    opt.dir.stats = opt.dir.output;

    opt.glm.useDummyRegressor = true;

    bidsFFX('specify', opt);

  else

    bidsFFX('specifyAndEstimate', opt); %#ok<*UNRCH>
    bidsFFX('contrasts', opt);
    bidsResults(opt);

    opt = opt_stats_group_level();
    opt.subjects = subjects;

    opt.model.file = model_file;

    bidsRFX('RFX', opt);
    bidsResults(opt);

  end

end
