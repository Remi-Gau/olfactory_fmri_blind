function merge_left_right_rois(roiList)
  %
  % merge_left_right_rois(roiList)
  %
  % (C) Copyright 2021 Remi Gau

  bf = bids.File(roiList{1});
  bf.entities.hemi = '';
  bf = bf.create_filename();
  outputFilename = fullfile(bf.pth, bf.filename);

  merge_rois(roiList, outputFilename);

end
