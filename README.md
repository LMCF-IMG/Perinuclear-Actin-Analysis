**(in progress, to be updated)**

# Perinuclear-Actin-Analysis
ImageJ/Fiji macros for analysis of perinuclear actin networks acquired by confocal microscopy.

Three macros.

### Macro #1:

**Input:** 3-channel 3D confocal data where the 1st channel contains an image of actin network (red), the 2nd channel is a picture of a protein (green) *(which one, why ???)* and the 3rd channel is a nucleus stained by DAPI (blue), see Fig.1-left. If the order of the channels is not correct in the data, it can be modified for processing in the macro using PARAMETERS section.

*Staining of three channels ???*

It is highly recommended to use deconvolved data, due to better resulting image contrast and less noise.

Data created and provided by Dr. Olga Marvalová, [Laboratory of Cell Signalling, Eukaryotic group - Dr. Tomáš Vomastek, Institute of Microbiology of the Czech Academy of Sciences](https://mbucas.cz/en/research/microbiology/laboratory-of-cell-signalization/).

![Montage_Orig_Nucleus_Mask](https://user-images.githubusercontent.com/63607289/158192279-af4b2f23-1b54-4e29-af9b-664eefae3d35.jpg)

Fig.1: Deconvolved 3-channel 3D confocal data for the analysis, for simplicity visualized using MIP, and a mask created from the nucleus.

**Purpose of the macro:** It is required to draw a guide line in the picture by using *Straight* tool in Fiji to  indicate where the scratch was made in the Petri dish, according to which cells orient during the experiment.

First, the macro splits channels. The image with the protein is not used and, thus, is closed. The image with the nucleus is processed, so as only nucleus part of the actin network, i.d. only perinuclear part, is segmented afterwards - a binary mask is created from the nucleus shape (Fig.1-right).

Then, the actin image is processed by subtraction of the nonhomegenous background, maximum intensity projection (MIP) is computed to visualize actin in one layer only, it is smoothed and filtered by Tubeness filter (https://biii.eu/tubeness) to enhance individual actin fibers (Fig.2-left). Then the mask created from the nucleus is applied, so as only perinuclear part of the actin is analysed (Fig.2-right).

![Montage02_Tubeness_Masked_Tubeness](https://user-images.githubusercontent.com/63607289/158388172-673d43ad-6598-4013-a69b-65a52be49356.jpg)

Fig.2: Tubeness-filtered actin and masked.

**1. Orientation of the nucleus (i.e. a cell) with respect to the guide line.** Each cell, a binary mask created from the shape of nucleus, respectively, is fitted by an ellipse and its axes, major and minor one, are computed. After drawing the guide line, an angle between the fitted ellipse main axis, rotated to align with the x-axis, and the guide line, in green, is evaluated in Fig.3.

![Fig_3_EllipseFit-AngleCorr-2 1664°-Scale_0_5](https://user-images.githubusercontent.com/63607289/158391329-fe918a21-1f3b-4bc4-84cc-a154c91f8cb5.jpg)

Fig.3: Ellipse fitted to the nucleus mask, rotated to align its main axis with x, with evaluation of the angle between the ellipse main axis (blue) and the guide line (green). The value "Corr." is the difference between an optimal expected angle, i.e. 90°, and the found angle, here 92.1664°.

**2. Distribution of perinuclear actin fiber directions.** MIP image of perinuclear actin fibers, without Tubeness filtration here, rotated by the angle found in the previous step is analysed for distribution of directions of the actin in the cell (Fig.4-left). The rotation applied is necessary, since the distribution of theses directions is related to the guide line, for various orientations of various cells during the treatment. For evaluation of these distributions the Directionality plugin is used (https://imagej.net/plugins/directionality) (Fig.4-right).

![Fig_4_Montage_Actin_Rotated_Directionality_Histogram](https://user-images.githubusercontent.com/63607289/158403957-6689d1e8-0467-4b84-9930-110079bf1cd0.jpg)

Fig.4: Image of MIP of perinuclear actin fibers, without Tubeness filtration, rotated with the found angle and the corresponding directionality histogram.
