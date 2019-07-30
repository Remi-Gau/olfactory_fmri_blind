function [all_stim, task] = average_beh(bids, task, subjects)

sampling_frequency = 25;

trial_type = {...
    'ch1', ...
    'ch3', ...
    'ch5', ...
    'ch7', ...
    'resp_03', ...
    'resp_12'};

% create template matrix to collect responses, stim, ...
template = zeros(numel(subjects), 280 * sampling_frequency); % seconds * sampling frequency

for iTrial_type = 1:numel(trial_type)
    all_stim{iTrial_type,1} = template; %#ok<*AGROW>
    all_stim{iTrial_type,2} = template;
end

% we take each event file from each subject for that task and we collect
% onsets and offsets of all stim and responses
for iSubjects = 1:numel(subjects)
    
    runs = spm_BIDS(bids, 'runs', ...
        'type', 'events', ...
        'sub', subjects{iSubjects}, ...
        'task', task);
    
    for iRun = 1:numel(runs)
        
        event_file = spm_BIDS(bids, 'data', ...
            'type', 'events', ...
            'sub', subjects{iSubjects}, ...
            'task', task, ...
            'run', runs{iRun});
        
        if numel(event_file)>1
            error('We should have only one file.')
        end
        
        %get events file
        disp(event_file)
        x = spm_load(event_file{1},'',false(1));

        % we collect the stim / resp onsets and offsets
        for iTrial_type = 1:numel(trial_type)
  
            idx = strcmp(x.Var3, trial_type{iTrial_type});
            
            event_onsets = str2double(x.Var1(idx));
            event_offsets = event_onsets + str2double(x.Var2(idx));
            
            % we round as we need to use those values as indices in a time
            % course
            event_onsets = round(event_onsets * sampling_frequency);
            event_offsets = round(event_offsets * sampling_frequency);
            if any(event_onsets<0)
                event_onsets(event_onsets<0) = 1;
                warning('some values are below 0 and they should not be.')
            end
            
            % we take onset and offsets for stimuli
            if iTrial_type<5
                all_stim{iTrial_type,iRun}(iSubjects, event_onsets) = 1;
                all_stim{iTrial_type,iRun}(iSubjects, event_offsets) = -1;
            % we only take onset for responses
            else
                all_stim{iTrial_type,iRun}(iSubjects, event_onsets) = 1;
            end
        end

    end
end


end