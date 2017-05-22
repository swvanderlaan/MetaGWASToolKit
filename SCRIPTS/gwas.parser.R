#!/hpc/local/CentOS7/dhl_ec/software/R-3.3.3/bin/Rscript --vanilla

### Mac OS X version
### #!/usr/local/bin/Rscript --vanilla

### Linux version
### #!/hpc/local/CentOS7/dhl_ec/software/R-3.3.3/bin/Rscript --vanilla

cat("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    GWAS Parser -- MetaGWASToolKit
    \n
    * Version: v1.2.2
    * Last edit: 2017-05-21
    * Created by: Sander W. van der Laan | s.w.vanderlaan-2@umcutrecht.nl
    \n
    * Description:  Results parsing of GWAS summary statistics files used for a downstream meta-analysis of GWAS. 
    The script should be usuable on both any Linux distribution with R 3+ installed, Mac OS X and Windows.
    
    ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n")

### Usage: ./gwas.parser.R -p projectdir -d datagwas -o outputdir [OPTIONAL: -v verbose (DEFAULT) -q quiet]
###        ./gwas.parser.R --projectdir projectdir --datagwas datagwas --outputdir outputdir [OPTIONAL: --verbose verbose (DEFAULT) -quiet quiet]

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
  make_option(c("-p", "--projectdir"), action="store", default=NA, type='character',
              help="Path to the project directory."),
  make_option(c("-d", "--datagwas"), action="store", default=NA, type='character',
              help="Path to the GWAS data, relative to the project directory; can be tab, comma, space or semicolon delimited, as well as gzipped."),
  make_option(c("-o", "--outputdir"), action="store", default=NA, type='character',
              help="Path to the output directory."),
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
# MACDIR="/Volumes/EliteProQx2Media/PLINK/analyses"
# 
# opt$projectdir=paste0(MACDIR, "/meta_gwasfabp4")
# ### original
# #opt$datagwas=paste0(MACDIR, "/meta_gwasfabp4/DATA_UPLOAD_FREEZE/1000G/AEGS.WHOLE.FABP4.20150125.txt.gz")
# opt$datagwas=paste0(MACDIR, "/meta_gwasfabp4/DATA_UPLOAD_FREEZE/1000G/EPICNL.WHOLE.FABP4.20160629.txt.gz")
# #opt$datagwas=paste0(MACDIR, "/meta_gwasfabp4/DATA_UPLOAD_FREEZE/1000G/CHS.FABP4.20140827.txt.gz")
# 
# opt$outputdir="METAFABP4_1000G/RAW"
# 
# ### FOR LOCAL DEBUGGING

#--------------------------------------------------------------------------

if (opt$verbose) {
  ### You can use either the long or short name; so opt$a and opt$avar are the same.
  ### Show the user what the variables are.
  cat("\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n")
  cat("* Checking the settings as given through the flags.")
  cat("\n - The project directory....................: ")
  cat(opt$projectdir)
  cat("\n - The GWAS data ...........................: ")
  cat(opt$datagwas)
  cat("\n - The output directory.....................: ")
  cat(opt$outputdir)
  cat("\n\n")
}
cat("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n")
cat("Starting \"GWAS Parser\".")

### START OF THE PROGRAM
### main point of program is here, do this whether or not "verbose" is set
if(!is.na(opt$projectdir) & !is.na(opt$datagwas) & !is.na(opt$outputdir)) {
  cat(paste("\n\nWe are going to parse the GWAS data, by parsing and doing some initial quality control of the data.
            \nAnalysing these results...............: '",basename(opt$datagwas),"'
            Parsed results will be saved here.....: '", opt$outputdir, "'.\n",sep=''))
  
  ### GENERAL SETUP
  Today=format(as.Date(as.POSIXlt(Sys.time())), "%Y%m%d")
  cat(paste("\nToday's date is: ", Today, ".\n", sep = ''))
  
  #### DEFINE THE LOCATIONS OF DATA
  ROOT_loc = opt$projectdir # argument 1
  
  cat("\nChecking existence of output directory and creating it if necessary.\n")
  OUT_loc = opt$outputdir # argument 3
  
  if (file.exists(paste(ROOT_loc, OUT_loc, "/", sep = "/", collapse = "/"))) {
    cat(paste0("* '", OUT_loc,"' exists in '", ROOT_loc, "' and is a directory..."))
  } else if (file.exists(paste(ROOT_loc, OUT_loc, sep = "/", collapse = "/"))) {
    cat(paste0("* '", OUT_loc,"' exists in '", ROOT_loc, "' but is a file..."))
    # you will probably want to handle this separately
  } else {
    cat(paste0("* '", OUT_loc,"' does not exist in '", ROOT_loc, "' - creating it now..."))
    dir.create(file.path(ROOT_loc, OUT_loc))
  }
  
  if (file.exists(paste(ROOT_loc, OUT_loc, "/", sep = "/", collapse = "/"))) {
    # By this point, the directory either existed or has been successfully created
    setwd(file.path(ROOT_loc, OUT_loc))
  } else {
    cat(paste0("*** ERROR *** '", OUT_loc,"' does not exist - you likely have a 'rights' issue..."))
    # Handle this error as appropriate
  }
  
  cat("\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n")
  
  ### LOADING GWAS RESULTS FILES
  cat("\nLoading GWAS data.\n")
  ### Location of is set by 'opt$datagwas' # argument 2
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
  
  ### Selecting the columns we want
  cat("\n* Selecting required columns, and creating them if not present...")
  VectorOfColumnsWeWant <- c("^marker$", "^snp$", "^rsid$", 
                             "^chr$", "^chrom$", "^chromosome$", 
                             "^position$", "^bp$",
                             "^effect[_]allele$", "^minor[_]allele$", "^risk[_]allele$", "^coded[_]allele$", 
                             "^effectallele$", "^minorallele$", "^riskallele$", "^codedallele$",
                             "^other[_]allele$", "^major[_]allele$", "^non[_]effect[_]allele$", "^non[_]coded[_]allele$", 
                             "^otherallele$", "^majorallele$", "^noneffectallele$", "^noncodedallele$", 
                             "^strand$", 
                             "^beta$", "^effect[_]size$", "^effectsize$", 
                             "^se.$", "^se$", 
                             "^p.value$", "^p$", "^p.val$", "^pvalue$", "^pval$",# p-value
                             "^[remc]af$", # effect/minor allele frequency
                             "^hwe.value$", "^hwe$", "^hwe.val$", 
                             "^n$", "^samplesize$",
                             "^n_case.$", "^n_control.$", "^n_cntrl.$",
                             "^imputed$", 
                             "^info$")
  matchExpression <- paste(VectorOfColumnsWeWant, collapse = "|")
  GWASDATA_RAWSELECTION <- GWASDATA_RAW %>% select(matches(matchExpression, ignore.case = TRUE))
  
  ### Change column names case to all 'lower cases'
  names(GWASDATA_RAWSELECTION) <- tolower(names(GWASDATA_RAWSELECTION))
  
  cat("\n* Renaming columns where necessary...")
  ### Rename columns
  ### - variant column will become "Marker"
  ### - chromosome & bp columns will become "CHR" and "BP"
  ### - if MAF/minor/major available, thus effect size must be relative to minor, so:
  ###   - MAF = CAF = RAF = EAF -- will be coded as "MAF"
  ###   - minor = coded = effect = risk -- will be coded as "MinorAllele"
  ###   - major = noncoded = noneffect = nonrisk = other -- will be coded as "MajorAllele"
  ### - if MAF/[coded/effect/risk]/[noncoded/noneffect/nonrisk/other], thus the effect 
  ###   size must be relative to [coded/effect/risk], so:
  ###   - MAF = CAF = RAF = EAF -- will be coded as "MAF"
  ###   - coded = effect = risk -- will be coded as "[Coded/Effect/Risk]Allele"
  ###   - noncoded = noneffect = nonrisk = other -- will be coded as "OtherAllele"
  ###   Set these three accordingly, other wise set these to CAF/coded/other
  ###
  
  ### Rename columns -- strand
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, Strand = matches("^strand$"), everything())
  
  ### Rename columns -- imputation
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, Info = matches("^info$"), everything())
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, Imputed = matches("^imputed$"), everything())
  
  ### Rename columns -- n cases and controls
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, N_controls = matches("^n_control.$"), everything())
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, N_controls = matches("^n_ctrl.$"), everything())
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, N_cases = matches("^n_case.$"), everything())
  
  ### Rename columns -- sample size
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, N = matches("^n$"), everything())
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, N = matches("^samplesize$"), everything())
  
  ### Rename columns -- HWE p-value
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, HWE_P = matches("^hwe.value$"), everything())
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, HWE_P = matches("^hwe$"), everything())
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, HWE_P = matches("^hwe.val$"), everything())
  
  ### Rename columns -- p-value
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, P = matches("^p.value$"), everything())
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, P = matches("^p$"), everything())
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, P = matches("^p.val$"), everything())
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, P = matches("^pvalue$"), everything())
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, P = matches("^pval$"), everything())
  
  ### Rename columns -- standard error
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, SE = matches("^se.$"), everything())
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, SE = matches("^se$"), everything())
  
  ### Rename columns -- beta/effect size
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, Beta = matches("^beta$"), everything())
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, Beta = matches("^effect[_]size$"), everything())
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, Beta = matches("^effectsize$"), everything())
  
  ### Rename columns -- allele frequency
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, RAF = matches("^raf$"), everything())
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, EAF = matches("^eaf$"), everything())
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, MAF = matches("^maf$"), everything())
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, CAF = matches("^caf$"), everything())
  
  ### Rename columns -- non effect allele
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, OtherAllele = matches("^non[_]effect[_]allele$"), everything())
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, OtherAllele = matches("^noneffectallele$"), everything())
  
  ### Rename columns -- other allele
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, OtherAllele = matches("^other[_]allele$"), everything())
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, OtherAllele = matches("^otherallele$"), everything())
  
  ### Rename columns -- non coded allele
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, OtherAllele = matches("^non[_]coded[_]allele$"), everything())
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, OtherAllele = matches("^noncodedallele$"), everything())
  
  ### Rename columns -- major allele
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, MajorAllele = matches("^major[_]allele$"), everything())
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, MajorAllele = matches("^majorallele$"), everything())
  
  #### Rename columns -- coded allele
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, CodedAllele = matches("^coded[_]allele$"), everything())
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, CodedAllele = matches("^codedallele$"), everything())
  
  ### Rename columns -- effect allele
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, EffectAllele = matches("^effect[_]allele$"), everything())
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, EffectAllele = matches("^effectallele$"), everything())
  
  ### Rename columns -- risk allele
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, RiskAllele = matches("^risk[_]allele$"), everything())
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, RiskAllele = matches("^riskallele$"), everything())
  
  ### Rename columns -- minor allele
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, MinorAllele = matches("^minor[_]allele$"), everything())
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, MinorAllele = matches("^minorallele$"), everything())
  
  ### Rename columns -- base pair position
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, BP = matches("^position$"), everything())
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, BP = matches("^bp$"), everything())
  
  ### Rename columns -- chromosome
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, CHR = matches("^chr$"), everything())
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, CHR = matches("^chrom$"), everything())
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, CHR = matches("^chromosome$"), everything())
  
  ### Rename columns -- marker name
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, MarkerOriginal = matches("^marker$"), everything())
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, MarkerOriginal = matches("^snp$"), everything())
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, MarkerOriginal = matches("^rsid$"), everything())
  
  ### Rename columns -- removing leading 'zeros'
  cat("\n* Removing leading 'zeros' from chromosome number...")
  GWASDATA_RAWSELECTION$CHR <- gsub("(?<![0-9])0+", "", GWASDATA_RAWSELECTION$CHR, perl = TRUE)
  
  cat("\n* Changing 23 to X, 24 to Y, 25 to XY, and 26 to MT...")
  ### Renaming chromosomes
  ### 1000G standard  Description                   'PLINK' standard
  ### X               X chromosome                    <-> 23
  ### Y               Y chromosome                    <-> 24
  ### XY              Pseudo-autosomal region of X    <-> 25
  ### MT              Mitochondrial                   <-> 26
  
  ### Rename chromosomes
  GWASDATA_RAWSELECTION$CHR[GWASDATA_RAWSELECTION$CHR == "x" | GWASDATA_RAWSELECTION$CHR == "23"] <- "X"
  GWASDATA_RAWSELECTION$CHR[GWASDATA_RAWSELECTION$CHR == "y" | GWASDATA_RAWSELECTION$CHR == "24"] <- "Y"
  GWASDATA_RAWSELECTION$CHR[GWASDATA_RAWSELECTION$CHR == "xY" | GWASDATA_RAWSELECTION$CHR == "Xy" | 
                              GWASDATA_RAWSELECTION$CHR == "xy" | GWASDATA_RAWSELECTION$CHR == "xy"] <- "XY"
  GWASDATA_RAWSELECTION$CHR[GWASDATA_RAWSELECTION$CHR == "Mt" | GWASDATA_RAWSELECTION$CHR == "mT" | 
                              GWASDATA_RAWSELECTION$CHR == "mt"] <- "MT"
  
  # ### set 'chromosome' column to integer
  # GWASDATA_RAWSELECTION <- mutate(GWASDATA_RAWSELECTION, CHR = as.integer(CHR)) # convert to numeric
  GWASDATA_RAWSELECTION <- mutate(GWASDATA_RAWSELECTION, BP = as.integer(BP)) # convert to numeric
  
  ### Calculating general statistics if not available
  cat("\n* Calculating 'allele frequencies'...")
  ### calculate MAF -- *only* if MAF/minor allele/major allele *not* present
  ###                  the effect size must be relative to the effect/coded allele and EAF
  ### calculate EAF -- *only* if MAF/minor allele/major allele *is* present - 
  ###                  if they are, the effect size must be relative to the minor
  
  if("MAF" %in% colnames(GWASDATA_RAWSELECTION)) {
    cat("\n* Minor allele frequency is present, checking for minor/major allele...")
    
    if("MinorAllele" %in% colnames(GWASDATA_RAWSELECTION)) {
      cat("\n- minor allele is present, checking for major allele...")
      
      if("MajorAllele" %in% colnames(GWASDATA_RAWSELECTION)) {
        cat("\n- minor/major allele is also present, setting effect/other allele, 
            and calculating effect allele frequency...") # we will only set the effect/other alleles here
        GWASDATA_RAWSELECTION$EAF <- GWASDATA_RAWSELECTION$MAF
        GWASDATA_RAWSELECTION$EffectAllele <- GWASDATA_RAWSELECTION$MinorAllele
        GWASDATA_RAWSELECTION$OtherAllele <- GWASDATA_RAWSELECTION$MajorAllele
        GWASDATA_RAWSELECTION$BetaMinor <- GWASDATA_RAWSELECTION$Beta
        
      } else {
        cat("\n\n*** ERROR *** Something is rotten in the City of Gotham. If there's a 'minor allele', 
            a 'major allele' must be present as well.", file=stderr()) # print error messages to stder
      } } } else if("OtherAllele" %in% colnames(GWASDATA_RAWSELECTION)) {
        cat("\n* Other alleles are present, calculating minor allele frequency...") # we only care for MAF
        
        if("EAF" %in% colnames(GWASDATA_RAWSELECTION)) {
          cat("\n- calculating 'MAF' using 'effect allele frequency'...")
          GWASDATA_RAWSELECTION$MAF <- ifelse(GWASDATA_RAWSELECTION$EAF < 0.50, 
                                              GWASDATA_RAWSELECTION$EAF, 1-GWASDATA_RAWSELECTION$EAF)
          GWASDATA_RAWSELECTION$MinorAllele <- ifelse(GWASDATA_RAWSELECTION$EAF < 0.50, 
                                                      GWASDATA_RAWSELECTION$EffectAllele, GWASDATA_RAWSELECTION$OtherAllele)
          GWASDATA_RAWSELECTION$MajorAllele <- ifelse(GWASDATA_RAWSELECTION$EAF > 0.50, 
                                                      GWASDATA_RAWSELECTION$EffectAllele, GWASDATA_RAWSELECTION$OtherAllele)
          GWASDATA_RAWSELECTION$BetaMinor <- ifelse(GWASDATA_RAWSELECTION$EAF < 0.50, 
                                                    GWASDATA_RAWSELECTION$Beta, -1*GWASDATA_RAWSELECTION$Beta)
          
        } else if("RAF" %in% colnames(GWASDATA_RAWSELECTION)) {
          cat("\n- calculating 'MAF' using 'risk allele frequency'...")
          GWASDATA_RAWSELECTION$MAF <- ifelse(GWASDATA_RAWSELECTION$RAF < 0.50, 
                                              GWASDATA_RAWSELECTION$RAF, 1-GWASDATA_RAWSELECTION$RAF)
          GWASDATA_RAWSELECTION$MinorAllele <- ifelse(GWASDATA_RAWSELECTION$RAF < 0.50, 
                                                      GWASDATA_RAWSELECTION$RiskAllele, GWASDATA_RAWSELECTION$OtherAllele)
          GWASDATA_RAWSELECTION$MajorAllele <- ifelse(GWASDATA_RAWSELECTION$RAF > 0.50, 
                                                      GWASDATA_RAWSELECTION$RiskAllele, GWASDATA_RAWSELECTION$OtherAllele)
          GWASDATA_RAWSELECTION$BetaMinor <- ifelse(GWASDATA_RAWSELECTION$RAF < 0.50, 
                                                    GWASDATA_RAWSELECTION$Beta, -1*GWASDATA_RAWSELECTION$Beta)
          colnames(GWASDATA_RAWSELECTION)[colnames(GWASDATA_RAWSELECTION) == "RAF"] <- "EAF"          
          
        } else if("CAF" %in% colnames(GWASDATA_RAWSELECTION)) {
          cat("\n- calculating 'MAF' using 'coded allele frequency'...")
          GWASDATA_RAWSELECTION$MAF <- ifelse(GWASDATA_RAWSELECTION$CAF < 0.50, 
                                              GWASDATA_RAWSELECTION$CAF, 1-GWASDATA_RAWSELECTION$CAF)
          GWASDATA_RAWSELECTION$MinorAllele <- ifelse(GWASDATA_RAWSELECTION$CAF < 0.50, 
                                                      GWASDATA_RAWSELECTION$CodedAllele, GWASDATA_RAWSELECTION$OtherAllele)
          GWASDATA_RAWSELECTION$MajorAllele <- ifelse(GWASDATA_RAWSELECTION$CAF > 0.50, 
                                                      GWASDATA_RAWSELECTION$CodedAllele, GWASDATA_RAWSELECTION$OtherAllele)
          GWASDATA_RAWSELECTION$BetaMinor <- ifelse(GWASDATA_RAWSELECTION$CAF < 0.50, 
                                                    GWASDATA_RAWSELECTION$Beta, -1*GWASDATA_RAWSELECTION$Beta)
          colnames(GWASDATA_RAWSELECTION)[colnames(GWASDATA_RAWSELECTION) == "CAF"] <- "EAF"
          
        } else {
          cat("\n\n*** ERROR *** Something is rotten in the City of Gotham. 'MAF', EAF', 'RAF', nor 'CAF' is present. Double back, please.", file=stderr()) # print error messages to stder
        } 
        
      } else {
        cat("\n\n*** ERROR *** Something is rotten in the City of Gotham. There's something wrong with the allele frequencies. Double back, please.", file=stderr()) # print error messages to stder
        
      } 
  
  ### Calculate MAC
  cat("\n* Calculating 'minor allele count' (MAC)...")
  GWASDATA_RAWSELECTION$MAC <- (GWASDATA_RAWSELECTION$MAF*GWASDATA_RAWSELECTION$N*2)
  
  cat("\n* Creating the final parsed dataset.")
  
  cat("\n- making empty dataframe...")
  col.Classes = c("character", "character", "integer", "integer", "character", 
                  "character", "character", "character", "character", 
                  "numeric", "numeric", "numeric", "numeric", "numeric", 
                  "numeric", "numeric", "numeric", "numeric", 
                  "integer", "integer", "integer", 
                  "character")
  col.Names = c("Marker", "MarkerOriginal", "CHR", "BP", "Strand", 
                "EffectAllele", "OtherAllele", "MinorAllele", "MajorAllele", 
                "EAF", "MAF", "MAC", "HWE_P", "Info",
                "Beta", "BetaMinor", "SE", "P",
                "N", "N_cases", "N_controls",
                "Imputed")
  num_rows = length(GWASDATA_RAWSELECTION$MarkerOriginal)
  num_cols = length(col.Names)
  
  ### Function to create empty table
  create_empty_table <- function(num_rows, num_cols) {
    GWASDATA_PARSED <- data.frame(matrix(NA, nrow = num_rows, ncol = num_cols))
    
    return(GWASDATA_PARSED)
  }
  
  GWASDATA_PARSED <- create_empty_table(num_rows, num_cols)
  colnames(GWASDATA_PARSED) <- col.Names
  
  cat("\n- adding data to dataframe...")
  cat("\n  > adding the new markers; these will have the form [ chr<#>:<#>:MinorAllele_MajorAllele] ...")
  GWASDATA_PARSED$Marker <- as.character(paste("chr",GWASDATA_RAWSELECTION$CHR,":",
                                               GWASDATA_RAWSELECTION$BP,":",
                                               GWASDATA_RAWSELECTION$MinorAllele,"_",
                                               GWASDATA_RAWSELECTION$MajorAllele, 
                                               sep = ""))
  
  cat("\n  > adding the original markers...")
  GWASDATA_PARSED$MarkerOriginal <- GWASDATA_RAWSELECTION$MarkerOriginal
  
  cat("\n  > changing NA to '0' for Chr...")
  GWASDATA_PARSED$CHR <- GWASDATA_RAWSELECTION$CHR
  GWASDATA_PARSED <- GWASDATA_PARSED %>% mutate(CHR = ifelse(is.na(CHR),0,CHR)) # unknown chromosomes are set to '0'
  
  cat("\n  > changing NA to '0' for BP...")
  GWASDATA_PARSED$BP <- GWASDATA_RAWSELECTION$BP
  GWASDATA_PARSED <- GWASDATA_PARSED %>% mutate(BP = ifelse(is.na(BP),0,BP))# unknown base pair positions are set to '0'
  
  cat("\n  > adding strand information...")
  GWASDATA_PARSED$Strand <- ifelse(("Strand" %in% colnames(GWASDATA_RAWSELECTION)) == TRUE, 
                                   GWASDATA_RAWSELECTION$Strand, "+") # we always assume that the +-strand was used
  
  cat("\n  > adding alleles...")
  GWASDATA_PARSED$EffectAllele <- ifelse(GWASDATA_RAWSELECTION$EffectAllele != "NA", GWASDATA_RAWSELECTION$EffectAllele, "NA")
  GWASDATA_PARSED$OtherAllele <- ifelse(GWASDATA_RAWSELECTION$OtherAllele != "NA", GWASDATA_RAWSELECTION$OtherAllele, "NA")
  GWASDATA_PARSED$MinorAllele <- ifelse(GWASDATA_RAWSELECTION$MinorAllele != "NA", GWASDATA_RAWSELECTION$MinorAllele, "NA")
  GWASDATA_PARSED$MajorAllele <- ifelse(GWASDATA_RAWSELECTION$MajorAllele != "NA", GWASDATA_RAWSELECTION$MajorAllele, "NA")
  
  cat("\n  > adding allele statistics...")
  GWASDATA_PARSED$EAF <- ifelse(GWASDATA_RAWSELECTION$EAF != "NA", GWASDATA_RAWSELECTION$EAF, "NA")
  GWASDATA_PARSED$MAF <- ifelse(GWASDATA_RAWSELECTION$MAF != "NA", GWASDATA_RAWSELECTION$MAF, "NA")
  GWASDATA_PARSED$MAC <- ifelse(GWASDATA_RAWSELECTION$MAC != "NA", GWASDATA_RAWSELECTION$MAC, "NA")
  
  if(("HWE_P" %in% colnames(GWASDATA_RAWSELECTION)) == TRUE){
    GWASDATA_PARSED$HWE_P <- ifelse(GWASDATA_RAWSELECTION$HWE_P != "NA", GWASDATA_RAWSELECTION$HWE_P, "1") # this is not always present, hence we set it at "1"
  } else {
    GWASDATA_PARSED$HWE_P <- "1" # this is not always present, hence we set it at "1"
  } 
  
  if(("Info" %in% colnames(GWASDATA_RAWSELECTION)) == TRUE){
    GWASDATA_PARSED$Info <- ifelse(GWASDATA_RAWSELECTION$Info != "NA", GWASDATA_RAWSELECTION$Info, "1") # in case "NA" we set it to 1
  } else {
    GWASDATA_PARSED$Info <- "1" # in case of genotyped data
  }
  
  cat("\n  > adding test statistics...")  
  GWASDATA_PARSED$Beta <- ifelse(GWASDATA_RAWSELECTION$Beta != "NA", GWASDATA_RAWSELECTION$Beta, "NA") # Note that beta is relative to the EffectAllele
  GWASDATA_PARSED$BetaMinor <- ifelse(GWASDATA_RAWSELECTION$BetaMinor != "NA", GWASDATA_RAWSELECTION$BetaMinor, "NA") # Note that betaminor is relative to the MinorAllele
  GWASDATA_PARSED$SE <- ifelse(GWASDATA_RAWSELECTION$SE != "NA", GWASDATA_RAWSELECTION$SE, "NA")
  GWASDATA_PARSED$P <- ifelse(GWASDATA_RAWSELECTION$P != "NA", GWASDATA_RAWSELECTION$P, "NA")
  
  cat("\n  > adding sample information statistics...")  
  GWASDATA_PARSED$N <- ifelse(GWASDATA_RAWSELECTION$N != "NA", GWASDATA_RAWSELECTION$N, "NA")
  
  if(("N_cases" %in% colnames(GWASDATA_RAWSELECTION)) == TRUE){
    GWASDATA_PARSED$N_cases <- ifelse(GWASDATA_RAWSELECTION$N_cases != "NA", GWASDATA_RAWSELECTION$N_cases, "NA")
  } else {
    GWASDATA_PARSED$N_cases <- "NA" # in case of quantitative trait analyses
  } 
  
  if(("N_controls" %in% colnames(GWASDATA_RAWSELECTION)) == TRUE){
    GWASDATA_PARSED$N_controls <- ifelse(GWASDATA_RAWSELECTION$N_controls != "NA", GWASDATA_RAWSELECTION$N_controls, "NA")
  } else {
    GWASDATA_PARSED$N_controls <- "NA" # in case of quantitative trait analyses
  }
  
  if(("Imputed" %in% colnames(GWASDATA_RAWSELECTION)) == TRUE){
    GWASDATA_PARSED$Imputed <- ifelse(GWASDATA_RAWSELECTION$Imputed != "NA", GWASDATA_RAWSELECTION$Imputed, "NA")
  } else {
    GWASDATA_PARSED$Imputed <- "2" # 2 = no information, 1 = imputed, 0 = genotyped
  }
  
  cat("\n* All done creating the final parsed dataset.")
  ### SAVE NEW DATA ###
  cat("\n\nSaving parsed data...\n")
  write.table(GWASDATA_PARSED, 
              paste0(ROOT_loc, "/", OUT_loc, "/", 
                     basename(opt$datagwas), 
                     ".pdat"),
              quote = FALSE , row.names = FALSE, col.names = TRUE, 
              sep = "\t", na = "NA", dec = ".")
  
  ### CLOSING MESSAGE
  cat(paste("\nAll done parsing [",file_path_sans_ext(basename(opt$datagwas), compression = TRUE),"].\n"))
  cat(paste("\nToday's date is: ", Today, ".\n", sep = ''))
  
  } else {
    cat("\n\n\n\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n")
    cat("\n*** ERROR *** You didn't specify all variables:\n
        - --p/projectdir    : Path to the project directory.
        - --d/datagwas      : Path to the GWAS data, relative to the project directory;
        can be tab, comma, space or semicolon delimited, as well as gzipped.
        - --o/outputdir     : Path to output directory.",
        file=stderr()) # print error messages to stderr
  }

cat("\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n")
# 
# ### SAVE ENVIRONMENT | FOR DEBUGGING
# save.image(paste0(ROOT_loc, "/", OUT_loc, "/", Today,"_", basename(opt$datagwas),"_DEBUG_GWAS_PARSER.RData"))
