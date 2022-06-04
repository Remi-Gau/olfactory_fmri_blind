#!/bin/bash

files=$(find analysis_rshrf -name "*.*")

for i in ${files}; do

    echo "${i}"
    output_dir="$(dirname "${i}")"
    output_file="bu_$(basename "${i}")"
    echo "${output_dir}/${output_file}"
    cat "${i}" > "${output_dir}/${output_file}"

done
