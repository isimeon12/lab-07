#!/bin/bash
# Part 2: Check the output WITHOUT changing any files.

all_pass=1

for number in 1 2 3 4; do
    folder="Testcase${number}"
    diff_folder="Testcase${number}Diff"
    result="PASS"
    any_different=0

    for first in "$folder"/*.1.txt; do
        [ -f "$first" ] || continue

        second="${first%.1.txt}.2.txt"
        filename="${first##*/}"
        version="${filename%.1.txt}"
        output="$diff_folder/${version}Diff.txt"

        if [ ! -f "$second" ]; then
            result="FAIL"
        elif cmp -s -- "$first" "$second"; then
            # Identical pairs must NOT have an output file.
            if [ -e "$output" ]; then
                result="FAIL"
            fi
        else
            any_different=1
            # Different pairs MUST have a correct output file.
            if [ ! -f "$output" ]; then
                result="FAIL"
            elif ! diff -q -- <(diff -u -- "$first" "$second" | tail -n +3) \
                               <(tail -n +3 "$output") > /dev/null; then
                result="FAIL"
            fi
        fi
    done

    # The Diff directory must exist if and only if differences exist.
    if [ "$any_different" -eq 1 ]; then
        if [ ! -d "$diff_folder" ]; then
            result="FAIL"
        fi
    elif [ -e "$diff_folder" ]; then
        result="FAIL"
    fi

    # Reject extra files (or subdirectories) that shouldn't be there.
    if [ -d "$diff_folder" ]; then
        for output in "$diff_folder"/*; do
            [ -e "$output" ] || continue
            filename="${output##*/}"

            if [[ "$filename" != *Diff.txt ]] || [ ! -f "$output" ]; then
                result="FAIL"
                continue
            fi

            version="${filename%Diff.txt}"
            first="$folder/${version}.1.txt"
            second="$folder/${version}.2.txt"

            if [ ! -f "$first" ] || [ ! -f "$second" ]; then
                result="FAIL"
            elif cmp -s -- "$first" "$second"; then
                result="FAIL"
            fi
        done
    fi

    echo "Testcase${number}: $result"
    if [ "$result" = "FAIL" ]; then
        all_pass=0
    fi
done

if [ "$all_pass" -eq 1 ]; then
    exit 0
else
    exit 1
fi
