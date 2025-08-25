#!/bin/bash
### This script checks the failed cases after runPipeline.sh has finished and
### reruns the tool on only them
### --- CONFIGURATION ---
BASE="/groups/ag-reuter/projects/etiv-processing/freesurfer8"
DATASET="$BASE/data/nki-rs.csv"
SUBJECTS_PER_JOB=7
SUBJ_DATA="$BASE/log/subject_data.txt"
CHECKFILE="mri/aparc.DKTatlas+aseg.mgz"

JOB_SCRIPT="$BASE/config/slurm/slurmJob.sh"

echo "Generating subject data list at: $SUBJ_DATA"
> "$SUBJ_DATA"

{
    read
    while IFS=',' read -r f1 f2 f3 f4 f5 f6 f7 f8 f9 f10 f11 f12 f13 f14 f15 f16 f17 f18 f19 f20 f21 f22 f23 f24 f25 f26 f27 f28 f29 rest; do

        nii_file="$f12"
        sess=$(basename "$(dirname "$(dirname "$nii_file")")")
        subj=$(basename "$(dirname "$(dirname "$(dirname "$nii_file")")")")
        dataset=$(basename "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$nii_file")")")")")")")
        results_dataset=${dataset/data_/results_}
        file_dir="$BASE/results/$results_dataset/${subj}_${sess}"

        if [ ! -f "$file_dir/$CHECKFILE" ]; then
            output="$nii_file"

            if [ "$f24" = "3" ]; then
                output="$output,1"
            else
                output="$output,0"
            fi

            threshold=$(echo "0.9^3" | bc -l)

            f25=$(echo "$f25" | sed 's/[^0-9.]//g')
            f26=$(echo "$f26" | sed 's/[^0-9.]//g')
            f27=$(echo "$f27" | sed 's/[^0-9.]//g')
            volume=$(echo "$f25 * $f26 * $f27" | bc -l)
            is_less=$(echo "$volume < $threshold" | bc -l)

            if (( $(echo "$is_less == 1" | bc -l) )); then
                output="$output,1"
            else
                output="$output,0"
            fi
            echo "$output" >> "$SUBJ_DATA"

            rm -rf "$file_dir"
        fi

    done
}  < "$DATASET"

NUM_SUBJECTS=$(wc -l < "$SUBJ_DATA")
NUM_TASKS=$(( (NUM_SUBJECTS + SUBJECTS_PER_JOB - 1) / SUBJECTS_PER_JOB ))

echo "Found $NUM_SUBJECTS subjects."
echo "Each SLURM job will process $SUBJECTS_PER_JOB subjects."
echo "Submitting SLURM array job with: --array=0-$((NUM_TASKS - 1))"

sbatch --array=0-$((NUM_TASKS - 1)) "$JOB_SCRIPT"