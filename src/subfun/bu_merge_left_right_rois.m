function merge_left_right_rois(roiList)
  %
  % merge_left_right_rois(roiList)
  %
  % (C) Copyright 2021 Remi Gau

  bf = bids.File(roiList{1});
  bf.entities.hemi = '';
  outputFilename = spm_file(bf.path, 'filename', bf.filename);

  merge_rois(roiList, outputFilename);

end
