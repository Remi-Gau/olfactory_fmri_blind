% (C) Copyright 2019 Remi Gau

% Comments:
%
% cvLME could not run for
% - ctrl-02

clear;
clc;

run ../../initEnv.m;

models = {  'Hrf'; ...
          'HrfTemp'; ...
          'HrfTempDisp'; ...
          'HrfNoTissueConfounds'; ...
          'HrfTempNoTissueConfounds'; ...
          'HrfTempDispNoTissueConfounds'};

opt = opt_stats_subject_level();
opt.subjects = 'ctrl0[3-5]';

for i = 1:numel(models)

  opt.toolbox.MACS.model.files{i} = fullfile(fileparts(mfilename('fullpath')), ...
                                             'models', ...
                                             ['model-' models{i} '_smdl.json']);

end

bidsModelSelection(opt, 'action', 'cvLME');
