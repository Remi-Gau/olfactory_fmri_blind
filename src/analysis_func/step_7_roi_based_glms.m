% (C) Copyright 2021 Remi Gau

close all;
clear;
clc;

run ../../initEnv.m;

opt = opt_stats_subject_level();

opt.glm.roibased.do = true;
opt.fwhm.func =  0;

opt.space = 'MNI';

opt.verbosity = 1;

bidsFFX('specify', opt);
% bidsRoiBasedGLM(opt);
