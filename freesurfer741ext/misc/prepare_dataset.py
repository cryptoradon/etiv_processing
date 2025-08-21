import os
import csv

def create_subj_list(input_dir, output_file, config_file):
    config_data = {}
    with open(config_file) as c:
        reader = csv.reader(c)
        for i, line in enumerate(reader):
            subject_data = []
            if i in [0, 51, 52, 53, 54, 55, 72, 73]:
                continue
            
            subject_id = line[1].strip()
            strength = line[8].strip() == "3"
            cm = i >= 53
            config_data[subject_id] = {
                "strength": strength,
                "cm": cm
            }
            

    with open(output_file, 'w') as o:
        for dirpath, dirnames, filenames in os.walk(input_dir):
            for filename in filenames:
                subject_name = filename[:-7]
                if subject_name in dirpath:
                    o.write(os.path.join(dirpath, filenames[0]))
                    if subject_name.lower() in config_data:
                        o.write(f',{config_data[subject_name.lower()]["strength"]},{config_data[subject_name.lower()]["cm"]}')
                    o.write('\n')
                    


# create_subj_list("/home/ahmadkhana/Desktop/etiv-comparison/freesurfer741/data", "/home/ahmadkhana/Desktop/etiv-comparison/freesurfer741/data/slurm_output/subject_data.txt", "/groups/ag-reuter/projects/labeling/etiv/samples/etiv_sample.csv")