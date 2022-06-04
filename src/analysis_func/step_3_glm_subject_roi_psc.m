% Collects percent signal change for each:
%
% - ROI
% - subject
% - contrast
%
% and save the collected data in a TSV
%
% (C) Copyright 2021 Remi Gau

% Warning: No data for sub-blnd02 / roi V1 / contrast Responses
% Warning: No data for sub-ctrl11 / roi V1 / contrast Responses

clc;
clear;

run ../../initEnv.m;

roi_list = {'V1'};

opt.pipeline.type = 'stats';

opt = opt_stats_subject_level(opt);

opt.verbosity = 2;

opt.model.bm = BidsModel('file', opt.model.file);

opt.glm.roibased.do = true;
opt.fwhm.func =  0;

contrasts = opt.results.name;

participants_tsv = bids.util.tsvread(fullfile(opt.dir.raw, 'participants.tsv'));

%% collect PSC data from each subject

output_file = fullfile(opt.dir.stats, 'derivatives', 'cpp_spm-groupStats', 'group_psc.tsv');

group_tsv = struct('subject', {{}}, ...
                   'roi', {{}}, ...
                   'contrast', {{}}, ...
                   'psc_max', [], ...
                   'group', {{}});

for i_sub = 1:numel(opt.subjects)

  sub_label = opt.subjects{i_sub};

  printProcessingSubject(i_sub, sub_label, opt);

  group = participants_tsv.Group{strcmp(participants_tsv.participant_id, ...
                                        ['sub-' sub_label])};

  ffx_dir = getFFXdir(sub_label, opt);

  % load subject data
  bf = bids.File(ffx_dir);
  bf.suffix = 'summary';
  bf.extension = '.tsv';
  bf = bf.update();
  summary_tsv = fullfile(ffx_dir, bf.filename);
  tsv = bids.util.tsvread(summary_tsv);

  for i_con = 1:numel(contrasts)
    for i_roi = 1:size(roi_list, 1)

      group_tsv.subject{end + 1} = sub_label;
      group_tsv.roi{end + 1} = roi_list{i_roi};
      group_tsv.contrast{end + 1} = contrasts{i_con};
      group_tsv.group{end + 1} = group;

      idx = all([strcmp(tsv.label, roi_list{i_roi}), ...
                 strcmp(tsv.contrast_name, contrasts{i_con})], ...
                2);

      % if GLM could not be estimated we nan pad
      assert(sum(idx) <= 1);
      if sum(idx) == 0
        warning('No data for sub-%s / roi %s / contrast %s\n', ...
                sub_label, ...
                roi_list{i_roi}, ...
                contrasts{i_con});
        group_tsv.psc_max(end + 1) = nan;
      elseif sum(idx) == 1
        group_tsv.psc_max(end + 1) = tsv.percent_signal_change_max(idx);
      end

    end
  end

end

bids.util.tsvwrite(output_file, group_tsv);
