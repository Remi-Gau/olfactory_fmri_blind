% (C) Copyright 2019 Remi Gau

clear;
clc;

run ../../initEnv.m;

opt = opt_preproc();

opt.query.desc = {'confounds'};
bidsCopyInputFolder(opt);

opt.query.modality = {'func'};
opt.query.desc = {'preproc', 'brain'};
opt.query.space = opt.space;
bidsCopyInputFolder(opt);
