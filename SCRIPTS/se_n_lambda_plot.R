##### SCRIPT FOR PLOTTING SE-N-PLOT OF GENOME-WIDE ASSOCIATION RESULTS #####
#
# Adapted from EasyQC by Thomas Winkler and Mathias Gorski.
# website: http://www.uni-regensburg.de/medizin/epidemiologie-praeventivmedizin/genetische-epidemiologie/software/index.html
# citation: http://www.nature.com/nprot/journal/v9/n5/full/nprot.2014.071.html
# 
# Description:  This script plots the inverse of the median standard error of the 
#               beta estimates accross all SNPs against the square root of the sample
#               size for the GWAS study.
#               
# Usage: 		R CMD BATCH --args -CL -input.txt -[PNG/PDF/TIFF] -output.[PNG/PDF/TIFF] se_n_lambda_plot.R
# 
# Input data: 	required: 
#               ONLY the output of the se-n-lambda.pl script; this consists of
#				        4 columns (Study Median_SE Lambda Mean_N) WITH headers
# 			  	    Columns present:
# 			      	- V1=[Study]
# 			      	- V2=[Median_SE]
# 		      		- V3=[Lambda]
# 		      		- V4=[Mean_N]
# Image styles: PDF (width=10, height=5), PNG (width=1280, height=720), 
#				        TIFF (width=1280, height=720, resolution=150).
# 				      Note on the image styles: PNG can best be used in PowerPoint
#				        presentations, whereas TIFF produces high-quality, large-sized 
#				        files for publication purposes.
# Output:       Name of the output-file with the correct extension [PNG/PDf/TIFF]
#
# Update: 2015-02-26
# Editor: Sander W. van der Laan
# E-mail: s.w.vanderlaan-2@umcutrecht.nl

### READS INPUT OPTIONS ###
rm(list=ls())
x <- 0
repeat {
		x <- x+1
		if (commandArgs()[x] == "-CL") {
			input <- commandArgs()[x+1]; input <- substr(input, 2, nchar(input))
			image_style <- commandArgs()[x+2]; image_style <- substr(image_style, 2, nchar(image_style))
			output <- commandArgs()[x+3]; output <- substr(output, 2, nchar(output))
			break
			}
		if (x == length(commandArgs())) {
				print("remember the -CL command!")
				break
				}
		}
rm(x)

#---------------------------------------------------------------------------------#
### READ IN THE DATA ###

data <- read.table(input, header=TRUE)

#---------------------------------------------------------------------------------#
# INSTALLATION OF REQUIRED PACKAGE(S)
# Install function for packages  
packages<-function(x){
  x<-as.character(match.call()[[2]])
  if (!require(x,character.only=TRUE)){
    install.packages(pkgs=x,repos="http://cran.r-project.org")
    require(x,character.only=TRUE)
  }
}
# Install and load required package(s)
packages(calibrate) #the "calibrate" package is needed to plot text at the datapoints    
library(calibrate)
#---------------------------------------------------------------------------------#
# PLOTTING

### DEFINE PLOT COLORS ###
### Define plotting colors for each element/point of the plot.
###  UtrechtSciencePark Colours Scheme
###	yellow				  #FBB820 => 1 or 1.0 > INFO
###	gold				    #F59D10 => 2
###	salmon				  #E55738 => 3 or 0.05 < MAF < 0.2 or 0.4 < INFO < 0.6
###	darkpink			  #DB003F => 4
###	lightpink			  #E35493 => 5 or 0.8 < INFO < 1.0
###	pink				    #D5267B => 6
###	hardpink			  #CC0071 => 7
###	lightpurple			#A8448A => 8
###	purple				  #9A3480 => 9
###	lavendel			  #8D5B9A => 10
###	bluepurple			#705296 => 11
###	purpleblue			#686AA9 => 12
###	lightpurpleblue	#6173AD => 13
###	seablue				  #4C81BF => 14
###	skyblue				  #2F8BC9 => 15
###	azurblue			  #1290D9 => 16 or 0.01 < MAF < 0.05 or 0.2 < INFO < 0.4
###	lightazurblue		#1396D8 => 17
###	greenblue			  #15A6C1 => 18
###	seaweedgreen		#5EB17F => 19
###	yellowgreen			#86B833 => 20
###	lightmossgreen	#C5D220 => 21
###	mossgreen			  #9FC228 => 22 or MAF > 0.20 or 0.6 < INFO < 0.8
###	lightgreen			#78B113 => 23/X/x
###	green				    #49A01D => 24/Y/y
###	grey				    #595A5C => 25/XY/xy/Xy/xY or MAF < 0.01 or 0.0 < INFO < 0.2
###	lightgrey			  #A2A3A4	 => 26/MT/Mt/mt/mT

## Plots axes and null distribution
print("Determining what type of image should be produced and plotting axes.")
if (image_style == "PNG") 
  png(output, width=600, height=800)

if (image_style == "TIFF") 
  tiff(output, width=600, height=800)

if (image_style == "PDF") 
  pdf(output, width=6, height=8)

# Plotting 2 figures arranged in 1 row1 and 2 columns
  par(mfrow=c(2,1), mar=c(4,4,4,4))
# plot 1/(median(SE)) vs. sqrt(N)  
  plot(sqrt(data$Mean_N), (data$Median_SE), 
       main="SE-N plot", xlab=expression(sqrt(paste(italic(N)))), ylab="Inverse median SE", 
       xlim= c(0, 1.5*max(sqrt(data$Mean_N))), ylim=c(0, 1.5*max(data$Median_SE)), 
       col="#E55738", pch=20, bty="n", cex.lab=0.75, cex.axis=0.75,
       xaxs="i", yaxs="i")
  abline(a=0, b=((1.5*max(data$Median_SE))/(1.5*max(sqrt(data$Mean_N)))), col="#595A5C", lty=2)
  textxy(sqrt(data$Mean_N), (data$Median_SE), data$Study, cex=0.5)

# plot lambda(p) vs. sqrt(N)  
  plot(sqrt(data$Mean_N), data$Lambda, 
       main="Lambda-N plot", xlab=expression(sqrt(paste(italic(N)))), ylab=expression(lambda), 
       xlim=c(0, 1.5*max(sqrt(data$Mean_N))), ylim=c(0.9*min(data$Lambda), 1.2*max(data$Lambda)), 
       col="#9FC228", pch=20, bty="n", cex.lab=0.75, cex.axis=0.75,
       xaxs="i", yaxs="i")
  abline(h=1.0, col="#595A5C", lty=2)
  abline(h=1.1, col="#E55738", lty=3)
  textxy(sqrt(data$Mean_N), data$Lambda, data$Study, cex=0.5)
  
  dev.off()
