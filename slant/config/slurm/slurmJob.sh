#!/bin/bash -x 

#SBATCH --output /home/ahmadkhana/Desktop/etiv-comparison/slant/log/slurm_output/%A_%a_.out # saves output as (jobID).out 
#SBATCH --error /home/ahmadkhana/Desktop/etiv-comparison/slant/log/slurm_output/%A_%a_.err # saves error as (jobID).err 
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --time=6:00:00 # change to the time you think your job will need. There is no upper limit. 
#SBATCH --mem=120000 # the amount of memory (here in MB) your job requires. If you pick too little your job will get stuck and die. 
#SBATCH --partition=HPC-8GPUs # which of the partitions you want to use, see details below. Please only use the ones with 8 GPUs if you actually use them all. 
#SBATCH --array=0-99  # Adjust based on number of subjects
#SBATCH --gres=gpu:8

module load singularity 

export PYTORCH_CUDA_ALLOC_CONF=max_split_size_mb:64

BASE="/home/ahmadkhana/Desktop/etiv-comparison/slant"
IMG="$BASE/singularity/nssSLANT_v1.2.simg"
LIST="$BASE/log/subject_list.txt"
SUBJECTS_PER_JOB=8

# --- Process chunk of subjects ---
if [ ! -f "$LIST" ]; then
    echo "Subject list not found: $LIST"
    exit 1
fi

START_INDEX=$((SLURM_ARRAY_TASK_ID * SUBJECTS_PER_JOB))
END_INDEX=$((START_INDEX + SUBJECTS_PER_JOB - 1))

echo "Processing subjects $START_INDEX to $END_INDEX (SLURM_ARRAY_TASK_ID=$SLURM_ARRAY_TASK_ID)"

for gpu_id in $(seq 0 7); do
    subj_index=$((START_INDEX + gpu_id))
    nii_file=$(sed -n "$((subj_index + 1))p" "$LIST")
    subj_dir=$(dirname "$nii_file")

    [ -z "$nii_file" ] && echo "Reached end of subject list for GPU $gpu_id." && continue

    subj=$(basename "$subj_dir")
    dataset=$(basename "$(dirname "$subj_dir")")
    results_dataset=${dataset/data_/results_}
    OUTPUT_DIR="$BASE/results/$results_dataset"
    nii_file=$(find "$subj_dir" -name "*.nii.gz" | head -n 1)

    if [ -f "$nii_file" ]; then
        echo "GPU $gpu_id running on $subj"
        CUDA_VISIBLE_DEVICES=$gpu_id \
        singularity exec -e --nv --contain \
        --env CUDA_VISIBLE_DEVICES=$gpu_id \
        -B "$subj_dir":/opt/slant/matlab/input_pre \
        -B "$subj_dir":/opt/slant/matlab/input_post \
        -B "$OUTPUT_DIR/$subj"/pre:/opt/slant/matlab/output_pre \
        -B "$OUTPUT_DIR/$subj"/post:/opt/slant/matlab/output_post \
        -B "$OUTPUT_DIR/$subj"/dl:/opt/slant/dl/working_dir \
        -B "$BASE"/software/tmp:/tmp --home "$subj_dir" -B "$BASE"/software/empty.sh:"$subj_dir"/.bashrc "$IMG" /opt/slant/run.sh &

    else
        echo "No NIfTI file found for $subj_dir on GPU $gpu_id"
    fi
done

wait
