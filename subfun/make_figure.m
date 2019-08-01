function make_figure(all_stim, tasks, opt)

% trial_type = {...
%     'ch1', ...
%     'ch3', ...
%     'ch5', ...
%     'ch7', ...
%     'resp_03', ...
%     'resp_12'};

fontsize = 12;

opt = get_option(opt);

samp_freq = opt.samp_freq;

stim_color = opt.stim_color;
stim_legend = opt.stim_legend;

% take latest offset of the last stim to set the end of the run for
% plottingg
run_length = find(any(all_stim{4,1}==-1), 1, 'last');

nb_bins = floor(run_length/opt.bin_size);

nb_columns = size(all_stim,2);

opt.nb_subj = size(all_stim{1,1},1);

bin_duration  = 1/samp_freq * opt.bin_size;
x_tick = round(linspace(0,nb_bins,10));
x_label = round(linspace(0,nb_bins*bin_duration,10));

[Color, Run, SubPlot] = choose_color(nb_columns, opt);

%%
figure('name', tasks, 'position', [50 50 1300 700], 'visible', opt.visible)

iSubplot = 1;

for iRun = 1:nb_columns
    
    %% Plot stimuli: each type with a different color
    
    opt.mov_mean = 0;
    opt.normalize = 0;
    
    subplot(3, nb_columns, SubPlot(iSubplot))
    hold on
    
    for iStim = 1:4
        to_plot = all_stim{iStim,iRun}(:,1:run_length);
        to_plot = process_timeSeries(to_plot, nb_bins, opt);
        plot(to_plot, stim_color{iStim}, 'linewidth', 2)
    end
    axis tight
    set(gca, 'fontsize', fontsize, 'xtick', x_tick)
    t = title(sprintf('%s %s ; Bin size: %i ; Mov win size: %i', ...
        opt.plot, Run{iRun}, opt.bin_size, opt.moving_win_size));
    set(t, 'fontsize', fontsize)
    ylabel('Stimuli')
    legend(stim_legend)
    
    iSubplot = iSubplot + 1;
    
    
    %% Plot response 1
    
    opt.mov_mean = opt.mov_mean_resp;
    opt.normalize = opt.norm_resp;
    
    subplot(3, nb_columns, SubPlot(iSubplot))
    hold on
    
    to_plot = all_stim{5,iRun}(:,1:run_length);
    [to_plot, sem, all_subjs] = process_timeSeries(to_plot, nb_bins, opt);
    do_plot(to_plot, sem, all_subjs, Color, iSubplot, opt)
    [norm_text] = label_your_axes(fontsize, x_tick, x_label, opt); % or ou might lose them: an old dwarf saying
    ylabel(sprintf('Resp 1 - Row norm: %s', norm_text))
    
    iSubplot = iSubplot + 1;
    
    %% Plot response 2
    subplot(3, nb_columns, SubPlot(iSubplot))
    hold on
    
    to_plot = all_stim{6,iRun}(:,1:run_length);
    [to_plot, sem, all_subjs] = process_timeSeries(to_plot, nb_bins, opt);
    do_plot(to_plot, sem, all_subjs, Color, iSubplot, opt)
    [norm_text] = label_your_axes(fontsize, x_tick, x_label, opt);
    ylabel(sprintf('Resp 2 - Row norm: %s', norm_text))
    
    iSubplot = iSubplot + 1;
    
end
end


function [Color, Run, SubPlot] = choose_color(nb_columns, opt)

blnd_color = opt.blnd_color;
sighted_color = opt.sighted_color;
black = [0 0 0];

if opt.iGroup==1
    Color = blnd_color/255;
else
    Color = sighted_color/255;
end
Color = repmat(Color, [6 1]);

switch nb_columns
    case 1
        SubPlot = [1 2 3];
        if strcmp(opt.plot, 'Run')
            Run = {'1 & 2'};
        else
            error('Cannot plot both runs and both groups at the same time.')
        end
    case 2
        SubPlot = [1 3 5 2 4 6];
        if strcmp(opt.plot, 'Run')
            Run = {'1','2'};
        else
            Run = {'blnd' 'ctrl'};
            Color = [...
                black; blnd_color; blnd_color;...
                black; sighted_color; sighted_color]/255;
        end
end

end