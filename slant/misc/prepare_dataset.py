'''
This script prepares the datasets for running with this toolbox.
'''

import os
import subprocess

def convert_mgz_to_nifti(root_dir):
    for dirpath, dirnames, filenames in os.walk(root_dir):
        subject_name = os.path.basename(dirpath)
        if f'{subject_name}.nii' in filenames:
            mgz_path = os.path.join(dirpath, f'{subject_name}.nii.gz')
            output_path = os.path.join(dirpath,f"{subject_name}.nii")

            print(f"Converting {mgz_path} to {output_path}...")
            try:
                subprocess.run(['mri_convert', mgz_path, output_path], check=True)
                subprocess.run(['rm', mgz_path], check=True)
                print("Success.")
            except subprocess.CalledProcessError as e:
                print(f"Failed to convert {mgz_path}: {e}")

def removeDashes(root_dir):
    for dirpath, dirnames, filenames in os.walk(root_dir):
        subject_name = os.path.basename(dirpath)
        if f'{subject_name}.nii.gz' in filenames:
            new_subject_name = "_".join(subject_name.split("-"))
            print(f"Renaming {subject_name}...")
            try:
                os.rename(os.path.join(root_dir, subject_name), os.path.join(root_dir, new_subject_name))
                os.rename(os.path.join(root_dir, new_subject_name, subject_name + ".nii.gz"), os.path.join(root_dir, new_subject_name, new_subject_name + ".nii.gz"))
                print("Success.")
            except subprocess.CalledProcessError as e:
                print(f"Failed to rename: {e}")

def create_output_dir(root_dir):
    for dirpath, dirnames, filenames in os.walk(root_dir):
        subject_name = os.path.basename(dirpath)
        if f'{subject_name}.nii.gz' in filenames:
            result_path = os.path.join("/".join(root_dir.split("/")[:-2]), 'results','results' + root_dir.split("/")[-1][4:], subject_name)

            print(f"Making result dir {result_path}...")
            try:
                subprocess.run(['mkdir', '-p', result_path], check=True)
                subprocess.run(['mkdir', '-p', os.path.join(result_path, "pre")], check=True)
                subprocess.run(['mkdir', '-p', os.path.join(result_path, "post")], check=True)
                subprocess.run(['mkdir', '-p', os.path.join(result_path, "dl")], check=True)
                
                print("Success.")
            except subprocess.CalledProcessError as e:
                print(f"Failed to mkdir: {e}")


create_output_dir("/home/ahmadkhana/Desktop/etiv-comparison/slant/data/data_retest-rhineland-conformed")