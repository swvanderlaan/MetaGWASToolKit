#!/hpc/local/CentOS7/dhl_ec/software/R-3.4.0/bin/Rscript --vanilla

### Mac OS X version
### #!/usr/local/bin/Rscript --vanilla

### Linux version
### #!/hpc/local/CentOS7/dhl_ec/software/R-3.4.0/bin/Rscript --vanilla

cat("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    Lambda Calculator -- MetaGWASToolKit
    \n
    * Version: v1.0.0
    * Last edit: 2018-04-08
    * Created by: Sara L. Pulit; Sander W. van der Laan | s.w.vanderlaan@gmail.com
    \n
    * Description: This script computes from p-values, z-scores, or Chi-squares the lambda (genomic inflation). 
    The script should be usuable on both any Linux distribution with R 3+ installed, Mac OS X and Windows.
    
    ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n")

### Usage: ./meta.lambda.R -i inputfile [OPTIONAL: -v verbose (DEFAULT) -q quiet]
###        ./meta.lambda.R --inputfile inputfile [OPTIONAL: --verbose verbose (DEFAULT) -quiet quiet]

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
  make_option(c("-t", "--teststat"), action="store", default=NA, type='character',
              help="Test-statistic. Options: Z-scores [Z], Chi-Squares [CHISQ], P-values [P]."),          
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
  cat("\n - The test-statistic used................: ")
  cat(opt$teststat)
  cat("\n\n")
}
cat("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n")
cat("Starting \"Lambda Calculator\".")

### START OF THE PROGRAM
### main point of program is here, do this whether or not "verbose" is set
if(!is.na(opt$inputfile) & !is.na(opt$teststat)) {
  cat(paste("\n\nWe are going to calculate genomic inflation (lambda) on a given list of test-statistics.
            \nCalculating lambda of these results............: '",basename(opt$inputfile), "'.\n",sep=''))
  
  ### GENERAL SETUP
  Today=format(as.Date(as.POSIXlt(Sys.time())), "%Y%m%d")
  cat(paste("\nToday's date is: ", Today, ".\n", sep = ''))
  
  cat("\nReading data and performing some calculations.\n")
  cat("* Loading data.\n")
  input = fread(opt$inputfile, header = TRUE, dec = ".", blank.lines.skip = TRUE)
  stat_type = opt$teststat ## P, Z, CHISQ
	
	## Reads data
	## Header should have column "P"
	
	S = input
	if (stat_type == "Z")
	z = S$P
	
	if (stat_type == "CHISQ")
	z = sqrt(S$P)
	
	if (stat_type == "P")
	z = qnorm(S$P/2)
	
	## calculates lambda
	lambda = round(median(z^2, na.rm = TRUE)/qchisq(0.5, df = 1), 3)
	cat(paste("\nThe lambda is: [",lambda,"] using test-statistic [",opt$teststat,"].\n"))

  ### CLOSING MESSAGE
  cat(paste("\nAll done calculating lambda in [",file_path_sans_ext(basename(opt$inputfile), compression = TRUE),"].\n"))
  cat(paste("\nToday's date is: ", Today, ".\n", sep = ''))
  
} else {
  cat("\n\n\n\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n")
  cat("\n*** ERROR *** You didn't specify all variables:\n
      - --i/inputfile    : Path to the input file.
      - --t/teststat     : Test-statistic to use for lambda calculation.",
      file=stderr()) # print error messages to stderr
}

cat("\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n")
# 
# ### SAVE ENVIRONMENT | FOR DEBUGGING
# save.image(paste0(ROOT_loc, "/", OUT_loc, "/", Today,"_", file_path_sans_ext(basename(opt$inputfile), compression = TRUE),"_DEBUG_LAMBDA_CALCULATOR.RData"))

