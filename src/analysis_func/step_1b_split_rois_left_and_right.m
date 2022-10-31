% (C) Copyright 2021 Remi Gau

clear;
clc;

run ../../initEnv.m;

opt = opt_stats_subject_level();

opt.roi.space = {'MNI'};
opt.bidsFilterFile.roi.space = {'MNI'};

%% Create right and left for each ROI

ROIs = {'V1'
        'V2'
        'V3'
        'MST'
        'hMT'
        'hV4'
        'VO1'
        'VO2'
        'LO2'
        'LO1'
       };

for iRoi = 1:numel(ROIs)

  roi_name =  ['^space.*label-' ROIs{iRoi} '.*'];
  opt.roi.name = {roi_name};
  roi_list = getROIs(opt);

  assert(numel(roi_list) == 1);

  left = keepHemisphere(roi_list{1}, 'L');
  right = keepHemisphere(roi_list{1}, 'R');

end

%% Same but for ROIs restricted to grey matter

ROIs = {'hand'
        'auditory'
       };

for iRoi = 1:numel(ROIs)

  roi_name =  ['^space.*label-' ROIs{iRoi} '.*GM.*'];
  opt.roi.name = {roi_name};
  roi_list = getROIs(opt);

  assert(numel(roi_list) == 1);

  left = keepHemisphere(roi_list{1}, 'L');
  right = keepHemisphere(roi_list{1}, 'R');

end
