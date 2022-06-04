#!/bin/bash

files=$(find "analysis_qc" -name '*.m')

for i in ${files}; do

    echo "${i}"
    output_file="bu_$(basename "${i}")"
    echo ${output_file}
    cat "${i}" > "analysis_qc/${output_file}"

done
