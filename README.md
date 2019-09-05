# code base for the analysis of olfaction fMRI experiment in blind and sighted control

## Dependencies

| Dependencies                                                                                                              | Used version |
|---------------------------------------------------------------------------------------------------------------------------|--------------|
| [Matlab](https://www.mathworks.com/products/matlab.html)                                                                  | 201?         |
| [SPM12](https://www.fil.ion.ucl.ac.uk/spm/software/spm12/)                                                                | v7487        |
| [Marsbar toolbox for SPM](http://marsbar.sourceforge.net/download.html)                                                   | 0.44         |
| [Anatomy toolbox for SPM](https://www.fz-juelich.de/SharedDocs/Downloads/INM/INM-1/DE/Toolbox/Toolbox_22c.html?nn=563092) | 2.2          |

This has not been tried on Octave. Sorry open-science friends... :see_no_evil:

### Other Dependencies

... are included in the `subfun/matlab_exchange` to make your life easier.

But might be worth using this in the future: https://github.com/mobeets/mpm

## Docker images

| Image                                                  | Used version                |
|--------------------------------------------------------|-----------------------------|
| [MRIQC](https://mriqc.readthedocs.io/en/stable/)       | poldracklab/mriqc:0.15.0    |
| [fMRIprep](https://fmriprep.readthedocs.io/en/stable/) | poldracklab/fmriprep:1.4.0  |
| [ANTs](http://marsbar.sourceforge.net/download.html)   | kaczmarj/ants:v2.3.1-source |



## fMRI QC and preprocessing


To make docker run, make sure you the docker daemon is running (may require admin rights)
```bash
sudo dockerd
```

### MRIQC

```bash
data_dir=~/mnt/data/christine/olf_blind/ # define where the data is

docker run -it --rm -v $data_dir/raw:/data:ro -v $data_dir:/out poldracklab/mriqc:0.15.0 /data /out/derivatives/mriqc participant --verbose-reports --mem_gb 50 --n_procs 16 -m bold
```

### fmriprep

Preprocessing done with [fMRIprep](https://fmriprep.readthedocs.io/en/stable/) and outputs data in both native and MNI space.  

```bash
data_dir=~/mnt/data/christine/olf_blind/ # define where the data is

docker run -it --rm -v $data_dir:/data:ro -v $data_dir:/out poldracklab/fmriprep:1.4.0 /data/raw /out/derivatives/ participant --participant_label ctrl02 ctrl06 ctrl07 ctrl08 ctrl09 --fs-license-file /data/freesurfer/license.txt --output-spaces T1w:res-native MNI152NLin2009cAsym:res-native --nthreads 10 --use-aroma
```

#### Problematic anat or func data

The `quality_control_fmriprep_FD.m` script uses the `confounds.tsv` report from fmriprep to estimate the number of timepoints in framewise displacement timeseries with values superior to a threshold.

This script also allows to estimate how many points are lost through scrubbing depending on the framewise displacement threshold and the number of points to scrub after an outlier


## Behavioral analysis

### Quality control

`quality_control_beh` plots stimulation epochs, responses and respirations.

`quality_control_physio` plots the respiratory data from each subject / run and shows when the acquisition was started.

### Results

`beh_avg_timeseries` plots the average across subjects of:
-   stimulus onsets / offsets (to make sure that there is not too much variation between subjects)
-   average across subject of the time course of each response type.
    -   this can be row normalized for each subject (by the sum of response for that subject on that run - gives more weight to subjects with more SNR in their response)
    -   it is possible to bin the responses from their original 25 Hz sampling frequency.
    -   responses can be passed through a moving with window size

`beh_PSTH` plots data with PSTH for each stimulus (averaged across runs) and also plots the mean +/- SEM (and distribution) of the number of responses.


## fMRI analysis

For those you might need to edit the `set_dir` function to specify where the code is, the folder containing the BIDS raw data and the target directory where the SPM analysis should go.

Here is how I set up the directories on my machine.

```matlab
case 1 % windows matlab/octave : Remi
    code_dir = '/home/remi/github/chem_sens_blind';
    data_dir = '/home/remi/BIDS/olf_blind';
    output_dir = fullfile(data_dir, 'derivatives', 'spm12');
```

### Copy and unzipping data

Run this script: `step_1_copy_and_unzip_files`

Setting up the `space` variable `MNI` or  `T1w` will take care of the data in MNI space or in native space respectively.

### Smoothing the data

Run this script:  `step_2_smooth_func_files.m`

Setting up the `space` variable `MNI` or  `T1w` will take care of the data in MNI space or in native space respectively.

### Converting the events.tsv files into SOT.mat files for SPM

Run this script:  `step_3_get_SOT.m`

### Running the subject level GLM

Run this script: `step_4_run_first_level.m`

Setting up the `space` variable `MNI` or  `T1w` will take care of the data in MNI space or in native space respectively.

After you can create a group mask with the `create_group_mask.m` script.
You can also create a group T1w image with the `create_mean_T1w.m` script.

When running the GLM with the data in MNI space, the images of the residuals are kept and this to do a bit of quality control: it calls the function `subfun/plot_power_spectra_of_GLM_residuals.m` (taken from this [repo](https://github.com/wiktorolszowy/fMRI_temporal_autocorrelation)) to plot the frequency content of the residuals to see how far it is from white noise (flat profile). The figure is generated in the folder of each GLM.

See this [paper](https://www.nature.com/articles/s41467-019-09230-w.pdf) and this [repo](https://github.com/wiktorolszowy/fMRI_temporal_autocorrelation) for more info.

### Running the group level GLM
You will first need to create the ROIs (or you can download them from neurovault (*insert URL*)) that will be used for this analysis.

`create_ROIs.m` create the ROIs to check responses in the regions corresponding to the terms _hand_ and _olfactory_ in neurosynth (*insert URL*)

`create_ROI_visual.m` creates the ROIs for the visual system. All of them combined and one for each ROI. It uses the [ROIs of the anatomy toolbox](https://www.fz-juelich.de/SharedDocs/Downloads/INM/INM-1/DE/Toolbox/Toolbox_22c.html?nn=563092).

Then run this script: `step_5_run_second_level.m`

### Converting ROIs to native space using ANTs

If you want to convert the ROIS created above into their native space equivalent we used ANTs and the transformation file created by fMRIprep to do that.

Set some variable for the directories: this part will depend on where the files are on your computer
```bash
data_dir=~/BIDS/olf_blind # where the data are
code_dir=~/github/chem_sens_blind # where this repo was downloaded or cloned
output_dir=~/BIDS/olf_blind/derivatives/ANTs  # where to output the data
mkdir $output_dir
```

Launch the ANTs docker container

```bash
docker run -it --rm \
-v $data_dir:/data \
-v $code_dir:/code \
-v $output_dir:/output \
kaczmarj/ants:v2.3.1-source
```

Run the conversion script
```bash
sh /code/inv_norm_ROIs.sh
```

### Running the ROI based analysis in native space to get time courses and percent signal change for each ROIs

Work in progress...
