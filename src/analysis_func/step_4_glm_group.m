% (C) Copyright 2019 Remi Gau

clear;
clc;

run ../../initEnv.m;

opt = opt_stats_group_level();

opt.verbosity = 2;

% bidsRFX('meanAnatAndMask', opt);

bidsRFX('RFX', opt);
bidsRFX('contrast', opt);
bidsResults(opt);

return

% TODO
% 2 samples ttest

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
