% quality_control_physio
% plots the respiratory data from each subject / run and shows when the
% acquisition was started.


clear
clc

% spm_path = '/home/remi-gau/Documents/SPM/spm12';
% addpath(spm_path)
spm('defaults','fmri')

tgt_dir = 'D:\BIDS\olf_blind\raw';


bids =  spm_BIDS(tgt_dir);
physio_file = spm_BIDS(bids, 'data', 'type', 'physio');
metadata = spm_BIDS(bids, 'metadata', 'type', 'physio');

out_dir = fullfile('output', 'figures', 'physio_qc');
mkdir(out_dir)

visible = 'off';

for i_stim = 1:numel(physio_file)

    disp(physio_file{i_stim})

    %get stimulus file
    if ~exist(physio_file{i_stim}(1:end-3), 'file')
        gunzip(physio_file{i_stim})
    end
    x = spm_load(physio_file{i_stim}(1:end-3),'',false(1));

    close all

    breath = x(:,1);
    MAX = max(breath);

    if range(breath)<0.1
        comment = 'Very small breath range.';
    else
        comment = '';
    end

    %% make figure
    figure('name', physio_file{i_stim}, 'position', [50 50 1300 700], 'visible', visible)
    hold on

    plot(breath, 'b', 'linewidth', 2) % plot breathing

    % get the start time of the run (after the dummies have been removed)
    StartTime = metadata{i_stim}.StartTime * -1 * metadata{i_stim}.SamplingFrequency;
    plot([StartTime StartTime], [0 MAX], '--k', 'linewidth', 2)

    axis tight

    legend({'respiration' ,'first scan'})

    [~, file, ~] = fileparts(physio_file{i_stim}(1:end-3));
    print(gcf, fullfile(out_dir, [file '.jpeg']), '-djpeg')


    filenames{i_stim,1} = [file '.jpeg']; %#ok<*SAGROW>
    comments{i_stim,1} = comment;

end

T = table(filenames,comments);
writetable(T, fullfile(out_dir, 'physio_files_QC.csv'), 'Delimiter', ',')

