% This script displays the ROIs on an anat file
%
% (C) Copyright 2023 Remi Gau

close all;
clear;
clc;

run ../../initEnv.m;

nb_slice_column = 6;

output_dir = '/home/remi/Documents/Christine';

suffix = 'all_slices';

% Main effects related to odors (not present in other contrast): ACC

% Identification task: thalamus, insula, hippocampus, entorhinal cortex
roi_groups(1).name = 'Identification';
roi_groups(1).slices = -20:1:10; % [-20 2]; %-20:3:10;
roi_groups(1).orientation = 'axial';
% roi_groups(1).slices = [-40 -20 -4]; %-40:1:1;
% roi_groups(1).orientation = 'sagittal';
roi_groups(1).roi(1).name = 'ThalamusMD';
roi_groups(1).roi(1).display_name = 'Thalamus';
roi_groups(1).roi(1).color = [228, 26, 28];
roi_groups(1).roi(2).name = 'Insula';
roi_groups(1).roi(2).color = [55, 126, 184];
roi_groups(1).roi(3).name = 'Hippocampus';
roi_groups(1).roi(3).color = [77, 175, 74];
roi_groups(1).roi(4).name = 'Broadmann28Ento';
roi_groups(1).roi(4).display_name = 'Entorhinal cortex';
roi_groups(1).roi(4).color = [152, 78, 163];

% Localization task: V2, V3, hV4, hMT
roi_groups(2).name = 'Localization';
roi_groups(2).slices = -18:1:12; % -18:3:12;
roi_groups(2).orientation = 'axial';
% roi_groups(2).slices = [-45 -25 -14]; %-50:1:1;
% roi_groups(2).orientation = 'sagittal';
roi_groups(2).roi(1).name = 'V2';
roi_groups(2).roi(1).color = [255, 127, 0];
roi_groups(2).roi(2).name = 'V3';
roi_groups(2).roi(2).color = [255, 255, 51];
roi_groups(2).roi(3).name = 'hMT';
roi_groups(2).roi(3).color = [166, 86, 40];
roi_groups(2).roi(4).name = 'hV4';
roi_groups(2).roi(4).color = [247, 129, 191];

for i_roi_group = 1:numel(roi_groups)
  roi_group_ = roi_groups(i_roi_group);
  for i_roi = 1:numel(roi_group_.roi)
    if ~isfield(roi_group_.roi(i_roi), 'display_name') || ...
            isempty(roi_group_.roi(i_roi).display_name)
      roi_group_.roi(i_roi).display_name = roi_group_.roi(i_roi).name;
    end
  end
  roi_groups(i_roi_group) = roi_group_;
end

opt = opt_stats_subject_level();

roi_folder = fullfile(opt.dir.roi, 'group');

hemi = '';

for i_roi_group = 1:numel(roi_groups)

  roi_group = roi_groups(i_roi_group);

  %% Layers to put on the figure
  layers = sd_config_layers('init', {'truecolor', 'cluster', 'cluster', 'cluster', 'cluster'});

  % Layer 1: Anatomical map
  anat_file = fullfile(opt.dir.stats, 'derivatives', 'bidspm-groupStats', 'space-MNI152NLin2009cAsym_desc-mean_T1w.nii');

  hdr = spm_vol(anat_file);
  vol = spm_read_vols(hdr);
  anat_range = [min(vol(:)) max(vol(:))];

  layers(1).color.file = anat_file;
  layers(1).color.range = [0 anat_range(2)];
  layers(1).color.map = gray(256);

  %% Contours of ROI

  for i_roi = 1:numel(roi_group.roi)

    pattern = ['^' hemi 'space-.*_label-' roi_group.roi(i_roi).name '_mask.nii'];
    pattern = regexify(pattern);
    roi_list = spm_select('FPlist', roi_folder, pattern);

    disp(roi_list);

    layers(1 + i_roi).color.file = roi_list;
    layers(1 + i_roi).color.map = roi_group.roi(i_roi).color / 255;
    layers(1 + i_roi).color.line_width = 2;

  end

  %% Settings
  settings = sd_config_settings('init');

  % we reuse the details for the SPM montage
  settings.slice.orientation = roi_group.orientation;
  settings.slice.disp_slices = roi_group.slices;
  settings.fig_specs.n.slice_column = nb_slice_column;
  settings.fig_specs.title = [roi_group.name ' task'];

  %% Display the layers
  [settings, p] = sd_display(layers, settings);

  output_file = fullfile(output_dir, ...
                         [roi_group.name '_' roi_group.orientation '_' suffix '.tif']);
  print(gcf, '-dtiff', output_file);

  %%
  legend_figure = figure();
  hold on;
  for i_roi = 1:numel(roi_group.roi)
    plot([0, 1], [i_roi, i_roi], ...
         'color', roi_group.roi(i_roi).color / 255, ...
         'LineWidth', 2);
  end
  legend({roi_groups(i_roi_group).roi.display_name});
  title(roi_groups(i_roi_group).name);

  output_file = fullfile(output_dir, ...
                         ['legend_' roi_group.name '.tif']);
  print(gcf, '-dtiff', output_file);

end
