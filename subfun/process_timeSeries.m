function [to_plot, sem, all_subjs] = process_timeSeries(to_plot, nb_bins, opt)
    
    to_plot(isnan(to_plot)) = 0;
    to_plot = bin_data(to_plot, nb_bins, opt);
    
    if opt.normalize
        to_plot = normalize_data(to_plot);
    end
    
    if opt.mov_mean
        to_plot = movmean(to_plot, [opt.moving_win_size], 2);
    end
    
    all_subjs = to_plot;
    sem = nanstd(to_plot) / size(to_plot, 1)^.5;
    to_plot = nanmean(to_plot);
    
end
