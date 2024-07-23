#!/bin/bash
files=($( ls * )) #Add () to convert output to array
counter=0

do_clean() {
    local file=$1
    local clean_file=$2
    echo $file
    echo $clean_file
    svgcleaner --multipass "$file" "$clean_file"
}

for file in *-working.svg ; do
    echo $file
    echo $destination_file
    destination_file="${file/-working/}"
    if [[ ! -f "$destination_file" ]]; then
        do_clean "$file" "$destination_file"
    fi
done
