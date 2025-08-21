*****Custom CHARM FAT Atlas Integration for SimNIBS*****

This guide provides instructions for setting up the custom CHARM FAT atlas for SimNIBS. Follow the steps below to properly integrate the custom atlas and run it with your MRI data.

--------------------------------------

Prerequisites

	•	SimNIBS must be installed on your system.
	•	You will need the custom CHARM FAT atlas files and the settings files (settings_fat.ini and shared_gmm_fat.txt).

--------------------------------------

*****Step-by-Step Instructions*****


1. Placing the Custom CHARM FAT Atlas

	1.	Locate your SimNIBS installation directory. This is typically at:
		<path_to_simnibs>/simnibs/segmentation/atlases/

	2.	In the atlases folder, you will see the standard atlas shipped with SimNIBS, named charm_atlas_mni.
	3.	Copy the charm_fat_atlas_mni folder from your custom_charm_fat directory and place it inside:
		<path_to_simnibs>/simnibs/segmentation/atlases/

-------------------------------------

2. Downloading and Placing the Settings Files

	1.	Download the following files:
		•	settings_fat.ini
		•	shared_gmm_fat.txt
	2.	Place both files in a folder of your choice. Ensure they are placed in the same directory, as settings_fat.ini points to shared_gmm_fat.txt and the new FAT atlas.

--------------------------------------

3. Running CHARM with the Custom FAT Atlas

To run CHARM using the custom FAT atlas, use the following command in the terminal:

charm <subid> sub_T1.nii.gz sub_T2.nii.gz --usesettings <path_to_settings_fat.ini> --noneck --forceqform
