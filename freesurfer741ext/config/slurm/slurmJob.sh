#!/bin/bash

#SBATCH --output /groups/ag-reuter/projects/etiv-processing/freesurfer741ext/log/slurm_output/%A_%a.out # saves output as (jobID)_out.out 
#SBATCH --error /groups/ag-reuter/projects/etiv-processing/freesurfer741ext/log/slurm_output/%A_%a.err # saves error as (jobID)_err.out 
#SBATCH --ntasks=7
#SBATCH --cpus-per-task 10
#SBATCH --time=2-23:55:00
#SBATCH --mem=768000
#SBATCH --partition=HPC-CPUs
#SBATCH --job-name=freesurfer741ext

module load singularity

BASE="/groups/ag-reuter/projects/etiv-processing/freesurfer741ext"
IMG="$BASE/singularity/diersk_freesurfer_741.sif"
DATA="$BASE/log/subject_data.txt"
SUBJECTS_PER_JOB=7
CPUS_PER_SUBJECT=10

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
    echo "Running on output dir $OUTPUT_DIR"

    if [ -f "$nii_file" ]; then
        echo "Running on $subj $sess (job $subj_i)"
        subj=${subj}_${sess}
        export SUBJECTS_DIR=$OUTPUT_DIR
        export FREESURFER_HOME=/groups/ag-reuter/software-centos/fs741
        source $FREESURFER_HOME/SetUpFreeSurfer.sh
        segmentHA_T1.sh "$subj" &
        segment_subregions thalamus --cross "$subj" &
        mri_sclimbic_seg \
            --i "$nii_file" \
            --o "$SUBJECTS_DIR/$subj/${subj}.sclimbic.mgz" \
            --conform &
        # singularity exec --nv -e \
        # --bind /groups/ag-reuter/projects/datasets \
        # --bind /groups/ag-reuter/projects/etiv-processing \
        # -B $OUTPUT_DIR:/mnt \
        # $IMG \
        # /bin/bash -c "
        #     source /opt/fs741/SetUpFreeSurfer.sh && \
        #     export SUBJECTS_DIR=/mnt && \
        #     segmentHA_T1.sh $subj \
        #     segment_subregions thalamus --cross $subj && \
        #     mri_sclimbic_seg \
        #         --i \"$nii_file\" \
        #         --o \"/mnt/$subj/$subj.sclimbic.mgz\" \
        #         --conform
        # " &
    else
        echo "No NIfTI file found at $nii_file"
    fi
done

wait