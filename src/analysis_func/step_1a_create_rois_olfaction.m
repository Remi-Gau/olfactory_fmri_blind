% (C) Copyright 2022 Remi Gau

clear;
clc;

run ../../initEnv.m;

opt = opt_stats_subject_level();

%%
% gunzip(fullfile(opt.dir.roi, 'sourcedata', 'ROIs', '*.nii.gz'));
% movefile(fullfile(opt.dir.roi, 'sourcedata', 'ROIs', '*.nii'), fullfile(opt.dir.roi, 'group'));

%% merge left and right

opt.bidsFilterFile.roi.space =  'MNI';

% ROIs = {'Broadmann28Ento'
%         'Broadmann34Piriform'
%         'Hippocampus'
%         'Insula'
%         'OFCant'
%         'OFClat'
%         'OFCmed'
%         'OFCpost'};
     
ROIs = {'ACC_'
        'ThalamusMD_'}; 

% ROIs = {'ThalamusMDl'
%         'ThalamusMDm'
%         'Amygdala'
%         'ACCsub'
%         'ACCsup'
%         'ACCpre'};      

rm_input = false;

for iRoi = 1:numel(ROIs)

  fprintf(1, '\n');
  roi_name =  ['label-' ROIs{iRoi}];
  opt.roi.name = {['hemi-L.*' roi_name ], ['hemi-R.*' roi_name ]};
  roiList = getROIs(opt);
  assert(numel(roiList)==2);
  fprintf(1, '%s', strjoin(roiList, '\n '));
  merge_left_right_rois(roiList, rm_input);

end

disp('Done');
