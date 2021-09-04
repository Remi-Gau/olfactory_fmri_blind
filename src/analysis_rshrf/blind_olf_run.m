% (C) Copyright 2021 Remi Gau

clear;
clc;

% Smoothing to apply
FWHM = 6;

run(fullfile(pwd, '..', 'initEnv.m'));

%% Set options
opt = blind_olf_get_option();

%%
% BIDS = bids.layout(opt.dir.input, false)
%
% opt.query = struct('modality', 'anat', 'suffix', 'mask', 'space', opt.space);
% opt.query.sub = opt.subjects;
%
% bids.query(BIDS, 'data', opt.query)
%
% opt.query = struct('suffix', 'T1w', 'desc', 'preproc', 'space', opt.space);
% opt.query.sub = opt.subjects;
%
% bids.query(BIDS, 'data', opt.query)

%%
opt.query = struct('suffix', 'bold', 'desc', 'preproc', 'task', opt.taskName, 'space', opt.space);
opt.query.sub = opt.subjects;

% bids.query(BIDS, 'data', opt.query)

% bidsCopyInputFolder(opt);

opt.query = struct('task', opt.taskName, 'space', opt.space);
opt.query.suffix = {'mask'};
opt.query.sub = opt.subjects;

% bids.query(BIDS, 'data', opt.query)

% bidsCopyInputFolder(opt);

%%
opt = blind_olf_get_option();
bidsRsHrf(opt);

% BIDS = bids.layout(opt.dir.preproc, false)
