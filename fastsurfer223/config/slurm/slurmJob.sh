#!/bin/bash

#SBATCH --output /groups/ag-reuter/projects/etiv-processing/fastsurfer223/log/slurm_output/%A_%a.out # saves output as (jobID)_out.out 
#SBATCH --error /groups/ag-reuter/projects/etiv-processing/fastsurfer223/log/slurm_output/%A_%a.err # saves error as (jobID)_err.out 
#SBATCH --ntasks=7
#SBATCH --cpus-per-task 10
#SBATCH --time=2-23:55:00
#SBATCH --mem=768000
#SBATCH --partition=HPC-CPUs
#SBATCH --job-name=fastsurfer223

module load singularity

BASE="/groups/ag-reuter/projects/etiv-processing/fastsurfer223"
IMG="$BASE/singularity/fastsurfer-gpu.sif"
DATA="$BASE/log/subject_data.txt"
SUBJECTS_PER_JOB=7

# --- Process chunk of subjects ---
if [ ! -f "$DATA" ]; then
    echo "Subject data not found: $DATA"
    exit 1
fi

START_INDEX=$((SLURM_ARRAY_TASK_ID * SUBJECTS_PER_JOB))
END_INDEX=$((START_INDEX + SUBJECTS_PER_JOB - 1))

echo "Processing subjects $START_INDEX to $END_INDEX (SLURM_ARRAY_TASK_ID=$SLURM_ARRAY_TASK_ID)"

for subj_i in $(seq 0 $((SUBJECTS_PER_JOB - 1))); do
    subj_index=$((START_INDEX + subj_i))

    line=$(sed -n "$((subj_index + 1))p" "$DATA")
    nii_file=$(echo "$line" | cut -d',' -f1 | sed 's/^"//' | sed 's/"$//')

    [ -z "$nii_file" ] && echo "Reached end of subject list." && continue

    sess=$(basename "$(dirname "$(dirname "$nii_file")")")
    subj=$(basename "$(dirname "$(dirname "$(dirname "$nii_file")")")")
    dataset=$(basename "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$nii_file")")")")")")")
    results_dataset=${dataset/data_/results_}
    OUTPUT_DIR="$BASE/results/$results_dataset"

    if [ -f "$nii_file" ]; then
        echo "Running on $subj (job $subj_i)" 
        singularity exec --nv \
        --bind /groups/ag-reuter/projects/datasets \
        --bind /groups/ag-reuter/projects/etiv-processing \
            $IMG \
            /bin/bash -c "
                /fastsurfer/run_fastsurfer.sh \
                    --t1 \"$nii_file\" \
                    --sid \"${subj}_${sess}\" \
                    --sd \"$OUTPUT_DIR\" \
                    --seg_only --no_biasfield --no_cereb --no_hypothal --tal_reg
            " &
    else
        echo "No NIfTI file found at $nii_file"
    fi
done

wait