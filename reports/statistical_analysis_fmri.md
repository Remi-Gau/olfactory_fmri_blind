The fMRI data were analysed with CPP SPM [@CPP_SPM] using statistical parametric
mapping (SPM12 - 7771; Wellcome Center for Neuroimaging, London, UK;
https://www.fil.ion.ucl.ac.uk/spm; RRID:SCR_007037) using MATLAB 9.2.0.538062
(R2017a) on a unix computer (Ubuntu 18.04.6 LTS).

### Input data and exclusion criterion

The input data were the preprocessed BOLD images in MNI152NLin2009cAsym space
for the task `olfid`, `olfloc`.

TODO list excluded participants and reasons

#### Bayesian model selection

TODO add reference

We performed a Bayesian model selection using the MACS toolbox to identify
the best model given our data.

All models included all experimental conditions:
- tasks: `olfid`, `olfloc`,
- stimuli: `almond`, `eucalyptus`
- nostril side: `left`, `right`

- motion parameters: translations along x, y, z, and rotations along x, y, z

Models distinguish themselves by the HRF basis set, extra confounds and scrubbing
regressors.

1. HRF

- HRF canonical
- HRF + derivative
- HRF + derivative + dispersion

2. extra confounds

To include the noise confounds computed by fmriprep in given regions.

- none
- cerebrospinal fluids + white matter

3. Scrubbing

TODO: how are outliers defined? Used the default fmriprep?

- no outlier removal
- with outlier removal

This gave us 12 models that we were specified and estimated for each subject:

1. No Derivative No Tissue Confounds No Scrubbing_model
2. No Derivative No Tissue Confounds With Scrubbing_model
3. No Derivative With Tissue Confounds No Scrubbing_model
4. No Derivative With Tissue Confounds With Scrubbing_model
5. Temporal Derivatives No Tissue Confounds No Scrubbing_model
6. Temporal Derivatives No Tissue Confounds With Scrubbing_model
7. Temporal Derivatives With Tissue Confounds No Scrubbing_model_L
8. Temporal Derivatives With Tissue Confounds With Scrubbing_model
9. Temporal Dispersion Derivatives No Tissue Confounds No Scrubbing_model
10. Temporal Dispersion Derivatives No Tissue Confounds With Scrubbing_model
11. Temporal Dispersion Derivatives With Tissue Confounds No Scrubbing_model
12. Temporal Dispersion Derivatives With Tissue Confounds With Scrubbing_model




### Run / subject level analysis

At the subject level, we performed a mass univariate analysis with a linear
regression at each voxel of the brain, using generalized least squares with a
global FAST model to account for temporal auto-correlation [@Corbin2018] and a
drift fit with discrete cosine transform basis (128 seconds cut-off).

Image intensity scaling was done run-wide before statistical modeling such that
the mean image would have a mean intracerebral intensity of 100.

TODO what slice was used as reference

We modeled the fMRI experiment in a block design with regressors entered into
the run-specific design matrix. The onsets were convolved with SPM canonical
hemodynamic response function (HRF) for the conditions:

- `olfid_eucalyptus_left`,
- `olfid_eucalyptus_right`,
- `olfid_almond_left`,
- `olfid_almond_right`,
- `olfloc_eucalyptus_left`,
- `olfloc_eucalyptus_right`,
- `olfloc_almond_left`,
- `olfloc_almond_right`,
- `resp_03`,
- `resp_12`.

Nuisance covariates included:

- `trans_?`,
- `rot_?`,
- `white_matter`,
- `csf`.

to account for residual motion artefacts, to regress out signal coming from non
grey matter regions, .

### Group level analysis

TODO ROI based analysis

Contrast for the following conditions were passed as summary statistics for a
group level analysis:

- `olfid_eucalyptus_left`,
- `olfid_eucalyptus_right`,
- `olfid_almond_left`,
- `olfid_almond_right`,
- `olfloc_eucalyptus_left`,
- `olfloc_eucalyptus_right`,
- `olfloc_almond_left`,
- `olfloc_almond_right`,

<!--
This method section was automatically generated using CPP SPM (v1.1.5dev;
https://github.com/cpp-lln-lab/CPP_SPM; DOI:
https://doi.org/10.5281/zenodo.3554331) and octache
(https://github.com/Remi-Gau/Octache).
-->
