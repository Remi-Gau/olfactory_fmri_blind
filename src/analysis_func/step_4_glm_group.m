% (C) Copyright 2019 Remi Gau

clear;
clc;

run ../../initEnv.m;

opt = opt_stats_group_level();

opt.verbosity = 2;

saveOptions(opt);

% bidsRFX('meanAnatAndMask', opt);

%%
% action = 'stats';
action = 'contrasts';

opt = add_results_options(opt);

% 'node_name', {'between_groups', 'dataset_level', 'within_group'}

bidspm(opt.dir.raw, opt.dir.derivatives, 'dataset', ...
        'action', action, ...
        'preproc_dir', opt.dir.preproc, ...
        'model_file', opt.model.file, ...
        'fwhm', 6, ...
        'verbosity', 2, ...
        'node_name', 'between_groups', ...
        'options', opt);

return

%%
action = 'results';

opt = opt_stats_group_level();
opt = add_results_options(opt);

bidspm(opt.dir.raw, opt.dir.derivatives, 'dataset', ...
        'action', action, ...
        'preproc_dir', opt.dir.preproc, ...
        'model_file', opt.model.file, ...
        'fwhm', 6, ...
        'verbosity', 2, ...
        'options', opt);
