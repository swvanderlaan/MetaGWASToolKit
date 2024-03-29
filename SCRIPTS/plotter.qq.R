#!/hpc/local/Rocky8/dhl_ec/software/R-3.6.3/bin/Rscript --vanilla

### Mac OS X version
### #!/usr/local/bin/Rscript --vanilla

### Linux version
### #!/hpc/local/Rocky8/dhl_ec/software/R-3.6.3/bin/Rscript --vanilla

cat("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    QQ Plotter -- MetaGWASToolKit
    \n
    * Version: v1.3.0
    * Last edit: 2023-05-11
    * Created by: Sander W. van der Laan | s.w.vanderlaan@gmail.com
    \n
    * Description:  QQ-Plotter for GWAS (meta-analysis) results. Can produce 
    output in different colours and image-formats. One column is expected
    containing the test-statistic (Z-score, Chi^2, or P-value). 
    NO HEADER.
    The script should be usuable on both any Linux distribution with R 3+ installed, Mac OS X and Windows.
    
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n")

# usage: ./plotter.qq.R -p projectdir -r resultfile -o outputdir -s stattype -f imageformat [OPTIONAL: -v verbose (DEFAULT) -q quiet]
#        ./plotter.qq.R --projectdir projectdir --resultfile resultfile --outputdir outputdir --stattype stattype --imageformat imageformat [OPTIONAL: --verbose verbose (DEFAULT) -quiet quiet]

cat("\n* Clearing the environment...\n\n")
#--------------------------------------------------------------------------
### CLEAR THE BOARD
rm(list=ls())

cat("\n* Loading function to install packages...\n\n")
### Prerequisite: 'optparse'-library
### * Manual: http://cran.r-project.org/web/packages/optparse/optparse.pdf
### * Vignette: http://www.icesi.edu.co/CRAN/web/packages/optparse/vignettes/optparse.pdf

### Don't say "Loading required package: optparse"...
###suppressPackageStartupMessages(require(optparse))
###require(optparse)

### The part of installing (and loading) packages via Rscript doesn't properly work.
### FUNCTION TO INSTALL PACKAGES
install.packages.auto <- function(x) { 
  x <- as.character(substitute(x)) 
  if(isTRUE(x %in% .packages(all.available = TRUE))) { 
    eval(parse(text = sprintf("require(\"%s\")", x)))
  } else { 
    # Update installed packages - this may mean a full upgrade of R, which in turn
    # may not be warrented. 
    #update.install.packages.auto(ask = FALSE) 
    eval(parse(text = sprintf("install.packages(\"%s\", dependencies = TRUE, repos = \"https://cloud.r-project.org/\")", x)))
  }
  if(isTRUE(x %in% .packages(all.available = TRUE))) { 
    eval(parse(text = sprintf("require(\"%s\")", x)))
  } else {
    if (!requireNamespace("BiocManager"))
      install.packages("BiocManager")
    BiocManager::install() # this would entail updating installed packages, which in turned may not be warrented
    
    # Code for older versions of R (<3.5.0)
    # source("http://bioconductor.org/biocLite.R")
    # Update installed packages - this may mean a full upgrade of R, which in turn
    # may not be warrented.
    # biocLite(character(), ask = FALSE) 
    eval(parse(text = sprintf("BiocManager::install(\"%s\")", x)))
    eval(parse(text = sprintf("require(\"%s\")", x)))
  }
}

cat("\n* Checking availability of required packages and installing if needed...\n\n")
### INSTALL PACKAGES WE NEED
install.packages.auto("optparse")
install.packages.auto("tools")
install.packages.auto("dplyr")
install.packages.auto("tidyr")
install.packages.auto("data.table")

cat("\nDone! Required packages installed and loaded.\n\n")

cat("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n")
uithof_color=c("#FBB820","#F59D10","#E55738","#DB003F","#E35493","#D5267B",
               "#CC0071","#A8448A","#9A3480","#8D5B9A","#705296","#686AA9",
               "#6173AD","#4C81BF","#2F8BC9","#1290D9","#1396D8","#15A6C1",
               "#5EB17F","#86B833","#C5D220","#9FC228","#78B113","#49A01D",
               "#595A5C","#A2A3A4", "#D7D8D7", "#ECECEC", "#FFFFFF", "#000000")

#--------------------------------------------------------------------------
### OPTION LISTING
option_list = list(
  make_option(c("-p", "--projectdir"), action="store", default=NA, type='character',
              help="Path to the project directory."),
  make_option(c("-r", "--resultfile"), action="store", default=NA, type='character',
              help="Path to the results directory, relative to the project directory.
                A single column is expected containing the test-statistic (Z-score, Chi^2, or P-value)."),
  make_option(c("-s", "--stattype"), action="store", default=NA, type='character',
              help="The statistics type input for the QQ-plot: 
              \n- Z:      Z-scores
              \n- CHISQ:  Chi^2 statistic
              \n- PVAL:   P-values."),
  make_option(c("-f", "--imageformat"), action="store", default=NA, type='character',
              help="The image format (PDF (width=10, height=10), PNG/TIFF/EPS (width=800, height=800) of the Manhattan plot."),
  make_option(c("-o", "--outputdir"), action="store", default=NA, type='character',
              help="Path to the output directory."),
  make_option(c("-v", "--verbose"), action="store_true", default=TRUE,
              help="Should the program print extra stuff out? [default %default]"),
  make_option(c("-q", "--quiet"), action="store_false", dest="verbose",
              help="Make the program not be verbose.")
  #make_option(c("-c", "--cvar"), action="store", default="this is c",
  #            help="a variable named c, with a default [default %default]")  
  )
opt = parse_args(OptionParser(option_list=option_list))

#--------------------------------------------------------------------------
### FOR LOCAL DEBUGGING
#opt$projectdir="/Users/swvanderlaan/PLINK/analyses/meta_gwasfabp4/epic_nl"
#opt$outputdir="/Users/swvanderlaan/PLINK/analyses/meta_gwasfabp4/epic_nl"
#opt$stattype="PVAL"
#opt$imageformat="PDF"
#opt$resultfile="/Users/swvanderlaan/PLINK/analyses/meta_gwasfabp4/epic_nl/EPICNL.WHOLE.FABP4adjBMIeGFR.20160629.QQ.txt"

if (opt$verbose) {
  # if (opt$verbose) {
  # you can use either the long or short name
  # so opt$a and opt$avar are the same.
  # show the user what the variables are
  cat("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n")
  cat("Checking the settings.")
  cat("\nThe project directory....................: ")
  cat(opt$projectdir)
  cat("\n\nThe results file.........................: ")
  cat(opt$resultfile)
  cat("\n\nThe output directory.....................: ")
  cat(opt$outputdir)
  cat("\n\nThe statistics type......................: ")
  cat(opt$stattype)
  cat("\n\nThe image format.........................: ")
  cat(opt$imageformat)
  cat("\n\n")
  
}
cat("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n")
cat("Wow. We are finally starting \"QQ-Plotter\". ")
#--------------------------------------------------------------------------
### START OF THE PROGRAM
# main point of program is here, do this whether or not "verbose" is set
if(!is.na(opt$projectdir) & !is.na(opt$resultfile) & !is.na(opt$outputdir) & !is.na(opt$stattype) & !is.na(opt$imageformat)) {
  ### set studyname
  study <- file_path_sans_ext(basename(opt$resultfile)) # argument 2
  cat(paste("We are going to \nmake the QQ-plot of your (meta-)GWAS results. \nData are taken from.....: '",study,"'\nand will be outputed in.....: '", opt$outputdir, "'.\n",sep=''))
  cat("\n\n")

  #--------------------------------------------------------------------------
  ### GENERAL SETUP
  Today=format(as.Date(as.POSIXlt(Sys.time())), "%Y%m%d")
  cat(paste("Today's date is: ", Today, ".\n", sep = ''))
  
  #--------------------------------------------------------------------------
  ### DEFINE THE LOCATIONS OF DATA
  ROOT_loc = opt$projectdir # argument 1
  OUT_loc = opt$outputdir # argument 4
  
  #--------------------------------------------------------------------------
  #### DEFINE THE PLOT FUNCTION
  
  ### Note about color: To make the confidence interval transparent, 
  ### it's given as rgb, with the transparency as last argument. 
  ### To look up rgb values for base colors (in 8-bit) do col2rgb, e.g. col2rgb("grey90").
  plotQQ <- function(z, color, confidence=T, confidence.col=rgb(229,229,229,60,maxColorValue=256), confidence.border="#E55738"){
    p <- 2*pnorm(-abs(z))
    p <- sort(p)
    expected <- c(1:length(p))
    lobs <- -(log10(p))
    lexp <- -(log10(expected / (length(expected)+1)))
    
    # Calculate confidence intervals
    find_conf_intervals = function(row){
      i = row[1]
      len = row[2]
      if (i < 1000 | i %% 100 == 0){
        return(c(-log10(qbeta(0.95,i,len-i+1)), -log10(qbeta(0.05,i,len-i+1))))
      } else { # Speed up
        return(c(NA,NA))
      }
    }
    
    # Find approximate confidence intervals
    if (isTRUE(confidence)){
      cat("\nPlotting confidence intervals.")
      ci = apply(cbind( 1:length(lexp), rep(length(lexp),length(lexp))), MARGIN=1, FUN=find_conf_intervals)
      bks = append(seq(1000,length(lexp),100),length(lexp)+1)
      for (i in 1:(length(bks)-1)){
        ci[1, bks[i]:(bks[i+1]-1)] = ci[1, bks[i]]
        ci[2, bks[i]:(bks[i+1]-1)] = ci[2, bks[i]]
      }
      colnames(ci) = names(lexp)
      # Extrapolate to make plotting prettier (doesn't affect interpretation at data points)
      slopes = c((ci[1,1] - ci[1,2]) / (lexp[1] - lexp[2]), (ci[2,1] - ci[2,2]) / (lexp[1] - lexp[2]))
      extrap_x = append(lexp[1]+xspace, lexp) #extrapolate slightly for plotting purposes only
      extrap_y = cbind( c(ci[1,1] + slopes[1]*xspace, ci[2,1] + slopes[2]*xspace), ci)
      polygon(c(extrap_x, rev(extrap_x)), c(extrap_y[1,], rev(extrap_y[2,])), col = confidence.col[1], border = confidence.border[1], lty = 2)  
    }
    
    # Plots all points with p < 1e-3 (0.001)
    cat("\nPlotting all points p < 1e-3 (0.001).")
    p_sig = subset(p,p<0.001)
    points(lexp[1:length(p_sig)], lobs[1:length(p_sig)], pch = 21, cex = 1.75, col=color, bg=color)
    
    # Samples 2,500 points from p > 1e-3
    cat("\nSampling 2,500 points from p < 1e-3 (0.001).")
    n = 2500
    i <- c(length(p)- c(0,round(log(2:(n-1))/log(n)*length(p))),1)
    lobs_bottom=subset(lobs[i],lobs[i] <= 3)
    lexp_bottom=lexp[i[1:length(lobs_bottom)]]
    
    print(length(lobs_bottom))
    print(length(lexp_bottom))
    
    points(lexp_bottom, lobs_bottom, pch = 21, cex = 1.75, col = color, bg = color)
    
  }
  
  #--------------------------------------------------------------------------
  ### LOADING RESULTS FILE
  ### Location of is set by 'opt$resultfile' # argument 2
  cat("\n\nLoading results file and removing NA's...")

  ### Checking file type -- is it gzipped or not?
  data_connection <- file(opt$resultfile)
  data_connection
  filetype <- summary(data_connection)$class
  filetype
  close(data_connection)
 
  ### Loading the data
  if(filetype == "gzfile"){
  cat("\n* The file appears to be gzipped, now loading...")
    # zcat should not be needed anymore - fread is able to read gz/zip-files.
    # rawdata = fread(paste0("zcat < ",opt$resultfile), header = FALSE, blank.lines.skip = TRUE)
    rawdata = fread(paste0(opt$resultfile), header = FALSE, blank.lines.skip = TRUE)
  } else if(filetype != "gzfile") {
  cat("\n* The file appears not to be gzipped, now loading...")
    rawdata = fread(opt$resultfile, header = FALSE, blank.lines.skip = TRUE)
  } else {
  cat ("\n\n*** ERROR *** Something is rotten in the City of Gotham. We can't determine the file type 
of the data. Double back, please.\n\n", 
         file=stderr()) # print error messages to stder
  }
  cat("\n* Removing NA's...")
  data <- na.omit(rawdata)
  
  # determine statistics type
  if (opt$stattype == "Z") # set by 'opt$stattype' # argument 3
    z=data$V1
  
  if (opt$stattype == "CHISQ")
    z=sqrt(data$V1)
  
  if (opt$stattype == "PVAL")
    z=qnorm(data$V1/2)
  
  maxY <- round(max(-log10(data$V1))+1)
  maxYplot <- maxY + 3
  # maxYplot <- 9
  cat(paste0("\n* The maximum on the Y-axis: ", round(maxY, digits = 0),"."))
     
  #--------------------------------------------------------------------------
  ### CALCULATES LAMBDA AND # variants
  cat("\n\nCalculating lambda from data.\n")
  lambda = round(median(z^2)/qchisq(0.5, df = 1),3)
  lambda
  n_snps = formatC(length(z), format="d", big.mark=',')
  n_snps
  
  #--------------------------------------------------------------------------
  ### PLOTS AXES AND NULL DISTRIBUTION
  cat("\n\nDetermining what type of image should be produced and plotting axes with null distribution.")
  if (opt$imageformat == "PNG") 
    png(paste0(opt$outputdir,"/",study,".png"), width = 800, height = 800)
  
  if (opt$imageformat == "TIFF") 
    tiff(paste0(opt$outputdir,"/",study,".tiff"), width = 800, height = 800)
  
  if (opt$imageformat == "EPS") 
    postscript(file = paste0(opt$outputdir,"/",study,".ps"), horizontal = FALSE, onefile = FALSE, paper = "special")
  
  if (opt$imageformat == "PDF") 
    pdf(paste0(opt$outputdir,"/",study,".pdf"), width = 10, height = 10)
  
  cat("\n- Setting up plot area.")
  # Setting xspace doesn't affect the interpretation of the 
  # QQ-plot, it's merely a way to visualize the polygon of the CI.
  xspace = 100
  cat("\n- Setting up plot area.")
  #Plot expected p-value distribution line
  par(mar=c(5,5,4,2)+0.1) # sets the bottom, left, top and right margins
  plot(c(0, maxYplot), c(0, maxYplot), col = "#E55738", lwd = 1, type = "l", 
       xlab = expression(Expected~~-log[10](italic(p)-value)), ylab = expression(Observed~~-log[10](italic(p)-value)), 
       las = 1, 
       xaxs = "i", yaxs = "i", bty = "l", 
       cex.axis = 2, cex.lab = 1.75, cex.main = 3, 
       main = "QQ-plot")
    
  #--------------------------------------------------------------------------
  ### PLOTS DATA
  cat("\n- Plotting data.") 	
  plotQQ(z, "black");
  
  #--------------------------------------------------------------------------
  ### PROVIDES LEGEND
  cat("\n- Adding legend and closing image.")
  legend(.2, maxYplot, legend = c("Expected","Observed","95% CI",lambda,paste(c(formatC(length(z), format="d", big.mark = ',')), "variants")), pch = c(23,23,23,32,32), cex = 1.4, pt.bg = c("#E55738","black", rgb(205,55,0,15,maxColorValue=256),"black","black"),bty = "n", title = "Legend", title.adj = 0)->leg
  points(leg$text$x[4]-0.12, leg$text$y[4], pch = 108, font = 5)
  points(leg$text$x[5]-0.12, leg$text$y[5], pch = 35, font = 1)
  
  dev.off()
  
} else {
  cat("\n\n\n\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n")
  cat("\n*** ERROR *** You didn't specify all variables:\n
      - --p/projectdir  : path to project directory\n
      - --r/resultfile  : path to resultfile\n
      - --o/outputdir   : path to output directory\n
      - --s/stattype    : the test-statistic (Z-score, Chi^2, or P-value)\n
      - --f/imageformat : the image format (PDF, PNG, TIFF or PostScript)\n\n", 
      file=stderr()) # print error messages to stderr
}

#--------------------------------------------------------------------------
### CLOSING MESSAGE
cat(paste("All done plotting a QQ-plot of",study,".\n"))
cat(paste("\nToday's: ",Today, "\n"))
cat("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n")

#--------------------------------------------------------------------------
#
# ### SAVE ENVIRONMENT | FOR DEBUGGING
# save.image(paste0(opt$outputdir,"/",Today,"_",study,"_DEBUG_QQPLOT.RData"))


###	UtrechtSciencePark Colours Scheme
###
### Website to convert HEX to RGB: http://hex.colorrrs.com.
### For some functions you should divide these numbers by 255.
###
###	No.	Color				HEX		RGB							CMYK					CHR		MAF/INFO
### --------------------------------------------------------------------------------------------------------------------
###	1	yellow				#FBB820 (251,184,32)				(0,26.69,87.25,1.57) 	=>	1 		or 1.0 > INFO
###	2	gold				#F59D10 (245,157,16)				(0,35.92,93.47,3.92) 	=>	2		
###	3	salmon				#E55738 (229,87,56) 				(0,62.01,75.55,10.2) 	=>	3 		or 0.05 < MAF < 0.2 or 0.4 < INFO < 0.6
###	4	darkpink			#DB003F ((219,0,63)					(0,100,71.23,14.12) 	=>	4		
###	5	lightpink			#E35493 (227,84,147)				(0,63,35.24,10.98) 		=>	5 		or 0.8 < INFO < 1.0
###	6	pink				#D5267B (213,38,123)				(0,82.16,42.25,16.47) 	=>	6		
###	7	hardpink			#CC0071 (204,0,113)					(0,0,0,0) 	=>	7		
###	8	lightpurple			#A8448A (168,68,138)				(0,0,0,0) 	=>	8		
###	9	purple				#9A3480 (154,52,128)				(0,0,0,0) 	=>	9		
###	10	lavendel			#8D5B9A (141,91,154)				(0,0,0,0) 	=>	10		
###	11	bluepurple			#705296 (112,82,150)				(0,0,0,0) 	=>	11		
###	12	purpleblue			#686AA9 (104,106,169)				(0,0,0,0) 	=>	12		
###	13	lightpurpleblue		#6173AD (97,115,173/101,120,180)	(0,0,0,0) 	=>	13		
###	14	seablue				#4C81BF (76,129,191)				(0,0,0,0) 	=>	14		
###	15	skyblue				#2F8BC9 (47,139,201)				(0,0,0,0) 	=>	15		
###	16	azurblue			#1290D9 (18,144,217)				(0,0,0,0) 	=>	16		 or 0.01 < MAF < 0.05 or 0.2 < INFO < 0.4
###	17	lightazurblue		#1396D8 (19,150,216)				(0,0,0,0) 	=>	17		
###	18	greenblue			#15A6C1 (21,166,193)				(0,0,0,0) 	=>	18		
###	19	seaweedgreen		#5EB17F (94,177,127)				(0,0,0,0) 	=>	19		
###	20	yellowgreen			#86B833 (134,184,51)				(0,0,0,0) 	=>	20		
###	21	lightmossgreen		#C5D220 (197,210,32)				(0,0,0,0) 	=>	21		
###	22	mossgreen			#9FC228 (159,194,40)				(0,0,0,0) 	=>	22		or MAF > 0.20 or 0.6 < INFO < 0.8
###	23	lightgreen			#78B113 (120,177,19)				(0,0,0,0) 	=>	23/X
###	24	green				#49A01D (73,160,29)					(0,0,0,0) 	=>	24/Y
###	25	grey				#595A5C (89,90,92)					(0,0,0,0) 	=>	25/XY	or MAF < 0.01 or 0.0 < INFO < 0.2
###	26	lightgrey			#A2A3A4	(162,163,164)				(0,0,0,0) 	=> 	26/MT
### 
### ADDITIONAL COLORS
### 27	midgrey				#D7D8D7
### 28	very lightgrey		#ECECEC
### 29	white				#FFFFFF
### 30	black				#000000
### --------------------------------------------------------------------------------------------------------------------
