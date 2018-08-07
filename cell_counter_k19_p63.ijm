imageTitle=getTitle()
run("Split Channels")
//Subtract background of DAPI image
	i="C3-";
    selectWindow(i+imageTitle); 
    run("Duplicate...", " ");
    run("Gaussian Blur...", "sigma=50");
    blurTitle=getTitle();
    imageCalculator("Subtract", i+imageTitle,blurTitle);
    close(blurTitle);
//Add K19 regions to manager
	j="C2-";
	selectWindow(j+imageTitle);
	run("Morphological Filters", "operation=Closing element=Disk radius=10");
	run("Square Root");
	setAutoThreshold("Yen dark");
	run("Threshold...");
	run("Convert to Mask");
	run("Analyze Particles...", "size=40-Infinity show=Masks display add");
//Combine ROI selections
	a=roiManager("count");
	b=Array.getSequence(a);
	c=Array.slice(b, 0);
	if (roiManager("count")==0){
		K19 = 0;
	}
	else { 
		if (roiManager("count")==1){
			roiManager("Select", 0);
		}else{
			roiManager("Select", c);
			roiManager("Combine");
			roiManager("Add");
			roiManager("Select", c);
			roiManager("Delete");
		}
	}
//count DAPI with combined ROI overlay
	selectWindow(i+imageTitle);
	run("Morphological Filters", "operation=Opening element=Disk radius=2");
	run("Square Root");
	setAutoThreshold("RenyiEntropy dark");
	run("Convert to Mask");
	run("Watershed");
	if (roiManager("count")>=1){
		roiManager("Select", 0);
		run("Analyze Particles...", "size=40-Infinity show=Masks display add");
	}
//Save data
	if (roiManager("count")>=1){
		K19 = roiManager("count")-1;
		roiManager("Delete");
	}
	else{
		K19 = 0;
	}
//Add p63 regions to manager
	k="C1-";
	selectWindow(k+imageTitle);
	run("Morphological Filters", "operation=Closing element=Disk radius=10");
	run("Square Root");
	setAutoThreshold("RenyiEntropy dark");
	run("Threshold...");
	run("Analyze Particles...", "size=40-Infinity show=Masks display add");
//Combine ROI selections
	a=roiManager("count");
	b=Array.getSequence(a);
	c=Array.slice(b, 0);
	if (roiManager("count")==0){
		p63 = 0;
	}
	else{
		if (roiManager("count")==1){
			roiManager("Select", 0);
		}else{
			roiManager("Select", c);
			roiManager("Combine");
			roiManager("Add");
			roiManager("Select", c);
			roiManager("Delete");
		}
		s = substring(imageTitle, 0, lengthOf(imageTitle)-4);
		selectWindow(i+s+"-Opening");
		roiManager("Select", 0);
		run("Analyze Particles...", "size=40-Infinity show=Masks display add");
		p63 = roiManager("count")-1;
	}
	roiManager("Delete");
//Colocalization analysis
	selectWindow(k+s+"-Closing");
	run("8-bit");
	coloc_str = "channel_1="+j+s+"-Closing channel_2="+k+s+"-Closing ratio=50 threshold_channel_1=50 threshold_channel_2=50 display=255 colocalizated";
	run("Colocalization ",coloc_str);
	selectWindow("Colocalizated points (8-bit) ");
	run("8-bit");
	run("Analyze Particles...", "size=40-Infinity show=Masks display add");
//Combine ROI selections
	a=roiManager("count");
	b=Array.getSequence(a);
	c=Array.slice(b, 0);
	if (roiManager("count")==0){
		coloc = 0;
	}
	else{
		if (roiManager("count")==1){
			roiManager("Select", 0);
		}else{
			roiManager("Select", c);
			roiManager("Combine");
			roiManager("Add");
			roiManager("Select", c);
			roiManager("Delete");
		}
		s = substring(imageTitle, 0, lengthOf(imageTitle)-4);
		selectWindow(i+s+"-Opening");
		roiManager("Select", 0);
		run("Analyze Particles...", "size=40-Infinity show=Masks display add");
		coloc = roiManager("count")-1;
	}
//Record data in table
	name = "[Cell Count]";
	f=name;
	if (isOpen("Cell Count")){
		print(f, substring(imageTitle, 0, lengthOf(imageTitle)-4)+":");
		print(f, "K19: "+(K19-coloc));
		print(f, "p63: "+(p63-coloc));
		print(f,"Colocalized: "+coloc);
	}
	else {
   		run("New... ", "name="+f+" type=Table");
   		print(f, substring(imageTitle, 0, lengthOf(imageTitle)-4)+":");
		print(f, "K19: "+(K19-coloc));
		print(f, "p63: "+(p63-coloc));
		print(f,"Colocalized: "+coloc);
	}
	if (roiManager("count")>=1) {
		roiManager("Delete");
	}
macro "Close All Windows" { 
    while (nImages>0) { 
         selectImage(nImages); 
         close(); 
      } 
  } 