#!/hpc/local/CentOS7/dhl_ec/software/R-3.6.3/bin/Rscript 

# SLURM settings
#SBATCH --job-name=gwas.miami    # Job name
#SBATCH --mail-type=END,FAIL          # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=e.j.a.smulders-2@umcutrecht.nl     # Where to send mail
#SBATCH --nodes=1                     #run on one node	
#SBATCH --ntasks=1                    # Run on a single CPU
#SBATCH --mem-per-cpu=10G                    # Job memory request
#SBATCH --time=5:00:00               # Time limit hrs:min:sec
#SBATCH --output=gias_miami.log   # Standard output and error log


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

install.packages.auto("optparse")
install.packages.auto("tools")
install.packages.auto("dplyr")
install.packages.auto("tidyr")
install.packages.auto("data.table")
install.packages.auto("tidyverse")
install.packages.auto("gridExtra")

cat("\nDone! Required packages installed and loaded.\n\n")


### OPTION LISTING
option_list = list(
  make_option(c("-p", "--projectdir"), action = "store", default = NA, type = 'character',
              help = "Path to the project directory."),
  make_option(c("-a", "--top"), action = "store", default = NA, type = 'character',
              help = "Upper half of the plot. Path to the results directory, relative to the project directory. Four columns are required:
                  1) IDs of the variants 
                  2) chromosomes (1-22, X, Y, XY, MT)
                  2) basepair position
                  3) test-statistic (P-value)"),
   make_option(c("-n", "--toptitle"), action = "store", default =  NA, type = 'character',
              help = "name of the upper half of the miami plot"),
   make_option(c("-b", "--bottom"), action = "store", default = NA, type = 'character',
               help = "Bottom half of the plot. Path to the results directory, relative to the project directory. Four columns are required:
                   1) IDs of the variants 
                   2) chromosomes (1-22, X, Y, XY, MT)
                   3) basepair position
                   4) test-statistic (P-value)"),
   make_option(c("-m", "--bottomtitle"), action = "store", default =  NA, type = 'character',
               help = "name of the bottom half of the miami plot"),                
  make_option(c("-f", "--imageformat"), action = "store", default = NA, type =  'character',
              help = "The image format (PDF (width=10, height=5), PNG/TIFF/EPS (width=1280, height=720)."),
  make_option(c("-o", "--outputdir"), action = "store", default =  NA, type = 'character',
              help = "Path to the output directory."),
  make_option(c("-v", "--verbose"), action = "store_true", default = TRUE,
              help = "Should the program print extra stuff out? [default %default]"),
  make_option(c("-q", "--quiet"), action = "store_false", dest = "verbose",
              help = "Make the program not be verbose.")
  # make_option(c("-c", "--cvar"), action="store", default="this is c",
  #             help="a variable named c, with a default [default %default]")  
)
opt = parse_args(OptionParser(option_list = option_list, add_help_option=TRUE))

#--------------------------------------------------------------------------
# 
# ### FOR LOCAL DEBUGGING
# ### MacBook Pro
# MACDIR = "/Users/swvanderlaan/OneDrive - UMC Utrecht"
# ### Mac Pro
# # MACDIR="/Volumes/MyBookStudioII/Backup"
# 
# opt$projectdir = paste0(MACDIR, "/PLINK/analyses/meta_gwasfabp4/ANALYSES2019/metagwas_fabp4/MANUSCRIPT")
# opt$outputdir = paste0(MACDIR, "/PLINK/analyses/meta_gwasfabp4/ANALYSES2019/metagwas_fabp4/MANUSCRIPT/PLOTS")
# opt$colorstyle = "FULL"
# opt$imageformat = "PNG"
# opt$titleplot = "MODEL 1, QC results"
# opt$top = paste0(MACDIR, "/PLINK/analyses/meta_gwasfabp4/ANALYSES2019/metagwas_fabp4/MANUSCRIPT/OUTPUT/meta.GWAS.FABP4.1Gp1.EUR.MODEL1.summary.ELISAonly.QCed.MH.txt.gz")
# #opt$top = paste0(MACDIR, "/iCloud/Downloads/Heleen/HTN_mht.txt")
# ### FOR LOCAL DEBUGGING
# 
#--------------------------------------------------------------------------

