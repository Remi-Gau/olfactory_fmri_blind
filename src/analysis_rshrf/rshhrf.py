histortysubject="blnd01"

input_dir="/home/remi/gin/olfaction_blind/derivatives/fmriprep/"
output_dir= "/home/remi/gin/olfaction_blind/derivatives/rshrf"


rsHRF --input_file input.nii --atlas mask.nii --estimation canon2dd --output_dir results
