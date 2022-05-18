% (C) Copyright 2019 Remi Gau

% Comments:
%
% cvLME could not run for
% - ctrl-02

clear;
clc;

run ../../initEnv.m;

subjects = '.*[^ctrl02]';

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

opt = opt_stats_subject_level();
% opt.subjects = subjects;

% TODO: probably should not have to be that heavy handed to save things in a
% different directory
% - getFFXDir seems to always create things in opt.dir.stats and not opt.dir.output
opt.dir.output = spm_file(fullfile(opt.dir.stats, '..', 'cpp_spm-modelSelection'), 'cpath');
opt.dir.stats = opt.dir.output;

for i = 1:numel(list_models_files)

  opt.toolbox.MACS.model.files{end+1} = fullfile(fileparts(mfilename('fullpath')), 'models', list_models_files{i});

end

bidsModelSelection(opt, 'action', 'cvLME');
% bidsModelSelection(opt, 'action', 'posterior');
% bidsModelSelection(opt, 'action', 'BMS');
