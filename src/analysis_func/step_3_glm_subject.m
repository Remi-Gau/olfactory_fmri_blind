% (C) Copyright 2019 Remi Gau

clear;
clc;

run ../../initEnv.m;

opt = opt_stats_subject_level();

bidsFFX('specifyAndEstimate', opt);
bidsFFX('contrasts', opt);
bidsResults(opt);

%% BIDS app version

% clc;

% opt.model.file = fullfile(fileparts(mfilename('fullpath')), ...
%                           'models', ...
%                           'model-defaultOlfidOlfloc_smdl.json');

% cpp_spm(opt.dir.raw, opt.dir.derivatives, 'subject', ...
%         'action', 'stats', ...
%         'preproc_dir', opt.dir.preproc, ...
%         'model_file', opt.model.file, ...
%         'fwhm', 6, ...
%         'verbosity', 2, ...
%         'options', opt);
