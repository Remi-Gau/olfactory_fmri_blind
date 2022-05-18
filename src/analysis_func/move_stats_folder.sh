#!/bin/bash

# move stats folder due to change of layout of cpp spm output

clear

root_dir=${PWD}'/../../..'

data_dir=${root_dir}'/outputs/derivatives/cpp_spm-modelSelection'


sub_list="$(find "${data_dir}" -type d -name "sub-*")"

for isubj in ${sub_list}; do

    participant_id=$(basename ${isubj})
    echo "${participant_id}"

    ls "${data_dir}/${participant_id}"
    

done
