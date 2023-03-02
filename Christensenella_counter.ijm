/*This macro is optimised for estmating the numbers of colony on plate. Optimised species Christensenella minuta.
 * 
 * reqiered:light background picture about colonies (Best to take foto on white sheet or  with trasluminescent ligth).
 * 
 * The methode of macro is based on "Watershed" segmentation and give a high level od control to the user.
 * This macro generate and save a summary.csv and log.txt in a same dir as your pictures.
 * 
 * author: Csongor Freytag
 */

//Choose a first piture from directory  // jó lenne egy gyors elemzés funkció 8bit, telep méret 1x, otsu, freehand, watershed, t
//3 mód közüllehssen választani batch; fusson a laplacian; ne fusson a laplacian
open("");
name=getInfo("image.filename");
print("refrence picture:" +name);
dir = getInfo("image.directory");
list = getFileList(dir);
run("FeatureJ Options", "progress log");

// the size selection need to just once // ehelyet legyen választható hogy csak egyszer vagy minden képenhez külön
	// Draw around a small colony
	setTool("oval");
	waitForUser("Select smallest colony.");
	getStatistics(area1);
	print("smallest colony" +area1);
		s = area1;
	
	// Draw around large colony 
	waitForUser("Select largest colony.");	
	getStatistics(area2);
	print("largest colony" +area2);
		l = area2;
	
for (i = 0; i < lengthOf(list); i++) {
	filename = list[i];
	print(filename);
	
 	
 	// select the whole petri dish
 	setTool("oval");
 	run("Scale to Fit");
	waitForUser("Crop image", "The colonies are in an oval and are ready for processing."); 
	
	// Laplacian filter: try with 3.5 write 0 or deselect computing image if you wanna switchit off // ha nem megy laplacian nem fut le az automata mentés
	setBackgroundColor(75, 75, 75);
	run("Clear Outside");
	run("Crop");
	run("8-bit");
	run("FeatureJ Laplacian");
	
	// top hat to remove dust and small particles
	//it is help to rounding the colonies
	run("Enhance Contrast...", "saturated=0.35");
	run("Top Hat...");
	
	// set Threshold	
	run("Threshold...");
	setAutoThreshold("Otsu");
	waitForUser("set Threshold..", "I selected almost all colony.");
	
	
	// count colonies with analyse particles
	run("Convert to Mask");
	run("Watershed");
	
	//optional pont to a 2nd crop if needed
	ans=getBoolean ("Would you like to remove edges or non-colony spots?"); 
	if (ans==1) {
		setTool("freehand");
		setBackgroundColor(255, 255, 255);
		waitForUser("Crop image", "Draw around colonies with freehand and comand will clear outside.");
		run("Clear Outside");
		}
	//it's run automaticlly with the values from the first step  // ez legyen újra indítható
	run("Analyze Particles...", "size=&s-&l  circularity=0.7-1.00 show=Overlay summarize overlay");
	waitForUser("set Threshold..", "Is it good?");
	close();
	name2=getInfo("image.filename");
	if (name==name2) {
		run("Open Next");
		}
		else {
		run("Open Next");
	}
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








