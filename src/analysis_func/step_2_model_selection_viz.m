% use interactive plotting functions of the MACS toolbox to vizualize winning
% models in each voxel
%
% (C) Copyright 2019 Remi Gau

clear;
clc;

run ../../initEnv.m;

models_files = list_models_files();

opt = opt_stats_subject_level();
opt.verbosity = 2;

opt.dir.output = spm_file(fullfile(opt.dir.stats, '..', 'bidspm-modelSelection'), 'cpath');

opt.dir.output = fullfile(opt.dir.output, ...
                          'derivatives', ...
                          'bidspm-modelSelection', ...
                          'group');

for i = 1:numel(models_files)

  model = BidsModel('file', fullfile(pwd, 'models', models_files{i}));

  MF_visualize.data{i, 1} = fullfile(opt.dir.output, [model.Name '_model_LFM.nii,1']);

end

% change here to change the model to view as overlay
% - MS_SMM_map_pos_01* will show the 1 model
% - MS_SMM_map_pos_01* will show the 1 model
overlay = spm_select('FPList', fullfile(opt.dir.output, 'MS_SMM_BMS_10'), 'MS_SMM_map_pos_02.*');
disp(spm_file(overlay, 'basename'));

MF_visualize.overlay = {overlay};
MF_visualize.thresh = '>0';
MF_visualize.PlotType = 'bar';
MF_visualize.LineSpec = 'b';
MF_visualize.XTicks = ['cellstr(num2str([1:' num2str(numel(models_files)) ']''))'''];
MF_visualize.YLimits = '[0, 1]';
MF_visualize.Title = 'Title';

matlabbatch{1}.spm.tools.MACS.MF_visualize = MF_visualize;

spm_jobman('run', matlabbatch);
