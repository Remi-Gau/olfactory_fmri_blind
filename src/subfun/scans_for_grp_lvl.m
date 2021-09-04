function [scans, con_names] = scans_for_grp_lvl(contrast_ls, ctrsts, contrasts_file_ls, subj_to_include)
  %
  % (C) Copyright 2021 Remi Gau

  % figure out which are the contrasts we want
  ctrst_to_choose = [];
  for iCtrsts = 1:numel(ctrsts)
    ctrst_to_choose = [ctrst_to_choose ...
                       find(ismember(contrast_ls, ctrsts{iCtrsts}))]; %#ok<*AGROW>
  end

  con_names = {};
  scans = {};

  i_scan = 1;

  for iSubj = 1:numel(subj_to_include)
    tmp = contrasts_file_ls(subj_to_include(iSubj)).con_name{ctrst_to_choose, :};
    if ~strcmp(tmp, 'dummy_contrast')
      con_names{i_scan, 1} = tmp;

      scans{i_scan} = cat(1, ...
                          contrasts_file_ls(subj_to_include(iSubj)).con_file{ctrst_to_choose, :});

      i_scan = i_scan + 1;
    else
      warning('we got a dumy contrast for subject %i. \n File: %s ', ...
              iSubj, contrasts_file_ls(subj_to_include(iSubj)).con_file{ctrst_to_choose, :});
    end

  end

end
