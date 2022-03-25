title = getTitle();

///////////////////////////////////////
// PARAMETERs ************************

// !necessary to fill in properly - the order of channels and range of layers with perinuclear actin!
actin = "C1-" + title;
protein = "C2-" + title;
nucleus = "C3-"  + title;
slicesWithActin = "13-23";
// PARAMETERS ************************
//////////////////////////////////////

name = substring(title, 0, lastIndexOf(title,"."));
dir = getDirectory("image");
getPixelSize(unit, pw, ph, pd);

// check if the guide line was drawn in the picture
selType = selectionType();
// storing the guide line drawn - selection in Fiji - before next processing
xpoints = newArray(0);
ypoints = newArray(0);
lineDrawn = true;
if (selType == 5)
	Roi.getCoordinates(xpoints, ypoints);
else {
	lineDrawn = false;
	showMessage("Warning", "No Guide Line Drawn in the Image...");
	exit;
}

saveSettings();

// avoid intensity changes when converting from 32bit to 16bit
run("Conversions...", " ");
run("16-bit");

run("Split Channels");

selectWindow(protein);
close();

selectWindow(nucleus);
run("Smooth", "stack");
run("Z Project...", "projection=[Max Intensity]");
setAutoThreshold("Huang dark");
setOption("BlackBackground", true);
run("Convert to Mask");
run("Fill Holes");
run("Divide...", "value=255");
run("Enhance Contrast", "saturated=0.35");
rename("Mask");

selectWindow(nucleus);
close();

selectWindow(actin);
run("Subtract Background...", "rolling=100 stack");
run("Duplicate...", "duplicate range=" + slicesWithActin);
run("Z Project...", "projection=[Max Intensity]");
rename("MaxIntProj_HalfStack");

run("Duplicate...", " ");
run("Conversions...", "scale");
run("8-bit");
rename("MaxIntProj_HalfStack-8bit");

selectWindow("MaxIntProj_HalfStack");
run("Properties...", "channels=1 slices=1 frames=1 unit=" + unit + " pixel_width=" + pw + " pixel_height=" + ph + " voxel_depth=1");
run("Gaussian Blur...", "sigma=2");
run("Enhance Contrast", "saturated=0.35");
run("Apply LUT");
run("Tubeness", "sigma=0.1 use");
rename("MaxIntProj_HalfStack-Tubeness");

selectWindow(actin);
close();

indexOfLastPoint = lastIndexOf(actin, ".");
actinNoExt = substring(actin, 0, indexOfLastPoint);
extension = substring(actin, indexOfLastPoint+1, lengthOf(actin));
actinWith1 =  actinNoExt + "-1." + extension;
selectWindow(actinWith1);
close();

imageCalculator("Multiply create", "MaxIntProj_HalfStack-Tubeness", "Mask");
resetMinAndMax();
rename("ActinFilteredMasked");

imageCalculator("Multiply create", "MaxIntProj_HalfStack-8bit", "Mask");
resetMinAndMax();
saveStr = dir + name + "-Actin-MIP-OrigIntensity.tif";
run("Enhance Contrast", "saturated=0.35");
saveAs("tiff", saveStr);
rename("MaxIntProj_HalfStack-8bit-Masked");

// analysis
guideLineAngle = 0;
x0 = 0;
y0 = 0;
if (lineDrawn) {
    x1 = xpoints[0];
    x2 = xpoints[1];
    y1 = ypoints[0];
    y2 = ypoints[1];

    // center of the guide line
    xmin = minOf(x1, x2);
    ymin = minOf(y1, y2);
    x0 = abs(x2 - x1) / 2 + xmin;
    y0 = abs(y2 - y1) / 2 + ymin;
    
    b = sqrt( pow(y1 - y2, 2) );
    a = sqrt( pow(x1 - x2, 2) );
    c = sqrt( pow(x1 - x2, 2) + pow(y1 - y2, 2) );

    // to distinguish with a sign how the guide line is drawn 
    sign = 0;
    if ( ((x2 - x1) > 0) && ((y2 - y1) > 0) )
        sign = 1;
    if ( ((x2 - x1) < 0) && ((y2 - y1) < 0) )
        sign = 1;       
    if ( ((x2 - x1) > 0) && ((y2 - y1) < 0) )
        sign = -1;
    if ( ((x2 - x1) < 0) && ((y2 - y1) > 0) )
        sign = -1;
    
    if (x1 == x2)
    	guideLineAngle = 90;
	else if (y1 == y2)
		guideLineAngle = 0;
	else
        guideLineAngle = sign * atan2(b, a) * 180 / PI;
}    

selectWindow("Mask");
run("Properties...", "pixel_width=1 pixel_height=1 voxel_depth=1");
setThreshold(1, 1);
run("Set Measurements...", " area mean centroid fit ");
run("Analyze Particles...", "size=0 circularity=0 show=Ellipses display exclude clear ");
run("RGB Color");

// drawing an ellipse and its main axes
// ATTENTION: the ellipse must be rotated so that it corresponds to the position of the drawn guided line
// that is, it is necessary to analyze the position of the center of the line relative to the center of the ellipse and draw a conclusion ... 	
x=getResult('X',0);
y=getResult('Y',0);
d=getResult('Major',0);
aDgr = getResult('Angle',0);
aRad = aDgr*PI/180;
setColor("blue");
drawLine(x+(d/2)*cos(aRad),y-(d/2)*sin(aRad),x-(d/2)*cos(aRad),y+(d/2)*sin(aRad));
d=getResult('Minor',0);
aRadPIPul=aRad+PI/2;
setColor("red");
drawLine(x+(d/2)*cos(aRadPIPul),y-(d/2)*sin(aRadPIPul),x-(d/2)*cos(aRadPIPul),y+(d/2)*sin(aRadPIPul));
// draw the guided line
setColor("green");
drawLine(xpoints[0], ypoints[0], xpoints[1], ypoints[1]);
// draw the center of the guided line
setColor("black");
drawLine(x0 - 5, y0, x0 + 5, y0);
drawLine(x0, y0 - 5, x0, y0 + 5);

