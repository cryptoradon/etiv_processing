#!/bin/bash -x 

#SBATCH --output /home/ahmadkhana/Desktop/etiv-processing/charm_ext/log/slurm_output/%A_%a.out # saves output as (jobID)_out.out 
#SBATCH --error /home/ahmadkhana/Desktop/etiv-processing/charm_ext/log/slurm_output/%A_%a.err # saves error as (jobID)_err.out 
#SBATCH --ntasks=7
#SBATCH --cpus-per-task 10
#SBATCH --time 2-23:55:00 # change to the time you think your job will need. There is no upper limit. 
#SBATCH --mem 768000 # the amount of memory (here in MB) your job requires. If you pick too little your job will get stuck and die. 
#SBATCH --partition HPC-CPUs # which of the partitions you want to use, see details below. Please only use the ones with 8 GPUs if you actually use them all. 
#SBATCH --array=0-99  # Adjust based on number of subjects

module load singularity

BASE="/home/ahmadkhana/Desktop/etiv-processing/charm_ext"
LIST="$BASE/log/subject_list.txt"
SUBJECTS_PER_JOB=7

# --- Process chunk of subjects ---
if [ ! -f "$LIST" ]; then
    echo "Subject list not found: $LIST"
    exit 1
fi

START_INDEX=$((SLURM_ARRAY_TASK_ID * SUBJECTS_PER_JOB))
END_INDEX=$((START_INDEX + SUBJECTS_PER_JOB - 1))

echo "Processing subjects $START_INDEX to $END_INDEX (SLURM_ARRAY_TASK_ID=$SLURM_ARRAY_TASK_ID)"

for subj_i in $(seq 0 $((SUBJECTS_PER_JOB - 1))); do
    subj_index=$((START_INDEX + subj_i))
    nii_file=$(sed -n "$((subj_index + 1))p" "$LIST")

    [ -z "$nii_file" ] && echo "Reached end of subject list." && continue

    subj=$(basename "$(dirname "$(dirname "$nii_file")")")
    subdataset=$(basename "$(dirname "$(dirname "$(dirname "$nii_file")")")")
    dataset=$(basename "$(dirname "$(dirname "$(dirname "$(dirname "$nii_file")")")")")
    results_dataset=${dataset/data_/results_}
    OUTPUT_DIR="$BASE/results/$results_dataset/$subdataset"

    if [ -f "$nii_file" ]; then
        echo "Running on $subj (job $subj_i)"
        mkdir "$OUTPUT_DIR"
        cd "$OUTPUT_DIR"
        /home/ahmadkhana/SimNIBS-4.5/bin/charm $subj $nii_file --usesettings "$BASE/software/MRI_Custom_Settings/settings_fat.ini" --noneck --forcesform --forcerun
    else
        echo "No NIfTI file found in $nii_file"
    fi
done

wait