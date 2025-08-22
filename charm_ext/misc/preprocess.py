import os
import re
import subprocess

data_folder = "/groups/ag-reuter/projects/etiv-processing/charm_ext/data/data_vinn-pruned"

for dirpath, _, filenames in os.walk(data_folder):
    for filename in filenames:
        if re.fullmatch(r".*mgz", filename):

            new_filename = ".".join([*filename.split(".")[:-1], "nii", "gz"])
            result = subprocess.run(["mri_convert", os.path.join(dirpath, filename), os.path.join(dirpath, new_filename)], capture_output=True, text=True)

            if result.stdout:
                print(f"{dirpath} mri_convert STDOUT:\n", result.stdout)
            if result.stderr:
                print(f"{dirpath} mri_convert STDERR:\n", result.stderr)

            result = subprocess.run(["rm", os.path.join(dirpath, filename)], capture_output=True, text=True)

            if result.stdout:
                print(f"{dirpath} rm STDOUT:\n", result.stdout)
            if result.stderr:
                print(f"{dirpath} rm STDERR:\n", result.stderr)

