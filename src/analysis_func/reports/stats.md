The fMRI data were analysed with CPP SPM (v1.1.5dev; https://github.com/cpp-lln-lab/CPP_SPM; DOI: https://doi.org/10.5281/zenodo.3554331)
using statistical parametric mapping
(SPM12 - 7771; Wellcome Center for Neuroimaging, London, UK;
https://www.fil.ion.ucl.ac.uk/spm; RRID:SCR_007037)
using MATLAB 9.2.0.538062 (R2017a)
on a unix computer (Ubuntu 18.04.6 LTS).

The input data were the preprocessed BOLD images in  MNI152NLin2009cAsym  space for the task " olfid, olfloc ".

At the subject level, we performed a mass univariate analysis with a linear
regression at each voxel of the brain, using generalized least squares with a
global  FAST  model to account for temporal auto-correlation
 (Corbin et al, 2018) and a drift fit with discrete cosine transform basis ( 128.2051  seconds cut-off).

Image intensity scaling was done run-wide before statistical modeling such that
the mean image would have a mean intracerebral intensity of 100.

We modeled the fMRI experiment in a  {{designType}}  design with regressors
entered into the run-specific design matrix. The onsets
were convolved with a canonical hemodynamic response function (HRF)
 for the conditions:
- olfid_eucalyptus_left, olfid_eucalyptus_right, olfid_almond_left, olfid_almond_right, olfloc_eucalyptus_left, olfloc_eucalyptus_right, olfloc_almond_left, olfloc_almond_right, resp_03, resp_12
 .

 Nuisance covariates included the 6 realignment parameters to account for residual motion artefacts.

 This method section was automatically generated using CPP SPM
(v1.1.5dev; https://github.com/cpp-lln-lab/CPP_SPM; DOI: https://doi.org/10.5281/zenodo.3554331)
and octache (https://github.com/Remi-Gau/Octache).
