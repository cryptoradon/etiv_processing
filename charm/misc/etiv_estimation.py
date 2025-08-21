import nibabel as nib
import numpy as np
import os
import csv

wmLabel = 1
gmLabel = 2
csfLabel = 3
bloodLabel = 9

def charmETIV(inputDir, inputFile, outputFile):
    with open(outputFile, 'w', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(["Subject", "White Matter Volume", "Gray Matter Volume", "CSF Volume", "Blood Volume", "eTIV"])
        
        for root, _, _ in os.walk(inputDir):
            full_path = os.path.join(root, inputFile)
            if os.path.exists(full_path):
                img = nib.load(full_path)
                data = img.get_fdata()
                voxelVolume = np.prod(img.header.get_zooms())

                wmVol = np.sum(data == wmLabel) * voxelVolume
                gmVol = np.sum(data == gmLabel) * voxelVolume
                csfVol = np.sum(data == csfLabel) * voxelVolume
                bloodVol = np.sum(data == bloodLabel) * voxelVolume
                tiv = wmVol + gmVol + csfVol + bloodVol

                subject_id = "/".join(root.strip(os.sep).split(os.sep)[-2:])

                subject_id = "/".join([subject_id.split(os.sep)[0], subject_id.split(os.sep)[1][4:]])

                writer.writerow([
                    subject_id,
                    f"{wmVol:.2f}",
                    f"{gmVol:.2f}",
                    f"{csfVol:.2f}",
                    f"{bloodVol:.2f}",
                    f"{tiv:.2f}"
                ])

                print(f"Subject {subject_id} done")

def charmETIVEveryn(subjectIDs, inputFiles, labelFiles, outputFile, labelOutputFile):
    with open(outputFile, 'w', newline='') as so, open(labelOutputFile, 'w', newline='') as lo:
        subjectWriter = csv.writer(so)
        subjectWriter.writerow(["Subject", "White Matter Volume", "Gray Matter Volume", "CSF Volume", "Blood Volume", "eTIV"])

        labelWriter = csv.writer(lo)
        labelWriter.writerow(["Subject", "eTIV"])
        for subjectID, inputFile, labelFile in zip(subjectIDs, inputFiles, labelFiles):
            if os.path.exists(inputFile):
                dataImg = nib.load(inputFile)
                inputData = dataImg.get_fdata()
                inputVoxelVolume = np.prod(dataImg.header.get_zooms())

                labelImg = nib.load(labelFile)
                labelData = labelImg.get_fdata()
                labelVoxelVolume = np.prod(labelImg.header.get_zooms())

                wmVol, gmVol, csfVol, bloodVol = 0, 0, 0, 0
                labelVol = 0
                for i, labelSlice in enumerate(labelData):
                    if np.any(labelSlice):
                        wmVol += np.sum(inputData[i] == wmLabel) * inputVoxelVolume
                        gmVol += np.sum(inputData[i] == gmLabel) * inputVoxelVolume
                        csfVol += np.sum(inputData[i] == csfLabel) * inputVoxelVolume
                        bloodVol += np.sum(inputData[i] == bloodLabel) * inputVoxelVolume

                        labelVol += np.sum(labelSlice > 0) * labelVoxelVolume

                tiv = wmVol + gmVol + csfVol + bloodVol

                subjectWriter.writerow([
                    subjectID,
                    f"{wmVol:.2f}",
                    f"{gmVol:.2f}",
                    f"{csfVol:.2f}",
                    f"{bloodVol:.2f}",
                    f"{tiv:.2f}"
                ])

                labelWriter.writerow([
                    subjectID,
                    f"{labelVol: .2f}"
                ])

                print(f"Subject {subjectID} done")

if __name__ == '__main__':
    # charmETIV(
    #     inputDir="/home/ahmadkhana/Desktop/etiv-comparison/charm/results",
    #     inputFile="final_tissues_MNI_to_subj.nii.gz",
    #     outputFile="/home/ahmadkhana/Desktop/etiv-comparison/charm/log/etiv_estimation.csv"
    # )

    ## To take manually labeled files as basis and computing the eTIV every n slices
    subjectIDs = ["HCP_133625", "adni_20329"]
    inputFiles = ["/home/ahmadkhana/Desktop/etiv-comparison/charm/results/results_vinn-labels/m2m_HCP_133625/final_tissues_MNI_to_subj.nii.gz", "/home/ahmadkhana/Desktop/etiv-comparison/charm/results/results_vinn-labels/m2m_adni_20329/final_tissues_MNI_to_subj.nii.gz"]
    labelFiles = ["/groups/ag-reuter/projects/etiv-evaluation/data/ground-truth/manual/HCP_133625/HCP_133625-etiv-cleaning.mgz", "/groups/ag-reuter/projects/etiv-evaluation/data/ground-truth/manual/adni_20329/adni_20329-etiv-cleaning.mgz"]

    charmETIVEveryn(
        subjectIDs=subjectIDs,
        inputFiles=inputFiles,
        labelFiles=labelFiles,
        outputFile="/home/ahmadkhana/Desktop/etiv-comparison/charm/log/etiv_estimation_every_n.csv",
        labelOutputFile="/home/ahmadkhana/Desktop/etiv-comparison/charm/log/etiv_estimation_ground_truth.csv"
    )
