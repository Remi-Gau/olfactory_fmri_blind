# fMRI analysis

## Copy and unzipping data

Run this script: `step_0_copy_data.m`

## Smoothing the data

Run this script: `step_1_smooth.m`

## Subject level GLMs

Run this script: `step_2_subject_GLM.m`

## Model selection using the MACs toolbox

### Specify all models

`step_4_run_all_models`

### Compute cvLME and do bayesian model selection

This is done by `step_5_model_selection.m` using bayesian model selection with
the [MACs toolbox](https://github.com/JoramSoch/MACS/releases/tag/v1.3).

```bash
datalad run -d . -m 'compute cvLME model 1' \
    -o outputs/derivatives/cpp_spm-modelSelection/ \
    'cd code/src/analysis_func && make run_model_selection'
```

#### Failed cvLME

For `ctrl02`

```matlab
Subject 18 (18 out of 32):
   - Model No Derivative No Tissue Confounds No Scrubbing
```

## Running the group level GLM

`step_3_group_GLM.m`

## Running the ROI based analysis in native space to get time courses and percent signal change for each ROIs

You will first need to create the ROIs (or you can download them from neurovault
(_insert URL_)) that will be used for this analysis.

`step_6_create_roi.m` create the ROIs to check responses in the regions
corresponding to the terms _hand_ and _olfactory_ in neurosynth and also for
visual ROIs from the Wang atlas.

This is done by `step_7_reoi_based_glm.m`
