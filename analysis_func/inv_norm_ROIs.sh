#!/bin/bash

# Script to convert the ROI files in MNI space to files in native space

clear

data_dir='/data'
code_dir='/code'

sub_list="$(ls $data_dir/raw | grep sub)"

roi_list="$(ls $code_dir/inputs/ROI*.nii)"

for isubj in $sub_list;
do

  echo
  echo $isubj

  mkdir /output/${isubj}/
  mkdir /output/${isubj}/roi

  reference_file=$data_dir/raw/${isubj}/anat/${isubj}_T1w.nii
  transform_file=$data_dir/derivatives/spm12/${isubj}/anat/${isubj}_from-MNI152NLin6Asym_to-T1w_mode-image_xfm.h5

  ls $reference_file
  ls $transform_file

  for iroi in $roi_list;
  do

    echo " ROI: ${iroi}"
    output_file=`echo ${iroi} | sed s@/code/inputs@/output/${isubj}/roi@g | sed s/MNI/T1w/g`

    antsApplyTransforms \
    -i $iroi \
    -r $reference_file \
    -n NearestNeighbor \
    -t $transform_file \
    -o $output_file

	done

done