if (guideLineAngle < 0)
	guideLineAngle = 180 + guideLineAngle;

angleOfMainEllipseAxis  = 180 - aDgr;

angleBetweenGuideLineAndEllipseMainAxis  = angleOfMainEllipseAxis - guideLineAngle;
if (angleBetweenGuideLineAndEllipseMainAxis  < 0)
	angleBetweenGuideLineAndEllipseMainAxis  = 180 + angleBetweenGuideLineAndEllipseMainAxis ;

showMessage("Message", "Angle of the guide line = " + guideLineAngle + "°, Angle of the main ellipse axis = " + angleOfMainEllipseAxis  + "°");
showMessage("Message", "The angle between the guide line and the main axis of the ellipse = " + angleBetweenGuideLineAndEllipseMainAxis  + "°");

// rotation of the center of the guide line according to the center of the ellipse
// center of rotation (ellipse) on [0, 0] 
x0new = x0 - x;
y0new = y0 - y;
// rotation according to the found angle from the fitting of the ellipse
x0tmp = x0new*cos(-aRad) + y0new*sin(-aRad);
y0tmp = -x0new*sin(-aRad) + y0new*cos(-aRad);
// center of rotation (ellipse) back
x0rot = x0tmp + x;
y0rot = y0tmp + y;
// decision on rotation by another 180°
if (x0rot < x)
    aDgr = aDgr + 180;

run("Rotate... ", "angle=" + aDgr + " grid=1 interpolation=Bicubic");
// write the angle in the picture
setFont("SansSerif", 20, "bold");
setColor("magenta");
drawString(angleBetweenGuideLineAndEllipseMainAxis  +  "°", getWidth() * 3/4, getHeight() * 3/4);

// calculation of the corrected angle, where 90° is 0° and another angle is the deviation from the perpendicular in absolute value 
angleCorr = abs(angleBetweenGuideLineAndEllipseMainAxis  - 90);
// write the angle in the picture
setFont("SansSerif", 20, "bold");
setColor("magenta");
drawString("Corr. " + angleCorr +  "°", getWidth() * 3/5, getHeight() * 3/4 + 25); 	

selectWindow("Drawing of Mask");
saveStr = dir + name + "-EllipseFit-AngleCorr-" + angleCorr + "°.tif";
saveAs("tiff", saveStr);
//close();

selectWindow("MaxIntProj_HalfStack-8bit-Masked");
run("Duplicate...", "title=MaxIntProj_HalfStack-8bit-Masked-Copy");	
run("Rotate... ", "angle=" + aDgr + " grid=1 interpolation=Bicubic");
saveStr = dir + name + "-Actin-MIP-8bit-Masked-Rotated.tif";
saveAs("tiff", saveStr);	
run("Directionality", "method=[Fourier components] nbins=90 histogram_start=-90 histogram_end=90 display_table");		

selectWindow("Directionality histograms for " + name + "-Actin-MIP-8bit-Masked-Rotated (using Fourier components)");
saveStr = dir + name + "_Directionality_Values.txt";
saveAs("text", saveStr);
run("Close");

selectWindow("Mask");
saveStr = dir + name + "-Nucleus-Mask.tif";
saveAs("tiff", saveStr);
close();
selectWindow("MaxIntProj_HalfStack");
close();
selectWindow("MaxIntProj_HalfStack-Tubeness");
saveStr = dir + name + "-Actin-Tubeness-NonMasked.tif";
saveAs("tiff", saveStr);
close();

selectWindow("ActinFilteredMasked");
run("8-bit");
saveStr = dir + name + "-Actin-Tubeness-Filtered-8bit.tif";
saveAs("tiff", saveStr);
rename("ActinFilteredMasked");

run("Duplicate...", " ");
rename("ActinFilteredMaskedCopy");
run("Enhance Contrast", "saturated=0.35");

// skeletonization
selectWindow("ActinFilteredMasked");
run("Properties...", "unit=" + unit + " pixel_width=" + pw + " pixel_height=" + ph + " voxel_depth=1");
run("Skeletonize (2D/3D)");
run("Analyze Skeleton (2D/3D)", "prune=[shortest branch] calculate show display");

//selectWindow("Tagged skeleton");
//close();

selectWindow("ActinFilteredMasked-labeled-skeletons");
run("8-bit");
setThreshold(1, 255);
run("Convert to Mask");

saveStr = dir + name + "-Skeleton-8bit.tif";
run("Properties...", "channels=1 slices=1 frames=1 unit=" + unit + " pixel_width=" + pw + " pixel_height=" + ph + " voxel_depth=1");
saveAs("tiff", saveStr);

selectWindow("Branch information");
run("Close");

selectWindow("Results");
run("Close");

selectWindow("Longest shortest paths");
run("Close");

selectWindow("ActinFilteredMasked");
close();

selectWindow("MaxIntProj_HalfStack-8bit");
close();

run("Tile");
run("Synchronize Windows");

restoreSettings();

////////////////////////////////////
// now manually editing the skeleton
////////////////////////////////////