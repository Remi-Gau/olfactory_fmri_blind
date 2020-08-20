% behavioral results

% plots data with PSTH for each stimulus (averaged across runs)

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

baseline_dur = 20;
pre_stim = 16;
stim_dur = 16;
post_stim = 16;

% offset time courses by the pre stimulus baseline level of response
opt.rm_baseline = 0;

% some settings for the figures
max_y_axis = 6.5;

opt.bin_size = 20;

opt.mov_mean = 1;
opt.moving_win_size = 20;

opt.max_y_axis = ones(2, 1) * .15;

opt.plot_subj = 0;
opt.normalize = 0;
opt.visible = 'on';

fontsize = 12;

% just to prevent label_your_axes from trying to give a meaningful scale
opt.norm_resp = 1;

%% get data

% loads bids data
bids =  spm_BIDS(tgt_dir);

% do the loading of the data and plot
close all;

out_dir = fullfile(pwd, 'output', 'figures', 'beh_avg');
mkdir(out_dir);

tasks = spm_BIDS(bids, 'tasks');
if numel(tasks) == 3
    tasks(3) = [];
end

group(1).name = 'blnd';
group(2).name = 'ctrl';

for iTask = 1:numel(tasks)

    for iGroup = 1:numel(group)

        subjects = spm_BIDS(bids, 'subjects', ...
            'task', tasks{iTask});

        idx = strfind(subjects, {group(iGroup).name});
        idx = find(~cellfun('isempty', idx)); %#ok<STRCL1>

        subjects(idx);

        group(iGroup).subjects = subjects(idx);

        all_stim = average_beh(bids, tasks{iTask}, subjects(idx));

        for iTrialType = 1:size(all_stim, 1)
            for iRun = 1:2
                all_time_courses{iTrialType, iRun, iGroup, iTask} = ...
                    all_stim{iTrialType, iRun}; %#ok<*SAGROW>
            end
        end

    end
end

%% epoch the data

opt = get_option(opt);

[prestim_epoch, stim_epoch, poststim_epoch] = ...
        epoch_data(tasks, group, all_time_courses, ...
        baseline_dur, stim_dur, pre_stim, post_stim, ...
        opt);

%% Plots the PSTH
clc;
close all;

pre_stim = pre_stim * opt.samp_freq;
stim_dur = stim_dur * opt.samp_freq;

stim_legend = opt.stim_legend;
samp_freq = opt.samp_freq;

blnd_color = opt.blnd_color;
sighted_color = opt.sighted_color;
black = [0 0 0];

bin_duration  = 1 / samp_freq * opt.bin_size;

stim_onset = pre_stim / opt.bin_size;
stim_offset = (pre_stim + stim_dur) / opt.bin_size;

for iGroup = 1:2

    if iGroup == 1
        Color = blnd_color / 255;
    else
        Color = sighted_color / 255;
    end

    for iTask = 1:2

        figure('name', ['PSTH - ' tasks{iTask}], ...
            'position', [50 50 1300 700], ...
            'visible', opt.visible);

        iSubplot = 1;

        for iResp = 1:2
            for iTrialtype = 1:4

                to_plot = cat(2, ...
                    prestim_epoch{iResp, iGroup, iTask}(:, :, iTrialtype), ...
                    stim_epoch{iResp, iGroup, iTask}(:, :, iTrialtype), ...
                    poststim_epoch{iResp, iGroup, iTask}(:, :, iTrialtype));

                opt.nb_subj = size(to_plot, 2);

                nb_bins = round(length(to_plot) / opt.bin_size);
                x_tick = round(linspace(0, nb_bins, 10));
                x_label = round(linspace(0, nb_bins * bin_duration, 10)) - ...
                    pre_stim / samp_freq;

                [to_plot, sem, all_subjs] = process_timeSeries(to_plot, nb_bins, opt);

                subplot(2, 4, iSubplot);
                hold on;
                
                draw_stim(stim_onset, stim_offset, opt.max_y_axis(1), opt);

                do_plot(to_plot, sem, all_subjs, Color, 1, opt);

                plot([0 numel(to_plot)], [0 0], 'k');

                label_your_axes(fontsize, x_tick, x_label, opt);

                axis tight;
                ax = axis;
                axis([ax(1) ax(2) ax(3) opt.max_y_axis(1)]);

                iSubplot = iSubplot + 1;
            end

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

        mtit(sprintf('Group: %s ; Task: %s ; Bin size: %i ; Mov win size: %i', ...
            group(iGroup).name, tasks{iTask}, opt.bin_size, opt.moving_win_size), ....
            'fontsize', 14, 'xoff', 0, 'yoff', 0.05);

        print(gcf, fullfile(out_dir, ...
            ['PSTH_' ...
            group(iGroup).name ...
            '_task-' tasks{iTask} ...
            '_rmbase-' num2str(opt.rm_baseline) ...
            '.jpg']), '-djpeg');

    end
