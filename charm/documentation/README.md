## Running Charm

Charm is run by running `./runPipeline.sh` on the HPC Clusters. It splits the data up automatically and runs the charm segmentation command. 

## Steps to calculate eTIV

After the initial command is run the mni2Subj.py file in misc/ is run to convert the MNI files (that already have the neck removed) to the subject space, allowing for a better etiv estimation.

To compute the eTIV volume the eTIV_estimation.py file is run. The output is in the log directory.

There is also an option in the eTIV_estimation.py code to take a manually labeled file as basis and calculating the eTIV volume from the ground truth slices and charm segmentation only for the labeled slices. The output is again written to the log/ folder.