#!/hpc/local/CentOS7/dhl_ec/software/R-3.3.3/bin/Rscript --vanilla

### Mac OS X version
### #!/usr/local/bin/Rscript --vanilla

### Linux version
### #!/hpc/local/CentOS7/dhl_ec/software/R-3.3.3/bin/Rscript --vanilla

cat("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    GWAS Cleaner -- MetaGWASToolKit
    \n
    * Version: v1.0.9
    * Last edit: 2017-05-19
    * Created by: Sander W. van der Laan | s.w.vanderlaan-2@umcutrecht.nl
    \n
    * Description:  Cleaning of GWAS summary statistics files used for a downstream meta-analysis of GWAS. 
    The script should be usuable on both any Linux distribution with R 3+ installed, Mac OS X and Windows.
    
    ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n")

### Usage: ./gwas.cleaner.R -d datagwas -o outputdir -f filename -e effectsize -s standarderror -m maf -c mac -i info -h hwe_p [OPTIONAL: -v verbose (DEFAULT) -q quiet]
###        ./gwas.cleaner.R --datagwas datagwas --outputdir outputdir --filename filename --effectsize effectsize --standarderror standarderror --maf maf --mac mac --info info --hwe_p hwe_p [OPTIONAL: --verbose verbose (DEFAULT) -quiet quiet]

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
  make_option(c("-d", "--datagwas"), action="store", default=NA, type='character',
              help="Path to the GWAS data; can be tab, comma, space or semicolon delimited, as well as gzipped."),
  make_option(c("-o", "--outputdir"), action="store", default=NA, type='character',
              help="Path to the output directory."),
  make_option(c("-f", "--filename"), action="store", default=NA, type='character',
              help="The output filename, an extension will be automatically added."),
  make_option(c("-e", "--effectsize"), action="store", default=NA, type='numeric',
              help="Maximum effect size to allow for any variant, e.g. 10."),
  make_option(c("-s", "--standarderror"), action="store", default=NA, type='numeric',
              help="Maximum standard error to allow for any variant, e.g. 10."),
  make_option(c("-m", "--maf"), action="store", default=NA, type='numeric',
              help="Minimum minor allele frequency to keep variants, e.g. 0.005."),
  make_option(c("-c", "--mac"), action="store", default=NA, type='numeric',
              help="Minimum minor allele count to keep variants, e.g. 30."),
  make_option(c("-i", "--info"), action="store", default=NA, type='numeric',
              help="Minimum imputation quality score to keep variants, e.g. 0.3."),
  make_option(c("-w", "--hwe_p"), action="store", default=NA, type='numeric',
              help="Hardy-Weinberg equilibrium p-value at which to drop variants, e.g. 1E-6."),
  make_option(c("-v", "--verbose"), action="store_true", default=TRUE,
              help="Should the program print extra stuff out? [logical (FALSE or TRUE); default %default]"),
  make_option(c("-q", "--quiet"), action="store_false", dest="verbose",
              help="Make the program not be verbose.")
  #make_option(c("-c", "--cvar"), action="store", default="this is c",
  #            help="a variable named c, with a default [default %default]")  
)
opt = parse_args(OptionParser(option_list=option_list))

