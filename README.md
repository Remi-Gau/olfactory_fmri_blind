[![pre-commit.ci status](https://results.pre-commit.ci/badge/github/Remi-Gau/olfactory_fmri_blind/master.svg)](https://results.pre-commit.ci/latest/github/Remi-Gau/olfactory_fmri_blind/master)
[![miss hit](https://img.shields.io/badge/code%20style-miss_hit-000000.svg)](https://misshit.org/)

# Analysis of olfaction fMRI experiment in blind and sighted control

- [Analysis of olfaction fMRI experiment in blind and sighted control](#analysis-of-olfaction-fmri-experiment-in-blind-and-sighted-control)
  - [Dependencies](#dependencies)
    - [Other Dependencies](#other-dependencies)
  - [Docker images](#docker-images)
  - [fMRI QC and preprocessing](#fmri-qc-and-preprocessing)
    - [MRIQC](#mriqc)
    - [fmriprep](#fmriprep)
      - [Problematic anat or func data](#problematic-anat-or-func-data)
  - [Behavioral analysis](#behavioral-analysis)
    - [Quality control](#quality-control)
    - [Results](#results)
  - [fMRI analysis](#fmri-analysis)

## Dependencies

| Dependencies                                               | Used version |
| ---------------------------------------------------------- | ------------ |
| [Matlab](https://www.mathworks.com/products/matlab.html)   | 201?         |
| [SPM12](https://www.fil.ion.ucl.ac.uk/spm/software/spm12/) | v7487        |
| [CPP SPM](http://marsbar.sourceforge.net/download.html)    | v1.1.5dev    |

This has not been tried on Octave. Sorry open-science friends... :see_no_evil:

### Other Dependencies

... are included in the `lib/matlab_exchange` to make your life easier.

## Docker images

| Image                                                  | Used version                |
| ------------------------------------------------------ | --------------------------- |
| [MRIQC](https://mriqc.readthedocs.io/en/stable/)       | poldracklab/mriqc:0.15.0    |
| [fMRIprep](https://fmriprep.readthedocs.io/en/stable/) | poldracklab/fmriprep:1.4.0  |
| [ANTs](http://marsbar.sourceforge.net/download.html)   | kaczmarj/ants:v2.3.1-source |

## fMRI QC and preprocessing

To make docker run, make sure you the docker daemon is running (may require
admin rights)

```bash
sudo dockerd
```

### MRIQC

```bash
data_dir=~/mnt/data/christine/olf_blind/ # define where the data is

docker run -it --rm
	-v $data_dir/raw:/data:ro \
	-v $data_dir:/out poldracklab/mriqc:0.15.0 /data /out/derivatives/mriqc \
	participant \
	--verbose-reports \
	--mem_gb 50 \
	--n_procs 16 \
	-m bold
```

### fmriprep

Preprocessing done with [fMRIprep](https://fmriprep.readthedocs.io/en/stable/)
and outputs data in both native and MNI space.

```bash
data_dir=~/mnt/data/christine/olf_blind/ # define where the data is

docker run -it --rm \
	-v $data_dir:/data:ro \
	-v $data_dir:/out \
	poldracklab/fmriprep:1.4.0 /data/raw /out/derivatives/ \
	participant --participant_label ctrl02 ctrl06 ctrl07 ctrl08 ctrl09 \
	--fs-license-file /data/freesurfer/license.txt \
	--output-spaces T1w:res-native MNI152NLin2009cAsym:res-native \
	--nthreads 10 --use-aroma
```

#### Problematic anat or func data

The `quality_control_fmriprep_FD.m` script uses the `confounds.tsv` report from
fmriprep to estimate the number of timepoints in framewise displacement
timeseries with values superior to a threshold.

This script also allows to estimate how many points are lost through scrubbing
depending on the framewise displacement threshold and the number of points to
scrub after an outlier

## Behavioral analysis

### Quality control

`quality_control_beh` plots stimulation epochs, responses and respirations.

`quality_control_physio` plots the respiratory data from each subject / run and
shows when the acquisition was started.

### Results

`beh_avg_timeseries` plots the average across subjects of:

- stimulus onsets / offsets (to make sure that there is not too much variation
  between subjects)
- average across subject of the time course of each response type.
  - this can be row normalized for each subject (by the sum of response for that
    subject on that run - gives more weight to subjects with more SNR in their
    response)
  - it is possible to bin the responses from their original 25 Hz sampling
    frequency.
  - responses can be passed through a moving with window size

`beh_PSTH` plots data with PSTH for each stimulus (averaged across runs) and
also plots the mean +/- SEM (and distribution) of the number of responses.

## fMRI analysis

See this [README](src/analysis_func/README.md)
