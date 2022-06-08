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

% 'node_name', 'between_groups'

% bidsRFX('meanAnatAndMask', opt);

cpp_spm(opt.dir.raw, opt.dir.derivatives, 'dataset', ...
        'action', action, ...
        'preproc_dir', opt.dir.preproc, ...
        'model_file', opt.model.file, ...
        'fwhm', 6, ...
        'verbosity', 2, ...
        'options', opt);

return

%% ANOVA
task = [1 2];
group = [1 2];
odor = [1 2];
side = [1 2];
% subject

C = cartesian(task, group, odor, side);

% function C = cartesian(varargin)
%   args = varargin;
%   n = nargin;
%
%   [F{1:n}] = ndgrid(args{:});
%
%   for i = n:-1:1
%     G(:, i) = F{i}(:);
%   end
%
%   C = unique(G, 'rows');
% end
