##### SCRIPT TO PLOT HISTOGRAMS OF META-ANALYSIS/GWAS RESULTS #####
#
# Originally from the MANTEL Package, MANTEL_RELEASE.May_2011
# made by De Bakker Lab members Sara Pulit, Jessica van Setten,
# Paul de Bakker
# website: http://debakker.med.harvard.edu/resources.html
# 
# Description: 
# This script creates two histograms
# 1) Histogram of effective sample size
# 2) Histogram of number of contributing studies
#
# Usage: R CMD BATCH --args -CL -input.file -number.of.studies -[PNG/PDF/TIFF] -output histograms.R
#
# Input data: 	ONLY effect size (beta), NO headers
# Image styles: PDF (width=6, height=6), PNG (width=800, height=800), 
#    			TIFF (width=800, height=800).
# 				Note on the image styles: PNG can best be used in PowerPoint
#				presentations, whereas TIFF produces high-quality, large-sized 
#				files for publication purposes.
#
# Update: 2015-02-25
# Editor(s): Sander W. van der Laan
# E-mail(s): s.w.vanderlaan-2@umcutrecht.nl

### READS INPUT OPTIONS ###
	rm(list=ls())

	x <- 0

	repeat {
			x <- x+1
			if (commandArgs()[x] == "-CL") {
			input <- commandArgs()[x+1]; input <- substr(input, 2, nchar(input))
			studies <- commandArgs()[x+2]; studies <- as.numeric(substr(studies, 2, nchar(studies)))
			image_style <- commandArgs()[x+3]; image_style <- substr(image_style, 2, nchar(image_style))
			output <- commandArgs()[x+4]; output <- substr(output, 2, nchar(output))
			break
			}
			if (x == length(commandArgs())) {
					print("remember the -CL command!")
					break}
			}

	rm(x)

### DEFINE PLOT COLORS ###
### Define plotting colors for each element/point of the plot.
###	UtrechtSciencePark Colours Scheme
###	yellow				#FBB820 => 1 or 1.0 > INFO
###	gold				#F59D10 => 2
###	salmon				#E55738 => 3 or 0.05 < MAF < 0.2 or 0.4 < INFO < 0.6
###	darkpink			#DB003F => 4
###	lightpink			#E35493 => 5 or 0.8 < INFO < 1.0
###	pink				#D5267B => 6
###	hardpink			#CC0071 => 7
###	lightpurple			#A8448A => 8
###	purple				#9A3480 => 9
###	lavendel			#8D5B9A => 10
###	bluepurple			#705296 => 11
###	purpleblue			#686AA9 => 12
###	lightpurpleblue		#6173AD => 13
###	seablue				#4C81BF => 14
###	skyblue				#2F8BC9 => 15
###	azurblue			#1290D9 => 16 or 0.01 < MAF < 0.05 or 0.2 < INFO < 0.4
###	lightazurblue		#1396D8 => 17
###	greenblue			#15A6C1 => 18
###	seaweedgreen		#5EB17F => 19
###	yellowgreen			#86B833 => 20
###	lightmossgreen		#C5D220 => 21
###	mossgreen			#9FC228 => 22 or MAF > 0.20 or 0.6 < INFO < 0.8
###	lightgreen			#78B113 => 23/X/x
###	green				#49A01D => 24/Y/y
###	grey				#595A5C => 25/XY/xy/Xy/xY or MAF < 0.01 or 0.0 < INFO < 0.2
###	lightgrey			#A2A3A4	 => 26/MT/Mt/mt/mT

### READS DATA ###
data <- read.table(input, header = FALSE)

## Plots axes and null distribution
print("Determining what type of image should be produced and plotting axes.")
if (image_style == "PNG") 
	png(paste(output, ".Histogram_EffectiveN.png", sep=""), width=800,height=800)

if (image_style == "TIFF") 
	png(paste(output, ".Histogram_EffectiveN.tiff", sep=""), width=800,height=800)
	
if (image_style == "PDF") 
	pdf(paste(output, ".Histogram_EffectiveN.pdf", sep=""), width=6,height=6)

	hist(data[,1], xlab="N", main="Effective sample size", col="#9FC228")
dev.off()

if (image_style == "PNG") 
	png(paste(output, ".Histogram_Kstudies.png", sep=""), width=800,height=800)

if (image_style == "TIFF") 
	pdf(paste(output, ".Histogram_Kstudies.tiff", sep=""), width=800,height=800)

if (image_style == "PDF") 
	pdf(paste(output, ".Histogram_Kstudies.pdf", sep=""), width=6,height=6)

	hist(1+data[,2], xlab="k", main="Number of contributing studies per SNP", xlim=c(0,studies), breaks=studies, col="#86B833")
dev.off()