if (opt$verbose) {
  # if (opt$verbose) {
  # you can use either the long or short name
  # so opt$a and opt$avar are the same.
  # show the user what the variables are
  cat("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n")
  cat("Checking the settings.")
  cat("\nThe project directory....................: ")
  cat(opt$projectdir)
  cat("\nThe results file of the top plot.........................: ")
  cat(opt$top)
    cat("\nThe results file of the bottom plot.........................: ")
  cat(opt$bottom)
  cat("\nThe output directory.....................: ")
  cat(opt$outputdir)
  cat("\nThe title of the top plot....................: ")
  cat(opt$toptitle)
  cat("\nThe title of the bottom plot....................: ")
  cat(opt$bottomtitle)
  cat("\n\n")
  
}

### START OF THE PROGRAM
# main point of program is here, do this whether or not "verbose" is set
if (!is.na(opt$projectdir) & !is.na(opt$top) & !is.na(opt$bottom) & !is.na(opt$outputdir) & !is.na(opt$imageformat)) {
  study1 <- file_path_sans_ext(basename(opt$top)) # argument 2
  study2 <- file_path_sans_ext(basename(opt$bottom)) # argument 2
  filename1 <- basename(opt$top)
  filename2 <- basename(opt$bottom)
  cat(paste("We are going to a make MIAMI-plot of your (meta-)GWAS results. \nData are taken from.........: '",filename1, "' and '", filename2,  "'\nand will be outputed in.....: '", opt$outputdir, "'.\n",sep = ''))
}
  #--------------------------------------------------------------------------
  ### GENERAL SETUP
  Today = format(as.Date(as.POSIXlt(Sys.time())), "%Y%m%d")
  cat(paste("\nToday's date is: ", Today, ".\n", sep = ''))
  #Time=format(as.POSIXlt(Sys.time()), "%H:%M:%S")
  
  #--------------------------------------------------------------------------
  ### DEFINE THE LOCATIONS OF DATA
  ROOT_loc = opt$projectdir # argument 1
  OUT_loc = opt$outputdir # argument 4
  

#' gmirror
#'
#' Create mirrored Manhattan plots for GWAS
#' Dependencies: ggplot2, gridExtra
#' Suggested: ggrepel
#' @param top data frame, must contain SNP, CHR, POS, pvalue, optional Shape
#' @param bottom data frame, must contain SNP, CHR, POS, pvalue, optional Shape
#' @param tline list of pvalues to draw red threshold lines in top plot
#' @param bline ist of pvalues to draw red threshold lines in bottom plot
#' @param chroms list of chromosomes to plot in the order desired, default c(1:22, "X", "Y")
#' @param log10 plot -log10() of pvalue column, logical
#' @param yaxis label for y-axis in the format c("top", "bottom"), automatically set if log10=TRUE
#' @param opacity opacity of points, from 0 to 1, useful for dense plots
#' @param annotate_snp vector of RSIDs to annotate
#' @param annotate_p list of pvalue thresholds to annotate in the order of c(p_top, p_bottom)
#' @param toptitle optional string for top plot title
#' @param bottomtitle optional string for bottom plot title
#' @param chrcolor1 first alternating color for chromosome
#' @param chrcolor2 second alternating color for chromosome
#' @param highlight_snp vector of snps to highlight
#' @param highlight_p list of pvalue thresholds to highlight in the order of c(p_top, p_bottom)
#' @param highlighter color to highlight
#' @param freey allow y-axes to scale with the data
#' @param background variegated or white
#' @param chrblocks logical, turns on x-axis chromosome marker blocks
#' @param file file name of saved image
#' @param type plot type/extension
#' @param hgt height of plot in inches
#' @param hgtratio height ratio of plots, equal to top plot proportion
#' @param wi width of plot in inches
#' @param res resolution of plot in pixels per inch
#' @return png image
#' @import ggplot2
#' @importFrom gridExtra arrangeGrob grid.arrange
#' gmirror(top=gwas.t, bottom=gwas.b, tline=0.05/nrow(gwas.t), bline=0.05/nrow(gwas.b), 
#' toptitle="GWAS Comparison Example: Data 1", bottomtitle = "GWAS Comparison Example: Data 2", 
#' highlight_p = c(0.05/nrow(gwas.t), 0.05/nrow(gwas.b)), highlighter="green")

