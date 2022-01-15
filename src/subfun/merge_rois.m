function merge_rois(roiList, outputFilename)
      %
  % merge_rois(roiList, outputFilename)
  %
  % (C) Copyright 2021 Remi Gau
  
    hdrs = spm_vol(char(roiList));
  vols = spm_read_vols(hdrs);
  
  vol = any(vols, 4);
  hdr = hdrs(1);
  
  hdr.fname = outputFilename;
  spm_write_vol(hdr, vol);
  
end