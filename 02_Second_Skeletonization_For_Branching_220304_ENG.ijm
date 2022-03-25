///////////////////////////////////////////////////////////////
// input: an image with manually edited skeleton opened in Fiji
///////////////////////////////////////////////////////////////

title = getTitle();
name = substring(title, 0, lastIndexOf(title,"."));
dir = getDirectory("image");
getPixelSize(unit, pw, ph, pd);
rename("Skeleton-Enhanced");

run("Skeletonize (2D/3D)");
run("Analyze Skeleton (2D/3D)", "prune=[shortest branch] calculate show display");

selectWindow("Results");
saveStr = dir + name + "-Skeleton-Lengths.csv";
saveAs("results", saveStr);
run("Close");

selectWindow("Branch information");
run("Close");

selectWindow("Longest shortest paths");
saveStr = dir + name + "-Longest-Shortest-Paths.tif";
saveAs("tiff", saveStr);

selectWindow("Skeleton-Enhanced-labeled-skeletons");
saveStr = dir + name + "-Enh-Labeled-32bit.tif";
run("Properties...", "unit=" + unit + " pixel_width=" + pw + " pixel_height=" + ph + " voxel_depth=1");
saveAs("tiff", saveStr);

run("Tile");

/////////////////////////////////////////////////////////////////////////
// except the color skeleton image, which will be used by the 3rd macro,
// it is possible to close other pictures (after visual inspection...)
/////////////////////////////////////////////////////////////////////////