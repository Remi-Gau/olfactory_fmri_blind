clear;
clc;

run ../../initEnv.m;

opt = opt_stats();

gunzip(fullfile(opt.dir.roi, 'group', '*.gz'));

zMaps = spm_select('FPlist', ...
                   fullfile(opt.dir.roi, 'group'), ...
                   '.*association-test.*.nii$');

for iROI = 1:size(zMaps, 1)

  zMap = renameNeuroSynth(deblank(zMaps(iROI, :)));
  roiImage = thresholdToMask(zMap, 5);

  %%
  leftRoiImage = keepHemisphere(roiImage, 'L');

  bf = bids.File(leftRoiImage, false);
  bf.entity_order = {'hemi'
                     'space'
                     'label'
                     'desc'
                    };
  bf.entities.label = strrep(bf.entities.label, 'neurosynth', 'ns');
  bf = bf.reorder_entities();
  bf = bf.create_filename();

  movefile(leftRoiImage, fullfile(bf.pth, bf.filename));

  %%
  rightRoiImage = keepHemisphere(roiImage, 'R');

  bf = bids.File(rightRoiImage, false);
  bf.entity_order = {'hemi'
                     'space'
                     'label'
                     'desc'
                    };
  bf.entities.label = strrep(bf.entities.label, 'neurosynth', 'ns');
  bf = bf.reorder_entities();
  bf = bf.create_filename();

  movefile(rightRoiImage, fullfile(bf.pth, bf.filename));

end

opt.roi.atlas = 'wang';
opt.roi.name = { ...
                'V1v'
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
