% use interactive plotting functions of the MACS toolbox to vizualize winning
% models in each voxel

% (C) Copyright 2019 Remi Gau

clear;
clc;

run ../../initEnv.m;

models_files = list_models_files();

opt = opt_stats_subject_level();
opt.verbosity = 2;

opt.dir.output = spm_file(fullfile(opt.dir.stats, '..', 'cpp_spm-modelSelection'), 'cpath');

opt.dir.output = fullfile(opt.dir.output, ...
                          'derivatives', ...
                          'cpp_spm-modelSelection', ...
                          'group');

for i = 1:numel(models_files)

  model = BidsModel('file', fullfile(pwd, 'models', models_files{i}));

  MF_visualize.data{i, 1} = fullfile(opt.dir.output, [model.Name '_model_LFM.nii,1']);

end

MF_visualize.overlay = {fullfile(opt.dir.output, ...
                                 'MS_SMM_BMS_5', ...
                                 'MS_SMM_map_pos_02_mod_01_No Derivative No Tissue Confounds No Scrubbing.nii,1')};
MF_visualize.thresh = '>0';
MF_visualize.PlotType = 'bar';
MF_visualize.LineSpec = 'b';
MF_visualize.XTicks = ['cellstr(num2str([1:' num2str(numel(models_files)) ']''))'''];
MF_visualize.YLimits = '[0, 1]';
MF_visualize.Title = 'Title';

matlabbatch{1}.spm.tools.MACS.MF_visualize = MF_visualize;

spm_jobman('run', matlabbatch);
