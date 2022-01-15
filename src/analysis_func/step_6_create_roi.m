% (C) Copyright 2021 Remi Gau

clear;
clc;

run ../../initEnv.m;

opt = opt_stats_subject_level();

%% take care of neurosynth maps

gunzip(fullfile(opt.dir.roi, 'group', '*.gz'));

cluster_threshold = 50;

z_threshold = 5;

zMaps = spm_select('FPlist', ...
                   fullfile(opt.dir.roi, 'group'), ...
                   'olfactory.*association-test.*.nii$');
thresholdAndSplitHemisphere(zMaps, z_threshold, cluster_threshold);

cluster_threshold = 50;

z_threshold = 8;

zMaps = spm_select('FPlist', ...
                   fullfile(opt.dir.roi, 'group'), ...
                   'hand.*association-test.*.nii$');
thresholdAndSplitHemisphere(zMaps, z_threshold, cluster_threshold);

zMaps = spm_select('FPlist', ...
                   fullfile(opt.dir.roi, 'group'), ...
                   'auditory.*association-test.*.nii$');
thresholdAndSplitHemisphere(zMaps, z_threshold, cluster_threshold);

disp('Done');

%% Create visual ROIs from the wang atlas

opt.roi.atlas = 'wang';
opt.roi.name = {'V1v'
                'V1d'
                'V2v'
                'V2d'
                'V3v'
                'V3d'
                'hV4'
                'VO1'
                'VO2'
                'MST'
                'hMT'
                'LO2'
                'LO1'};
opt.roi.space = {'MNI'};

bidsCreateROI(opt);

%% merge ventral / dorsal ROIs
opt.dir.roi = spm_file(fullfile(opt.dir.derivatives, 'cpp_spm-roi'), 'cpath');

hemi = {'L', 'R'};

for iHemi = 1:numel(hemi)

  for iROI = 1:numel(opt.roi.name)

    extractRoiFromAtlas(fullfile(opt.dir.roi, 'group'), ...
                        opt.roi.atlas, ...
                        opt.roi.name{iROI}, ...
                        hemi{iHemi});

  end

end

%% merge left and right
