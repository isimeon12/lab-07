#!/bin/bash
# Part 1: Create Diff files for file pairs that are different.

for number in 1 2 3 4; do
    folder="Testcase${number}"
    diff_folder="Testcase${number}Diff"

    # Delete previous output so repeated runs give the same result.
    rm -rf -- "$diff_folder"

    for first in "$folder"/*.1.txt; do
        [ -f "$first" ] || continue

        second="${first%.1.txt}.2.txt"
        filename="${first##*/}"
        version="${filename%.1.txt}"
        output="$diff_folder/${version}Diff.txt"

        # Only make an output file when the pair differs.
        if ! cmp -s -- "$first" "$second"; then
            mkdir -p -- "$diff_folder"
            diff -u -- "$first" "$second" > "$output"
        fi
    done
done

exit 0
