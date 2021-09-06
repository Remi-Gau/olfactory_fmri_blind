% script to smooth the functional fmriprep preprocessed data

clc;

if ~exist('machine_id', 'var')
  machine_id = 2; % 0: container ;  1: Remi ;  2: Beast
end

% 'MNI' or  'T1w' (native)
if ~exist('space', 'var')
  space = 'T1w';
end

switch space
  case 'MNI'
    FWHM = 8;
    prefix = 's-8_';
    filter =  'sub-.*space-MNI152NLin2009cAsym_desc-preproc'; % to smooth only the preprocessed files
  case 'T1w'
    FWHM = 6;
    prefix = 's-6_';
    filter =  'sub-.*space-T1w_desc-preproc'; % for the files in native space
end

% setting up directories
[data_dir, code_dir, output_dir, fMRIprep_DIR] = set_dir(machine_id);

% smooth
smooth_batch(FWHM, prefix, output_dir, filter);