gmirror <- function(top, bottom, tline, bline, chroms = c(1:22, "X", "Y"),log10=TRUE, 
                    yaxis, opacity=1, annotate_snp, annotate_p, toptitle=NULL, 
                    bottomtitle=NULL, highlight_snp, highlight_p, highlighter="red", 
                    chrcolor1="#AAAAAA", chrcolor2="#4D4D4D", freey=FALSE, 
                    background="variegated", chrblocks=FALSE, file="gmirror", 
                    type="png", hgt=7, hgtratio=0.5, wi=12, res=300 ){
  
  #Sort data
  topn <- names(top)
  bottomn <- names(bottom)
  top$Location <- "Top"
  bottom$Location <- "Bottom"
  
  # Check file formats
  if(!identical(topn, bottomn)){stop("Please ensure both inputs have the same metadata columns.")}
  
  d <- as.data.frame(rbind(top, bottom))
  
  d$POS <- as.numeric(as.character(d$POS))
  d$CHR <- droplevels(factor(d$CHR, levels = as.character(chroms)))
  d <- d[d$CHR %in% chroms, ]
  d_order <- d[order(d$CHR, d$POS), ]
  d_order$pos_index <- seq.int(nrow(d_order))
  d_order_sub <- d_order[, c("SNP", "CHR", "POS", "pvalue", "pos_index")]
  
  #Set up dataframe with color and position info
  maxRows <- by(d_order_sub, d_order_sub$CHR, function(x) x[which.max(x$pos_index),])
  minRows <- by(d_order_sub, d_order_sub$CHR, function(x) x[which.min(x$pos_index),])
  milimits <- do.call(rbind, minRows)
  malimits <- do.call(rbind, maxRows)
  lims <- merge(milimits, malimits, by="CHR")
  names(lims) <- c("Color", "snpx", "px", "posx", "posmin", "snpy", "py", "posy", "posmax")
  lims$av <- (lims$posmin + lims$posmax)/2
  lims <- lims[order(lims$Color),]
  lims$shademap <- rep(c("shade_ffffff", "shade_ebebeb"), length.out=nrow(lims), each=1)
  
  #Set up colors
  nchrcolors <- nlevels(factor(lims$Color))
  
  #Color by CHR
  colnames(d_order)[2] <- "Color"
  newcols <-c(rep(x=c(chrcolor1, chrcolor2), length.out=nchrcolors, each=1), "#FFFFFF", "#EBEBEB")
  names(newcols) <-c(levels(factor(lims$Color)), "shade_ffffff", "shade_ebebeb")
  
  #Info for y-axis
  if(log10==TRUE){
    d_order$pval <- -log10(d_order$pvalue)
    yaxislab1 <- expression(paste("-log"[10], "(p-value)", sep=""))
    yaxislab2 <- expression(paste("-log"[10], "(p-value)", sep=""))
    if(!missing(tline)) {tredline <- -log10(tline)}
    if(!missing(bline)) {bredline <- -log10(bline)}
  } else {
    d_order$pval <- d_order$pvalue
    yaxislab1 <- yaxis[1]
    yaxislab2 <- yaxis[2]
    if(!missing(tline)) {tredline <- tline}
    if(!missing(bline)) {bredline <- bline}
  }
  yaxismax1 <- ifelse(freey==FALSE, max(d_order$pval[which(d_order$pval< Inf)]), max(d_order$pval[which(d_order$pval< Inf) & d_order$Location=="Top"]))
  yaxismax2 <- ifelse(freey==FALSE, max(d_order$pval[which(d_order$pval< Inf)]), max(d_order$pval[which(d_order$pval< Inf) & d_order$Location=="Bottom"]))
  yaxismin1 <- ifelse(freey==FALSE, 0, min(d_order$pval[d_order$Location=="Top"]))
  yaxismin2 <- ifelse(freey==FALSE, 0, min(d_order$pval[d_order$Location=="Bottom"]))
  
  #Theme options
  backpanel1 <- ifelse(background=="white", "NULL", "geom_rect(data = lims, aes(xmin = posmin-.5, xmax = posmax+.5, ymin = yaxismin1, ymax = Inf, fill=factor(shademap)), alpha = 0.5)" )
  backpanel2 <- ifelse(background=="white", "NULL", "geom_rect(data = lims, aes(xmin = posmin-.5, xmax = posmax+.5, ymin = yaxismin2, ymax = Inf, fill=factor(shademap)), alpha = 0.5)" )
  
  #Start plotting
  #TOP PLOT
  p1 <- ggplot() + eval(parse(text=backpanel1))
  #Add shape info if available
  if("Shape" %in% topn){
    p1 <- p1 + geom_point(data=d_order[d_order$Location=="Top",], aes(x=pos_index, y=pval, color=factor(Color), shape=factor(Shape)), alpha=opacity)
  } else {
    p1 <- p1 + geom_point(data=d_order[d_order$Location=="Top",], aes(x=pos_index, y=pval, color=factor(Color)), alpha=opacity)
  }
  p1 <- p1 + scale_x_continuous(breaks=lims$av, labels=lims$Color, expand=c(0,0))
  if(chrblocks==TRUE){
    p1 <- p1 + geom_rect(data = lims, aes(xmin = posmin-.5, xmax = posmax+.5, ymin = -Inf, ymax = min(d_order$pval), fill=as.factor(Color)), alpha = 1)
  }
  p1 <- p1 + scale_colour_manual(name = "Color", values = newcols) + scale_fill_manual(name = "Color", values = newcols)
  p1 <- p1 + theme(panel.grid.minor.x = element_blank(), panel.grid.major.x=element_blank(), axis.title.x=element_blank(), legend.position="top", legend.title=element_blank())
  
  #BOTTOM PLOT
  p2 <- ggplot() + eval(parse(text=backpanel2))
  #Add shape info if available
  if("Shape" %in% bottomn){
    p2 <- p2 + geom_point(data=d_order[d_order$Location=="Bottom",], aes(x=pos_index, y=pval, color=factor(Color), shape=factor(Shape)), alpha=opacity)
  } else {
    p2 <- p2 + geom_point(data=d_order[d_order$Location=="Bottom",], aes(x=pos_index, y=pval, color=factor(Color)), alpha=opacity)
  }
  p2 <- p2 + scale_x_continuous(breaks=lims$av, labels=lims$Color, expand=c(0,0))
  if(chrblocks==TRUE){
    p2 <- p2 + geom_rect(data = lims, aes(xmin = posmin-.5, xmax = posmax+.5, ymin = -Inf, ymax = min(d_order$pval), fill=as.factor(Color)), alpha = 1)
  }  
  p2 <- p2 + scale_colour_manual(name = "Color", values = newcols) + scale_fill_manual(name = "Color", values = newcols)
  p2 <- p2 + theme(axis.text.x=element_text(angle=90), panel.grid.minor.x = element_blank(), panel.grid.major.x=element_blank(), axis.title.x=element_blank(), legend.position="bottom", legend.title=element_blank())
  
  #Highlight if given
  if(!missing(highlight_snp)){
    if("Shape" %in% topn){
      p1 <- p1 + geom_point(data=d_order[d_order$SNP %in% highlight_snp & d_order$Location=="Top", ], aes(x=pos_index, y=pval, shape=Shape), colour=highlighter)
      p1 <- p1 + guides(shape = guide_legend(override.aes = list(colour = "black")))
    } else {
      p1 <- p1 + geom_point(data=d_order[d_order$SNP %in% highlight_snp & d_order$Location=="Top", ], aes(x=pos_index, y=pval), colour=highlighter)
    }
    if("Shape" %in% bottomn){
      p2 <- p2 + geom_point(data=d_order[d_order$SNP %in% highlight_snp & d_order$Location=="Bottom", ], aes(x=pos_index, y=pval, shape=Shape), colour=highlighter)
      p2 <- p2 + guides(shape = guide_legend(override.aes = list(colour = "black")))
    } else {
      p2 <- p2 + geom_point(data=d_order[d_order$SNP %in% highlight_snp & d_order$Location=="Bottom", ], aes(x=pos_index, y=pval), colour=highlighter)
    }
  }
  if(!missing(highlight_p)){
    if("Shape" %in% topn){
      p1 <- p1 + geom_point(data=d_order[d_order$pvalue < highlight_p[1] & d_order$Location=="Top", ], aes(x=pos_index, y=pval, shape=Shape), colour=highlighter)
      p1 <- p1 + guides(shape = guide_legend(override.aes = list(colour = "black")))
    } else {
      p1 <- p1 + geom_point(data=d_order[d_order$pvalue < highlight_p[1] & d_order$Location=="Top", ], aes(x=pos_index, y=pval), colour=highlighter)
    }
    if("Shape" %in% bottomn){
      p2 <- p2 + geom_point(data=d_order[d_order$pvalue < highlight_p[2] & d_order$Location=="Bottom", ], aes(x=pos_index, y=pval, shape=Shape), colour=highlighter)
      p2 <- p2 + guides(shape = guide_legend(override.aes = list(colour = "black")))
    } else {
      p2 <- p2 + geom_point(data=d_order[d_order$pvalue < highlight_p[2] & d_order$Location=="Bottom", ], aes(x=pos_index, y=pval), colour=highlighter)
    }
  }
  #Add pvalue threshold line
  if(!missing(tline)){
    for(i in 1:length(tline)){
      p1 <- p1 + geom_hline(yintercept = tredline[i], colour="red")
    }
  }
  if(!missing(bline)){
    for(i in 1:length(bline)){
      p2 <- p2 + geom_hline(yintercept = bredline[i], colour="red")
    }
  }
  #Annotate
  if(!missing(annotate_p)){
    if (!requireNamespace(c("ggrepel"), quietly = TRUE)==TRUE) {
      print("Consider installing 'ggrepel' for improved text annotation")
      p1 <- p1 + geom_text(data=d_order[d_order$pvalue < annotate_p[1] & d_order$Location=="Top",], aes(pos_index,pval,label=SNP))
      p2 <- p2 + geom_text(data=d_order[d_order$pvalue < annotate_p[2] & d_order$Location=="Bottom",], aes(pos_index,pval,label=SNP))
    } else {
      p1 <- p1 + ggrepel::geom_text_repel(data=d_order[d_order$pvalue < annotate_p[1] & d_order$Location=="Top",], aes(pos_index,pval,label=SNP))
      p2 <- p2 + ggrepel::geom_text_repel(data=d_order[d_order$pvalue < annotate_p[2] & d_order$Location=="Bottom",], aes(pos_index,pval,label=SNP))
    }
  }
  if(!missing(annotate_snp)){
    if (!requireNamespace(c("ggrepel"), quietly = TRUE)==TRUE){
      print("Consider installing 'ggrepel' for improved text annotation")
      p1 <- p1 + geom_text(data=d_order[d_order$SNP %in% annotate_snp & d_order$Location=="Top",], aes(pos_index,pval,label=SNP))
      p2 <- p2 + geom_text(data=d_order[d_order$SNP %in% annotate_snp & d_order$Location=="Bottom",], aes(pos_index,pval,label=SNP))
    } else {
      p1 <- p1 + ggrepel::geom_text_repel(data=d_order[d_order$SNP %in% annotate_snp & d_order$Location=="Top",], aes(pos_index,pval,label=SNP))
      p2 <- p2 + ggrepel::geom_text_repel(data=d_order[d_order$SNP %in% annotate_snp & d_order$Location=="Bottom",], aes(pos_index,pval,label=SNP))
    }
  }
  #Add title and y axis title
  p1 <- p1 + ylab(yaxislab1)
  p2 <- p2 + ylab(yaxislab2)
  
  #Format
  if(chrblocks==TRUE){
    if(freey==TRUE){
      print("Sorry, drawing chrblocks with freey=TRUE is currently unsupported and will be ignored.")
    } else {
      p1 <- p1+theme(axis.text.x = element_text(vjust=1),axis.ticks.x = element_blank())+ylim(c(yaxismin1,yaxismax1))
      p2 <- p2+scale_y_reverse(limits=c(yaxismax2, yaxismin2)) + theme(axis.text.x = element_blank(),axis.ticks.x = element_blank())
    }
  } else {
    p1 <- p1+theme(axis.text.x = element_text(vjust=1),axis.ticks.x = element_blank())+ scale_y_continuous(limits=c(yaxismin1, yaxismax1),expand=expansion(mult=c(0,0.1)))
    p2 <- p2+scale_y_reverse(limits=c(yaxismax2,yaxismin2), expand=expansion(mult=c(0.1,0))) + theme(axis.text.x = element_blank(),axis.ticks.x = element_blank())
  }
  
  if(background=="white"){
    p1 <- p1 + theme(panel.background = element_rect(fill="white"))
    p2 <- p2 + theme(panel.background = element_rect(fill="white"))
  }
  p1 <- p1 + guides(fill="none", color="none")
  p2 <- p2 + guides(fill="none", color="none")
  #Save
  print(paste0("Saving plot to ", file, ".", type))
  p <- grid.arrange(arrangeGrob(p1, top=toptitle), arrangeGrob(p2, bottom=bottomtitle), padding=0, heights=c(hgtratio,1-hgtratio))
  ggsave(p, filename=paste0(file, ".", type), dpi=res, units="in", height=hgt, width=wi)
  return(p)
}


