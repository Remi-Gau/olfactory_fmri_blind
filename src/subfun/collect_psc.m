function collect_psc(opt, contrasts, roi_list, output_file)
  %
  % (C) Copyright 2022 Remi Gau

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
          group_tsv.hemi{end + 1} = 'NaN';
        end

        if isfield(bf.entities, 'desc')
          desc_filter = strcmp(tsv.desc, bf.entities.desc);
          group_tsv.desc{end + 1} = bf.entities.desc;
        else
          desc_filter = true(size(tsv.label));
          group_tsv.desc{end + 1} = nan;
        end

        idx = all([strcmp(tsv.hemi, group_tsv.hemi{end}), ...
                   strcmp(tsv.label, bf.entities.label), ...
                   strcmp(tsv.contrast_name, contrasts(i_con).name), ...
                   desc_filter], ...
                  2);

        if sum(idx) == 0
          warning('No data for sub-%s / roi %s / contrast %s\n', ...
                  sub_label, ...
                  bf.entities.label, ...
                  contrasts(i_con).name);
          group_tsv.psc_abs_max(end + 1) = nan;

        elseif sum(idx) == 1
          group_tsv.psc_abs_max(end + 1) = tsv.percent_signal_change_absMax(idx);

        elseif sum(idx) > 1
          error('Too many data for sub-%s / roi %s / contrast %s\n', ...
                sub_label, ...
                bf.entities.label, ...
                contrasts(i_con).name);

        end

      end

    end

  end

  bids.util.tsvwrite(output_file, group_tsv);

end
