function threshold_and_split_hemisphere(zMaps, z_threshold, cluster_threshold)
  %
  % thresholdAndSplitHemisphere(zMaps, z_threshold)
  %
  % (C) Copyright 2022 Remi Gau
  
  for iROI = 1:size(zMaps, 1)
    
    zMap = renameNeuroSynth(deblank(zMaps(iROI, :)));
    roiImage = thresholdToMask(zMap, z_threshold, cluster_threshold);
    
    %%
    keepHemisphere(roiImage, 'L');
    
    %%
    keepHemisphere(roiImage, 'R');
   
    
  end
  
end