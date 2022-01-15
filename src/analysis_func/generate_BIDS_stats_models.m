% (C) Copyright 2022 Remi Gau

clear;
clc;

%%
run ../../initEnv.m;

%% Generate BIDS stats models

template = bids.util.jsondecode(fullfile(pwd, 'models', 'model-defaultOlfidOlfloc_smdl.json'));

list_models_files = {};

for hrf_derivatives = 1:3

  switch hrf_derivatives
    case 1
      hrf_derivatives_type = 'none';
      hrf_derivatives_suffix = 'No Derivative';
      hrf_derivatives_description = 'HRF: no derivatives';
    case 2
      hrf_derivatives_type = 'temporal';
      hrf_derivatives_suffix = 'Temporal Derivatives';
      hrf_derivatives_description = 'HRF: temporal derivative';
    case 3
      hrf_derivatives_type = 'temporalAndDispersion';
      hrf_derivatives_suffix = 'Temporal Dispersion Derivatives';
      hrf_derivatives_description = 'HRF: temporal and dispersion derivatives';
  end

  for tissue_confounds = 0:1

    confound_suffix = 'No Tissue Confounds';
    tissue_confounds_to_add = {};
    confound_description = confound_suffix;

    if tissue_confounds
      confound_suffix = 'With Tissue Confounds';
      tissue_confounds_to_add = {'white_matter', 'csf'};
      confound_description = 'includes WM and CSF confounds';
    end

    for outliers = 0:1

      outliers_suffix = 'No Scrubbing';
      outliers_confounds_to_add = {};

      if outliers
        outliers_suffix = 'With Scrubbing';
        outliers_confounds_to_add = {'*outlier*'};
      end

      outliers_description = outliers_suffix;

      description = ['combined GLM for olfaction identification and localization tasks - ', ...
                     hrf_derivatives_description, ' - ', ...
                     confound_description, ' - ', ...
                     outliers_description, ' - ', ...
                     'include all voxels in SPM ICV mask'];

      confounds_to_add = cat(2, tissue_confounds_to_add, outliers_confounds_to_add);

      name = [hrf_derivatives_suffix ' ' confound_suffix ' ' outliers_suffix];

      json_content = template;

      json_content.Name = name;
      json_content.Description = description;
      json_content.Nodes{1}.Model.X(end + 1:end + numel(confounds_to_add)) = confounds_to_add;
      json_content.Nodes{2}.Model.X(end + 1:end + numel(confounds_to_add)) = confounds_to_add;

      list_models_files{end + 1, 1} =  ['model-' strrep(name, ' ', '') '_smdl.json']; %#ok<SAGROW>
      model_file = fullfile(pwd, 'models', ['model-' strrep(name, ' ', '') '_smdl.json']);

      bids.util.jsonwrite(model_file, json_content);

    end
  end
end

disp(list_models_files);
