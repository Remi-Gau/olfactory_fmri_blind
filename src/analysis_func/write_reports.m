% (C) Copyright 2021 Remi Gau

% write method description for dataset

clear;
clc;

run ../../initEnv.m;

%%
opt = opt_preproc();

bids.diagnostic(opt.dir.raw, 'split_by', {'task'}, 'output_path', fullfile(pwd, 'reports'));

%%
bids.report(opt.dir.raw, ...
            'filter', struct('sub', 'ctrl01', 'modality', {{'anat', 'func'}}), ...
            'output_path', fullfile(pwd, 'reports'), ...
            'read_nifti', true, ...
            'verbose', true);
%%
clear opt;

opt = opt_stats_subject_level();

outputFile = boilerplate(opt, 'outputPath', fullfile(pwd, 'reports'), ...
                         'pipelineType', 'stats');