### LOADING RESULTS FILE
### Location of is set by 'opt$top' # argument 2
cat("\n\nLoading results file and removing NA's.")

### Checking file type -- is it gzipped or not?
data_connection1 <- file(opt$top)
filetype1 <- summary(data_connection1)$class
close(data_connection1)

data_connection2 <- file(opt$bottom)
filetype2 <- summary(data_connection2)$class
close(data_connection2)

print(filetype1)

### Loading the data for the top plot
if (filetype1 == "gzfile") {
  cat("\n* The file appears to be gzipped, now loading...\n")
  # zcat should not be needed anymore - fread is able to read gz/zip-files.
  # rawdata = fread(paste0("zcat < ",opt$top), header = FALSE, blank.lines.skip = TRUE)
  rawdata1 = fread(paste0(opt$top), header = TRUE, blank.lines.skip = TRUE)
} else if (filetype1 != "gzfile") {
  cat("\n* The file appears not to be gzipped, now loading...\n")
  rawdata1 = fread(opt$top, header = TRUE, blank.lines.skip = TRUE)
} else {
  cat("\n\n*** ERROR *** Something is rotten in the City of Gotham. We can't determine the file type 
of the data. Double back, please.\n\n", 
      file = stderr()) # print error messages to stder
}

cat("\n* Select the appropiate columns...")
rawdata1 <- rawdata1 %>%
  select( "SNP", "CHR", "POS", "pvalue")
  
