% Collects time course for each:
%
% - ROI
% - subject
% - contrast
%
% and save the collected data in a TSV
%
% (C) Copyright 2021 Remi Gau

% No file for sub-ctrl11 and roi V1 ??

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

output_file = fullfile(opt.dir.stats, 'derivatives', 'cpp_spm-groupStats', 'group_timecourse.tsv');

opt.roi.name = {['^space-.*(', ...
                 strjoin(roi_list, '|') ')']};

opt.bidsFilterFile.roi.space = {'MNI'};

roi_files = getROIs(opt);

nb_time_points = 4500;

header = {'subject', 'roi', 'contrast', 'group', 'sampling_frequency'};
group_tsv = cell(numel(opt.subjects) * numel(roi_list) * numel(contrasts), 5);
group_tsv = cat(1, header, group_tsv);

group_data = nan(numel(opt.subjects) * numel(roi_list) * numel(contrasts), nb_time_points);

row = 2;

for i_sub = 1:numel(opt.subjects)

  sub_label = opt.subjects{i_sub};

  printProcessingSubject(i_sub, sub_label, opt);

  group = participants_tsv.Group{strcmp(participants_tsv.participant_id, ...
                                        ['sub-' sub_label])};

  ffx_dir = getFFXdir(sub_label, opt);

  for i_roi = 1:numel(roi_list)

    nameStructure = roiGlmOutputName(opt, sub_label, roi_files{i_roi});
    nameStructure.suffix = 'timecourse';
    nameStructure.ext = '.tsv';

    bf = bids.File(nameStructure);

    time_course_tsv = fullfile(ffx_dir, bf.filename);

    if exist(time_course_tsv, 'file') ~= 2
      warning('No file for sub-%s and roi %s\n', sub_label, roi_list{i_roi});
      continue
    end
    tsv = bids.util.tsvread(time_course_tsv);

    metadata = bids.util.jsondecode(fullfile(ffx_dir, bf.json_filename));

    for i_con = 1:numel(contrasts)

      if isfield(tsv, contrasts{i_con})

        group_tsv{row, 1} = sub_label; %#ok<*NASGU,*REDEF,*SAGROW>
        group_tsv{row, 2} = roi_list{i_roi};
        group_tsv{row, 3} = contrasts{i_con};
        group_tsv{row, 4} = group;
        group_tsv{row, 5} = metadata.SamplingFrequency;

        group_data(row, 1:numel(tsv.(contrasts{i_con}))) = tsv.(contrasts{i_con})';
      end

      row = row + 1;

    end

  end

end

group_data = num2cell(group_data);

header = num2cell(1:size(group_data, 2));
header = cellfun(@(x) sprintf('timepoint_%i', x), header, 'UniformOutput', false);

tmp = cat(1, header, group_data);

bids.util.tsvwrite(output_file, tmp);
