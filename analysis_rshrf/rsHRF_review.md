# rsHRF review

## Paper

- can the HRF estimate be reused for task fMRI?
- how much data is required to get a reliable estimate of the HRF?
- difference in results between python and matlab implementation

- output on neurovault : NIDM results
- too many acronyms

## App and code

- which matlab versions

After running the following:

```bash
subject=blnd01

input_dir=/home/remi/gin/olfaction_blind/derivatives/fmriprep/sub-$subject/func

input_file=`ls $input_dir/sub-blnd01_task-rest*2009*preproc_bold*nii.gz`
mask=`ls $input_dir/sub-blnd01_task-rest*2009*mask*nii.gz`

echo $input_file
echo $mask

output_dir=/home/remi/gin/olfaction_blind/derivatives/rshrf

rsHRF --input_file $input_file \
	  --atlas $mask \
	  --estimation canon2dd \
	  --output_dir $output_dir
```

I get these files

```
sub-blnd01_task-rest_run-01_space-MNI152NLin2009cAsym_desc-preproc_bold_deconv.nii.gz
sub-blnd01_task-rest_run-01_space-MNI152NLin2009cAsym_desc-preproc_bold_event_number.nii.nii.gz
sub-blnd01_task-rest_run-01_space-MNI152NLin2009cAsym_desc-preproc_bold_FWHM.nii.gz
sub-blnd01_task-rest_run-01_space-MNI152NLin2009cAsym_desc-preproc_bold_Height.nii.gz
sub-blnd01_task-rest_run-01_space-MNI152NLin2009cAsym_desc-preproc_bold_hrf.mat
sub-blnd01_task-rest_run-01_space-MNI152NLin2009cAsym_desc-preproc_bold_plot_1.png
sub-blnd01_task-rest_run-01_space-MNI152NLin2009cAsym_desc-preproc_bold_plot_2.png
sub-blnd01_task-rest_run-01_space-MNI152NLin2009cAsym_desc-preproc_bold_Time2peak.nii.gz
```

## Issues

### Wrong extension

The extension of this file seems wrong

```
sub-blnd01_task-rest_run-01_space-MNI152NLin2009cAsym_desc-preproc_bold_event_number.nii.nii.gz
```

### non bids name

Although not required, when the input is from a BIDS dataset, it would be
preferable if the output also conformed to the general BIDS filename format

sub-<label>([_entity-<label>])\*\_suffix.ext

## BIDS related issues

- assumes non valid bids filenames: process is not a valid suffix in BIDs
  derivatives
- assumes task name will be rest
- does not check that the input is a BIDS derivative: users could run this on
  unpreprocessed data
- ideally the output should be a BIDS like dataset:
  - dataset_description.json

datalad clone /// cd datasets.datalad.org/ datalad install openneuro datalad
install openneuro/ds002790 datalad get ds002790/derivatives/fmriprep/ datalad
get
ds002790/derivatives/fmriprep/sub-0001/func/sub-0001*task-restingstate_acq-seq*\*

## rsHRF

The following does not work does work because the package expects files ending
with a `preproc.nii` and not `*preproc_bold.nii`

### Docker: expecting a BIDS dataset

```
input_dir=../../derivatives/fmriprep
output_dir=../../derivatives/rsHRF

input_dir=/home/remi/gin/olfaction_blind/derivatives/fmriprep
output_dir=/home/remi/gin/olfaction_blind/derivatives/rsHRF

mkdir $output_dir

docker run -ti --rm \
-v $input_dir:/input_dir:ro \
-v $output_dir:/results \
bids/rshrf --bids_dir input_dir --output_dir results --analysis_level participant --brainmask --estimation canon2dd --participant_label blnd01
```

### Docker: one file at a time

subject=blnd01

input_dir=/home/remi/gin/olfaction_blind/derivatives/fmriprep/sub-$subject/func

input_file=`ls $input_dir/sub-blnd01_task-rest*2009*preproc_bold*nii*`
mask=`ls $input_dir/sub-blnd01_task-rest*2009*mask*nii*`

echo $input_file echo $mask

output_dir=/home/remi/gin/olfaction_blind/derivatives/rshrf

```
docker run -ti --rm \
-v $input_file:/input.nii:ro \
-v $mask:/mask.nii \
-v $output_dir:/results \
bids/rshrf --input_file input.nii --atlas mask.nii --estimation canon2dd --output_dir results
```

docker run -ti --rm -v $input_file:/input.nii:ro -v $mask:/mask.nii -v
$output_dir:/results bids/rshrf --input_file input.nii --atlas mask.nii
--estimation canon2dd --output_dir results

Traceback (most recent call last): File "/usr/bin/rsHRF", line 8, in <module>
sys.exit(main()) File "/usr/lib/python3.6/site-packages/rsHRF/CLI.py", line 374,
in main run_rsHRF() File "/usr/lib/python3.6/site-packages/rsHRF/CLI.py", line
218, in run_rsHRF TR =
(spm_dep.spm.spm_vol(args.input_file).header.get_zooms())[-1] File
"/usr/lib/python3.6/site-packages/rsHRF/spm_dep/spm.py", line 13, in spm_vol v =
nib.load(input_file) File
"/usr/lib/python3.6/site-packages/nibabel/loadsave.py", line 55, in load raise
ImageFileError(f'Cannot work out file type of "{filename}"')
nibabel.filebasedimages.ImageFileError: Cannot work out file type of
"/input.nii"

### Python: one file at a time

#### virtual environment

##### Virtual env

```bash
virtualenv -p /usr/bin/python3 env
source env/bin/activate
pip install -r requirements.txt
```

Problems:

- python: 3.8.0 --> nope
- python: 3.6.9 --> OK

##### Conda

```bash
conda env create -n rshrf -f ./environment.yml
conda activate rshrf
```
