function merge_rois(roiList, outputFilename, rm_input)
  %
  % merge_rois(roiList, outputFilename, delete)
  %
  % (C) Copyright 2021 Remi Gau

  if nargin < 3 || isempty(rm_input)
    rm_input = true;
  end

  hdrs = spm_vol(char(roiList));
  vols = spm_read_vols(hdrs);

  vol = any(vols, 4);
  hdr = hdrs(1);

  hdr.fname = outputFilename;
  spm_write_vol(hdr, vol);

  if rm_input
    for i = 1:numel(roiList)
      delete(roiList{i});
    end
  end

end
