# code base for the analysis of olfaction fMRI experiment in blind and sighted control


## fMRI preprocessing run with fMRIprep

```
insert here command used to run fMRIprep
```


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