cat("\n* Removing NA's...")

datatop <- na.omit(rawdata1)


### Loading the data for the bottom plot
if (filetype2 == "gzfile") {
  cat("\n* The file appears to be gzipped, now loading...\n")
  # zcat should not be needed anymore - fread is able to read gz/zip-files.
  # rawdata = fread(paste0("zcat < ",opt$bottom), header = FALSE, blank.lines.skip = TRUE)
  rawdata2 = fread(paste0(opt$bottom), header = TRUE, blank.lines.skip = TRUE)
} else if (filetype2 != "gzfile") {
  cat("\n* The file appears not to be gzipped, now loading...\n")
  rawdata2 = fread(opt$bottom, header = TRUE, blank.lines.skip = TRUE)
} else {
  cat("\n\n*** ERROR *** Something is rotten in the City of Gotham. We can't determine the file type 
of the data. Double back, please.\n\n", 
      file = stderr()) # print error messages to stder
}

cat("\n* Select the appropiate columns...")
rawdata2 <- rawdata2 %>%
  select( "SNP", "CHR", "POS", "pvalue")

cat("\n* Removing NA's...")
databottom <- na.omit(rawdata2)

### PLOT MIAMI ###
cat("\n\nDetermining what type of image should be produced and plotting axes.")
if (opt$imageformat == "PNG") {
    png(paste0(opt$outputdir,"/",study1,".",study2,".png"), width = 1280, height = 720)
	gmirror(top=datatop, bottom=databottom, tline=0.05/nrow(datatop), bline=0.05/nrow(databottom), chrcolor1="palevioletred1", chrcolor2="royalblue1",
          toptitle = opt$toptitle, bottomtitle = opt$bottomtitle, chrblocks=TRUE,
          highlight_p = c(0.05/nrow(datatop),0.05/nrow(databottom)), highlighter="mediumorchid")
  }
