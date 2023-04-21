% Plots data with PSTH for each stimulus (averaged across runs)
%
%
% Some subjects have weird onsets for some stimuli so we replace them by
% the average onset from the rest of the group
%
% Assumes a fixed 16 seconds stimulation duration
%
%
% (C) Copyright 2021 Remi Gau

close all;
clear;
clc;

run ../../initEnv.m;

opt = options();

% offset time courses by the pre stimulus baseline level of response
opt.rm_baseline = 0;

opt.bin_size = 20;

opt.mov_mean = 1;
opt.moving_win_size = 20;

opt.max_y_axis = ones(2, 1) * .15;

opt.plot_subj = 0;
opt.normalize = 0;

fontsize = 12;

% just to prevent label_your_axes from trying to give a meaningful scale
opt.norm_resp = 1;

out_dir = fullfile(opt.dir.beh, 'derivatives',  'beh', 'figures', 'beh_avg');
spm_mkdir(out_dir);

[prestim_epoch, stim_epoch, poststim_epoch, group, tasks] = get_and_epoch_data(opt.dir.beh, opt);

%% Plots the PSTH
pre_stim = opt.pre_stim * opt.samp_freq;
stim_dur = opt.stim_dur * opt.samp_freq;

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

    %% get data to plot
    for iResp = 1:2
      for iTrialtype = 1:4

        data = cat(2, ...
                   prestim_epoch{iResp, iGroup, iTask}(:, :, iTrialtype), ...
                   stim_epoch{iResp, iGroup, iTask}(:, :, iTrialtype), ...
                   poststim_epoch{iResp, iGroup, iTask}(:, :, iTrialtype));

        epoched_data{iResp, iTrialtype} = data;

      end
    end

    %% Average across trial depending on task

    switch tasks{iTask}
      case 'olfid'

        stim_legend;

    end

    %% bin and smooth data
    opt.nb_subj = size(data, 2);
    nb_bins = round(length(data) / opt.bin_size);
    for iResp = 1:2
      for iTrialtype = 1:4

        [mean_to_plot{iResp, iTrialtype}, ...
            sem_to_plot{iResp, iTrialtype}, ...
            all_subjs{iResp, iTrialtype}] = ...
            process_timeSeries(epoched_data{iResp, iTrialtype}, nb_bins, opt);

      end
    end

    %% plot

    x_tick = round(linspace(0, nb_bins, 10));
    x_label = round(linspace(0, nb_bins * bin_duration, 10)) - ...
        pre_stim / samp_freq;

    figure('name', ['PSTH - ' tasks{iTask}], ...
           'position', [50 50 1300 700], ...
           'visible', opt.visible);

    iSubplot = 1;

    for iResp = 1:size(mean_to_plot, 1)
      for iTrialtype = 1:size(mean_to_plot, 2)

        data_to_plot = mean_to_plot{iResp, iTrialtype};
        sem = sem_to_plot{iResp, iTrialtype};

        subplot(size(mean_to_plot, 1), size(mean_to_plot, 2), iSubplot);
        hold on;

        draw_stim(stim_onset, stim_offset, opt.max_y_axis(1), opt);

        do_plot(data_to_plot, sem, all_subjs{iResp, iTrialtype}, Color, 1, opt);

        plot([0 numel(data_to_plot)], [0 0], 'k');

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

    if isOctave
      title(sprintf('Group: %s ; Task: %s ; Bin size: %i ; Mov win size: %i', ...
                    group(iGroup).name, tasks{iTask}, opt.bin_size, opt.moving_win_size));
    else
      mtit(sprintf('Group: %s ; Task: %s ; Bin size: %i ; Mov win size: %i', ...
                   group(iGroup).name, tasks{iTask}, opt.bin_size, opt.moving_win_size), ....
           'fontsize', 14, 'xoff', 0, 'yoff', 0.05);
    end

    %     print(gcf, fullfile(out_dir, ...
    %                         ['PSTH_' ...
    %                          group(iGroup).name ...
    %                          '_task-' tasks{iTask} ...
    %                          '_rmbase-' num2str(opt.rm_baseline) ...
    %                          '.jpg']), '-djpeg');

  end
end
