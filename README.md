# Perinuclear-Actin-Analysis
ImageJ/Fiji macros for analysis of perinuclear actin networks acquired by confocal microscopy.

Three macros.

**Macro #1:**

Input: 3-channel 3D confocal data where the 1st channel contains an image of actin network (red), the 2nd channel is a picture of a protein (green) *(which one, why ???)* and the 3rd channel is a nucleus stained by DAPI (blue), see Fig. 1. However, if the order of the channels is not correct in the data, it can be modified in the macro using PARAMETERS section.

*Staining of three channels ???*

It is highly recommended to use deconvolved data, due to better resulting image contrast and less noise.

![MAX_2019-05-16_Protocol_16_decon-ROI01 tif (RGB)](https://user-images.githubusercontent.com/63607289/157253623-369f9b0f-f25f-477a-8ce1-758bebe1b001.jpg)

Fig. 1: Deconvolved 3-channel 3D confocal data for the analysis, for simplicity visualized using MIP.

Purpose: It is required to draw a guide line in the picture by using *Straight* tool in Fiji to  indicate where the scratch was made in the Petri dish, according to which cells orient during the experiment.

First, the macro splits channels. The image with the protein is not used and, thus, is closed. The image with the nucleus is processed, so as only nucleus part of the actin network, i.d. only perinuclear part, can be segmented afterwards - a binary mask is created from the nucleus shape (PIC).

