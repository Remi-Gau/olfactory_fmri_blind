# code base for the analysis of olfaction fMRI experiment in blind and sighted control


## fMRI QC and preprocessing


To make docker run
```
sudo dockerd
```

### MRIQC

```
docker run -it --rm -v ~/mnt/data/christine/olf_blind/raw:/data:ro -v ~/mnt/data/christine/olf_blind:/out poldracklab/mriqc:0.15.0 /data /out/derivatives/mriqc participant --verbose-reports --mem_gb 50 --n_procs 16 -m bold
```

### fmriprep

```
docker run -it --rm -v /mnt/data/christine/olf_blind:/data:ro -v /mnt/data/christine/olf_blind/:/out poldracklab/fmriprep:1.4.0 /data/raw /out/derivatives/ participant --participant_label ctrl02 ctrl06 ctrl07 ctrl08 ctrl09 --fs-license-file /data/freesurfer/license.txt --output-spaces T1w:res-native MNI152NLin2009cAsym:res-native --nthreads 10 --use-aroma
```

Done:
ctrl01 ctrl02 ctrl03 ctrl04 ctrl05 ctrl06 ctrl07 ctrl08 ctrl09 ctrl10 ctrl11 ctrl12 ctrl13 ctrl14 ctrl15 ctrl17 ctrl18 blnd01 blnd02 blnd03 blnd04 blnd05 blnd06 blnd07 blnd08 blnd09 blnd10 blnd11 blnd12 blnd13 blnd14 blnd15

Running:
blnd16 blnd17


#### Less urgent (problematic anat or func data)

???


## behavioral analysis

### quality control

`quality_control_beh` plots stimulation epochs, responses and respirations.

`quality_control_physio` plots the respiratory data from each subject / run and shows when the acquisition was started.

### results

`beh_avg_timeseries` plots the average across subjects of:
- stimulus onsets / offsets (to make sure that there is not too much variation between subjects)
- average across subject of the time course of each response type.
  - this can be row normalized for each subject (by the sum of response for that subject on that run - gives more weight to subjects with more SNR in their response)
  - it is possible to bin the responses from their original 25 Hz sampling frequency.
  - responses can be passed through a moving with window size

`beh_PSTH` plots data with PSTH for each stimulus (averaged across runs) and also plots the mean +/- SEM (and distribution) of the number of responses.


## fMRI analysis

For those you might need to edit the `set_dir` function to specify where the code is, the folder containing the BIDS raw data and the target directory where the SPM analysis should go.

### Copy and unzipping data
Type in the following command to copy the relevant files and unzip them:
`step_1_copy_and_unzip_files`


### Smoothing the data
Type in the following command to smooth the data them:
`step_2_smooth_func_files.m`


### Running the subject level GLM
Type in the following command to run the subject level GLM:
`step_3_run_first_level.m`
