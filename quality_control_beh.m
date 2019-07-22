function quality_control_beh()

clear 
close all
clc

tgt_dir = 'D:\olf_blind\raw'; % target folder

bids =  spm_BIDS(tgt_dir);
stim_file = spm_BIDS(bids, 'data', 'type', 'stim');
metadata = spm_BIDS(bids, 'metadata', 'type', 'stim');

for i_stim = 1%:numel(stim_file)

gunzip(stim_file{i_stim})

x = spm_load(stim_file{i_stim}(1:end-3),'',false(1));

breath = x(:,1);
MIN = min(breath);
MAX = max(breath);

stim = x(:,2);

resp = x(:,5);

figure(i_stim)
hold on

FIIK = x(:,4);
FIIK = norm_2_range(FIIK, MIN, MAX);
plot(FIIK, 'g')

resp = norm_2_range(resp, MIN, MAX);
plot(resp, 'k', 'linewidth', 1.5)

stim = norm_2_range(stim, MIN, MAX);
plot(stim, 'r', 'linewidth', 2)

plot(breath, 'b', 'linewidth', 2) % plot breathing

StartTime = metadata{i_stim}.StartTime * -1 * metadata{i_stim}.SamplingFrequency;
plot([StartTime StartTime], [0 MAX], '--k', 'linewidth', 2)

axis tight

end

end

function x = norm_2_range(x, MIN, MAX)
    x = x - min(x);
%     x = x + MIN;
    x = x / max(x);
    x = x * MAX;
end