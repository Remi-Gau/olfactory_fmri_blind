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
        {'color', Color(iSubplot,:), 'linewidth', 2}, 1)
end
end