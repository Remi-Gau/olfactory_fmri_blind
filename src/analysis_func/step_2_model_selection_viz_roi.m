% For each ROI and each model:
%
% plots the distribution across voxels of the probabilities (between 0 and 100%)
%
% Main results:
%
% - Model 1 (HRF, no denoising at all) seems better for olfactory regions
% - Model 3 (HRF with tissue confounds) seems better for visual / auditory regions
%
% (C) Copyright 2019 Remi Gau

close all;
clear;
clc;

run ../../initEnv.m;

models_files = list_models_files();

opt = opt_stats_subject_level();

opt.dir.output = spm_file(fullfile(opt.dir.stats, '..', 'cpp_spm-modelSelection'), 'cpath');

opt.dir.output = fullfile(opt.dir.output, ...
                          'derivatives', ...
                          'cpp_spm-modelSelection', ...
                          'group');

opt.bidsFilterFile.roi.space = {'MNI'};

opt.roi.name = {['^space-.*(', ...
                 strjoin({'V1', ...
                          'V2', ...
                          'V3', ...
                          'hV4', ...
                          'hMT', ...
                          'MST', ...
                          'VO1', ...
                          'VO2', ...
                          'LO2', ...
                          'LO1', ...
                          'PrimaryOlfCortex', ...
                          'Orbitofrontal', ...
                          'neurosynthOlfactory', ...
                          'neurosynthAuditory', ...
                          'neurosynthHand'}, '|') ')']};

roiList = getROIs(opt);

for i = 1:numel(models_files)

  model = BidsModel('file', fullfile(pwd, 'models', models_files{i}));

  data{i, 1} = fullfile(opt.dir.output, [model.Name '_model_LFM.nii,1']); %#ok<SAGROW>

end

%%
close all;

dataLabel = [repmat('m ', numel(models_files), 1), num2str((1:numel(models_files))')];
dataLabel = cellstr(dataLabel);

rois_to_plot = {4:7, 8, 9, [10 2:3]};

for i = 1:numel(rois_to_plot)
  plotDataInRoi(data, roiList(rois_to_plot{i}), ...
                'scaleFactor', 100, ...
                'roiAs', 'cols', ...
                'dataLabel', dataLabel, ...
                'maxVox', 50, ...
                'nbBins', 100);
end
