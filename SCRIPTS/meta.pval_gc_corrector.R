#!/hpc/local/CentOS7/dhl_ec/software/R-3.6.3/bin/Rscript --vanilla

### Mac OS X version
### #!/usr/local/bin/Rscript --vanilla

### Linux version
### #!/hpc/local/CentOS7/dhl_ec/software/R-3.3.3/bin/Rscript --vanilla

cat("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    Genomic Control of P-values -- MetaGWASToolKit
    \n
    * Version: v1.0.4
    * Last edit: 2020-11-18
    * Created by: Sara L. Pulit; Sander W. van der Laan | s.w.vanderlaan@gmail.com
    \n
    * Description: This script computes p-values for given effect sizes and standard errors from a meta-analysis 
    of GWAS and applies genomic control. The lambda-value is calculated based on the given effect size and standard 
    errors.
    The script should be usuable on both any Linux distribution with R 3+ installed, Mac OS X and Windows.
    
    ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n")

### Usage: ./meta.pval_gc_corrector.R -i inputfile -o outputfile [OPTIONAL: -v verbose (DEFAULT) -q quiet]
###        ./meta.pval_gc_corrector.R --inputfile inputfile --outputfile outputfile [OPTIONAL: --verbose verbose (DEFAULT) -quiet quiet]

cat("\n* Clearing the environment...\n\n")
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

### OPTION LISTING
option_list = list(
  make_option(c("-i", "--inputfile"), action="store", default=NA, type='character',
              help="Path to the input file."),
  make_option(c("-o", "--outputfile"), action="store", default=NA, type='character',
              help="Path to the output file."),
  make_option(c("-v", "--verbose"), action="store_true", default=TRUE,
              help="Should the program print extra stuff out? [logical (FALSE or TRUE); default %default]"),
  make_option(c("-s", "--silent"), action="store_false", dest="verbose",
              help="Make the program not be verbose.")
  #make_option(c("-c", "--cvar"), action="store", default="this is c",
  #            help="a variable named c, with a default [default %default]")  
)
opt = parse_args(OptionParser(option_list=option_list))

#--------------------------------------------------------------------------

# ### FOR LOCAL DEBUGGING
# ### MacBook Pro
# #MACDIR="/Users/swvanderlaan/PLINK/analyses"
# ### Mac Pro
# MACDIR="/Volumes/EliteProQx2Media/PLINK/analyses/meta_gwasfabp4"
# 
# opt$inputfile=paste0(MACDIR, "/test_environment/test.gc_p_val_corr.out")
# opt$outputfile=paste0(MACDIR, "/test_environment/test.p_corrected.out")#
# 
# #test.gc_p_val_corr.out
# #test.p_val_corr.out
# ### FOR LOCAL DEBUGGING

#--------------------------------------------------------------------------

if (opt$verbose) {
  ### You can use either the long or short name; so opt$a and opt$avar are the same.
  ### Show the user what the variables are.
  cat("\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n")
  cat("* Checking the settings as given through the flags.")
  cat("\n - The input file.........................: ")
  cat(opt$inputfile)
  cat("\n - The output file........................: ")
  cat(opt$outputfile)
  cat("\n\n")
}
cat("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n")
cat("Starting \"Genomic Control of P-values\".")

### START OF THE PROGRAM
### main point of program is here, do this whether or not "verbose" is set
if(!is.na(opt$inputfile) & !is.na(opt$outputfile)) {
  cat(paste("\n\nWe are going to apply genomic control on a given list of effect sizes and 
            \nstandard errors (from a meta-analysis of GWAS).
            \nCorrecting p-values of these results...........: '",basename(opt$inputfile),"'
            Corrected results will be saved here.............: '", opt$outputfile, "'.\n",sep=''))
  
### GENERAL SETUP
Today=format(as.Date(as.POSIXlt(Sys.time())), "%Y%m%d")
cat(paste("\nToday's date is: ", Today, ".\n", sep = ''))

cat("\nReading data and performing some calculations.\n")
cat("* Loading data.\n")
data = fread(opt$inputfile, header = TRUE, dec = ".", blank.lines.skip = TRUE)

cat("* Calculating lambda (based on given effect size and standard error).\n")
Z_forlamba <- data$BETA_FIXED / data$SE_FIXED
lambdavalue = round(median(Z_forlamba^2)/qchisq(0.5, df = 1),3)

cat("* Performing some calculations while correcting for lambda = []", lambdavalue ,"]...\n")
cat("  - effect size (beta)\n")
BETA_GC <- data$BETA_FIXED
cat("  - standard error\n")
SE_GC <- data$SE_FIXED * as.numeric(sqrt(lambdavalue))
cat("  - Z-score\n")
Z_GC <- data$BETA_FIXED / SE_GC
cat("  - P-value\n")
P_GC <- pnorm(-(abs(Z_GC))) * 2;
cat("  - making updated dataset for export\n")
data.updated <- data.frame(data$VARIANTID, BETA_GC, SE_GC, Z_GC, P_GC)

names(data.updated)[names(data.updated) == 'data.VARIANTID'] <- 'VARIANTID'

cat("\nAll done applying genomic control to the data.")
### SAVE NEW DATA ###
cat("\n\nSaving data...\n")
write.table(data.updated, 
            file = opt$outputfile, 
            quote = FALSE , row.names = FALSE, col.names = TRUE, 
            sep = "\t", na = "NA", dec = ".")

### CLOSING MESSAGE
cat(paste("\nAll done applying genomic control to [",file_path_sans_ext(basename(opt$inputfile), compression = TRUE),"].\n"))
cat(paste("\nToday's date is: ", Today, ".\n", sep = ''))

} else {
  cat("\n\n\n\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n")
  cat("\n*** ERROR *** You didn't specify all variables:\n
      - --i/inputfile    : Path to the input file.
      - --o/outputfile   : Path to the output file.",
      file=stderr()) # print error messages to stderr
}

cat("\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n")
# 
# ### SAVE ENVIRONMENT | FOR DEBUGGING
# save.image(paste0(ROOT_loc, "/", OUT_loc, "/", Today,"_", file_path_sans_ext(basename(opt$inputfile), compression = TRUE),"_DEBUG_PVAL_GC_CORRECTOR.RData"))

