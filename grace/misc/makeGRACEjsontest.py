import os
import json
import glob

# Description and metadata
description = 'AISEG V5 - Code Validation'
labels = {
    'xO': 'background',
    'x1': 'wm',
    'x2': 'gm',
    'x3': 'eyes',
    'x4': 'csf',
    'x5': 'air',
    'x6': 'blood',
    'x7': 'cancellous',
    'x8': 'cortical',
    'x9': 'skin',
    'x10': 'fat',
    'x11': 'muscle'
}
license = 'UF'
modality = {'x0': 'T1'}

data_folder = "/home/ahmadkhana/Desktop/etiv-comparison/grace/data/data_retest-rhineland-conformed"

# Count test and training images
numTest = len(glob.glob(os.path.join(data_folder, 'imagesTs', '*.nii')))
numTraining = len(glob.glob(os.path.join(data_folder, 'imagesTr', '*.nii')))

# Collect test file paths
test_files = sorted(glob.glob(os.path.join(data_folder, 'imagesTs', '*.nii')))
test = ['/'.join(path.split('/')[-2:]) for path in test_files]

# Collect training image and label paths
train_images = sorted(glob.glob(os.path.join(data_folder, 'imagesTr', '*.nii')))
train_labels = sorted(glob.glob(os.path.join(data_folder, 'labelsTr', '*.nii')))

T = len(train_images)
Te = round(T * 0.10)

traindir_fin = train_images[:T-Te-1]
validdir_fin = train_images[T-Te:]
traindir_label_fin = train_labels[:T-Te-1]
validdir_label_fin = train_labels[T-Te:]

# Build training and validation sets
training = [{'image': img, 'label': lbl} for img, lbl in zip(traindir_fin, traindir_label_fin)]
validation = [{'image': img, 'label': lbl} for img, lbl in zip(validdir_fin, validdir_label_fin)]

# Full structure
s = {
    'description': description,
    'labels': labels,
    'license': license,
    'modality': modality,
    'name': 'ACT',
    'numTest': numTest,
    'numTraining': numTraining,
    'reference': 'NA',
    'release': 'NA',
    'tensorImageSize': '3D',
    'test': test,
    'training': training,
    'validation': validation
}

# Save to JSON
with open(os.path.join(data_folder, 'dataset_1.json'), 'w') as f:
    json.dump(s, f, indent=4)
