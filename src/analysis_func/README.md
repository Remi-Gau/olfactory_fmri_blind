# fMRI analysis

## Copy and unzipping data

Run this script: `step_0_copy_data.m`

## Smoothing the data

Run this script: `step_1_smoothm`

## Subject level GLMs

Run this script: `step_2_subject.m`

## Model selection using the MACs toolbox

This is done by `step_6_model_selection.m` using bayesian model selection with
the [MACs toolbox](https://github.com/JoramSoch/MACS/releases/tag/v1.3).

## Running the group level GLM

You will first need to create the ROIs (or you can download them from neurovault
(_insert URL_)) that will be used for this analysis.

`create_ROIs.m` create the ROIs to check responses in the regions corresponding
to the terms _hand_ and _olfactory_ in neurosynth (_insert URL_)

`create_ROI_visual.m` creates the ROIs for the visual system. All of them
combined and one for each ROI. It uses the
[ROIs of the anatomy toolbox](https://www.fz-juelich.de/SharedDocs/Downloads/INM/INM-1/DE/Toolbox/Toolbox_22c.html?nn=563092).

Then run this script: `step_5_run_second_level.m`

## Running the ROI based analysis in native space to get time courses and percent signal change for each ROIs

This is done by `step_7_get_ROI_PSC.m`
