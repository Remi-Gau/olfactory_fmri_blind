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

blnd_color = opt.blnd_color;
sighted_color = opt.sighted_color;

black = [0 0 0];


% take latest offset of the last stim to set the end of the run for
% plottingg
run_length = find(any(all_stim{4,1}==-1), 1, 'last');

nb_bins = floor(run_length/opt.bin_size);

nb_columns = size(all_stim,2);

opt.nb_subj = size(all_stim{1,1},1);

bin_duration  = 1/samp_freq * opt.bin_size;
x_tick = round(linspace(0,nb_bins,10));
x_label = round(linspace(0,nb_bins*bin_duration,10));

switch nb_columns
    case 1
        SubPlot = [1 2 3];
        if strcmp(opt.plot, 'Run')
            Run = {'1 & 2'};
            Color = repmat(black,[3,1])/255;
        else
            Run = {opt.group};
            %             Color = repmat(black,[3,1]);
        end
    case 2
        SubPlot = [1 3 5 2 4 6];
        if strcmp(opt.plot, 'Run')
            Run = {'1','2'};
            Color = repmat(black,[6,1])/255;
        else
            Run = {'blnd' 'ctrl'};
            Color = [...
                black; blnd_color; blnd_color;...
                black; sighted_color; sighted_color]/255;
        end
end

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

function do_plot(to_plot, sem, all_subjs, Color, iSubplot, opt)
% either plot mean and each subject or mean +/- sem
if opt.plot_subj
    for iSubj = 1:size(all_subjs,1)
        plot(1:length(to_plot), all_subjs(iSubj,:), ...
            'color', Color(iSubplot,:)*.9, 'linewidth', .5);
        plot(1:length(to_plot), to_plot, ...
            'color', Color(iSubplot,:), 'linewidth', 2);
    end
else
    shadedErrorBar(1:length(to_plot), to_plot, sem, ...
        {'color', Color(iSubplot,:), 'linewidth', 2})
end
end

function [to_plot, sem, all_subjs] = process_timeSeries(to_plot, nb_bins, opt)
to_plot(isnan(to_plot)) = 0;
to_plot = bin_data(to_plot, nb_bins, opt);
if opt.normalize
    to_plot = normalize_data(to_plot);
end
if opt.mov_mean
    to_plot = movmean(to_plot,opt.moving_win_size,2);
end
all_subjs = to_plot;
sem = nanstd(to_plot)/size(to_plot,1);
to_plot = nanmean(to_plot);
end


function to_plot = bin_data(to_plot, nb_bins, opt)

tmp = zeros(size(to_plot,1),nb_bins);

t_start = 1;
t_end = opt.bin_size;

for iBin = 1:nb_bins
    tmp(:,iBin) = sum(to_plot(:,t_start:t_end), 2);
    t_start = t_start + opt.bin_size;
    t_end = t_end + opt.bin_size;
end

to_plot = tmp;

end

function to_plot = normalize_data(to_plot)
for iRow = 1:size(to_plot,1)
    to_plot(iRow,:) = to_plot(iRow,:)/sum(to_plot(iRow,1:end));
end
end

function [norm_text] = label_your_axes(fontsize, x_tick, x_label, opt)

if opt.norm_resp
    norm_text = 'YES';
    y_tick = 0:.0025:.1;
    y_label = 0:.0025:.1;
else
    norm_text = 'NO';
    one_resp = 1/opt.nb_subj;
    y_tick = 0:one_resp/4:1;
    y_label = 0:.5:numel(y_tick);
end

axis tight
set(gca, 'fontsize', fontsize, ...
    'ytick', y_tick, 'yticklabel', y_label, ...
    'xtick', x_tick, 'xticklabel', x_label, ...
    'ticklength', [.02 .02], 'tickdir', 'out')

if ~isempty(opt.max_y_axis)
    max_y_axis = opt.max_y_axis(opt.normalize+1);
    ax = axis;
    axis([ax(1) ax(2) 0 max_y_axis]);
end

xlabel('time (sec)')
end