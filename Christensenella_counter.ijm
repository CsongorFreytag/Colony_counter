/*This macro is optimised for estmating the numbers of colony on plate. Optimised species Christensenella minuta.
 * 
 * reqiered:light background picture about colonies (Best to take foto on white sheet or  with trasluminescent ligth).
 * 			Fiji and FeatureJ plugin
 * 
 * The methode of macro is based on "Watershed" segmentation and give a high level of control to the user.
 * This macro generate and save a summary.xls and log.txt in a same dir as your pictures.
 * 
 * author: Csongor Freytag
 */

// settings before run
Dialog.create("Settings");
	Dialog.addMessage("Choose your options!");
	Dialog.addCheckbox("Batch mode", false);
	Dialog.addMessage("Use if colonies are less than 1mm in diameter (like: Christensenellaceae)");
	Dialog.addCheckbox("Laplacian filter", false);
Dialog.show();

batch=Dialog.getCheckbox();
filter=Dialog.getCheckbox();

//Choose a first piture from your directory  
// open image and collect infos
open("");
name=getInfo("image.filename");
print("refrence picture:" +name);
dir=getInfo("image.directory");
list=getFileList(dir);
run("FeatureJ Options", "progress log");

if (batch==1) {
	// the size selection need to just once
	// Draw around a small colony 
	setTool("oval");
	waitForUser("Select smallest colony.");
	getStatistics(area1);
	
while (area1 > 2000) {//error checking
			setTool("oval");
			waitForUser("WARNING!!!", "Missing selected colony!");
			getStatistics(area1);
		}
	print("smallest colony" +area1);
		s=area1;
	
	// Draw around large colony 
	waitForUser("Select largest colony.");
	getStatistics(area2);
	while (area2<=area1) {//error checking
			setTool("oval");
			waitForUser("WARNING!!!", "Missing selected colony!");
			getStatistics(area2);
		}
	print("largest colony" +area2);
		l=area2;
}
// area settings
for (i = 0; i < lengthOf(list); i++) {
	filename = list[i];
	print(filename);
	if (batch==0) {
		setTool("oval");
		waitForUser("Select smallest colony.");
		getStatistics(area1);
		while (area1 > 2000) {
			setTool("oval");
			waitForUser("WARNING!!!", "Missing selected colony!");
			getStatistics(area1);
		}
		print("smallest colony" +area1);
			s = area1;	
		waitForUser("Select largest colony.");
		getStatistics(area2);
		while (area2<=area1) {
			setTool("oval");
			waitForUser("WARNING!!!", "Missing selected colony!");
			getStatistics(area2);
		}
		print("largest colony" +area2);
			l = area2;
	}	
 	// select the whole petri dish
 	setTool("oval");
 	run("Scale to Fit");
	waitForUser("Crop image", "The colonies are in an oval and are ready for processing.");
	getStatistics(area3);
	while (area3 <= area2) {
		setTool("oval");
		waitForUser("WARNING!!!", "The colonies are not in an oval and are not ready for processing.");
		getStatistics(area3);
	}
	setBackgroundColor(75, 75, 75);
	run("Clear Outside");
	run("Crop");
	run("8-bit");
	
	if (filter==1) {
		// Laplacian filter: try with 3.5 write 0 or deselect computing image if you wanna switch it off
		run("FeatureJ Laplacian");
	
		// top hat to remove dust and small particles
		//it is help to rounding the colonies
		run("Enhance Contrast...", "saturated=0.35");
		run("Top Hat...");
	}
	// set Threshold	
	if (filter==0) {
		setAutoThreshold("Otsu");
		run("Threshold...");
		waitForUser("set Threshold..", "I selected almost all colony.");
	}
	
	if (filter==1) {
		run("Invert");
		setAutoThreshold("Otsu");
		run("Threshold...");
		waitForUser("set Threshold..", "I selected almost all colony.");
	}
	
	// count colonies with analyse particles
	run("Convert to Mask");
	run("Watershed");
	//it's run automaticlly with the values from the first step
	run("Analyze Particles...", "size=&s-&l  circularity=0.6-1.00 show=Overlay summarize overlay add")
;
	
	//check the result 
	ans=1;
	while (ans!="all Good!") {
		choose=newArray("add few ROI", "Analyze Part... again", "freehand tool", "all Good!" );
		Dialog.create("Check the result!");
			Dialog.addRadioButtonGroup("Choose an option!", choose, 4, 1, "all Good!");
		Dialog.show();
	
		ans=Dialog.getRadioButton();
		print(ans);
	
		if (ans=="freehand tool") {
			setTool("freehand");
			setBackgroundColor(255, 255, 255);
			waitForUser("Crop image", "Draw around colonies with freehand and command will clear outside.");
			run("Clear Outside");
			run("Analyze Particles...");
		}
			
		 else if (ans=="Analyze Part... again") {
			run("Analyze Particles...");
		}
		
		else if (ans=="add few ROI"){
			selectWindow(name);
			roiManager("Add");
			setTool("oval");
			waitForUser("Add missed colonies to ROI via ROImanager then OK")
			nROIs = roiManager("count");
			print(nROIs);
			run("Summarize");
		}
	}
		
	if (filter==1) {
		close();
	}
	run("Open Next");
}
close(name); // it close the image at the end of analysis


//save log file if they exist 				// ezt a logot még fejleszteni kell hogy a user által megadott értékeket képenként visszaadja
if (isOpen("Log")==true){ //error checking
	out =  dir + "Log.txt";
	selectWindow("Log");
	saveAs("Text", out);	
	close("Log");
	}

if (isOpen("Summary")==true){ //error checking
	out1 =  dir + "Summary.xls";
	selectWindow("Summary");
	saveAs("Results", out1);	
	}






git trial


