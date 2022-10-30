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

opt.dir.output = spm_file(fullfile(opt.dir.stats, '..', 'bidspm-modelSelection'), 'cpath');

opt.dir.output = fullfile(opt.dir.output, ...
                          'derivatives', ...
                          'bidspm-modelSelection', ...
                          'group');

%% Get data
for i = 1:numel(models_files)

  model = BidsModel('file', fullfile(pwd, 'models', models_files{i}));

  data{i, 1} = fullfile(opt.dir.output, [model.Name '_model_LFM.nii,1']); %#ok<SAGROW>

end

dataLabel = [repmat('m ', numel(models_files), 1), num2str((1:numel(models_files))')];
dataLabel = cellstr(dataLabel);

%% ROIs
close all;

opt.bidsFilterFile.roi.space = {'MNI'};

rois_to_plot = {{'V1', 'V2', 'V3', 'hMT'}, 'visual'
                {'auditory'}, 'audio'
                {'hand'}, 'S1'
                {'PrimaryOlfCortex', 'olfactory', 'Orbitofrontal'}, 'olfactory'};

for i = 1:size(rois_to_plot, 1)

  opt.roi.name = {['^space-.*(', ...
                   strjoin(rois_to_plot{i, 1}, '|') ')']};

  roiList = getROIs(opt);

  plotDataInRoi(data, roiList, ...
                'scaleFactor', 100, ...
                'roiAs', 'cols', ...
                'dataLabel', dataLabel, ...
                'maxVox', 50, ...
                'nbBins', 100);

  print(gcf, fullfile(pwd, 'images', ['model_distribution_' rois_to_plot{i, 2} '.png']), '-dpng');
end
