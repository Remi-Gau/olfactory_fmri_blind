% behavioral results

% Plots the average number of response during stimulus period

% some subjects have weird onsets for some stimuli so we replace them by
% the average onset from the rest of the group

% assumes a fixed 16 seconds stimulation duration

close all;
clear;
clc;

if ~exist('machine_id', 'var')
    machine_id = 1; % 0: container ;  1: Remi ;  2: Beast
end
% setting up directories
[data_dir, code_dir] = set_dir(machine_id);

% mention where the BIDS data set is (can get the behavioral from OSF)
tgt_dir = fullfile(data_dir, 'raw');

out_dir = fullfile(pwd, 'output', 'figures', 'beh_avg');
mkdir(out_dir);

opt.baseline_dur = 20;
opt.pre_stim = 16;
opt.stim_dur = 16;
opt.post_stim = 16;

% offset time courses by the pre stimulus baseline level of response
opt.rm_baseline = 0;

% some settings for the figures
max_y_axis = 6.5;

opt.visible = 'on';

fontsize = 12;

% just to prevent label_your_axes from trying to give a meaningful scale
% opt.norm_resp = 1;

opt = get_option(opt);

[~, stim_epoch, ~, group, tasks] = get_and_epoch_data(tgt_dir, opt);

%% Plots the average number of response during stimulus period
clc;
close all;

stim_legend = opt.stim_legend;
Colors(1, :) = opt.blnd_color;
Colors(2, :) = opt.sighted_color;
Colors = Colors / 255;

for iTask = 1:2
    
    figure('name', tasks{iTask}, 'position', [50 50 1300 700], 'visible', opt.visible);
    
    iSubplot = 1;
    
    
    for iTrialtype = 1:4
        
        clear to_plot;
        
        subplot(2, 4, iSubplot);
        hold on;
        
        for iGroup = 1:2
            
            resp_1 = sum(stim_epoch{1, iGroup, iTask}(:, :, iTrialtype), 2);
            resp_2 = sum(stim_epoch{1, iGroup, iTask}(:, :, iTrialtype), 2);
            
            h = plotSpread(to_plot, 'distributionIdx', ones(size(to_plot)), ...
                'distributionMarkers', {'o'}, ...
                'distributionColors', Colors(iGroup, :), ...
                'xValues', iGroup, ...
                'showMM', 0, ...
                'binWidth', .1, 'spreadWidth', 1);
            
            set(h{1}, 'MarkerSize', 7, 'MarkerEdgeColor', 'k', ...
                'MarkerFaceColor', Colors(iGroup, :), ...
                'LineWidth', 2);
            
            h = errorbar(iGroup - .5, ...
                mean(to_plot), ...
                std(to_plot) / numel(to_plot)^.5, ...
                'o', ...
                'color', Colors(iGroup, :), 'linewidth', 2, ...
                'MarkerSize', 5, ...
                'MarkerEdgeColor', 'k', ...
                'MarkerFaceColor', Colors(iGroup, :));
            
        end
        
        plot([0 3], [0 0], 'k');
        
        set(gca, 'fontsize', fontsize, ...
            'ytick', 0:1:6, 'yticklabel', 0:1:6, ...
            'xtick', 1:2, 'xticklabel', {group.name}, ...
            'ticklength', [.02 .02], 'tickdir', 'out');
        
        axis([0.2 2.5 0 max_y_axis]);
        
        iSubplot = iSubplot + 1;
    end
    
    
    subplot(2, 4, 1);
    t = ylabel('Resp 1  - [A U]');
    set(t, 'fontsize', fontsize);
    
    subplot(2, 4, 5);
    t = ylabel('Resp 2 - [A U]');
    set(t, 'fontsize', fontsize);
    
    for iTrialtype = 1:4
        subplot(2, 4, iTrialtype);
        title(stim_legend{iTrialtype});
    end
    
    mtit(sprintf('Mean number of responses during stim epoch ; Task: %s', tasks{iTask}), ....
        'fontsize', 14, 'xoff', 0, 'yoff', 0.05);
    
    print(gcf, fullfile(out_dir, ...
        ['Avg_Resp_' ...
        group(iGroup).name ...
        '_task-' tasks{iTask} ...
        '_rmbase-' num2str(opt.rm_baseline) ...
        '.jpg']), '-djpeg');
    
end
