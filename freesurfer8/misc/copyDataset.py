import csv
import os
import shutil

input_file = "/home/ahmadkhana/Desktop/etiv-comparison/freesurfer8/data/vinn_pruned.csv"

with open(input_file, newline='') as f_in:
    reader = csv.reader(f_in)

    for i, row in enumerate(reader):
        original_path = row[18]
        if not os.path.isfile(original_path):
            print(f"Skipping (not a file): {original_path}")
            continue

        sub_path = original_path.split("/")
        
        i = sub_path.index("fs711_hires")

        new_path = os.path.join("/home/ahmadkhana/Desktop/etiv-comparison/freesurfer8/data/", *sub_path[(i + 1):])        

        new_dir = os.path.dirname(new_path)
        os.makedirs(new_dir, exist_ok=True)

        shutil.copy2(original_path, new_path)

        print(f"Copied {original_path} to {new_path}")


