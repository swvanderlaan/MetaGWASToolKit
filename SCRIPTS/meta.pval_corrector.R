#!/hpc/local/CentOS7/dhl_ec/software/R-3.3.3/bin/Rscript --vanilla

### Mac OS X version
### #!/usr/local/bin/Rscript --vanilla

### Linux version
### #!/hpc/local/CentOS7/dhl_ec/software/R-3.3.3/bin/Rscript --vanilla

cat("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    P-values Corrector -- MetaGWASToolKit
    \n
    * Version: v1.0.1
    * Last edit: 2017-05-15
    * Created by: Sara L. Pulit | s.l.pulit@umcutrecht.nl; Sander W. van der Laan | s.w.vanderlaan-2@umcutrecht.nl
    \n
    * Description: This script computes p-values for given z-scores from a meta-analysis of GWAS. 
    The script should be usuable on both any Linux distribution with R 3+ installed, Mac OS X and Windows.
    
    ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n")

### Usage: ./meta.pval_corrector.R -i inputfile -o outputfile [OPTIONAL: -v verbose (DEFAULT) -q quiet]
###        ./meta.pval_corrector.R --inputfile inputfile --outputfile outputfile [OPTIONAL: --verbose verbose (DEFAULT) -quiet quiet]

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
    #update.packages(ask = FALSE) 
    eval(parse(text = sprintf("install.packages(\"%s\", dependencies = TRUE, repos = \"http://cran-mirror.cs.uu.nl/\")", x)))
  }
  if(isTRUE(x %in% .packages(all.available = TRUE))) { 
    eval(parse(text = sprintf("require(\"%s\")", x)))
  } else {
    source("http://bioconductor.org/biocLite.R")
    # Update installed packages - this may mean a full upgrade of R, which in turn
    # may not be warrented.
    #biocLite(character(), ask = FALSE) 
    eval(parse(text = sprintf("biocLite(\"%s\")", x)))
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
# opt$inputfile=paste0(MACDIR, "/test_environment/test.p_val_corr.out")
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
cat("Starting \"P-values Corrector\".")

### START OF THE PROGRAM
### main point of program is here, do this whether or not "verbose" is set
if(!is.na(opt$inputfile) & !is.na(opt$outputfile)) {
  cat(paste("\n\nWe are going to apply genomic control on a given list of p-values (from a meta-analysis of GWAS.
            \nCorrecting p-values of these results...........: '",basename(opt$inputfile),"'
            Corrected results will be saved here.............: '", opt$outputfile, "'.\n",sep=''))
  
  ### GENERAL SETUP
  Today=format(as.Date(as.POSIXlt(Sys.time())), "%Y%m%d")
  cat(paste("\nToday's date is: ", Today, ".\n", sep = ''))
  
  cat("\nReading data and performing some calculations.\n")
  cat("* Loading data.\n")
  data = fread(opt$inputfile, header = TRUE, dec = ".", blank.lines.skip = TRUE)
  
  cat("* Performing some calculations...\n")
  cat("  - p-value for 'P_SQRTN'\n")
  P1 <- pnorm(-(abs(data$P_SQRTN))) * 2;
  cat("  - p-value for 'P_FIXED'\n")
  P2 <- pnorm(-(abs(data$P_FIXED))) * 2;
  cat("  - p-value for 'P_RANDOM'\n")
  P3 <- pnorm(-(abs(data$P_RANDOM))) * 2;
  cat("  - making updated dataset for export\n")
  data.updated <- data.frame(data[,1], P1, P2, P3)

  cat("\nAll done correcting p-values in the dataset.")
  ### SAVE NEW DATA ###
  cat("\n\nSaving corrected data...\n")
  write.table(data.updated, 
              file = opt$outputfile, 
              quote = FALSE , row.names = FALSE, col.names = TRUE, 
              sep = "\t", na = "NA", dec = ".")
  
  ### CLOSING MESSAGE
  cat(paste("\nAll done correcting p-values in [",file_path_sans_ext(basename(opt$inputfile), compression = TRUE),"].\n"))
  cat(paste("\nToday's date is: ", Today, ".\n", sep = ''))
  
} else {
  cat("\n\n\n\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n")
  cat("\n*** ERROR *** You didn't specify all variables:\n
      - --i/inputfile    : Path to the input file.
      - --l/lambda       : Lambda-value to correct the data by.
      - --o/outputfile   : Path to the output file.",
      file=stderr()) # print error messages to stderr
}

cat("\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n")
# 
# ### SAVE ENVIRONMENT | FOR DEBUGGING
# save.image(paste0(ROOT_loc, "/", OUT_loc, "/", Today,"_", file_path_sans_ext(basename(opt$inputfile), compression = TRUE),"_DEBUG_PVAL_CORRECTOR.RData"))
