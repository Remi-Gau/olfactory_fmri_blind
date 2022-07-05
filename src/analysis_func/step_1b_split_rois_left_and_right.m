% (C) Copyright 2021 Remi Gau

clear;
clc;

run ../../initEnv.m;

opt = opt_stats_subject_level();

%% Create right and left for each ROI

opt.roi.space = {'MNI'};
opt.bidsFilterFile.roi.space = {'MNI'};

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
        'Orbitofrontal'
       };

for iRoi = 1:numel(ROIs)

  roi_name =  ['^space.*label-' ROIs{iRoi} '.*'];
  opt.roi.name = {roi_name};
  roiList = getROIs(opt);

  assert(numel(roiList) == 1);

  left = keepHemisphere(roiList{1}, 'L');
  right = keepHemisphere(roiList{1}, 'R');

end

ROIs = {'hand'
        'auditory'
        'olfactory'
       };

for iRoi = 1:numel(ROIs)

  roi_name =  ['^space.*label-' ROIs{iRoi} '.*GM.*'];
  opt.roi.name = {roi_name};
  roiList = getROIs(opt);

  assert(numel(roiList) == 1);

  left = keepHemisphere(roiList{1}, 'L');
  right = keepHemisphere(roiList{1}, 'R');

end
