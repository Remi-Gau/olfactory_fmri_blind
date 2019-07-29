function [all_resp, all_stim, run_length, task] = average_beh(bids, task, subjects)

% create template matrix to collect responses, stim, ...
template = zeros(numel(subjects),7000);

all_stim = {template, template};
all_resp = {...
    template, template;...
    template, template};

run_length = [];

for iSubjects = 1:numel(subjects)
    
    runs = spm_BIDS(bids, 'runs', ...
        'type', 'stim', ...
        'sub', subjects{iSubjects}, ...
        'task', task);
    
    for iRun = 1:numel(runs)
        
        stim_file = spm_BIDS(bids, 'data', ...
            'type', 'stim', ...
            'sub', subjects{iSubjects}, ...
            'task', task, ...
            'run', runs{iRun});
        
        if numel(stim_file)>1
            error('We should have only one file.')
        end
        
        %get stimulus file
        if ~exist(stim_file{1}(1:end-3), 'file')
            gunzip(stim_file{1})
        end
        disp(stim_file)
        x = spm_load(stim_file{1}(1:end-3),'',false(1));
        
        run_length = [run_length size(x, 1)];
        
        % we collect the stim onsets and offsets
        stim = x(:,2);
        stim = diff(stim);
        stim_onsets = find(stim>0);
        stim_offsets = find(stim<0);
        all_stim{1,iRun}(iSubjects,stim_onsets) = 1;
        all_stim{1,iRun}(iSubjects,stim_offsets) = -1;
        
        % collect responses
        resp = x(:,5);
        if numel(unique(resp))>3
            error('We have more than 3 value types in response vector.')
        end
        
        resp = diff(resp);
        
        % We collect the onsets of each type of response
        resp_values = unique(resp);
        resp_values(resp_values<=0) = [];
        if ~isempty(resp_values)
            if ~all(resp_values==[8; 17])
                warning('some unusual responses')
                disp(resp_values)
            end
            resp_onset = find(all([resp<10 resp>0],2));
            all_resp{1,iRun}(iSubjects,resp_onset) = 1;
            resp_onset = find(resp>10);
            all_resp{2,iRun}(iSubjects,resp_onset) = 1;
        end
        
    end
end


end