# #--------------------------------------------------------------------------
# 
# ### FOR LOCAL DEBUGGING
# ### MacBook Pro
# MACDIR="/Users/swvanderlaan"
# ### Mac Pro
# MACDIR="/Volumes/MyBookStudioII/Backup"
# ### HPC
# MACDIR="/hpc/dhl_ec/svanderlaan/projects/meta_gwasfabp4/test_environment"
#
# opt$effectsize=10
# opt$standarderror=10
# opt$maf=0.005
# opt$mac=30
# opt$info=0.3
# opt$hwe_p=1E-3
# 
# opt$outputdir=paste0(MACDIR, "/PLINK/analyses/meta_gwasfabp4/METAFABP4_1000G/RAW/EPICNL_m1")
# opt$datagwas=paste0(MACDIR, "/PLINK/analyses/meta_gwasfabp4/METAFABP4_1000G/RAW/EPICNL_m1/EPICNL_m1.rdat.gz")
# opt$filename="EPICNL_m1"
# 
# opt$outputdir=paste0(MACDIR, "/PLINK/analyses/meta_gwasfabp4/METAFABP4_1000G/MODELX/RAW/AEGS_m1")
# opt$datagwas=paste0(MACDIR, "/PLINK/analyses/meta_gwasfabp4/METAFABP4_1000G/MODELX/RAW/AEGS_m1/AEGS.WHOLE.FABP4.20150125.alz.ref.pdat")
# opt$filename="AEGS_m1"
# 
# opt$outputdir=paste0(MACDIR, "/")
# opt$datagwas=paste0(MACDIR, "/FHS_m1.rdat")
# opt$filename="FHS_m1"
#
# ### FOR LOCAL DEBUGGING
# 
# #--------------------------------------------------------------------------

if (opt$verbose) {
  ### You can use either the long or short name; so opt$a and opt$avar are the same.
  ### Show the user what the variables are.
  cat("\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n")
  cat("* Checking the settings as given through the flags.")
  cat("\n - The GWAS data .................................................: ")
  cat(opt$datagwas)
  cat("\n - The output directory...........................................: ")
  cat(opt$outputdir)
  cat(paste0("\n - The output filename will be....................................: ", opt$filename,".cdat"))
  cat("\n - Maximum effect size to allow for any variant...................: ")
  cat(opt$effectsize)
  cat("\n - Maximum standard error to allow for any variant................: ")
  cat(opt$standarderror)
  cat("\n - Minimum minor allele frequency to keep variants................: ")
  cat(opt$mac)
  cat("\n - Minimum minor allele count to keep variants....................: ")
  cat(opt$mac)
  cat("\n - Minimum imputation quality score to keep variants..............: ")
  cat(opt$info)
  cat("\n - Hardy-Weinberg equilibrium p-value at which to drop variants...: ")
  cat(opt$hwe_p)
  cat("\n\n")
}
cat("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n")
cat("Starting \"GWAS Cleaner\".")

