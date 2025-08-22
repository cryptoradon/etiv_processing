#!/bin/bash

### --- CONFIGURATION ---
BASE="/groups/ag-reuter/projects/etiv-processing/charm_ext"
DATASETS=("data_vinn-pruned")
SUBJECTS_PER_JOB=7
LIST="$BASE/log/subject_list.txt"
JOB_SCRIPT="$BASE/config/slurm/slurmJob.sh"

echo "Generating subject list at: $LIST"
> "$LIST"

for dataset in "${DATASETS[@]}"; do
    DATASET_DIR="$BASE/data/$dataset"
    if [ -d "$DATASET_DIR" ]; then
        echo "Scanning dataset: $dataset"
        find "$DATASET_DIR" -mindepth 2 -type f -name "orig.nii.gz" | while read nii_file; do
            echo "$nii_file" >> "$LIST"
        done
    else
        echo "!! Dataset not found: $DATASET_DIR"
    fi
done

NUM_SUBJECTS=$(wc -l < "$LIST")
NUM_TASKS=$(( (NUM_SUBJECTS + SUBJECTS_PER_JOB - 1) / SUBJECTS_PER_JOB ))

echo "Found $NUM_SUBJECTS subjects."
echo "Each SLURM job will process $SUBJECTS_PER_JOB subjects."
echo "Submitting SLURM array job with: --array=0-$((NUM_TASKS - 1))"

sbatch --array=0-$((NUM_TASKS - 1)) "$JOB_SCRIPT"