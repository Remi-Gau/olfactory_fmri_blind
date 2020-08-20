function draw_stim(idx_onset, idx_offset, max_value, opt)
    % draw_stim(idx_onset, idx_offset, max_value, opt)
    %
    % draw patches for the stimulus blocks
    
    stim_color_mat = opt.stim_color_mat;
    stim_color_mat(stim_color_mat == 0) = .9;
    
    for iStim = 1:numel(idx_onset)
        patch( ...
            [idx_onset(iStim) idx_onset(iStim) idx_offset(iStim) idx_offset(iStim)], ...
            [0 max_value max_value 0], ...
            stim_color_mat(iStim,:), ...
            'linestyle', opt.stim_linestyle{iStim});
    end
end