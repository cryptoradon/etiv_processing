#!/bin/bash -x 
#SBATCH --output /home/ahmadkhana/Desktop/etiv-comparison/grace/log/slurm_output/%j_out.out # saves output as (jobID)_out.out 
#SBATCH --error /home/ahmadkhana/Desktop/etiv-comparison/grace/log/slurm_output/%j_err.out # saves error as (jobID)_err.out 
#SBATCH --ntasks-per-node 1 
#SBATCH --cpus-per-task 4 
#SBATCH --gpus=2
#SBATCH --time 6:00:00 # change to the time you think your job will need. There is no upper limit. 
#SBATCH --gres gpu:2 # the number of GPUs you want to use 
#SBATCH --mem 300000 # the amount of memory (here in MB) your job requires. If you pick too little your job will get stuck and die. 
#SBATCH --partition HPC-4GPUs # which of the partitions you want to use, see details below. Please only use the ones with 8 GPUs if you actually use them all. 

module load singularity 

export CUDA_VISIBLE_DEVICES=0,1 # the GPUs to make available to python. Add numbers 4-7 in case of using 8GPUs. 

BASE="/home/ahmadkhana/Desktop/etiv-comparison/grace"

DATASETS=("data_retest-rhineland")

for DATASET in "${DATASETS[@]}"
do
    echo "Processing dataset: $DATASET"

    results_dataset=${DATASET/data_/results_}
    OUTPUT_DIR="$BASE/results/$results_dataset"
    
    singularity exec --nv \
        --bind "$BASE:/mnt" \
        --bind /groups/ag-reuter/projects/etiv-processing \
        "$BASE/singularity/pytorch_2.0.1-cuda11.7-cudnn8-runtime.sif" \
        python3 /mnt/software/GRACE/test.py \
        --num_gpu 2 \
        --data_dir "/mnt/data/$DATASET/" \
        --results_dir "$OUTPUT_DIR" \
        --model_load_name "/mnt/software/pretrained_model/GRACE.pth" \
        --N_classes 12 \
        --dataparallel "False" \
        --a_max_value 255 \
        --spatial_size 64

    echo "Finished: $DATASET"
    echo "--------------------------------------"
done
