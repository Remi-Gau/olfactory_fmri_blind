% Collects percent signal change for each:
%
% - ROI
% - subject
% - contrast
%
% and save the collected data in a TSV
%
% (C) Copyright 2021 Remi Gau

% Warning: No data for sub-ctrl11 / roi V1

clc;
clear;

run ../../initEnv.m;

opt = opt_stats_subject_level();

opt.fwhm.func =  0;

opt.glm.roibased.do = true;

opt.verbosity = 2;

opt.pipeline.type = 'stats';

opt.bidsFilterFile.roi.space = 'MNI';

for i = 1:numel(opt.results.name)
  contrasts(i).name = opt.results.name{i}; %#ok<*SAGROW>
end

%% Model 3 : visual, auditory, hand regions

opt.model.bm = BidsModel('file', opt.model.file);

opt.space = opt.model.bm.Input.space;
opt.taskName = opt.model.bm.Input.task;

roi_names = {'V1', ...
             'V2', ...
             'V3', ...
             'hV4', ...
             'VO1', ...
             'VO2', ...
             'auditory', ...
             'hand'};

opt.roi.name = {['^space-.*(', strjoin(roi_names, '|') ')']};
roi_list = getROIs(opt);

output_file = fullfile(opt.dir.stats, 'derivatives', 'cpp_spm-groupStats', 'group_model-3_psc.tsv');

collect_psc(opt, contrasts, roi_list, output_file);

%% Model 1 : olfactory regions

opt.model.file = fullfile(fileparts(mfilename('fullpath')), ...
                          'models', ...
                          'model-default_smdl.json');

opt.model.bm = BidsModel('file', opt.model.file);

roi_names = {'olfactory.*GM', ...
             'Orbitofrontal'};

opt.roi.name = {['^space-.*(', strjoin(roi_names, '|') ')']};
roi_list = getROIs(opt);

output_file = fullfile(opt.dir.stats, 'derivatives', 'cpp_spm-groupStats', 'group_model-1_psc.tsv');

collect_psc(opt, contrasts, roi_list, output_file);

%% Helper function

function collect_psc(opt, contrasts, roi_list, output_file)

  % collect PSC data from each subject
  group_tsv = struct('subject', {{}}, ...
                     'roi', {{}}, ...
                     'hemi', {{}}, ...
                     'desc', {{}}, ...
                     'contrast', {{}}, ...
                     'psc_abs_max', [], ...
                     'group', {{}});

  participants_tsv = bids.util.tsvread(fullfile(opt.dir.raw, 'participants.tsv'));

  for i_sub = 1:numel(opt.subjects)

    sub_label = opt.subjects{i_sub};

    printProcessingSubject(i_sub, sub_label, opt);

    group = participants_tsv.Group{strcmp(participants_tsv.participant_id, ...
                                          ['sub-' sub_label])};

    % load subject data
    summary_tsv = saveRoiGlmSummaryTable(opt, sub_label, roi_list, contrasts);
    tsv = bids.util.tsvread(summary_tsv);

    for i_con = 1:numel(contrasts)

      for i_roi = 1:numel(roi_list)

        group_tsv.subject{end + 1} = sub_label;
        group_tsv.group{end + 1} = group;

        group_tsv.contrast{end + 1} = contrasts(i_con).name;

        bf = bids.File(roi_list{i_roi});

        group_tsv.roi{end + 1} = bf.entities.label;

        if isfield(bf.entities, 'hemi')
          group_tsv.hemi{end + 1} = bf.entities.hemi;
        else
          group_tsv.hemi{end + 1} = nan;
        end

        if isfield(bf.entities, 'desc')
          desc_filter = strcmp(tsv.desc, bf.entities.desc);
          group_tsv.desc{end + 1} = bf.entities.desc;
        else
          desc_filter = true(size(tsv.label));
          group_tsv.desc{end + 1} = nan;
        end

        idx = all([strcmp(tsv.label, bf.entities.label), ...
                   strcmp(tsv.contrast_name, contrasts(i_con).name), ...
                   desc_filter], ...
                  2);

        % if GLM could not be estimated we nan pad
        assert(sum(idx) <= 1);

        if sum(idx) == 0
          warning('No data for sub-%s / roi %s / contrast %s\n', ...
                  sub_label, ...
                  bf.entities.label, ...
                  contrasts(i_con).name);
          group_tsv.psc_abs_max(end + 1) = nan;

        elseif sum(idx) == 1
          group_tsv.psc_abs_max(end + 1) = tsv.percent_signal_change_absMax(idx);

        end

      end

    end

  end

  bids.util.tsvwrite(output_file, group_tsv);

end
