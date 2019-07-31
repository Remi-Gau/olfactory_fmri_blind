function [norm_text] = label_your_axes(fontsize, x_tick, x_label, opt)

if opt.norm_resp
    norm_text = 'YES';
    if ~isempty(opt.max_y_axis)
        max_y_axis = opt.max_y_axis(opt.normalize+1);
        y_tick = linspace(0,max_y_axis,6);
        y_label = linspace(0,max_y_axis,6);
    else
        y_tick = 0:.0025:.1;
        y_label = 0:.0025:.1;
    end
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
    'ticklength', [.03 .03], 'tickdir', 'out')

if ~isempty(opt.max_y_axis)
    max_y_axis = opt.max_y_axis(opt.normalize+1);
    ax = axis;
    axis([ax(1) ax(2) 0 max_y_axis]);
end

xlabel('time (sec)')
end