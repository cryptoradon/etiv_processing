## 1. Overview
- **Toolbox Name**: SLANT-TICV (Non-skull stripped)
- **Version**: v1.2
- **Github**: https://github.com/MASILab/SLANTbrainSeg_TICV/tree/master
- **Pretrained Model**: https://zenodo.org/records/14618566
- **Paper**: https://doi.org/10.5281/zenodo.14618566
- **Reference**: Liu, Y., Kim, M., & Huo, Y. (2025). SLANT-TICV (Non-skull stripped): Generalizing deep learning brain segmentation for skull removal and intracranial measurements. In Magnetic Resonance Imaging (1.2, Vol. 88, Number 1, pp. 44–52). Zenodo.
- **Purpose**: U-Net tiles to achieve automatic TICV estimation and whole brain segmentation simultaneously on brains w/and w/o the skull. 

---

## 2. Expected Performance

- **Qualitative Analysis**:

![Qualitative TICV](/documentation/Screenshot%20from%202025-04-09%2010-17-24.png)
- **Segmentation**: 

![TICV Segmentation Comparison](/documentation/Screenshot%20from%202025-04-09%2010-16-48.png) 
- **Metrics**: 
    - Dice:

    ![Dice](/documentation/Screenshot%20from%202025-04-09%2010-20-28.png)

---

## 3. Installation & Setup
Note: There is a prepare_dataset.py file with helper functions you can use to clean your data.
1. Create an empty file in the software folder and make it executable: 
```bash
touch software/empty.sh
chmod +x software/empty.sh
```
2. Create an empty `software/tmp` folder in the software directory.
3. Create the inputs and outputs directories for each case study: `mkdir -p </path/to/output/dir>/{pre,post,dl} </path/to/input/dir>`.

    Note: Please do not include any `-` in the name of the folders and files.

4. Place the compressed `.nii.gz` T1 image into the input folder.
5. Download the image from here `https://zenodo.org/records/14618566`.
6. Run the following command:
```bash
singularity exec -e --nv --contain -B </path/to/input/dir>:/opt/slant/matlab/input_pre \
-B </path/to/input/dir>:/opt/slant/matlab/input_post \
-B </path/to/output/dir>/pre:/opt/slant/matlab/output_pre \
-B </path/to/output/dir>/post:/opt/slant/matlab/output_post \
-B </path/to/output/dir>/dl:/opt/slant/dl/working_dir \
-B </path/to/temp/directory>:/tmp --home </path/to/input/dir> -B </path/to/empty.sh>/empty.sh:</path/to/input/dir>/.bashrc <singularity_path> /opt/slant/run.sh
```