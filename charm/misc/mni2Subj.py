import os
import subprocess
from concurrent.futures import ProcessPoolExecutor, as_completed

def run_mni2subject(fullPath, subjectResultFolder, outputFileName):
    try:
        subprocess.run([
            "mni2subject",
            "-i", fullPath,
            "-m", subjectResultFolder,
            "-o", os.path.join(subjectResultFolder, outputFileName),
            "--interpolation_order", "0"
        ], shell=False, check=True)
        print(f"Completed: {fullPath}")
    except subprocess.CalledProcessError as e:
        print(f"Failed: {fullPath}\n{e}")

def collect_tasks(inputDir, targetFileName):
    tasks = []
    for root, _, _ in os.walk(inputDir):
        fullPath = os.path.join(root, targetFileName)
        if os.path.exists(fullPath):
            subjectResultFolder = os.path.dirname(root)
            tasks.append((fullPath, subjectResultFolder, "final_tissues_MNI_to_subj.nii.gz"))
    return tasks

if __name__ == '__main__':
    resultsDir = "/home/ahmadkhana/Desktop/etiv-comparison/charm/results"
    os.chdir(resultsDir)

    targetFileName = "final_tissues_MNI.nii.gz"
    tasks = collect_tasks(resultsDir, targetFileName)

    print(f"Launching {len(tasks)} parallel jobs...")
    with ProcessPoolExecutor() as executor:
        futures = [executor.submit(run_mni2subject, *task) for task in tasks]
        for f in as_completed(futures):
            _ = f.result()
