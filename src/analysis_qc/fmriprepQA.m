% frmiprepQA
% (C) Copyright 2021 Remi Gau

clear;
clc;
close all;

% stores only the FD values

opt = options();

opt.dir.fmriprep = '/home/remi/gin/olfaction_blind/derivatives/fmriprep';

metrics = {'framewise_displacement', 'std_dvars'};

use_schema = false;
fprintf(1, '\nIndexing fmriprep dataset: %s', opt.dir.fmriprep);
BIDS = bids.layout(opt.dir.fmriprep, use_schema);

%%

tasks = bids.query(BIDS, 'tasks');
subjects = bids.query(BIDS, 'subjects');

fprintf(1, '\n');

for iTasks = 1:numel(tasks)

  maximums = [];
  fileLists = {};
  counter = 1;

  clear filter;
  filter.suffix = 'regressors';
  filter.extension = '.tsv';
  filter.task = tasks{iTasks};

  for iSubj = 1:numel(subjects)

    filter.sub = subjects{iSubj};

    if isfield(filter, 'run')
      filter = rmfield(filter, 'run');
    end

    runs = bids.query(BIDS, 'runs', filter);

    if isempty(runs)
      runs = {''};
    end

    for iRun = 1:numel(runs)

      filter.run = runs{iRun};

      % get data for each subject
      confoundFile = bids.query(BIDS, 'data', filter);

      for iFile = 1:size(confoundFile, 1)

        fileLists{counter, 1} = ['sub-' subjects{iSubj}, ...
                                 ' task-' tasks{iTasks}, ...
                                 ' run-' runs{iRun}];

        % load each event file
        fprintf(1, '\n %s', fileLists{counter, 1});
        data = bids.util.tsvread(confoundFile{iFile});

        % for iMetric = 1:numel(metrics)

        maximums.framewise_displacement(counter, 1) =  ...
            nanmax(data.framewise_displacement); %#ok<*SAGROW>
        maximums.std_dvars(counter, 1) =  nanmax(abs(1 - data.std_dvars));

        % end

        counter = counter + 1;

      end

    end

  end

  metrics = fieldnames(maximums);

  all_outliers = [];

  for metric = 1:numel(metrics)

    valuesToPlot = maximums.(metrics{metric});

    outliers = iqr_method(valuesToPlot, 0);

    plotMetric(valuesToPlot, outliers, metrics{metric}, fileLists);

  end

end
