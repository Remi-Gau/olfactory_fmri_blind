
###  5.2. <a name='Batches'></a>Batches

There are 2 batch files `batch_MNI_space` and `batch_native_space` that can run the whole analysis in native or MNI space. Ideally once you have configured `set_dir`, they are the only things you should have to run.

Below is described their content.

####  5.2.1. <a name='Copyandunzippingdata'></a>Copy and unzipping data

Run this script: `step_1_copy_and_unzip_files`

Setting up the `space` variable `MNI` or  `T1w` will take care of the data in MNI space or in native space respectively.

####  5.2.2. <a name='Smoothingthedata'></a>Smoothing the data

Run this script:  `step_2_smooth_func_files.m`

Setting up the `space` variable `MNI` or  `T1w` will take care of the data in MNI space or in native space respectively.

####  5.2.3. <a name='Convertingtheevents.tsvfilesintoSOT.matfilesforSPM'></a>Converting the events.tsv files into SOT.mat files for SPM

Run this script:  `step_3_get_SOT.m`

####  5.2.4. <a name='RunningthesubjectlevelGLM'></a>Running the subject level GLM

Run this script: `step_4_run_first_level.m`

Setting up the `space` variable `MNI` or  `T1w` will take care of the data in MNI space or in native space respectively.

After you can create a group mask with the `create_group_mask.m` script.
You can also create a group T1w image with the `create_mean_T1w.m` script.

When running the GLM with the data in MNI space, the images of the residuals are kept and this to do a bit of quality control: it calls the function `subfun/plot_power_spectra_of_GLM_residuals.m` (taken from this [repo](https://github.com/wiktorolszowy/fMRI_temporal_autocorrelation)) to plot the frequency content of the residuals to see how far it is from white noise (flat profile). The figure is generated in the folder of each GLM.

See this [paper](https://www.nature.com/articles/s41467-019-09230-w.pdf) and this [repo](https://github.com/wiktorolszowy/fMRI_temporal_autocorrelation) for more info.

####  5.2.5. <a name='ModelselectionusingtheMACstoolbox'></a>Model selection using the MACs toolbox

This is done by `step_6_model_selection.m` using bayesian model selection with the [MACs toolbox](https://github.com/JoramSoch/MACS/releases/tag/v1.3).

####  5.2.6. <a name='RunningthegrouplevelGLM'></a>Running the group level GLM
You will first need to create the ROIs (or you can download them from neurovault (*insert URL*)) that will be used for this analysis.

`create_ROIs.m` create the ROIs to check responses in the regions corresponding to the terms _hand_ and _olfactory_ in neurosynth (*insert URL*)

`create_ROI_visual.m` creates the ROIs for the visual system. All of them combined and one for each ROI. It uses the [ROIs of the anatomy toolbox](https://www.fz-juelich.de/SharedDocs/Downloads/INM/INM-1/DE/Toolbox/Toolbox_22c.html?nn=563092).

Then run this script: `step_5_run_second_level.m`

####  5.2.7. <a name='RunningtheROIbasedanalysisinnativespacetogettimecoursesandpercentsignalchangeforeachROIs'></a>Running the ROI based analysis in native space to get time courses and percent signal change for each ROIs

This is done by `step_7_get_ROI_PSC.m`
