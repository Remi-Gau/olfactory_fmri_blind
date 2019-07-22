function quality_control_beh()

clear
close all
clc

tgt_dir = 'D:\olf_blind\raw'; % target folder

bids =  spm_BIDS(tgt_dir);
stim_file = spm_BIDS(bids, 'data', 'type', 'stim');
metadata = spm_BIDS(bids, 'metadata', 'type', 'stim');

out_dir = fullfile('output', 'figures', 'beh_qc');
mkdir(out_dir)

visible = 'off';

for i_stim = 1:numel(stim_file)
    
    %get stimulus file
    gunzip(stim_file{i_stim}) 
    x = spm_load(stim_file{i_stim}(1:end-3),'',false(1));
    
    breath = x(:,1);
    MAX = max(breath);
    
    stim = x(:,2);
    
    resp = x(:,5);
    
    if range(breath)<0.1
        comment = 'Very small breath range.';
    else
        comment = '';
    end
    
    if numel(unique(resp))==1
        comment = [comment ' No responses.']; %#ok<*AGROW>
    end
    
    %% make figure
    figure('name', stim_file{i_stim}, 'position', [50 50 1300 700], 'visible', visible)
    clf
    hold on
    
    FIIK = x(:,4);
    FIIK = norm_2_range(FIIK, MAX);
    plot(FIIK, 'g')
    
    resp = norm_2_range(resp, MAX);
    plot(resp, 'k', 'linewidth', 1.5)
    
    stim = norm_2_range(stim, MAX);
    plot(stim, 'r', 'linewidth', 2)
    
    plot(breath, 'b', 'linewidth', 2) % plot breathing
%     plot(diff(breath), 'c')
    
    % get the start time of the run (after the dummies have been removed)
    StartTime = metadata{i_stim}.StartTime * -1 * metadata{i_stim}.SamplingFrequency;
    plot([StartTime StartTime], [0 MAX], '--k', 'linewidth', 2)
    
    axis tight
    
    legend({'FIIK', 'responses?', 'stimuli', 'breath'})
    
    [~, file, ~] = fileparts(stim_file{i_stim}(1:end-3));
    print(gcf, fullfile(out_dir, [file '.jpeg']), '-djpeg')
    

    filenames{i_stim,1} = [file '.jpeg'];
    comments{i_stim,1} = comment;
    
end

T = table(filenames,comments);
writetable(T, fullfile(out_dir, 'stim_files_QC.csv'), 'Delimiter', ',')  

end

function x = norm_2_range(x, MAX)
% normalizes between 0 and a given max alue
x = x - min(x);
x = x / max(x);
x = x * MAX;
end