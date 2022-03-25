///////////////////////////////////////////////////////////////////////////////////////////////
// 1st input image - color-labeled skeleton created by the 2nd macro - it must be open in Fiji
// 2nd input image (reading via dialog) - an image with the suffix: "*-Actin-OrigIntensity.tif"
///////////////////////////////////////////////////////////////////////////////////////////////

// Skeleton pic
titleSkeleton = getTitle();
dir = getDirectory("image");
rename("SkeletonImg");

width = getWidth();
height = getHeight();
getPixelSize(unit, pixelWidth, pixelHeight);

// Actin-OrigIintensity pic
pathInt = File.openDialog("Select an image with '-Actin-MIP-OrigIntensity' suffix...");
open(pathInt);
title = getTitle();
name = substring(title, 0, lastIndexOf(title,"."));
rename("MaskedImg");

// Local thickness image creation from Actin-OrigIintensity pic by using Auto Local Threshold
run("Duplicate...", "title=OrigIntensity_Copy");
run("Auto Local Threshold", "method=Mean radius=15 parameter_1=0 parameter_2=0 white");
saveStr = dir + name + "-LocThreshold.tif";
save(saveStr);
run("Local Thickness (complete process)", "threshold=20");
selectWindow("OrigIntensity_Copy_LocThk");
saveStr = dir + name + "-LocThickness.tif";
save(saveStr);
rename("ThicknessImg");

skeletons = newArray(width * height);
for (i = 0; i < width * height; i++)
	skeletons[i] = 0;

int = 0;
// histogram of skeleton labels creation
selectWindow("SkeletonImg");
for (y = 0; y < height; y++)
	for (x = 0; x < width; x++) {
		int = getPixel(x, y);
		if (int > 0)
			skeletons[int] = skeletons[int] + 1;
	}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// evaluation of average thicknesses and intensities of actins with using individual color-labeled parts of the skeleton

// array with coordinates of a single skeleton part - (x, y) per 1 pixel in one array
oneSkeleton = newArray(width * height * 2);
for (i = 0; i < width * height * 2; i++)
	oneSkeleton[i] = 0;

sktInt = 0;
frequency = 0;
sktLength = 0;
xx = 0;
yy = 0;
thicknessAccum = 0;
skeletonIndex = 0;
intensityAccum = 0;

for (i = 0; i < width * height; i++)
{
	frequency = skeletons[i];
	if (frequency > 0)
	{
		skeletonIndex++;
		sktInt = i;
		// scannig the skeleton image and find all the pixels of one skeleton part of the same color label
		selectWindow("SkeletonImg");
		sktLength = 0;
		for (y = 0; y < height; y++)
			for (x = 0; x < width; x++) {
				int = getPixel(x, y);
				if (int == sktInt)
				{
					oneSkeleton[2 * sktLength] = x;
					oneSkeleton[2 * sktLength + 1] = y;
					sktLength++;
					setPixel(x, y, 10000);
				}
			}
		updateDisplay();						

		// average thickness of the now analyzed skeleton part
		selectWindow("ThicknessImg");
		thicknessAccum = 0;
		for (l = 0; l < sktLength; l++)
		{
			xx = oneSkeleton[2 * l];
			yy = oneSkeleton[2 * l + 1];
			thicknessAccum = thicknessAccum + getPixel(xx, yy);
			setPixel(xx, yy, 10000);
		}
		updateDisplay();

		// average intensity of the fiber in Actin-OrigIintensity pic that corresponds to now analyzed skeleton part
		selectWindow("MaskedImg");
		intensityAccum = 0;
		for (l = 0; l < sktLength; l++)
		{
			xx = oneSkeleton[2 * l];
			yy = oneSkeleton[2 * l + 1];
			intensityAccum = intensityAccum + getPixel(xx, yy);
			setPixel(xx, yy, 10000);
		}
		updateDisplay();

		thicknessAvg = thicknessAccum / sktLength * pixelWidth;
		intensityAvg = intensityAccum / sktLength;
		
		// for each skeleton part writing to Fiji Log file: number, color, length, average thickness, average intensity 
		outputString = "Skeleton_No	" + skeletonIndex + 
		"	Color	" + sktInt + 
		"	Length	" + sktLength * pixelWidth + "	[" + unit + "]	" + 
		"Average Thickness	" + thicknessAvg + "	[" + unit + "]	" + 
		"Average Intensity	" + intensityAvg;
		print(outputString);
	}
}

selectWindow("Log");
saveStr = dir + name + "-Thickness-Int.txt";
saveAs("text", saveStr);
run("Close");

selectWindow("MaskedImg");
saveStr = dir + name + "-Skeleton.tif";
saveAs("tiff", saveStr);

selectWindow("ThicknessImg");
saveStr = dir + name + "-LocalThick-Skeleton.tif";
saveAs("tiff", saveStr);

run("Tile");