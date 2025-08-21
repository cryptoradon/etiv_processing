'''
This script prepares the datasets for running with this toolbox.
'''

import os
import subprocess

def convert_mgz_to_nifti(root_dir):
    for dirpath, dirnames, filenames in os.walk(root_dir):
        if '001.mgz' in filenames:
            mgz_path = os.path.join(dirpath, '001.mgz')
            subject_name = os.path.basename(dirpath)
            output_path = os.path.join(root_dir,f"{subject_name}.nii")

            print(f"Converting {mgz_path} to {output_path}...")
            try:
                subprocess.run(['mri_convert', mgz_path, output_path], check=True)
                print("Success.")
            except subprocess.CalledProcessError as e:
                print(f"Failed to convert {mgz_path}: {e}")

def move_to_parent(root_dir, filename):
    for dirpath, dirnames, filenames in os.walk(root_dir):
        if filename in filenames:
            base_path = os.path.join(dirpath, filename)
            subject_name = os.path.basename(dirpath)
            result_path = os.path.join(root_dir,f"{subject_name}.nii.gz")

            print(f"Moving to parent folder...")
            try:
                subprocess.run(['mv', base_path, result_path], check=True)
                subprocess.run(['rm','-r', dirpath], check=True)
                print("Success.")
            except subprocess.CalledProcessError as e:
                print(f"Failed to move: {e}")

def unzip(root_dir):
    for filename in os.listdir(root_dir):
        if filename.split(".")[-1] == "gz":
            print(f"Unzipping...")
            try:
                subprocess.run(['gzip', '-d', os.path.join(root_dir, filename), ], check=True)
                print("Success.")
            except subprocess.CalledProcessError as e:
                print(f"Failed to unzip: {e}")

# move_to_parent(root_dir="/home/ahmadkhana/Desktop/etiv-comparison/grace/data/data_retest-rhineland-conformed/imagesTs", filename="conformed.nii.gz")
unzip(root_dir="/home/ahmadkhana/Desktop/etiv-comparison/grace/data/data_retest-rhineland-conformed/imagesTs")