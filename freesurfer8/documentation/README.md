## Running Freesurfer

Freesurfer is run by running `./runPipeline.sh` on the HPC Clusters. It splits the data up automatically and runs the segmentation command. 

This command also uses the scanner information (the -3T and -cm flags) for each subject. This data is stored as a csv file in the data folder. The runPipeline script takes the dataset and the information about the scanner as input and creates a subject_data.txt file under log/.
