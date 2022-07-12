function merge_left_right_rois(roiList, rm_input)
  %
  % merge_left_right_rois(roiList)
  %
  % (C) Copyright 2021 Remi Gau

  if nargin < 2 || isempty(rm_input)
    rm_input = true;
  end

  bf = bids.File(roiList{1});
  bf.entities.hemi = '';
  outputFilename = spm_file(bf.path, 'filename', bf.filename);

  merge_rois(roiList, outputFilename, rm_input);

end