end

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

    for iResp = 1:2
        for iTrialtype = 1:4

            clear to_plot;

            subplot(2, 4, iSubplot);
            hold on;

            for iGroup = 1:2

                to_plot = sum(stim_epoch{iResp, iGroup, iTask}(:, :, iTrialtype), 2);

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

%%
function [prestim_epoch, stim_epoch, poststim_epoch] = epoch_data(tasks, group, all_time_courses, baseline_dur, stim_dur, pre_stim, post_stim, opt)

    baseline_dur = baseline_dur * opt.samp_freq;
    pre_stim = pre_stim * opt.samp_freq;
    stim_dur = stim_dur * opt.samp_freq;
    post_stim = post_stim * opt.samp_freq;

    fprintf(1, '\n\nEpoching the data');

    for iTask = 1:numel(tasks)
        for iGroup = 1:numel(group)
            for iRun = 1:2

                % onset and offset of each stim
                for iTrialtype = 1:4
                    data = all_time_courses{iTrialtype, iRun, iGroup, iTask};
                    for iSubj = 1:size(data, 1)
                        ON = find(data(iSubj, :) == 1);
                        if isempty(ON)
                            ON = 1;
                        end
                        onsets(iSubj, iTrialtype) = ON;
                    end
                end

                % indices of baseline epoch
                baseline_idx = onsets(:, 1);

                % in case some subjects have messed up onsets
                bad_baseline = baseline_idx <= baseline_dur / 2;
                if any(bad_baseline)

                    fprintf(1, '\n');
                    warning('Filling in some bad onsets with average from onset from the rest of the group.');
                    fprintf(1, 'Group: %s\n', ...
                        group(iGroup).name);
                    fprintf(1, 'Subject: %s \n', ...
                        group(iGroup).subjects{bad_baseline});

                    baseline_idx(bad_baseline, :) = ...
                        repmat(round(mean(baseline_idx(~bad_baseline, :))), ...
                        [sum(bad_baseline), 1]);
                end

                % Do something similar for the other onsets
                for iTrialtype = 2:4
                    tmp = onsets(:, iTrialtype) == 1;
                    onsets(tmp, iTrialtype) = repmat(round(mean(onsets(~tmp, iTrialtype))), ...
                        [sum(tmp), 1]);
                end

                % update onsets
                onsets(:, 1) = baseline_idx(:, 1);

                % create offsets using a fixed duration
                offsets = onsets + stim_dur;

                % create epoch index for baseline
                baseline_idx = [baseline_idx - baseline_dur, baseline_idx];

                % for each response
                for iResp = 1:2

                    data = all_time_courses{iResp + 4, iRun, iGroup, iTask};

                    % get baseline
                    for iSubj = 1:size(data, 1)
                        baseline(iSubj, iResp) = ...
                            mean(data(iSubj, baseline_idx(iSubj, 1):baseline_idx(iSubj, 2)));
                    end

                    % slice the responses time courses for pre-stim epoch for each stim
                    % and normalizes the data by the baseline (minus the
                    % average number of responses per time point during the
                    % baseline)
                    for iTrialtype = 1:4
                        for iSubj = 1:size(data, 1)

                            ON = onsets(iSubj, iTrialtype);
                            OFF = offsets(iSubj, iTrialtype);

                            if opt.rm_baseline
                                OFFSET = baseline(iSubj, iResp);
                            else
                                OFFSET = 0;
                            end

                            prestim_epoch{iResp, iGroup, iTask}(iSubj, :, iTrialtype, iRun) = ...
                                data(iSubj, ON - pre_stim:ON - 1) - OFFSET;
                            stim_epoch{iResp, iGroup, iTask}(iSubj, :, iTrialtype, iRun) = ...
                                data(iSubj, ON:OFF) - OFFSET;
                            poststim_epoch{iResp, iGroup, iTask}(iSubj, :, iTrialtype, iRun) = ...
                                data(iSubj, OFF + 1:OFF + post_stim) - OFFSET;

                        end
                    end
                end

            end

            % average across runs
            for iResp = 1:2
                prestim_epoch{iResp, iGroup, iTask} = mean(poststim_epoch{iResp, iGroup, iTask}, 4);
                stim_epoch{iResp, iGroup, iTask} = mean(stim_epoch{iResp, iGroup, iTask}, 4);
                poststim_epoch{iResp, iGroup, iTask} = mean(poststim_epoch{iResp, iGroup, iTask}, 4);
            end
        end

    end

    fprintf(1, '\nDone!\n\n');
end
