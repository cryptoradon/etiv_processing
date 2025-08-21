# Read csv-file into array
mapfile -t input < $1
SLURM_ARRAY_TASK_ID=0

# get sid from csv
a=(${input[SLURM_ARRAY_TASK_ID]})

# settings
PROJECT_DIR=/groups/ag-reuter/projects/fastsurfer-tests/test-cases/20250502
DATA_SUBDIR=data
OUTPUT_SUBDIR=output

# Display info
echo "Command file: $1"
echo "Job Id: $SLURM_JOB_ID"
echo "Task Id: $SLURM_ARRAY_TASK_ID of $SLURM_ARRAY_TASK_COUNT"
echo ${a[*]}

id=`echo ${a[0]} | sed "s/,.*//"`
flag_3t=`echo ${a[0]} | sed "s/.*,\(.*\),.*/\1/"`
flag_cm=`echo ${a[0]} | sed "s/.*,//"`

# source freesurfer
#export FREESURFER_HOME=/groups/ag-reuter/software-centos/fs80
#source /groups/ag-reuter/software-centos/fs80/SetUpFreeSurfer.sh

# Create cmd
#cmd="recon-all -i ${PROJECT_DIR}/${DATA_SUBDIR}/${id}/001.mgz -all -subjid ${id} -sd ${PROJECT_DIR}/${OUTPUT_SUBDIR} ${flag_3t} ${flag_cm}"
#cmd="singularity exec --no-mount home,cwd -e -B ${PROJECT_DIR}:/data ${PROJECT_DIR}/singularity/diersk_freesurfer_80.sif /opt/fs80/recon-all -i /data/${DATA_SUBDIR}/${id}/001.mgz -all -subjid ${id} -sd /data/${OUTPUT_SUBDIR} ${flag_3t} ${flag_cm}"

# Display cmd
#echo $cmd

# Create directory
#mkdir -p ${PROJECT_DIR}/${OUTPUT_SUBDIR}/${id}

# Run freesurfer from the input directory
#cd ${PROJECT_DIR}/${OUTPUT_SUBDIR}/${id}

# Display time
echo "Started at "`date`

# Run cmd
#echo $cmd > ${PROJECT_DIR}/${OUTPUT_SUBDIR}/${id}_fs8.log 2>&1

# singularity exec --no-mount home,cwd -e -B ${PROJECT_DIR}:/data ${PROJECT_DIR}/singularity/diersk_freesurfer_80.sif /bin/bash -c "source /opt/fs80/SetUpFreeSurfer.sh && /opt/fs80/bin/recon-all -i /data/${DATA_SUBDIR}/${id}/001.mgz -all -subjid ${id} -sd /data/${OUTPUT_SUBDIR} ${flag_3t} ${flag_cm}" > ${PROJECT_DIR}/${OUTPUT_SUBDIR}/${id}_fs8.log 2>&1
singularity exec --nv -e /home/ahmadkhana/Desktop/etiv-comparison/freesurfer8/singularity/diersk_freesurfer_80.sif /bin/bash -c "source /opt/fs80/SetUpFreeSurfer.sh && /opt/fs80/bin/recon-all -i /home/ahmadkhana/Desktop/etiv-comparison/freesurfer8/data/data_retest-oasis1/OAS1_0061_MR1/OAS1_0061_MR1.nii.gz -parallel -openmp 8 -all -subjid OAS1_0061_MR1 -sd /home/ahmadkhana/Desktop/etiv-comparison/freesurfer8/results/ -3T -cm"

# Display time
echo "Finished at "`date`

