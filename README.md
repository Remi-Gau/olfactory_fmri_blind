# code base for the analysis of olfaction fMRI experiment in blind and sighted control

## dependencies

matlab

SPM 12

[marsbar 0.44](http://marsbar.sourceforge.net/download.html)

docker



## fMRI QC and preprocessing


To make docker run, make sure you the docker daemon is running (may require admin rights)
```bash
sudo dockerd
```

### MRIQC

```bash
data_dir=~/mnt/data/christine/olf_blind/

docker run -it --rm -v $data_dir/raw:/data:ro -v $data_dir:/out poldracklab/mriqc:0.15.0 /data /out/derivatives/mriqc participant --verbose-reports --mem_gb 50 --n_procs 16 -m bold
```

### fmriprep

```bash
data_dir=~/mnt/data/christine/olf_blind/

docker run -it --rm -v $data_dir:/data:ro -v $data_dir:/out poldracklab/fmriprep:1.4.0 /data/raw /out/derivatives/ participant --participant_label ctrl02 ctrl06 ctrl07 ctrl08 ctrl09 --fs-license-file /data/freesurfer/license.txt --output-spaces T1w:res-native MNI152NLin2009cAsym:res-native --nthreads 10 --use-aroma
```
http://marsbar.sourceforge.net/download.html

#### Problematic anat or func data

???


## behavioral analysis

### quality control

`quality_control_beh` plots stimulation epochs, responses and respirations.

`quality_control_physio` plots the respiratory data from each subject / run and shows when the acquisition was started.

### results

`beh_avg_timeseries` plots the average across subjects of:
-   stimulus onsets / offsets (to make sure that there is not too much variation between subjects)
-   average across subject of the time course of each response type.
    -   this can be row normalized for each subject (by the sum of response for that subject on that run - gives more weight to subjects with more SNR in their response)
    -   it is possible to bin the responses from their original 25 Hz sampling frequency.
    -   responses can be passed through a moving with window size

`beh_PSTH` plots data with PSTH for each stimulus (averaged across runs) and also plots the mean +/- SEM (and distribution) of the number of responses.


## fMRI analysis

For those you might need to edit the `set_dir` function to specify where the code is, the folder containing the BIDS raw data and the target directory where the SPM analysis should go.

### Copy and unzipping data

Run this script: `step_1_copy_and_unzip_files`

### Smoothing the data

Run this script:  `step_2_smooth_func_files.m`

### Converting the evnts.tsv files into SOT.mat files for SPM

Run this script:  `step_3_get_SOT.m`

### Running the subject level GLM

Run this script: `step_4_run_first_level.m`

After you can create a group mask with the `create_group_mask.m` script.

You can also create a group T1w image with the `create_mean_T1w.m` script.

### Running the group level GLM
You will first need to create the ROIs (or you can download them from neurovault (*insert URL*)) that will be used for this analysis.

`create_ROIs.m` create the ROIs to check responses in the regions corresponding to the terms _hand_ and _olfactory_ in neurosynth (*insert URL*)

`create_ROI_visual.m` creates the ROIs for the visual system. All of them combined and one for each ROI. It uses the [retinotopic atlas from Kastner's lab](http://scholar.princeton.edu/sites/default/files/napl/files/probatlas_v4.zip).

Then run this script: `step_5_run_second_level.m`

### Converting ROIs to native space usin ANTs

Set some variable for the directories: this part will depend on where the files are on your computer
```bash
data_dir=~/BIDS/olf_blind # where the data are
code_dir=~/github/chem_sens_blind # where this repo was downloaded or cloned
output_dir=~/BIDS/olf_blind/derivatives/ANTs  # where to output the data
mkdir $output_dir
```

Launch the ANTs docker

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
