% (C) Copyright 2019 Remi Gau

clear;
clc;

run ../../initEnv.m;

opt = opt_stats_group_level();

opt.verbosity = 2;

saveOptions(opt);

action = 'stats';
% action = 'contrasts';
% action = 'results';

% 'node_name', {'between_groups', 'dataset_level', 'within_group'}

% bidsRFX('meanAnatAndMask', opt);

cpp_spm(opt.dir.raw, opt.dir.derivatives, 'dataset', ...
        'action', action, ...
        'preproc_dir', opt.dir.preproc, ...
        'model_file', opt.model.file, ...
        'fwhm', 6, ...
        'verbosity', 2, ...
        'node_name', 'between_groups', ...
        'options', opt);
