function make_figure(all_resp, all_stim, run_length, tasks, opt)

run_length = min(run_length);
nb_bins = floor(run_length/opt.bin_size);

figure('name', tasks, 'position', [50 50 1300 700], 'visible', opt.visible)

for iRun = 1:2
    
    subplot(3,2,0+iRun)
    hold on
    opt.normalize = 0;
    to_plot = all_stim{1,iRun}(:,1:run_length);
    to_plot = process_timeSeries(to_plot, nb_bins, opt);
    opt.first_onset = find(to_plot,1);
    plot(to_plot, 'r', 'linewidth', 2)
    axis tight
    title(sprintf('Task: %s ; Run %i', tasks, iRun))
    
    subplot(3,2,2+iRun)
    hold on
    opt.normalize = opt.norm_resp;
    to_plot = all_resp{1,iRun}(:,1:run_length);
    to_plot = process_timeSeries(to_plot, nb_bins, opt);
    plot(to_plot, 'r', 'linewidth', 2)
    axis tight
    ylabel('Resp 1')
    
    subplot(3,2,4+iRun)
    hold on
    opt.normalize = opt.norm_resp;
    to_plot = all_resp{2,iRun}(:,1:run_length);
    to_plot = process_timeSeries(to_plot, nb_bins, opt);
    plot(to_plot, 'r', 'linewidth', 2)
    axis tight
    ylabel('Resp 2')
    
end
end

function to_plot = process_timeSeries(to_plot, nb_bins, opt)
    to_plot(isnan(to_plot)) = 0;
    to_plot = bin_data(to_plot, nb_bins, opt);
    if opt.normalize
        to_plot = normalize_data(to_plot, opt);
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

function to_plot = normalize_data(to_plot, opt)
for iRow = 1:size(to_plot,1)
    to_plot(iRow,:) = to_plot(iRow,:)/sum(to_plot(iRow,1:end));
end
end