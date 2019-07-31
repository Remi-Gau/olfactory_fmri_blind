% quality_control_beh()

clear
clc

% spm_path = '/home/remi-gau/Documents/SPM/spm12';
% addpath(spm_path)
spm('defaults','fmri')

tgt_dir = 'D:\BIDS\olf_blind\raw';

out_dir = fullfile(pwd, 'output', 'figures', 'beh_qc');

visible = 'off';

% get options
opt = get_option;
nb_dummies = opt.nb_dummies;
RT = opt.RT;
samp_freq = opt.samp_freq;
trial_type = opt.trial_type;
stim_color = opt.stim_color;
Legend = opt.stim_legend;
Legend{end+1} = 'resp_1';
Legend{end+1} = 'resp_2';
Legend{end+1} = 'respiration';

% get date info
bids =  spm_BIDS(tgt_dir);
subjects = spm_BIDS(bids, 'subjects');
tasks = spm_BIDS(bids, 'tasks');

% number of time points to remove from phsyio to align with beh
physio_crop = 1:RT*nb_dummies*samp_freq;

mkdir(out_dir)

%%

for iSub = 1:numel(subjects)
    for iTasks = 1:2
        
        physio_file = spm_BIDS(bids, 'data', ...
            'sub', subjects{iSub}, ...
            'task', tasks{iTasks}, ...
            'type', 'physio');
        
        metadata = spm_BIDS(bids, 'metadata', ...
            'sub', subjects{iSub}, ...
            'task', tasks{iTasks}, ...
            'type', 'physio');
        
        event_file = spm_BIDS(bids, 'data', ...
            'sub', subjects{iSub}, ...
            'task', tasks{iTasks}, ...
            'type', 'events');
        
        for iRun = 1:numel(physio_file)
            
            close all

            
            % get physio data
            disp(physio_file{iRun})
            if ~exist(physio_file{iRun}(1:end-3), 'file')
                gunzip(physio_file{iRun})
            end
            x = spm_load(physio_file{iRun}(1:end-3),'',false(1));
            respiration = x(:,1);
            respiration(physio_crop) = [];
            MAX = max(respiration);
            
            if range(respiration)<0.1
                comment = 'Very small respiration range.';
            else
                comment = '';
            end
            
            
            % Get stim and responses
            %get events file
            disp(event_file(iRun))
            trial_courses = get_trial_timecourse(event_file(iRun));
            
            % crop the time courses of the responses and trial types to
            % match that of the respiration
            fprintf('respiration file longer by: %02.1f seconds\n', ...
                (length(respiration)-size(trial_courses,2)) / samp_freq );
            trial_courses(:,length(respiration)+1:end) = [];
            
            % some sanity checks for later
            if all(all(trial_courses(1:4,:)==0))
                comment = [comment ' No stim.']; %#ok<*AGROW>
            end
            
            if all(all(trial_courses(5:end,:)==0))
                comment = [comment ' No responses.']; %#ok<*AGROW>
            end
            
            % fill the onset and offset by durations
            for iTrialtype = 1:size(trial_courses,1)
                onsets = find(trial_courses(iTrialtype,:)==1);
                offsets = find(trial_courses(iTrialtype,:)==-1);
                % in case the offset was cropped out we make the stim end
                % at the end of the timecourse
                if isempty(offsets) && iTrialtype<5
                    offsets = size(trial_courses,2); 
                end
                if iTrialtype>4
                    trial_courses(iTrialtype,onsets) = 1;
                else
                    trial_courses(iTrialtype,onsets:offsets) = 1;
                end
                
            end
            
            % make figure
            figure('name', physio_file{iRun}, 'position', [50 50 1300 700], 'visible', visible)
            hold on
            
            % plot stimuli
            for iStim = 1:4
                plot(trial_courses(iStim,:), stim_color{iStim}, 'linewidth', 2)
            end
            % plot responses
            plot(trial_courses(5,:), '--k', 'linewidth', 2)
            plot(trial_courses(6,:), 'k', 'linewidth', 2)
            % plot breathing
            plot(respiration, 'b', 'linewidth', 2) 
            
            axis tight
            
            legend(Legend)
            
            [~, file, ~] = fileparts(event_file{iRun}(1:end-3));
            print(gcf, fullfile(out_dir, [file '.jpeg']), '-djpeg')
            
            
            filenames{iRun,1} = [file '.jpeg']; %#ok<*SAGROW>
            comments{iRun,1} = comment;
            
        end
    end
end

T = table(filenames,comments);
writetable(T, fullfile(out_dir, 'stim_files_QC.csv'), 'Delimiter', ',')