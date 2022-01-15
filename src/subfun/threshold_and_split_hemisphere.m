function threshold_and_split_hemisphere(zMaps, z_threshold, cluster_threshold)
  %
  % thresholdAndSplitHemisphere(zMaps, z_threshold)
  %
  % (C) Copyright 2022 Remi Gau
  
  for iROI = 1:size(zMaps, 1)
    
    zMap = renameNeuroSynth(deblank(zMaps(iROI, :)));
    roiImage = thresholdToMask(zMap, z_threshold, cluster_threshold);
    
    %%
    leftRoiImage = keepHemisphere(roiImage, 'L');
    
    bf = bids.File(leftRoiImage);
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
    
    bf = bids.File(rightRoiImage);
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
  
end