# code base for the analysis of olfaction fMRI experiment in blind and sighted control


## fMRI QC and preprocessing

### MRIQC

```
docker run -it --rm \
-v ~/mnt/data/christine/olf_blind/raw:/data:ro \
-v ~/mnt/data/christine/olf_blind:/out poldracklab/mriqc:0.15.0 /data /out/derivatives/mriqc \
participant \
--verbose-reports --mem_gb 50 --n_procs 16 -m bold
```

### fmriprep

```
docker run -it --rm \
-v /mnt/data/christine/olf_blind:/data:ro \
-v /mnt/data/christine/olf_blind/:/out poldracklab/fmriprep:1.4.0 /data/raw /out/derivatives/ \
participant --participant_label ctrl02 ctrl06 ctrl07 ctrl08 ctrl09 \
--fs-license-file /data/freesurfer/license.txt \
--output-spaces T1w:res-native MNI152NLin2009cAsym:res-native --nthreads 10 --use-aroma
```

#### Done:
ctrl01 ctrl03 ctrl04 ctrl05

#### Running:
ctrl02 ctrl06 ctrl07 ctrl08 ctrl09

#### Less urgent (problematic anat or func data)

???

## functions descriptions

`quality_control_physio`
Plots the respiratory data from each subject / run and shows when the acquisition was started.

`avg_beh_results`
Plots for each task the average across subjects time courses of:
- stimulus onsets / offsets (to make sure that there is not too much variation between subjects)
- mean across subject of each response type for each run and each group
- mean across subject / runs of each response type for each group
- same as above but plots the 2 groups on the same figure with the same scale

Possible options:
 - row normalization for each subject's response (by the sum of response for that subject on that run - gives more weight to subjects with more SNR in their response)
 - bin the responses from their original 25 Hz sampling frequency.
 - responses can be passed through a moving with window size
