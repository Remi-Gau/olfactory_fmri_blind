% (C) Copyright 2021 Remi Gau

% write method description for dataset

clear;
clc;

run ../../initEnv.m;

%%
close all;

opt = opt_dir();
opt.dir.input = opt.dir.raw;
opt.dir.output = pwd;

opt.subjects = 'ctrl01';
opt.query.modality = {'anat', 'func'};

reportBIDS(opt);

%%
clear opt;
opt.model.file = fullfile(fileparts(mfilename('fullpath')), '..', ...
                          'analysis_func', ...
                          'models', ...
                          'model-TissueConfounds_smdl.json');
opt.fwhm.contrast = 0;
opt = checkOptions(opt);

opt.designType = 'block';

outputFile = boilerplate(opt, 'outputPath', pwd, ...
                         'pipelineType', 'stats');
