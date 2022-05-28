function merge_dorsal_ventral_rois(roiList, label)
  %
  %  merge_dorsal_ventral_rois(roiList, label)
  %
  % (C) Copyright 2021 Remi Gau

  if strcmp(roiList{1}, '')
    return
  end

  bf = bids.File(roiList{1});
  bf.entities.label = label;
  outputFilename = spm_file(bf.path, 'filename', bf.filename);

  merge_rois(roiList, outputFilename);

end
