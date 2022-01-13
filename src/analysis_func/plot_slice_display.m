% (C) Copyright 2021 Remi Gau

clear;
clc;

run ../../initEnv.m;

opt = opt_stats_group_level();

use_schema = false;
BIDS_ROI = bids.layout(opt.dir.roi, use_schema);

% we get the con image to extract data
rfxDir = getRFXdir(opt);

contrast = 'all_olf';

output_dir = fullfile(rfxDir, contrast);

conImage = spm_select('FPList', output_dir, '^con_0001.nii$');
spmTImage = spm_select('FPList', output_dir, '^spmT_0001.nii$');

%% Layers to put on the figure
layers = sd_config_layers('init', {'truecolor', 'contour', 'contour', 'contour', 'contour', 'dual'});

% Layer 1: Anatomical map
layers(1).color.file = opt.result.Nodes(1).Output.montage.background;

hdr = spm_vol(layers(1).color.file);
vol = spm_read_vols(hdr);
anat_range = [min(vol(:)) max(vol(:))];

layers(1).color.range = [0 anat_range(2)];
layers(1).color.map = gray(256);

%% Contour of ROI

layers(2).color.file = spm_select('FPList', fullfile(opt.dir.roi, 'group'), ...
                                  'ROI-L-R-Amyg-mOC_space-MNI.nii');
layers(2).color.map = [0 0 0];
layers(2).color.line_width = 2;

layers(3).color.file = spm_select('FPList', fullfile(opt.dir.roi, 'group'), ...
                                  'ROI-L-R-Olfactory-Cortex-mOC_space-MNI.nii');
layers(3).color.map = [1 1 1];
layers(3).color.line_width = 2;

layers(4).color.file = spm_select('FPList', fullfile(opt.dir.roi, 'group'), ...
                                  'space-MNI_label-neurosynthOlfactory_desc-p05pt00_mask.nii');
layers(4).color.map = [0.5 0.5 0.5];
layers(4).color.line_width = 2;

layers(5).color.file = spm_select('FPList', fullfile(opt.dir.roi, 'group'), ...
                                  'hemi-R_space-MNI_label-V1d_desc-wang_mask.nii');
layers(5).color.map = [0 1 0];
layers(5).color.line_width = 2;

%% Layer 2: Dual-coded layer

%   - contrast estimates color-coded;
layers(6).color.file = conImage;

color_map_folder = fullfile(fileparts(which('map_luminance')), '..', 'mat_maps');
load(fullfile(color_map_folder, 'diverging_bwr_iso.mat'));
layers(6).color.map = diverging_bwr;

layers(6).color.range = [-4 4];
layers(6).color.label = '\beta_{allolf} - \beta_{baseline} (a.u.)';

%   - t-statistics opacity-coded
layers(6).opacity.file = spmTImage;
layers(6).opacity.range = [2 3];
layers(6).opacity.label = '| t |';

%% Settings and display
settings = sd_config_settings('init');

% we reuse the details for the SPM montage
settings.slice.orientation = opt.result.Nodes(1).Output.montage.orientation;
settings.slice.disp_slices = -30.5:3:56.5;
settings.fig_specs.title = opt.result.Nodes(1).Contrasts(1).Name;

% Display the layers
[settings, p] = sd_display(layers, settings);
