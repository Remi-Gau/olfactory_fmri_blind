% (C) Copyright 2019 Remi Gau

clear;
clc;

run ../../initEnv.m;

opt = get_option_fmriprep_preproc();

% TODO add ability to copy filter several times on the same data set

opt.query.desc = {'confounds'};
bidsCopyInputFolder(opt);

opt.query.desc = {'preproc', 'brain'};
opt.query.space = opt.space;
bidsCopyInputFolder(opt);

% bidsSmoothing(opt);