if (opt$imageformat == "TIFF") {
    tiff(paste0(opt$outputdir,"/",study1,".",study2,".tiff"), width = 1280, height = 720)
	gmirror(top=datatop, bottom=databottom, tline=0.05/nrow(datatop), bline=0.05/nrow(databottom), chrcolor1="palevioletred1", chrcolor2="royalblue1",
          toptitle = opt$toptitle, bottomtitle = opt$bottomtitle, 
          highlight_p = c(0.05/nrow(datatop),0.05/nrow(databottom)), highlighter="mediumorchid")
  }
if (opt$imageformat == "EPS") {
    postscript(file = paste0(opt$outputdir,"/",study1,".",study2,".ps"),
               horizontal = FALSE, onefile = FALSE, paper = "special")
	gmirror(top=datatop, bottom=databottom, tline=0.05/nrow(datatop), bline=0.05/nrow(databottom), chrcolor1="palevioletred1", chrcolor2="royalblue1",
          toptitle = opt$toptitle, bottomtitle = opt$bottomtitle, 
          highlight_p = c(0.05/nrow(datatop),0.05/nrow(databottom)), highlighter="mediumorchid")
  }
if (opt$imageformat == "PDF") {
    pdf(paste0(opt$outputdir,"/",study1,".",study2,".pdf"), width = 10, height = 5)
	gmirror(top=datatop, bottom=databottom, tline=0.05/nrow(datatop), bline=0.05/nrow(databottom), chrcolor1="palevioletred1", chrcolor2="royalblue1",
          toptitle = opt$toptitle, bottomtitle = opt$bottomtitle, 
          highlight_p = c(0.05/nrow(datatop),0.05/nrow(databottom)), highlighter="mediumorchid")
  }


dev.off()


#--------------------------------------------------------------------------
### CLOSING MESSAGE
cat(paste("\nAll done plotting a MIAMI-plot of",study1,"and ", study2".\n"))
cat(paste("\nToday's: ",Today, "\n"))
cat("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n")

#--------------------------------------------------------------------------
#
