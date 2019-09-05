% a script to run through a bids structure and create .mat files that
% can be used as stimulus onset time file for a subject level GLM by SPM

clc

% subj_to_do = [18 20:22];

if ~exist('machine_id', 'var')
    machine_id = 2;% 0: container ;  1: Remi ;  2: Beast
end

% setting up directories
[data_dir, code_dir, output_dir, fMRIprep_DIR] = set_dir(machine_id);

% get date info
bids =  spm_BIDS(fullfile(data_dir, 'raw'));

%%
subjects = spm_BIDS(bids, 'subjects');

tasks = spm_BIDS(bids, 'tasks');
if numel(tasks)==3
    tasks(3) = [];
end

group(1).name = 'blnd';
group(2).name = 'ctrl';

if ~exist('subj_to_do', 'var')
    subj_to_do = 1:numel(subjects);
end

for iTask = 1:numel(tasks)

    % we take each event file from each subject for that task and we collect
    % onsets and offsets of all stim and responses
    for iSubjects = 1:numel(subjects)

        runs = spm_BIDS(bids, 'runs', ...
            'type', 'events', ...
            'sub', subjects{iSubjects}, ...
            'task', tasks{iTask});

        for iRun = 1:numel(runs)

            event_file = spm_BIDS(bids, 'data', ...
                'type', 'events', ...
                'sub', subjects{iSubjects}, ...
                'task', tasks{iTask}, ...
                'run', runs{iRun});

            if numel(event_file)>1
                error('We should have only one file.')
            end

            % we collect the stim / resp onsets and offsets
            %get events file
            disp(event_file)
            x = spm_load(event_file{1},'',1);

            % Get the unique names of the conditions (removing repetitions)
            names = unique(x.trial_type(:))';
            nb_cdt = length(names);

            if length(names)<6
                warning('We are missing conditions.')
                disp(names)
            end

            % Create empty variables of onsets and durations
            onsets = cell(1,nb_cdt) ;
            durations = cell(1,nb_cdt) ;

            % we collect the stim / resp onsets and offsets
            for iCdt = 1:nb_cdt

                idx = strcmp(x.trial_type, names{iCdt});

                onsets{1,iCdt} = x.onset(idx);

                if isempty(onsets{1,iCdt})
                    warning('One condition has no onset.')
                    dips(names{iCdt})
                end

                durations{1,iCdt} = x.duration(idx);

            end

            opt = get_option;

            % rename conditions to make them easier to ID later
            % variable used to check that we have all 4 stims for that run
            % if not the .mat filename is flagged as MIA
            is_here = zeros(4,1);
            for iCdt = 1:numel(names)
                switch names{iCdt}
                    case 'ch1'
                        target_name = 1;
                    case 'ch3'
                        target_name = 2;
                    case 'ch5'
                        target_name = 3;
                    case 'ch7'
                        target_name = 4;
                    otherwise
                        target_name = 0;
                end
                if target_name
                    names{iCdt} = strrep(opt.stim_legend{target_name}, ' ', '');
                    is_here(target_name) = 1;
                end
                names{iCdt} = strrep(names{iCdt}, '_', '-');
            end

            if all(is_here)
                suffix = '.mat';
            else
                suffix = '_MIA.mat';
            end

            [path, filename] = spm_fileparts(event_file{1});
            % save the onsets as a matfile
            save(fullfile(output_dir, ['sub-' subjects{iSubjects}], ...
                'func', [filename suffix]),...
                'names','onsets','durations');

        end

    end

end
