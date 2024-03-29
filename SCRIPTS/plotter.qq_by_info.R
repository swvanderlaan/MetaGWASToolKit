#!/hpc/local/Rocky8/dhl_ec/software/R-3.6.3/bin/Rscript --vanilla

### Mac OS X version
### #!/usr/local/bin/Rscript --vanilla

### Linux version
### #!/hpc/local/Rocky8/dhl_ec/software/R-3.6.3/bin/Rscript --vanilla

cat("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    QQ by INFO-score Plotter -- MetaGWASToolKit
    \n
    * Version: v1.2.0
    * Last edit: 2023-05-15
    * Created by: Sander W. van der Laan | s.w.vanderlaan@gmail.com
    * Edited by: Mike Puijk | mikepuijk@hotmail.com
    \n
    * Description: QQ-Plotter for GWAS (meta-analysis) results stratified 
      by imputation quality (INFO-score). Can produce output in different colours 
      and image-formats. Two columns are required:
      - first with a test-statistic (Z-score, Chi^2, or P-value)
      - second with INFO-metric
      NO HEADER.
    The script should be usuable on both any Linux distribution with R 3+ installed, Mac OS X and Windows.
    
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n")

# usage: ./plotter.qq_by_info.R -p projectdir -r resultfile -o outputdir -s stattype -f imageformat [OPTIONAL: -v verbose (DEFAULT) -q quiet]
#        ./plotter.qq_by_info.R --projectdir projectdir --resultfile resultfile --outputdir outputdir --stattype stattype --imageformat imageformat [OPTIONAL: --verbose verbose (DEFAULT) -quiet quiet]

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
                 help="Path to the results directory, relative to the project directory. Two columns are expected:
                  1) test-statistic (Z-score, Chi^2, or P-value)
                  2) imputation quality score (INFO)"),
     make_option(c("-s", "--stattype"), action="store", default=NA, type='character',
                 help="The statistics type input for the QQ-plot: 
                 \n- Z:      Z-scores
                 \n- CHISQ:  Chi^2 statistic
                 \n- PVAL:   P-values."),
     make_option(c("-f", "--imageformat"), action="store", default=NA, type='character',
                 help="The image format (PDF (width=10, height=10), PNG/TIFF/EPS (width=800, height=800)."),
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
#opt$projectdir="/Users/swvanderlaan/PLINK/_CARDIoGRAM/cardiogramplusc4d_1kg_cad_add/"
#opt$outputdir="/Users/swvanderlaan/PLINK/_CARDIoGRAM/cardiogramplusc4d_1kg_cad_add/" 
#opt$stattype="PVAL"
#opt$imageformat="PNG"
#opt$resultfile="/Users/swvanderlaan/PLINK/_CARDIoGRAM/cardiogramplusc4d_1kg_cad_add/cad.add.160614.website.qqbyinfo.txt.gz"
#opt$resultfile="/Users/swvanderlaan/PLINK/_CARDIoGRAM/cardiogramplusc4d_1kg_cad_add/cad.add.160614.website.qqbycaf.txt.gz"
#opt$resultfile="/Users/swvanderlaan/PLINK/_CARDIoGRAM/cardiogramplusc4d_1kg_cad_add/cad.add.160614.website.qq.txt.gz"

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
cat("Wow. We are finally starting \"QQ-Plotter - stratification by imputation quality\". ")
#--------------------------------------------------------------------------
### START OF THE PROGRAM
# main point of program is here, do this whether or not "verbose" is set
if(!is.na(opt$projectdir) & !is.na(opt$resultfile) & !is.na(opt$outputdir) & !is.na(opt$stattype) & !is.na(opt$imageformat)) {
  ### set studyname
  study <- file_path_sans_ext(basename(opt$resultfile)) # argument 2
  cat(paste("We are going to \nmake the QQ-plot stratified by INFO-score of your (meta-)GWAS results. \nData are taken from.....: '",study,"'\nand will be outputed in.....: '", opt$outputdir, "'.\n",sep=''))
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
     plotQQ <- function(z, color, cex){
       p <- 2*pnorm(-abs(z))
       p <- sort(p)
       expected <- c(1:length(p))
       lobs <- -(log10(p))
       lexp <- -(log10(expected / (length(expected)+1)))
       
       # Plots all points with p < 1e-3 (0.001)
       cat("  - plotting all points p < 1e-3 (0.001).\n")
       p_sig = subset(p,p<0.001)
       points(lexp[1:length(p_sig)], lobs[1:length(p_sig)], pch = 21, cex = 1.75, col = color, bg = color)
       
       # Samples 10,000 points from p > 1e-3
       cat("  - sampling 10,000 points from p < 1e-3 (0.001).\n")
       n=10000
       i<- c(length(p)- c(0,round(log(2:(n-1))/log(n)*length(p))),1)
       lobs_bottom=subset(lobs[i],lobs[i] <= 3)
       lexp_bottom=lexp[i[1:length(lobs_bottom)]]
       
       if (length(lobs_bottom) != length(lexp_bottom)) {
         lobs_bottom <- lobs_bottom[1:length(lexp_bottom)]
       }
       
       #cat(length(lobs_bottom))
       #cat(length(lexp_bottom))
       
       points(lexp_bottom, lobs_bottom, pch = 21, cex = cex, col = color, bg = color)
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
     cat("\n* The file appears to be gzipped, now loading...\n")
       # zcat should not be needed anymore - fread is able to read gz/zip-files.
       # rawdata = fread(paste0("zcat < ",opt$resultfile), header = FALSE, blank.lines.skip = TRUE)
       rawdata = fread(paste0(opt$resultfile), header = FALSE, blank.lines.skip = TRUE)
     } else if(filetype != "gzfile") {
     cat("\n* The file appears not to be gzipped, now loading...\n")
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
     
     maxY <- round(max(-log10(data$V1)))  	
     maxYplot <- maxY + 3
     cat(paste0("\n* The maximum on the Y-axis: ", round(maxY, digits = 0),"."))
     
     ### Stratify by INFO-metric/imputation quality (r^2)
     impqc_lo1=subset(data, ( data$V2 >= 0.0 & data$V2 <= 0.20 ))
     impqc_lo2=subset(data, ( data$V2 > 0.20 & data$V2 <= 0.40 ))
     impqc_lo3=subset(data, ( data$V2 > 0.40 & data$V2 <= 0.60 ))
     impqc_lo4=subset(data, ( data$V2 > 0.60 & data$V2 <= 0.80 ))
     impqc_lo5=subset(data, ( data$V2 > 0.80 & data$V2 <= 1.00 ))
     impqc_lo6=subset(data, ( data$V2 > 1.00 ))
     
     z=qnorm(data$V1/2)
     z_lo1=qnorm(impqc_lo1$V1/2)
     z_lo2=qnorm(impqc_lo2$V1/2)
     z_lo3=qnorm(impqc_lo3$V1/2)
     z_lo4=qnorm(impqc_lo4$V1/2)
     z_lo5=qnorm(impqc_lo5$V1/2)
     z_lo6=qnorm(impqc_lo6$V1/2)
     
     n_snps1=formatC(length(z_lo1), format="d", big.mark=',')
     n_snps2=formatC(length(z_lo2), format="d", big.mark=',')
     n_snps3=formatC(length(z_lo3), format="d", big.mark=',')
     n_snps4=formatC(length(z_lo4), format="d", big.mark=',')
     n_snps5=formatC(length(z_lo5), format="d", big.mark=',')
     n_snps6=formatC(length(z_lo6), format="d", big.mark=',')
     
     #--------------------------------------------------------------------------
     ### CALCULATES LAMBDA AND # variants
     cat("\nCalculating lambda and number of variants from data.")
     n_snps = formatC(length(z), format="d", big.mark=',')
     cat(paste0("\n - number of variants...: ",format(n_snps, big.mark = ",")))
     lambdavalue = round(median(z^2)/qchisq(0.5, df = 1),3)
     cat(paste0("\n - lambda...............: ",round(lambdavalue, digits = 4)))
     
     l1 = round(median(z_lo1^2)/qchisq(0.5,df=1),3)
     l2 = round(median(z_lo2^2)/qchisq(0.5,df=1),3)
     l3 = round(median(z_lo3^2)/qchisq(0.5,df=1),3)
     l4 = round(median(z_lo4^2)/qchisq(0.5,df=1),3)
     l5 = round(median(z_lo5^2)/qchisq(0.5,df=1),3)
     l6 = round(median(z_lo6^2)/qchisq(0.5,df=1),3)
     
     #--------------------------------------------------------------------------
     ### PLOTS AXES AND NULL DISTRIBUTION
     if (opt$imageformat == "PNG") 
       png(paste0(opt$outputdir,"/",study,".png"), width = 800, height = 800)
     
     if (opt$imageformat == "TIFF") 
       tiff(paste0(opt$outputdir,"/",study,".tiff"), width = 800, height = 800)
     
     if (opt$imageformat == "EPS") 
       postscript(file = paste0(opt$outputdir,"/",study,".eps"), horizontal = FALSE, onefile = FALSE, paper = "special")
     
     if (opt$imageformat == "PDF") 
       pdf(paste0(opt$outputdir,"/",study,".pdf"), width = 10, height = 10)
     
     cat("\n\nSetting up plot area.")
     #Plot expected p-value distribution line
     par(mar=c(5,5,4,5)+0.1) # sets the bottom, left, top and right margins
     plot(c(0, maxYplot), c(0, maxYplot), col = "#E55738", lwd = 1, type = "l",
          xlab = expression(Expected~~-log[10](italic(p)-value)), ylab = expression(Observed~~-log[10](italic(p)-value)),
          xlim = c(0, maxYplot), ylim = c(0, maxYplot), las = 1,
          xaxs = "i", yaxs = "i", bty = "l",
          cex.axis = 2, cex.lab = 1.75, cex.main = 3,
          main = c(substitute(paste("QQ-plot stratified by imputation quality - ",lambda," = ", lam),list(lam = lambdavalue)),expression()))
     
     #--------------------------------------------------------------------------
     ### PLOTS DATA
     cat("\n* Plotting data.")
     cat("\n- sample of all data.\n")
     plotQQ(z, "black", 1.25);
     cat("\n- sample of data with 0.0 < info < 0.2.\n")
     plotQQ(z_lo1, "#595A5C", 1.25);
     cat("\n- sample of data with 0.2 < info < 0.4.\n")
     plotQQ(z_lo2, "#1290D9", 1.25);
     cat("\n- sample of data with 0.4 < info < 0.6.\n")
     plotQQ(z_lo3, "#DB003F", 1.25);
     cat("\n- sample of data with 0.6 < info < 0.8.\n")
     plotQQ(z_lo4, "#9FC228", 1.25);
     cat("\n- sample of data with 0.8 < info < 1.0.\n")
     plotQQ(z_lo5, "#E35493", 1.25);
     cat("\n- sample of data with info > 1.0.\n")
     plotQQ(z_lo6, "#FBB820", 1.25);
     
     #--------------------------------------------------------------------------
     ### PROVIDES LEGEND
     cat("\n* Adding legend and closing image.")
     legend(0.2, maxYplot, legend=c("Expected",
                              substitute(paste("Observed [n = ", snps, "]"),list(snps = n_snps)),expression(),
                              #paste("0.0 < INFO < 0.2 [",format(length(z_lo1),big.mark = ","),"]"),
                              #paste("0.2 < INFO < 0.4 [",format(length(z_lo2),big.mark = ","),"]"),
                              #paste("0.4 < INFO < 0.6 [",format(length(z_lo3),big.mark = ","),"]"),
                              #paste("0.6 < INFO < 0.8 [",format(length(z_lo4),big.mark = ","),"]"),
                              #paste("0.8 < INFO < 1.0 [",format(length(z_lo5),big.mark = ","),"]"),
                              #paste("1.0 > INFO [",format(length(z_lo6),big.mark = ","),"]")),
                              substitute(paste("0.0 <= INFO <= 0.2 [", lambda," = ", lam, ", n = ", snps, "]"),list(lam = l1, snps = n_snps1)),expression(),
                              substitute(paste("0.2 < INFO <= 0.4 [", lambda," = ", lam, ", n = ", snps, "]"),list(lam = l2, snps = n_snps2)),expression(),
                              substitute(paste("0.4 < INFO <= 0.6 [", lambda," = ", lam, ", n = ", snps, "]"),list(lam = l3, snps = n_snps3)),expression(),
                              substitute(paste("0.6 < INFO <= 0.8 [", lambda," = ", lam, ", n = ", snps, "]"),list(lam = l4, snps = n_snps4)),expression(),
                              substitute(paste("0.8 < INFO <= 1.0 [", lambda," = ", lam, ", n = ", snps, "]"),list(lam = l5, snps = n_snps5)),expression(),
                              substitute(paste("1.0 > INFO [", lambda," = ", lam, ", n = ", snps, "]"),list(lam = l6, snps = n_snps6)),expression()),
            pch=c((vector("numeric",5)+1)*23), cex=1.4, 
            pt.bg=c("#E55738","black","#595A5C","#1290D9","#DB003F", "#9FC228", "#E35493", "#FBB820"),
            bty="n",title="Legend",title.adj=0)
     
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
cat(paste("\n\nAll done plotting a QQ-plot stratified by INFO-score of",study,".\n"))
cat(paste("\nToday's: ",Today, "\n"))
cat("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n")

#--------------------------------------------------------------------------
#
# ### SAVE ENVIRONMENT | FOR DEBUGGING
# save.image(paste0(opt$outputdir,"/",Today,"_",study,"_DEBUG_QQPLOT_BY_INFO.RData"))

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
