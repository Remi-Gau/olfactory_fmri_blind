% attempt at a flexible factorial design
%
% (C) Copyright 2019 Remi Gau

clear;
clc;

run ../../initEnv.m;

% in participants.tsv
group_field = 'Group';

% for folder naming
node_name = 'rm_anova';
contrasts = 'ALL';
groups = 'ALL';

% Some level labels defined here
odor_labels = {'almond', 'eucalyptus'};
side_labels = {'left', 'right'};

opt = opt_stats_group_level();

opt.verbosity = 2;

opt.pipeline.type = 'stats';

[BIDS, opt] = setUpWorkflow(opt, 'anova flexible design');

opt.dir.output = fullfile(opt.dir.stats, 'derivatives', 'cpp_spm-groupStats');
opt.dir.jobs = fullfile(opt.dir.output, 'jobs',  strjoin(opt.taskName, ''));

% Levels names for each factor
group_labels = unique(BIDS.raw.participants.content.(group_field));
task_labels = opt.taskName;

% list of constrasts and the levels they correspond to
% contrasts_list = {'olfid_almond_left'; ...
%                   'olfid_almond_right'; ...
%                   'olfid_eucalyptus_left'; ...
%                   'olfid_eucalyptus_right'; ...
%                   'olfloc_almond_left'; ...
%                   'olfloc_almond_right'; ...
%                   'olfloc_eucalyptus_left'; ...
%                   'olfloc_eucalyptus_right'};
% 
% contrast_levels = cartesian(1:numel(task_labels), ...
%                             1:numel(odor_labels), ...
%                             1:numel(side_labels));
                          
contrasts_list = {'all_olfid'; ...
                  'all_olfloc'};

contrast_levels = cartesian(1:numel(task_labels));                          

%%

% collect con images
for iSub = 1:numel(opt.subjects)
  sub_label = opt.subjects{iSub};
  contrasts_images_filenames{iSub} = findSubjectConImage(opt, sub_label, contrasts_list); %#ok<SAGROW>
end

%% set batch

matlabbatch = {};
clear factorial_design;

printBatchName('flexible factorial design', opt);

factor = @(x, y) struct('name', x, ...
                        'dept', y, ...
                        'variance', 1, ...
                        'gmsca', 0, ...
                        'ancova', 0);

factorial_design.des.fblock.fac(1) = factor('subject', false);
factorial_design.des.fblock.fac(end + 1) = factor('group', false);
factorial_design.des.fblock.fac(end + 1) = factor('task', true);
% factorial_design.des.fblock.fac(end + 1) = factor('odor', true);
% factorial_design.des.fblock.fac(end + 1) = factor('side', true);

rfxDir = getRFXdir(opt, node_name, contrasts, groups);
overwriteDir(rfxDir, opt);

factorial_design.dir = {rfxDir};

for iSub = 1:numel(opt.subjects)

  sub_label = opt.subjects{iSub};

  sub_idx = strcmp(BIDS.raw.participants.content.participant_id, ['sub-' sub_label]);
  participant_group = BIDS.raw.participants.content.(group_field){sub_idx};

  group_index = find(ismember(group_labels, participant_group));

  for iCon = 1:numel(contrasts_list)
    des_mat = [repmat(group_index, size(contrast_levels, 1), 1), ...
               contrast_levels];
    this_sub = struct('conds', des_mat, ...
                      'scans', {contrasts_images_filenames{iSub}(:)});
    factorial_design.des.fblock.fsuball.fsubject(iSub) = this_sub;
  end

end

factorial_design.des.fblock.maininters{1}.fmain.fnum = 2;
factorial_design.des.fblock.maininters{2}.fmain.fnum = 3;
% factorial_design.des.fblock.maininters{3}.fmain.fnum = 4;
% factorial_design.des.fblock.maininters{4}.fmain.fnum = 5;
factorial_design.des.fblock.maininters{3}.fmain.fnum = 1;

factorial_design.cov = struct('c', {}, ...
                              'cname', {}, ...
                              'iCFI', {}, ...
                              'iCC', {});
factorial_design.multi_cov = struct('files', {}, ...
                                    'iCFI', {}, ...
                                    'iCC', {});

factorial_design.masking.tm.tm_none = 1;
factorial_design.masking.im = 1;
factorial_design.masking.em = {''};

factorial_design.globalc.g_omit = 1;

factorial_design.globalm.gmsca.gmsca_no = 1;
factorial_design.globalm.glonorm = 1;

matlabbatch{1}.spm.stats.factorial_design = factorial_design;

matlabbatch = setBatchPrintFigure(matlabbatch, opt, ...
                                  fullfile(rfxDir, ...
                                           designMatrixFigureName(opt, ...
                                                                  'before estimation')));

matlabbatch = setBatchEstimateModel(matlabbatch, ...
                                    opt, ...
                                    node_name, ...
                                    contrasts, ...
                                    groups);

%% run

saveAndRunWorkflow(matlabbatch, 'RM ANOVA flexible', opt);
