% scritps to transform Z-score maps from neurosynth into binary mask with
% fewer clusters
% Adapted from: https://en.wikibooks.org/wiki/SPM/How-to#How_to_remove_clusters_under_a_certain_size_in_a_binary_mask?

roi_path = fullfile(pwd, 'inputs');

for iROI = 1:2

  switch iROI
    case 1
      % hand
      z = .1;
      k = 10;
      ROI  = 'hand_association-test_z_FDR_0.01.nii';
      ROIf = 'ROI_hand_Z_.1_k_10.nii';
    case 2
      % hand
      z = .1;
      k = 10;
      ROI  = 'olfactory_association-test_z_FDR_0.01.nii';
      ROIf = 'ROI_olfactory_Z_.1_k_10.nii';
  end

  gunzip(fullfile(roi_path, [ROI '.gz']));

  % -Connected Component labelling
  V = spm_vol(fullfile(roi_path, ROI));
  data = spm_read_vols(V);
  [l2, num] = spm_bwlabel(double(data > z), 26);
  if ~num
    warning('No clusters found.');
  end

  % -Extent threshold, and sort clusters according to their extent
  [n, ni] = sort(histc(l2(:), 0:num), 1, 'descend');
  l  = zeros(size(l2));
  n  = n(2:end);
  ni = ni(2:end) - 1;
  ni = ni(n >= k);
  n  = n(n >= k);
  for i = 1:length(n)
    l(l2 == ni(i)) = i;
  end
  clear l2 ni;
  fprintf('Selected %d clusters (out of %d) in image.\n', length(n), num);

  % -Write new image
  V.fname = fullfile(roi_path, ROIf);
  spm_write_vol(V, l ~= 0); % save as binary image. Remove '~=0' so as to
  % have cluster labels as their size.
  % or use (l~=0).*dat if input image was not binary

end
