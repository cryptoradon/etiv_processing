## Running Freesurfer

Freesurfer is run by running `./runPipeline.sh` on the HPC Clusters. It splits the data up automatically and runs the segmentation command. 

This command also uses the scanner information (the -3T and -cm flags) for each subject. To run the runPipeline script, it requires this data in the .csv format stored in the data folder. It automatically extracts these details from the csv file, stores them in log/subject_data.txt and uses it to run freesurfer on the data.

## Steps to calculate eTIV

misc/etiv_estimation.py is run to calculate the eTIV volume for the data. The result is stored in log/etiv_estimation.csv.