### START OF THE PROGRAM
### main point of program is here, do this whether or not "verbose" is set
if(!is.na(opt$filename) & !is.na(opt$datagwas) & !is.na(opt$outputdir)
   & !is.na(opt$effectsize) & !is.na(opt$standarderror)
   & !is.na(opt$maf) & !is.na(opt$mac)
   & !is.na(opt$info) & !is.na(opt$hwe_p)) {
cat(paste0("\n\nWe are going to clean the GWAS data.
\nAnalysing these results................: '",basename(opt$datagwas),"'
Cleaned results will be saved here.....: '", opt$outputdir, "'.\n",sep=''))
  study <- opt$filename # argument 3
  filename <- basename(opt$datagwas)
  
  ### GENERAL SETUP
  Today=format(as.Date(as.POSIXlt(Sys.time())), "%Y%m%d")
  cat(paste("\nToday's date is: ", Today, ".\n", sep = ''))
  
  #### DEFINE THE LOCATIONS OF DATA
  OUT_loc = opt$outputdir # argument 2
  
  cat("\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n")
  
  ### LOADING GWAS RESULTS FILES
  
  cat("\nLoading GWAS data.\n")
  
  ### Location of is set by 'opt$datagwas' # argument 1
  ### Checking file type -- is it gzipped or not?
  datagwas_connection <- file(opt$datagwas)
  filetype <- summary(datagwas_connection)$class
  TESTDELIMITER <- readLines(datagwas_connection, n = 1)
  close(datagwas_connection)
  if(filetype == "gzfile"){
    cat("\n* The file appears to be gzipped, checking delimiter now...")
    cat("\n* Data header looks like this:\n")
    print(TESTDELIMITER)
    if(grepl(",", TESTDELIMITER) == TRUE){
      cat("\n* Data is comma-seperated, loading...\n")
      GWASDATA_RAW = fread(paste0("zcat < ",opt$datagwas), header = TRUE, sep = ",",
                           dec = ".", na.strings = c("", "NA", "na", "Na",
                                                     "NaN", "Nan", ".",
                                                     "N/A","n/a", "N/a"),
                           blank.lines.skip = TRUE)
      
    } else if(grepl(";", TESTDELIMITER) == TRUE) {
      cat("\n\n* Data is semicolon-seperated, loading...\n")
      GWASDATA_RAW = fread(paste0("zcat < ",opt$datagwas), header = TRUE, sep = ";",
                           dec = ".", na.strings = c("", "NA", "na", "Na",
                                                     "NaN", "Nan", ".",
                                                     "N/A","n/a", "N/a"),
                           blank.lines.skip = TRUE)
      
    } else if(grepl("\\t", TESTDELIMITER) == TRUE) {
      cat("\n\n* Data is tab-seperated, loading...\n")
      GWASDATA_RAW = fread(paste0("zcat < ",opt$datagwas), header = TRUE, sep ="\t", 
                           dec = ".", na.strings = c("", "NA", "na", "Na",
                                                     "NaN", "Nan", ".",
                                                     "N/A","n/a", "N/a"),
                           blank.lines.skip = TRUE)
      
    } else if(grepl("\\s", TESTDELIMITER) == TRUE) {
      cat("\n\n* Data is space-seperated, loading...\n")
      GWASDATA_RAW = fread(paste0("zcat < ",opt$datagwas), header = TRUE, sep =" ", 
                           dec = ".", na.strings = c("", "NA", "na", "Na",
                                                     "NaN", "Nan", ".",
                                                     "N/A","n/a", "N/a"),
                           blank.lines.skip = TRUE)
      
    } else if(grepl("[:blank:]", TESTDELIMITER) == TRUE) {
      cat("\n\n* Data is blankspace-seperated, loading...\n")
      GWASDATA_RAW = fread(paste0("zcat < ",opt$datagwas), header = TRUE, sep =" ", 
                           dec = ".", na.strings = c("", "NA", "na", "Na",
                                                     "NaN", "Nan", ".",
                                                     "N/A","n/a", "N/a"),
                           blank.lines.skip = TRUE)
      
    } else {
      cat ("\n\n*** ERROR *** Something is rotten in the City of Gotham. The GWAS data is neither comma,
           tab, space, nor semicolon delimited. Double back, please.\n\n", 
           file=stderr()) # print error messages to stder
    }
  } else if(filetype != "gzfile") {
    cat("\n* The file appears not to be gzipped, checking delimiter now...")
    cat("\n* Data header looks like this:\n")
    print(TESTDELIMITER)
    if(grepl(",", TESTDELIMITER) == TRUE){
      cat("\n* Data is comma-seperated, loading...\n")
      GWASDATA_RAW = fread(opt$datagwas, header = TRUE, sep = ",",
                           dec = ".", na.strings = c("", "NA", "na", "Na",
                                                     "NaN", "Nan", ".",
                                                     "N/A","n/a", "N/a"),
                           blank.lines.skip = TRUE)
      
    } else if(grepl(";", TESTDELIMITER) == TRUE) {
      cat("\n\n* Data is semicolon-seperated, loading...\n")
      GWASDATA_RAW = fread(opt$datagwas, header = TRUE, sep = ";",
                           dec = ".", na.strings = c("", "NA", "na", "Na",
                                                     "NaN", "Nan", ".",
                                                     "N/A","n/a", "N/a"),
                           blank.lines.skip = TRUE)
      
    } else if(grepl("\\t", TESTDELIMITER) == TRUE) {
      cat("\n\n* Data is tab-seperated, loading...\n")
      GWASDATA_RAW = fread(opt$datagwas, header = TRUE, sep ="\t", 
                           dec = ".", na.strings = c("", "NA", "na", "Na",
                                                     "NaN", "Nan", ".",
                                                     "N/A","n/a", "N/a"),
                           blank.lines.skip = TRUE)
      
    } else if(grepl("\\s", TESTDELIMITER) == TRUE) {
      cat("\n\n* Data is space-seperated, loading...\n")
      GWASDATA_RAW = fread(opt$datagwas, header = TRUE, sep =" ", 
                           dec = ".", na.strings = c("", "NA", "na", "Na",
                                                     "NaN", "Nan", ".",
                                                     "N/A","n/a", "N/a"),
                           blank.lines.skip = TRUE)
      
    } else if(grepl("[:blank:]", TESTDELIMITER) == TRUE) {
      cat("\n\n* Data is blankspace-seperated, loading...\n")
      GWASDATA_RAW = fread(opt$datagwas, header = TRUE, sep =" ", 
                           dec = ".", na.strings = c("", "NA", "na", "Na",
                                                     "NaN", "Nan", ".",
                                                     "N/A","n/a", "N/a"),
                           blank.lines.skip = TRUE)
      
    } else {
      cat ("\n\n*** ERROR *** Something is rotten in the City of Gotham. The GWAS data is neither comma,
           tab, space, nor semicolon delimited. Double back, please.\n\n", 
           file=stderr()) # print error messages to stder
    }
  } else {
    cat ("\n\n*** ERROR *** Something is rotten in the City of Gotham. We can't determine the file type 
         of the GWAS data. Double back, please.\n\n", 
         file=stderr()) # print error messages to stder
  }
  
  ### set columns class properly
  GWASDATA_RAWSELECTION <- mutate(GWASDATA_RAW, CHR = as.integer(CHR)) # convert to integer
  GWASDATA_RAWSELECTION <- mutate(GWASDATA_RAW, BP = as.integer(BP)) # convert to integer
  
  ### Create new column to count SNPs and INDELs
  GWASDATA_RAWSELECTION <- mutate(GWASDATA_RAWSELECTION, 
                                  VT = ifelse((nchar(GWASDATA_RAWSELECTION$EffectAllele) == 1 & nchar(GWASDATA_RAWSELECTION$OtherAllele) == 1), 
                                              "SNP", 
                                              "INDEL"))

  report.variants <- function(DATASET){
    no_variants=length(DATASET$VariantID)
    no_variants_snp=length(grep(TRUE, DATASET$VT == "SNP"))
    no_variants_indel=length(grep(TRUE, DATASET$VT == "INDEL"))
    cat(paste0("\n  - number of remaining variants : ",format(no_variants, big.mark=",")))
    cat(paste0("\n  - of which SNVs                : ",format(no_variants_snp, big.mark=",")))
    cat(paste0("\n  - of which INDELs              : ",format(no_variants_indel, big.mark=",")))
  }
  cat("\nContents of the raw, parsed, and harmonized data.")
  report.variants(GWASDATA_RAWSELECTION)
  
  cat("\nCleaning dataset.")
  cat(paste0("\n* removing variants where -",opt$effectsize," < effect size < ",opt$effectsize," or 'NA'..."))
  GWASDATA_RAW_CLEANED <- filter(GWASDATA_RAWSELECTION, 
                                 Beta > -opt$effectsize & Beta < opt$effectsize & !is.na(Beta))
  report.variants(GWASDATA_RAW_CLEANED)
  
  cat(paste0("\n* removing variants where ",-opt$standarderror," < standard error < ",opt$standarderror," or 'NA'..."))
  GWASDATA_RAW_CLEANED <- filter(GWASDATA_RAW_CLEANED, 
                                 SE > -opt$standarderror & SE < opt$standarderror & !is.na(SE))
  report.variants(GWASDATA_RAW_CLEANED)
  
  cat("\n* removing out of range p-values, i.e. p < 0, p > 1, or P = 'NA'...")
  GWASDATA_RAW_CLEANED <- filter(GWASDATA_RAW_CLEANED, P >= 0 & P <= 1 & !is.na(P))
  report.variants(GWASDATA_RAW_CLEANED)
  
  cat(paste0("\n* removing variants with minor allele frequencies < ",opt$maf,"... (note: monomorphs are also removed)"))
  GWASDATA_RAW_CLEANED <- filter(GWASDATA_RAW_CLEANED, MAF > opt$maf & MAF < (1-opt$maf) & MAF != 0 & MAF != 1 )
  report.variants(GWASDATA_RAW_CLEANED)
  
  cat(paste0("\n* removing variants with minor allele counts < ",opt$mac,"..."))
  GWASDATA_RAW_CLEANED <- filter(GWASDATA_RAW_CLEANED, MAC > opt$mac)
  report.variants(GWASDATA_RAW_CLEANED)
  
  cat(paste0("\n* removing variants where ",opt$info," < imputation quality < 1.1..."))
  GWASDATA_RAW_CLEANED <- filter(GWASDATA_RAW_CLEANED, (Info > opt$info & Info < 1.1) | !is.na(Info) )
  report.variants(GWASDATA_RAW_CLEANED)

  cat(paste0("\n* removing variants where HWE p-value < ",opt$hwe_p,"... (note: HWE p could potentially be 'NA'.)"))
  if(any(GWASDATA_RAW_CLEANED$CHR < 22) == TRUE) {
  	cat(paste0("\n  - processing autosomal chromosomes..."))
  	GWASDATA_RAW_CLEANED <- filter(GWASDATA_RAW_CLEANED, HWE_P < opt$hwe_p | is.na(HWE_P) | HWE_P != 0 )
  	report.variants(GWASDATA_RAW_CLEANED)
  	} else {
	cat(paste0("\n  - processing non-autosomal chromosomes..."))
  	GWASDATA_RAW_CLEANED <- filter(GWASDATA_RAW_CLEANED, is.na(HWE_P) | HWE_P != 0 )
  	report.variants(GWASDATA_RAW_CLEANED)
  	}
  
  cat("\nAll done cleaning the dataset.")
  ### SAVE NEW DATA ###
  cat("\n\nSaving cleaned data...\n")
  write.table(GWASDATA_RAW_CLEANED, paste0(OUT_loc, "/", opt$filename, ".cdat"),
              quote = FALSE , row.names = FALSE, col.names = TRUE, 
              sep = "\t", na = "NA", dec = ".")
  
  ### CLOSING MESSAGE
  cat(paste("\nAll done cleaning [",basename(opt$datagwas),"].\n"))
  cat(paste("\nToday's date is: ", Today, ".\n", sep = ''))
  
  } else {
    cat("\n\n\n\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n")
    cat("\n*** ERROR *** You didn't specify all variables:\n
        - --d/datagwas      : Path to the GWAS data; can be tab, comma, space or semicolon delimited, as well as gzipped.
        - --o/outputdir     : Path to output directory.
        - --f/filename      : The output filename, an extension will be automatically added.
        - --e/effectsize    : Maximum effect size to allow for any variant, e.g. 10.
        - --s/standarderror : Maximum standard error to allow for any variant, e.g. 10.
        - --m/maf           : Minimum minor allele frequency to keep variants, e.g. 0.005.
        - --c/mac           : Minimum minor allele count to keep variants, e.g. 30.
        - --i/info          : Minimum imputation quality score to keep variants, e.g. 0.3.
        - --w/hwe_p         : Hardy-Weinberg equilibrium p-value at which to drop variants, e.g. 1E-6.",
        file=stderr()) # print error messages to stderr
  }

cat("\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n")
#        
# ### SAVE ENVIRONMENT | FOR DEBUGGING
# save.image(paste0(OUT_loc, "/", Today,"_",study,"_DEBUG_GWAS_CLEANER.RData"))
