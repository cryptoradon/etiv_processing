'''
This script prepares the datasets for running with this toolbox.
'''

import os
import subprocess

def convert_mgz_to_nifti(root_dir):
    for dirpath, dirnames, filenames in os.walk(root_dir):
        if 'orig.mgz' in filenames:
            mgz_path = os.path.join(dirpath, 'orig.mgz')
            subject_name = os.path.basename(dirpath)
            output_path = os.path.join(dirpath,f"{subject_name}.nii")

            print(f"Converting {mgz_path} to {output_path}...")
            try:
                subprocess.run(['mri_convert', mgz_path, output_path], check=True)
                subprocess.run(['rm', mgz_path], check=True)
                print("Success.")
            except subprocess.CalledProcessError as e:
                print(f"Failed to convert {mgz_path}: {e}")

def zipAll(root_dir):
    for dirpath, dirnames, filenames in os.walk(root_dir):
        subject_name = os.path.basename(dirpath)
        if f'{subject_name}.nii' in filenames:
            file_path = os.path.join(dirpath,f"{subject_name}.nii")

            print(f"Zipping...")
            try:
                subprocess.run(['gzip', file_path, ], check=True)
                print("Success.")
            except subprocess.CalledProcessError as e:
                print(f"Failed to zip: {e}")

def deleteConformed(root_dir):
    for dirpath, dirnames, filenames in os.walk(root_dir):
        subject_name = os.path.basename(dirpath)
        if f'T1_RMS.nii.gz' in filenames:
            conformed_path = os.path.join(dirpath,"conformed.nii.gz")

            print(f"Deleting {conformed_path}...")
            try:
                subprocess.run(['rm', conformed_path, ], check=True)
                print("Success.")
            except subprocess.CalledProcessError as e:
                print(f"Failed to delete: {e}")
    
def rename(root_dir, filename):
    for dirpath, dirnames, filenames in os.walk(root_dir):
        subject_name = os.path.basename(dirpath)
        if filename in filenames:
            conformed_path = os.path.join(dirpath, filename)            
            result_path = os.path.join(dirpath, f"{subject_name}.nii.gz")

            print(f"Renaming {conformed_path} to {result_path}...")
            try:
                subprocess.run(['mv', conformed_path, result_path], check=True)
                print("Success.")
            except subprocess.CalledProcessError as e:
                print(f"Failed to rename: {e}")

def makeResultsDir(root_dir):
    for dirpath, dirnames, filenames in os.walk(root_dir):
        subject_name = os.path.basename(dirpath)
        if f'{subject_name}.nii.gz' in filenames:
            result_path = os.path.join("/".join(root_dir.split("/")[:-2]), 'results', 'results' + root_dir.split("/")[-1][4:], subject_name)

            print(f"Making result dir {result_path}...")
            try:
                subprocess.run(['mkdir', '-p', result_path], check=True)
                print("Success.")
            except subprocess.CalledProcessError as e:
                print(f"Failed to mkdir: {e}")

#rename("/home/ahmadkhana/Desktop/etiv-comparison/icvmapp3r/data/data_retest-rhineland-conformed", "conformed.nii.gz")
makeResultsDir("/home/ahmadkhana/Desktop/etiv-comparison/icvmapp3r/data/data_retest-rhineland-conformed")
