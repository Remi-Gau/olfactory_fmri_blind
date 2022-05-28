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
threshold_and_split_hemisphere(zMaps, z_threshold, cluster_threshold);

cluster_threshold = 50;

z_threshold = 8;

zMaps = spm_select('FPlist', ...
                   fullfile(opt.dir.roi, 'group'), ...
                   'hand.*association-test.*.nii$');
threshold_and_split_hemisphere(zMaps, z_threshold, cluster_threshold);

zMaps = spm_select('FPlist', ...
                   fullfile(opt.dir.roi, 'group'), ...
                   'auditory.*association-test.*.nii$');
threshold_and_split_hemisphere(zMaps, z_threshold, cluster_threshold);

disp('Done');

%% Create visual ROIs from the wang atlas

opt.dir.roi = spm_file(fullfile(opt.dir.derivatives, 'cpp_spm-roi'), 'cpath');

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

delete(fullfile(opt.dir.roi, 'group', 'hemi*atlas-wang*.json'));

disp('Done');

%% merge ventral / dorsal ROIs

opt.bidsFilterFile.roi.space =  'MNI';

hemi = {'L', 'R'};

for iRoi = 1:3

  for iHemi = 1:2

    roi_name = sprintf('V%i', iRoi);

    opt.roi.name = {['hemi-' hemi{iHemi} '.*' roi_name '.*']};
    roiList = getROIs(opt);
    merge_dorsal_ventral_rois(roiList, roi_name);

  end

end

disp('Done');

%% merge left and right

ROIs = {'V1'
        'V2'
        'V3'
        'MST'
        'hMT'
        'hV4'
        'VO1'
        'VO2'
        'LO2'
        'LO1'};

for iRoi = 1:numel(ROIs)

  roi_name =  ['label-' ROIs{iRoi}];
  opt.roi.name = {['.*hemi-L.*' roi_name '.*'], ['.*hemi-R.*' roi_name '.*']};
  roiList = getROIs(opt);
  merge_left_right_rois(roiList);

end

disp('Done');
