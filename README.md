**(in progress, to be updated)**

# Perinuclear-Actin-Analysis
ImageJ/Fiji macros for analysis of perinuclear actin networks acquired by confocal microscopy.

Three macros.

### Macro #1:

**Input:** 3-channel 3D confocal data where the 1st channel contains an image of actin network (red), the 2nd channel is a picture of a protein (green) *(which one, why ???)* and the 3rd channel is a nucleus stained by DAPI (blue), see Fig. 1-left. If the order of the channels is not correct in the data, it can be modified for processing in the macro using PARAMETERS section.

*Staining of three channels ???*

It is highly recommended to use deconvolved data, due to better resulting image contrast and less noise.

![Montage_Orig_Nucleus_Mask](https://user-images.githubusercontent.com/63607289/158192279-af4b2f23-1b54-4e29-af9b-664eefae3d35.jpg)

Fig. 1: Deconvolved 3-channel 3D confocal data for the analysis, for simplicity visualized using MIP.

**Purpose of the macro:** It is required to draw a guide line in the picture by using *Straight* tool in Fiji to  indicate where the scratch was made in the Petri dish, according to which cells orient during the experiment.

First, the macro splits channels. The image with the protein is not used and, thus, is closed. The image with the nucleus is processed, so as only nucleus part of the actin network, i.d. only perinuclear part, is segmented afterwards - a binary mask is created from the nucleus shape (Fig. 1-right).

Then, the actin image is processed by subtraction of the nonhomegenous background, maximum intensity projection (MIP) is computed to visualize actin in one layer only, it is smoothed and filtered by Tubeness filter (https://biii.eu/tubeness) to enhance individual actin fibers (PIC). Then the mask created from the nucleus is applied, so as only perinuclear part of the actin is analysed (PIC).

