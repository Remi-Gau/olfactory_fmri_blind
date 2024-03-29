---
title: "Material and methods"
author: "Rémi Gau"
date: "2022-06-05"
output: word_document
# output: html_document
bibliography: references.bib
---

# Material and methods

## Participants

Sixteen early-blind (EB; age Mean (M) = 52.56, Standard deviation (SD) = 13.216,
level of education M = 13.25, SD = 3.215, 8 women, 2 smokers) and sixteen
matched (age, gender, level of education, manual dominance and smoking habits)
sighted individuals (controls; age M = 53.50, SD = 11.413, level of education M
= 14.69, SD = 2.27, 8 women, 2 smokers) participated in our study.

All EB participants were affected by blindness as a result of bilateral ocular
or optic nerve lesions from birth. Further detailed description about blind
individuals can be found in Table 1. Except for blindness, all subjects were
healthy and without medical history of neurological or psychiatric problems. All
participants declared that they did not suffer from any medical condition that
could affect their sense of smell at the time of the testing.

Participants were instructed not to eat or drink anything besides water one hour
prior to the experiment.

As depicted in the supplementary Figure 1, all participants had normal olfactory
function as ascertained by means of the Sniffin Sticks identification test
(Hummel et al. 2007; Hummel et al. 1997). A one-way ANOVA did not suggest a
difference between any of the groups with regards to their average scores
F(3, 36) = 2.06, p = .12, ηpartial2 = .15).

The study was approved by the Multicentric Research Ethics Board of the
“Regroupement Neuroimagerie du Québec” [CMER RNQ 11-12-007].

```{r, echo=FALSE, warning=FALSE}
library(flextable)
flextable(read.table(file = "participants.tsv", sep = '\t', header = TRUE))
```

## Chemosensory stimuli

We used two mixed olfactory-trigeminal stimuli, i.e., substances that stimulate
both the olfactory and the trigeminal system (Doty et al. 1978; Viana 2011).
Specifically, we used benzaldehyde (`almond` odor with a burning/tingling
sensation; Sigma-Aldrich, St Louis, MO) and eucalyptol (`eucalyptus` odors with
a cooling sensation; Galenova St-Hyacinthe, Quebec). For simplicity we will
henceforth refer to those stimuli respectively as `almond` and `eucalyptus`.

## Odor presentation

Odorants were delivered with an adapted computer-controlled air compressor (IBB,
University of Münster, Germany), which was used in past studies for
administration of time-controlled air pulses (Frasnelli et al. 2010; La
Buissonnière-Ariza et al. 2012).

The odorants were presented via a eight-channel air compressor. It delivered air
puffs of 2.0 L/min per channel, as ascertained by a flow meter (Cole Parmer,
Montreal, QC). A valve control unit directed air into the air compressor via
polyurethane tubing with 8.0 mm outer diameter and an inner diameter of 4.8 mm
(Fre-Thane 85A, Freelin-Wade, McMinnville, OR). From the air compressor,
polyurethane tubes were connected to bottles containing the odorants. For
odorant localization and identification, four tubes were connected to four 60mL
glass bottles containing the odorants; two bottles filled with `almond` and two
bottles filled with `eucalyptus` (Figure 2). From the four bottles, two
polyurethane tubes were directly connected to the `left` nostril and the other
two polyurethane tubes were connected to the `right` nostril. To administer the
odorants, an air stream was sent to the compressor, which delivered an air puff
into one of the four odor-containing bottles for the identification and
localization tasks. During the inter-stimulus interval, a continuous air flow
was delivered. The LabView software (INFOS DE LABVIEW À DEMANDER) was used to
deliver odorants as well as record participants responses and reaction times.

<!--
TODO Figure 2
TODO INFOS DE LABVIEW À DEMANDER
 -->

## Testing Paradigm

Each participant underwent four fMRI runs with 4 stimulus presentations per run,
resulting in a total of 16 stimulus presentations. The chemosensory stimuli were
either `eucalyptus` or `almond` and delivered either to the `left` or the
`right` nostril. The 16-s stimuli ("on"-period) were separated by fixed
inter-stimulus intervals of 40 s to avoid habituation (Hummel and Kobal 1999)
and during which subjects received odorless air ("off"-periods). This design
allows for physiological refreshment and prevents the overlap of hemodynamic
responses.

Each run has the same order of stimulus presentation:

1. `left` nostril/`eucalyptus`
2. `left` nostril/`almond`
3. `right` nostril/`eucalyptus`
4. `right` nostril/`almond`.

<!-- TODO
- talk about how this confounds some interpretation
-->

<!-- TODO
 check average duration of runs
 -->

The total duration of one run was 214 s. A short verbal instruction was
delivered before the start of each run to instruct participants which task they
would have to carry out:

- a localization task (`oldloc`),
- an identification (`olfid`).

After each sniffing, subjects responded to the presence of an odorant and
according to the task by pressing one of two buttons with the index or the major
of their `right` hand. Specifically, during the localization task they had to
indicate whether their `left` or their `right` nostril was stimulated and during
the identification task, they had to indicate whether they received `eucalyptus`
or `almond`.

## MRI acquisition parameters

```{r, child=c('sub-ctrl01/bids-matlab_report.md')}

```

## Quality control

```{r, child=c('quality_control.md')}

```

## Preprocessing

```{r, child=c('fmriprep/CITATION.md')}

```

## Statistical analysis

### Behavioral

### fMRI

```{r, child=c('statistical_analysis_fmri.md')}

```

## Data and code

Code and data are bundled together as a datalad dataset available on GIN:
https://gin.g-node.org/cpp-lln-lab/olf_blind_yoda

Code is also available on
[Github](https://github.com/Remi-Gau/olfactory_fmri_blind).

Raw behavioral in-scan data are available on Gin:
https://gin.g-node.org/cpp-lln-lab/olfaction_blind_beh

Raw and derivative (fMRIprep and MRIQC) output data is available on requests.

<!--
where to store stats data at the group level
-->

Statiscal maps are availble on neurovault

## References
