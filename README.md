**(in progress, to be updated)**

# Perinuclear-Actin-Analysis
ImageJ/Fiji macros for analysis of perinuclear actin networks images acquired by confocal microscopy.

Three macros.

### Macro #1:

**Input:** 3-channel 3D confocal data where the 1st channel contains an image of actin network (red), the 2nd channel is a picture of a protein (green) *(which one, why ???)* and the 3rd channel is a nucleus stained by DAPI (blue), see Fig.1-left. If the order of the channels is not correct in the data, it can be modified for processing in the macro using PARAMETERS section.

*Staining of three channels ???*

It is highly recommended to use deconvolved data, due to better resulting image contrast and less noise.

Data created and provided by Dr. Olga Marvalová, [Laboratory of Cell Signalling, Eukaryotic group - Dr. Tomáš Vomastek, Institute of Microbiology of the Czech Academy of Sciences, Prague, Czech Republic.](https://mbucas.cz/en/research/microbiology/laboratory-of-cell-signalization/)

![Montage_Orig_Nucleus_Mask](https://user-images.githubusercontent.com/63607289/158192279-af4b2f23-1b54-4e29-af9b-664eefae3d35.jpg)

Fig.1: Deconvolved 3-channel 3D confocal data for the analysis, for simplicity visualized using MIP, and a mask created from the nucleus.

**Purpose of the macro:** It is required to draw a guide line in the picture by using *Straight* tool in Fiji to  indicate where the scratch was made in the Petri dish, according to which cells orient during the experiment.

First, the macro splits channels. The image with the protein is not used and, thus, is closed. The image with the nucleus is processed, so as only nucleus part of the actin network, i.d. only perinuclear part, is segmented afterwards - a binary mask is created from the nucleus shape (Fig.1-right).

Then, the actin image is processed by subtraction of the nonhomegenous background, maximum intensity projection (MIP) is computed to visualize actin in one layer only, it is smoothed and filtered by [Tubeness filter](https://biii.eu/tubeness) to enhance individual actin fibers (Fig.2-left). Then the mask created from the nucleus is applied, so as only perinuclear part of the actin is analysed (Fig.2-right).

![Montage02_Tubeness_Masked_Tubeness](https://user-images.githubusercontent.com/63607289/158388172-673d43ad-6598-4013-a69b-65a52be49356.jpg)

Fig.2: Tubeness-filtered actin and masked.

**1. Orientation of the nucleus (i.e. a cell) with respect to the guide line.** Each cell, a binary mask created from the shape of nucleus, respectively, is fitted by an ellipse and its axes, major and minor one, are computed. After drawing the guide line, an angle between the fitted ellipse main axis, rotated to align with the x-axis, and the guide line, in green, is evaluated in Fig.3.

![Fig_3_EllipseFit-AngleCorr-2 1664°-Scale_0_5](https://user-images.githubusercontent.com/63607289/158391329-fe918a21-1f3b-4bc4-84cc-a154c91f8cb5.jpg)

Fig.3: Ellipse fitted to the nucleus mask, rotated to align its main axis with x, with evaluation of the angle between the ellipse main axis (blue) and the guide line (green). The value "Corr." is the difference between an optimal expected angle, i.e. 90°, and the found angle, here 92.1664°.

**2. Distribution of perinuclear actin fiber directions.** MIP image of perinuclear actin fibers, without Tubeness filtration here, rotated by the angle found in the previous step is analysed for distribution of directions of the actin in the cell (Fig.4-left). The rotation applied is necessary for normalization of the directions, since the distribution of theses directions is related to the guide line and due to various orientations of various cells during the treatment. For evaluation of these distributions the [Directionality plugin](https://imagej.net/plugins/directionality) is used (Fig.4-right).

![Fig_4_Montage_Actin_Rotated_Directionality_Histogram](https://user-images.githubusercontent.com/63607289/158403957-6689d1e8-0467-4b84-9930-110079bf1cd0.jpg)

Fig.4: Image of MIP of perinuclear actin fibers, without Tubeness filtration, rotated with the found angle, and the corresponding directionality histogram.

After these steps the picture of perinuclear actin filtered with Tubeness, Fig.2-right, is skeletonized just to get initial network of the actin in the cell before analyzing fiber lenghts and branchings.

Since the data of actin is far from ideal due to noise, low contrast locally etc., before applying the next macro, Macro #2, it is necessary to edit skeleton manually with the help of the image of original perinuclear actin as a reference to correct for badly skeletonized parts (Fig.5).

![Fig_5_MIPOrig-Skeletons](https://user-images.githubusercontent.com/63607289/158555087-8676a740-0d32-4269-9957-d70a22b64f7c.jpg)

Fig.5: MIP of actin, not filtered, with original intensities (left), and skeletons - original (middle) and slightly edited one (right) with respect to the left image.

### Macro #2:

**Input:** An image with manually edited skeleton, e.g., Fig.5-right.

**Purpose:** Evaluation of lengths and branchings of the actin fiber network.

A picture with the perinuclear actin skeleton, edited in the previous step, is analyzed again by skeletonizing. For this purpose the following plugins are used: [Skeletonize (2D/3D)](https://imagej.net/plugins/skeletonize3d) and [Analyze Skeleton (2D/3D)](https://imagej.net/plugins/analyze-skeleton/). The results of this macro - a CSV file with lenghts of the skeleton parts and a picture of skeleton with colour-labeled parts (Fig.6) that will be used by the next macro, Macro #3, are stored in the disk.

![Fig_6_Skeleton_Color_Labeled_Parts](https://user-images.githubusercontent.com/63607289/159013891-2de8792e-da80-4fc5-95f4-20871dff5e52.jpg)

### Macro #3:

**Input:** An image with a color-labeled skeleton created and stored by Macro #2 (Fig.6) and an image created and stored by the Macro #1 with the suffix "-Actin-MIP-OrigIntensity.tif" (Fig.5-left)

**Purpose:** Evaluation of thicknesses and intensities of individual perinuclear actin fibers based on the color-labeled skeleton image, which contains skeleton parts distinguished by color, and the MIP image of these fibers.

Color-labeled skeleton parts are mapped to the image with intensities (Fig.7-left), another image where skeleton parts are mapped to [local thicknesses](https://imagej.net/imagej-wiki-static/Local_Thickness) (Fig.7-right) is created as well. Corresponding values (skeleton lenghts, their average thicknesses and intensities) are stored in the disk in a TXT file (Fig.8).

![Fig_7_Montage_Skeleton_Mapped_To_Intensities_And_LocalThicknesses_Scale_0_5](https://user-images.githubusercontent.com/63607289/159048362-44edf6b8-829c-442d-80df-8abbdd75c222.jpg)
