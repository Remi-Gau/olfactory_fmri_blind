function plotMetric(valuesToPlot, outliers, metricName, fileLists)
    
    metricName = strrep(metricName, '_', ' ');
    
    figure('name', metricName);
    
    hold on;
    
    bar(1.5:numel(valuesToPlot) + .5, valuesToPlot);
    plot(find(outliers), valuesToPlot(logical(outliers)), ' or');
    
    xlabel('files');
    ylabel(metricName);
    
    set(gca, 'xtick', 1:size(fileLists, 1), ...
        'xticklabel', fileLists, ...
        'fontsize', 8);
    
end

