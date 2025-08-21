import csv
import os
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec

def calculateETIV(input_folder, target_filename, output_file):
    output_header = ["SubjectID", "eTIV"]

    with open(output_file, mode='w', newline='') as csv_f:
        writer = csv.writer(csv_f)
        writer.writerow(output_header)
        for dirpath, _, filenames in os.walk(input_folder):
            if target_filename in filenames:
                with open(os.path.join(dirpath, target_filename)) as f:
                    for line in f:
                        if "EstimatedTotalIntraCranialVol" in line:
                            lineParts = line.split(",")
                            eTIV = float(lineParts[-2]) 

                            if eTIV > 0:
                                subj_id = "/".join(dirpath.strip(os.sep).split(os.sep)[-3:-1])
                                writer.writerow([subj_id, f"{eTIV:.2f}"])
                                print(f"{subj_id} done")
                            
                            break

if __name__ == '__main__':
    input_folder = "/home/ahmadkhana/Desktop/etiv-comparison/freesurfer741/results"
    target_filename = "aseg.stats"
    output_file = "/home/ahmadkhana/Desktop/etiv-comparison/freesurfer741/log/etiv_estimation.csv"

    calculateETIV(input_folder, target_filename, output_file)

