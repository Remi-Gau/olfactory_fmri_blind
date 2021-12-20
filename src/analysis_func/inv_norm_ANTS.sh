#!/bin/bash

# Script to convert the ROI files in MNI space to files in native space

clear

root_dir=${PWD}'/../../..'

raw_data_dir=${root_dir}'/inputs/raw'
fmriprep_dir=${root_dir}'/inputs/fmriprep'
roi_dir=${root_dir}'/outputs/derivatives/cpp_spm-roi'

source_space="MNI152NLin6Asym"
reference_file_suffix=T1w

sub_list="$(find "${raw_data_dir}" -type d -name "sub-*")"
roi_list="$(find "${roi_dir}/group" -name "*mask.nii")"

for isubj in ${sub_list}; do

    participant_id=$(basename ${isubj})
    echo "${participant_id}"

    reference_file="$(find "${raw_data_dir}" -name "${participant_id}*${reference_file_suffix}.nii*")"
    # echo "${reference_file}"

    transform_file="$(find "${fmriprep_dir}" -name "${participant_id}*from-${source_space}_to-${reference_file_suffix}*_xfm.h5")"
    # echo "${transform_file}"

    output_dir="${roi_dir}/${participant_id}/roi"
    mkdir -p "${output_dir}"

    for iroi in $roi_list; do

        input_filename=$(basename "${iroi}")
        echo "\n ROI: ${input_filename}"

        output_file="${participant_id}_${input_filename}"
        output_file=$(echo "${output_file}" | sed s@space-MNI@space-T1w@g)
        echo "${output_file}"

        # antsApplyTransforms \
        #     -i "${iroi}" \
        #     -r "${reference_file}" \
        #     -n NearestNeighbor \
        #     -t "${transform_file}" \
        #     -o "${output_file}"

    done

done
