function make_figure(all_stim, tasks, opt)

fontsize = 12;

trial_type = {...
    'ch1', ...
    'ch3', ...
    'ch5', ...
    'ch7', ...
    'resp_03', ...
    'resp_12'};

stim_color = {...
    '-g';...  % Eucalyptus Left
    '-r'; ... % Almond Left
    '--g';...  % Eucalyptus Right
    '--r'};    % Almond Right

Legend = {...
    'Euc - Left';...
    'Alm - Left';...
    'Euc - Right';...
    'Alm - Right'};

% take latest offset of the last stim to set the end of the run for
% plottingg
run_length = find(any(all_stim{4,1}==-1), 1, 'last'); 

nb_bins = floor(run_length/opt.bin_size);

nb_subj = size(all_stim{1,1},1);

if opt.norm_resp
    norm_text = 'YES';
    y_tick = 0:.01:1;
    y_label = 0:.01:1;
else
    norm_text = 'NO';
    one_resp = 1/nb_subj;
    y_tick = 0:one_resp:1;
    y_label = 0:1:numel(y_tick);
end


figure('name', tasks, 'position', [50 50 1300 700], 'visible', opt.visible)

for iRun = 1:2
    
    % plot stimuli: each type with a different color
    subplot(3,2,0+iRun)
    hold on
    opt.normalize = 0;
    for iStim = 1:4
        to_plot = all_stim{iStim,iRun}(:,1:run_length);
        to_plot = process_timeSeries(to_plot, nb_bins, opt);
        plot(to_plot, stim_color{iStim}, 'linewidth', 2)
    end
    axis tight
    set(gca, 'fontsize', fontsize)
    t = title(sprintf('Group: %s ; Task: %s ; Run %i ; Bin size: %i', ...
        opt.group, tasks, iRun, opt.bin_size));
    set(t, 'fontsize', fontsize)
    ylabel('Stimuli')
    legend(Legend)
    
    subplot(3,2,2+iRun)
    hold on
    opt.normalize = opt.norm_resp;
    to_plot = all_stim{5,iRun}(:,1:run_length);
    to_plot = process_timeSeries(to_plot, nb_bins, opt);
    plot(to_plot, 'k', 'linewidth', 2)
    axis tight
    set(gca, 'fontsize', fontsize, ...
        'ytick', y_tick, 'yticklabel', y_label)
    ylabel(sprintf('Resp 1 - Row norm: %s', norm_text))
    
    subplot(3,2,4+iRun)
    hold on
    opt.normalize = opt.norm_resp;
    to_plot = all_stim{6,iRun}(:,1:run_length);
    to_plot = process_timeSeries(to_plot, nb_bins, opt);
    plot(to_plot, 'k', 'linewidth', 2)
    axis tight
    set(gca, 'fontsize', fontsize, ...
        'ytick', y_tick, 'yticklabel', y_label)
    ylabel(sprintf('Resp 2 - Row norm: %s', norm_text))
    
end
end

function to_plot = process_timeSeries(to_plot, nb_bins, opt)
to_plot(isnan(to_plot)) = 0;
to_plot = bin_data(to_plot, nb_bins, opt);
if opt.normalize
    to_plot = normalize_data(to_plot);
end
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