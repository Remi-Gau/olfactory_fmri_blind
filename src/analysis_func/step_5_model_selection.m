% (C) Copyright 2019 Remi Gau

% Comments:
%
% cvLME could not run for
% - ctrl-02

clear;
clc;

run ../../initEnv.m;

subjects = '.*[^ctrl02]';

list_models_files = {
    'model-NoDerivativeNoTissueConfoundsNoScrubbing_smdl.json'
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

opt = opt_stats_subject_level();
opt.subjects = subjects;

for i = 1:numel(models)

  opt.toolbox.MACS.model.files{i} = fullfile(fileparts(mfilename('fullpath')), ...
                                             'models', ...
                                             ['model-' models{i} '_smdl.json']);

end

bidsModelSelection(opt, 'action', 'BMS');
