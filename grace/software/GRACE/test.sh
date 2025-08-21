#!/bin/bash

#module load pytorch
#module load singularity
#module load monai

# Check if cuda enabled
#python -c "import torch; print(torch.cuda.is_available())"
# singularity exec --nv /path/to/monai/container/monaicore081 python3 -c "import torch; print(torch.cuda.is_available())"
singularity exec --nv /home/ahmadkhana/Desktop/etiv-comparison/grace/singularity/pytorch_2.1.2-cuda11.8-cudnn8-runtime.sif python3 -c "import torch; print(torch.cuda.is_available())"

#run code
#python monai_test.py --num_gpu 2 --data_dir "/path/to/your/data/" --N_classes 12 --model_load_name "grace.pth" --dataparallel "True"

# singularity exec --nv --bind /path/to/working/directory:/mnt /path/to/monai/container/monaicore081 python3 /mnt/test.py --num_gpu 2 --data_dir '/mnt/data_folder/' --model_load_name "grace.pth" --N_classes 12 --dataparallel "True" --a_max_value 255 --spatial_size 64
singularity exec --nv --bind /home/ahmadkhana/Desktop/etiv-comparison/grace:/mnt /home/ahmadkhana/Desktop/etiv-comparison/grace/singularity/pytorch_2.1.2-cuda11.8-cudnn8-runtime.sif python3 /mnt/software/GRACE/test.py --num_gpu 1 --data_dir '/mnt/data/data_retest-oasis1/' --results_dir '/mnt/results/results_retest-oasis1/' --model_load_name "/mnt/software/pretrained_model/GRACE.pth" --N_classes 12 --dataparallel "False" --a_max_value 255 --spatial_size 64

#singularity version assumes that data_folder is in the working directory.