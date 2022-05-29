% (C) Copyright 2019 Remi Gau

clear;
clc;

run ../../initEnv.m;

opt = opt_stats_subject_level();

opt.subjects = {'^.*01$'};

% bidsFFX('specifyAndEstimate', opt);
 
bidsFFX('contrasts', opt);

bidsResults(opt);
