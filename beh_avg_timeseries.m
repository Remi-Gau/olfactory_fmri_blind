% plots the average across subjects of:
% - stimulus onsets / offsets (to make sure that there is not too much
% variation between subjects
% - average across subject of the time course of each response type.
% - this can be row normalized for each subject (by the sum of response for
% that subject on that run - gives more weight to subjects with more SNR in their
% response)
% - it is possible to bin the responses from their original 25 Hz sampling
% frequency.
% - responses can be passed through a moving with window size

clear
clc

% mention where the BIDS data set is (can get the behavioral from OSF)
tgt_dir = 'D:\BIDS\olf_blind\raw';

% if needed add spm to the path
% spm_path = '/home/remi-gau/Documents/SPM/spm12';
% addpath(spm_path)

spm('defaults','fmri')

addpath(genpath(fullfile(pwd, 'subfun')))

% loads bids data
bids =  spm_BIDS(tgt_dir);

%% plotting
opt.bin_size = 20; % number of data point to bin. e.g. 25: means 1 sec of responses are summed 

opt.plot_subj = 0; % plot subjects - usualluy not pretty

opt.mov_mean_resp = 1; % use a moving window to average
opt.moving_win_size = 20; % width of the moving window

% limit of y axis when plotting both groups
max_y_axis = [...
        0.105;... % with no row normalization
        0.015 ]*1.55; % with row normalization

% do the loading of the data and plot
close all

out_dir = fullfile('output', 'figures', 'beh_avg');
mkdir(out_dir)

tasks = spm_BIDS(bids, 'tasks');
if numel(tasks)==3
    tasks(3) = [];
end

group(1).name = 'blnd';
group(2).name = 'ctrl';

opt.visible = 'on';

if ~opt.mov_mean_resp 
    opt.moving_win_size = 0;
end

for iTask = 1:numel(tasks)
    
    for iGroup = 1:numel(group)
        
        opt.group = group(iGroup).name;
        
        opt.plot = 'Run';
        opt.max_y_axis = [];
        
        subjects = spm_BIDS(bids, 'subjects', ...
            'task', tasks{iTask});
        
        idx = strfind(subjects, {group(iGroup).name});
        idx = find(~cellfun('isempty', idx)); %#ok<STRCL1>
        
        subjects(idx)
        
        [all_stim, task] = average_beh(bids, tasks{iTask}, subjects(idx));
        
        % average data across runs
        for iTrialType = 1:size(all_stim,1)
            avg_all_stim{iTrialType,1} = ...
                mean( ...
                cat(3, ...
                all_stim{iTrialType,1},  ...
                all_stim{iTrialType,2}), ...
                3); %#ok<SAGROW>
            % keep a copy for plotting both groups later
            bothgrp_avg_all_stim{iTrialType,iGroup} = ...
                mean( ...
                cat(3, ...
                all_stim{iTrialType,1},  ...
                all_stim{iTrialType,2}), ...
                3); %#ok<SAGROW>
        end

        % plot each group with and without row normalization
        for iNorm = 0:1
            opt.norm_resp = iNorm;
            
            % plot the 2 runs separately
            prefix = 'beh_grp-';
            make_figure(all_stim, task, opt)
            mtit(sprintf('Group: %s ; Task: %s ; Row norm: %i', ...
                opt.group, tasks{iTask}, opt.norm_resp), ....
                'fontsize', 14, 'xoff', 0,'yoff',0.05);
            print_fig(prefix, out_dir, group(iGroup).name, task, iNorm)
            
            % plot the run averages
            prefix = 'beh_runavg_grp-';
            make_figure(avg_all_stim, task, opt)
            mtit(sprintf('Run avg ; Group: %s ; Task: %s ; Row norm: %i', ...
                opt.group, tasks{iTask}, opt.norm_resp), ....
                'fontsize', 14, 'xoff', 0,'yoff',0.05);
            print_fig(prefix, out_dir, group(iGroup).name, task, iNorm)
        end

    end
    
    opt.plot = 'Group';
    opt.max_y_axis = max_y_axis;
    
    % plot both groups with and without row normalization
    for iNorm = 0:1
        opt.norm_resp = iNorm;
        
        % plot the 2 groups separately
        prefix = 'beh_bothgrp-';
        make_figure(bothgrp_avg_all_stim, task, opt)
        mtit(sprintf('Group: %s ; Task: %s ; Row norm: %i', ...
            'both', tasks{iTask}, opt.norm_resp), ....
            'fontsize', 14, 'xoff', 0,'yoff',0.05);
        print_fig(prefix, out_dir, group(iGroup).name, task, iNorm)
        
    end
    
end

function print_fig(prefix, out_dir, group_name, task, iNorm)
print(gcf, fullfile(out_dir, ...
    [prefix group_name '_task-' task '_norm-' num2str(iNorm) '.jpg']), '-djpeg')
end