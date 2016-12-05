#!/hpc/local/CentOS7/dhl_ec/software/R-3.3.1/bin/Rscript --vanilla

# Alternative shebang for local Mac OS X: #!/usr/local/bin/Rscript --vanilla
# Linux version for HPC: #!/hpc/local/CentOS7/dhl_ec/software/R-3.3.1/bin/Rscript --vanilla
cat("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    GWAS Parser v1
    \n
    * Version: v1.1.0
    * Last edit: 2016-12-05
    * Created by: Sander W. van der Laan | s.w.vanderlaan-2@umcutrecht.nl
    \n
    * Description:  Results parsing of GWAS summary statistics files used for a downstream meta-analysis of GWAS. 
    The script should be usuable on both any Linux distribution with R 3+ installed, Mac OS X and Windows.
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n")

# usage: ./gwas.parser.R -p projectdir -d datagwas -o outputdir [OPTIONAL: -v verbose (DEFAULT) -q quiet]
#        ./gwas.parser.R --projectdir projectdir --datagwas datagwas --outputdir outputdir [OPTIONAL: --verbose verbose (DEFAULT) -quiet quiet]

#--------------------------------------------------------------------------
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
    eval(parse(text = sprintf("install.packages(\"%s\", dependencies = TRUE)", x)))
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

cat("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n")

cat("\n* Setting colours...\n\n")
uithof_color=c("#FBB820","#F59D10","#E55738","#DB003F","#E35493","#D5267B",
               "#CC0071","#A8448A","#9A3480","#8D5B9A","#705296","#686AA9",
               "#6173AD","#4C81BF","#2F8BC9","#1290D9","#1396D8","#15A6C1",
               "#5EB17F","#86B833","#C5D220","#9FC228","#78B113","#49A01D",
               "#595A5C","#A2A3A4")
#--------------------------------------------------------------------------

#--------------------------------------------------------------------------
### OPTION LISTING
option_list = list(
  make_option(c("-p", "--projectdir"), action="store", default=NA, type='character',
              help="Path to the project directory."),
  make_option(c("-d", "--datagwas"), action="store", default=NA, type='character',
              help="Path to the GWAS data, relative to the project directory; can be tab, comma, space or semicolon delimited, as well as gzipped."),
  make_option(c("-o", "--outputdir"), action="store", default=NA, type='character',
              help="Path to the output directory."),
  make_option(c("-v", "--verbose"), action="store_true", default=TRUE,
              help="Should the program print extra stuff out? [default %default]"),
  make_option(c("-s", "--silent"), action="store_false", dest="verbose",
              help="Make the program not be verbose.")
  #make_option(c("-c", "--cvar"), action="store", default="this is c",
  #            help="a variable named c, with a default [default %default]")  
)
opt = parse_args(OptionParser(option_list=option_list))

# ### OPTIONLIST | FOR LOCAL DEBUGGING -- MacBook Pro
# opt$projectdir="/Users/swvanderlaan/PLINK/analyses/meta_gwasfabp4"
# # original
# ###opt$datagwas="/Users/swvanderlaan/PLINK/analyses/meta_gwasfabp4/DATA_UPLOAD_FREEZE/1000G/AEGS.WHOLE.FABP4.20150125.txt.gz"
# opt$datagwas="/Users/swvanderlaan/PLINK/analyses/meta_gwasfabp4/DATA_UPLOAD_FREEZE/1000G/AEGS.WHOLE.FABP4.20150125.txt"
# 
# opt$outputdir="METAFABP4_1000G/RAW"
# ### OPTIONLIST | FOR LOCAL DEBUGGING

# ### OPTIONLIST | FOR LOCAL DEBUGGING -- Mac Pro
# opt$projectdir="/Volumes/MyBookStudioII/Backup/PLINK/analyses/meta_gwasfabp4"
# # original
# #opt$datagwas="/Volumes/MyBookStudioII/Backup/PLINK/analyses/meta_gwasfabp4/DATA_UPLOAD_FREEZE/AEGS.WHOLE.FABP4.20150125.TEMP.txt"
# # different header
# opt$datagwas="/Volumes/MyBookStudioII/Backup/PLINK/analyses/meta_gwasfabp4/DATA_UPLOAD_FREEZE/AEGS.WHOLE.FABP4.20150125.TEMP.differenthearder.EffectOther.txt.gz"
# #opt$datagwas="/Volumes/MyBookStudioII/Backup/PLINK/analyses/meta_gwasfabp4/DATA_UPLOAD_FREEZE/AEGS.WHOLE.FABP4.20150125.TEMP.differenthearder.txt.gz"
# #opt$datagwas="/Volumes/MyBookStudioII/Backup/PLINK/analyses/meta_gwasfabp4/DATA_UPLOAD_FREEZE/AEGS.WHOLE.FABP4.20150125.TEMP.differenthearderMinorMajor.txt.gz"
# 
# opt$outputdir="MANTEL_1000G/RAW"
# ### OPTIONLIST | FOR LOCAL DEBUGGING

if (opt$verbose) {
  # You can use either the long or short name; so opt$a and opt$avar are the same.
  # Show the user what the variables are.
  cat("\n+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n")
  cat("* Checking the settings as given through the flags.")
  cat("\n - The project directory....................: ")
  cat(opt$projectdir)
  cat("\n - The GWAS data ...........................: ")
  cat(opt$datagwas)
  cat("\n - The output directory.....................: ")
  cat(opt$outputdir)
  cat("\n+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n")
  cat("\n\n")
}
cat("\n+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n")
cat("Starting \"GWAS Parser\".")
#--------------------------------------------------------------------------
### START OF THE PROGRAM
# main point of program is here, do this whether or not "verbose" is set
if(!is.na(opt$projectdir) & !is.na(opt$datagwas) & !is.na(opt$outputdir)) {
  cat(paste("\n\nWe are going to parse the GWAS data, by parsing and doing some initial quality control of the data.
\nAnalysing these results...............: '",basename(opt$datagwas),"'
Parsed results will be saved here.....: '", opt$outputdir, "'.\n",sep=''))
  
  #--------------------------------------------------------------------------
  ### GENERAL SETUP
  Today=format(as.Date(as.POSIXlt(Sys.time())), "%Y%m%d")
  cat(paste("\nToday's date is: ", Today, ".\n", sep = ''))
  
  #--------------------------------------------------------------------------
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
  
  #METAGWASTOOLKIT = "/Users/swvanderlaan/Library/Mobile Documents/com~apple~CloudDocs/SNP_suites/MetaGWASToolKit"
  #METAGWASTOOLKIT_RESOURCES = paste0(METAGWASTOOLKIT,"/RESOURCES")
  
  cat("\n+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n")
  #--------------------------------------------------------------------------
  ### LOADING GWAS RESULTS FILES

  cat("\nLoading GWAS data.\n")
  ### Location of is set by 'opt$datagwas' # argument 2
  ### Checking file type -- is it gzipped or not?
  filetype = summary(file(opt$datagwas))$class
  if(filetype == "gzfile"){
    TESTDELIMITER = readLines(opt$datagwas, n = 1)
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
    TESTDELIMITER = readLines(opt$datagwas, n = 1)
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
  cat("\n* selecting required columns, and creating them if not present...")
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

  cat("\n* renaming columns where necessary...")
  # Rename columns
  # - variant column will become "Marker"
  # - chromosome & bp columns will become "CHR" and "BP"
  # - if MAF/minor/major available, thus effect size must be relative to minor, so:
  #   - MAF = CAF = RAF = EAF -- will be coded as "MAF"
  #   - minor = coded = effect = risk -- will be coded as "MinorAllele"
  #   - major = noncoded = noneffect = nonrisk = other -- will be coded as "MajorAllele"
  # - if MAF/[coded/effect/risk]/[noncoded/noneffect/nonrisk/other], thus the effect 
  #   size must be relative to [coded/effect/risk], so:
  #   - MAF = CAF = RAF = EAF -- will be coded as "MAF"
  #   - coded = effect = risk -- will be coded as "[Coded/Effect/Risk]Allele"
  #   - noncoded = noneffect = nonrisk = other -- will be coded as "OtherAllele"
  #   Set these three accordingly, other wise set these to CAF/coded/other
  #

  # strand
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, Strand = matches("^strand$"), everything())
  
  # imputation
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, Info = matches("^info$"), everything())
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, Imputed = matches("^imputed$"), everything())
  
  # n cases and controls
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, N_controls = matches("^n_control.$"), everything())
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, N_controls = matches("^n_ctrl.$"), everything())
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, N_cases = matches("^n_case.$"), everything())
  
  # sample size
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, N = matches("^n$"), everything())
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, N = matches("^samplesize$"), everything())
  
  # HWE p-value
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, HWE_P = matches("^hwe.value$"), everything())
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, HWE_P = matches("^hwe$"), everything())
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, HWE_P = matches("^hwe.val$"), everything())
  
  # p-value
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, P = matches("^p.value$"), everything())
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, P = matches("^p$"), everything())
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, P = matches("^p.val$"), everything())
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, P = matches("^pvalue$"), everything())
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, P = matches("^pval$"), everything())
  
  # standard error
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, SE = matches("^se.$"), everything())
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, SE = matches("^se$"), everything())
  
  # beta/effect size
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, Beta = matches("^beta$"), everything())
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, Beta = matches("^effect[_]size$"), everything())
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, Beta = matches("^effectsize$"), everything())
  
  # allele frequency
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, RAF = matches("^raf$"), everything())
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, EAF = matches("^eaf$"), everything())
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, MAF = matches("^maf$"), everything())
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, CAF = matches("^caf$"), everything())

  # non effect allele
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, OtherAllele = matches("^non[_]effect[_]allele$"), everything())
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, OtherAllele = matches("^noneffectallele$"), everything())
  
  # other allele
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, OtherAllele = matches("^other[_]allele$"), everything())
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, OtherAllele = matches("^otherallele$"), everything())
  
  # non coded allele
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, OtherAllele = matches("^non[_]coded[_]allele$"), everything())
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, OtherAllele = matches("^noncodedallele$"), everything())
  
  # major allele
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, MajorAllele = matches("^major[_]allele$"), everything())
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, MajorAllele = matches("^majorallele$"), everything())

  #coded allele
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, CodedAllele = matches("^coded[_]allele$"), everything())
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, CodedAllele = matches("^codedallele$"), everything())
  
  # effect allele
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, EffectAllele = matches("^effect[_]allele$"), everything())
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, EffectAllele = matches("^effectallele$"), everything())
  
  # risk allele
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, RiskAllele = matches("^risk[_]allele$"), everything())
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, RiskAllele = matches("^riskallele$"), everything())
  
  # minor allele
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, MinorAllele = matches("^minor[_]allele$"), everything())
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, MinorAllele = matches("^minorallele$"), everything())
  
  # base pair position
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, BP = matches("^position$"), everything())
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, BP = matches("^bp$"), everything())

  # chromosome
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, CHR = matches("^chr$"), everything())
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, CHR = matches("^chrom$"), everything())
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, CHR = matches("^chromosome$"), everything())
  
  # marker name
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, Marker = matches("^marker$"), everything())
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, Marker = matches("^snp$"), everything())
  GWASDATA_RAWSELECTION <- select(GWASDATA_RAWSELECTION, Marker = matches("^rsid$"), everything())
  
  # removing leading 'zeros'
  cat("\n* removing leading 'zeros' from chromosome number...")
  GWASDATA_RAWSELECTION$CHR <- gsub("(?<![0-9])0+", "", GWASDATA_RAWSELECTION$CHR, perl = TRUE)

  cat("\n* changing X to 23, Y to 24, XY to 25, and MT to 26...")
  # X    X chromosome                    -> 23
  # Y    Y chromosome                    -> 24
  # XY   Pseudo-autosomal region of X    -> 25
  # MT   Mitochondrial                   -> 26
  
  # rename chromosomes
  GWASDATA_RAWSELECTION$CHR[GWASDATA_RAWSELECTION$CHR == "X" | GWASDATA_RAWSELECTION$CHR == "x"] <- 23
  GWASDATA_RAWSELECTION$CHR[GWASDATA_RAWSELECTION$CHR == "Y" | GWASDATA_RAWSELECTION$CHR == "y"] <- 24
  GWASDATA_RAWSELECTION$CHR[GWASDATA_RAWSELECTION$CHR == "XY" | 
                              GWASDATA_RAWSELECTION$CHR == "xY" | 
                              GWASDATA_RAWSELECTION$CHR == "Xy" | 
                              GWASDATA_RAWSELECTION$CHR == "xy"] <- 25
  GWASDATA_RAWSELECTION$CHR[GWASDATA_RAWSELECTION$CHR == "MT" | 
                              GWASDATA_RAWSELECTION$CHR == "Mt" | 
                              GWASDATA_RAWSELECTION$CHR == "mT" | GWASDATA_RAWSELECTION$CHR == "mt"] <- 26
  
  # set 'chromosome' column to integer
  GWASDATA_RAWSELECTION <- mutate(
    GWASDATA_RAWSELECTION, 
    CHR      = as.integer(CHR)) # convert to numeric
  
  #cat("\n* arranging based on chromosomal base pair position...") # if you are batching the data, this may not be that useful...
  #GWASDATA_RAWSELECTION <- arrange(GWASDATA_RAWSELECTION, CHR, BP) # first by chr, then by bp
  
  # Calculating general statistics if not available
  cat("\n* calculating 'allele frequencies'...")
  # calculate MAF -- *only* if MAF/minor allele/major allele *not* present
  #                  the effect size must be relative to the effect/coded allele and EAF
  # calculate EAF -- *only* if MAF/minor allele/major allele *is* present - 
  #                  if they are, the effect size must be relative to the minor

  if("MAF" %in% colnames(GWASDATA_RAWSELECTION)) {
  	cat("\n- minor allele frequency is present, checking for minor/major allele...")
    
    if("MinorAllele" %in% colnames(GWASDATA_RAWSELECTION)) {
  	cat("\n- minor allele is present, checking for major allele...")
      
      if("MajorAllele" %in% colnames(GWASDATA_RAWSELECTION)) {
  	cat("\n- minor/major allele is also present, setting effect/other allele, 
 	and calculating effect allele frequency...") # we will only set the effect/other alleles here, and get rid of minor/major alleles later
        GWASDATA_RAWSELECTION$EAF <- GWASDATA_RAWSELECTION$MAF
        GWASDATA_RAWSELECTION$EffectAllele <- GWASDATA_RAWSELECTION$MinorAllele
        GWASDATA_RAWSELECTION$OtherAllele <- GWASDATA_RAWSELECTION$MajorAllele
      
      } else {
  cat("\n\n*** ERROR *** Something is rotten in the City of Gotham. If there's a 'minor allele', 
  a 'major allele' must be present as well.", file=stderr()) # print error messages to stder
        } } } else if("OtherAllele" %in% colnames(GWASDATA_RAWSELECTION)) {
  	cat("\n- other alleles are present, calculating minor allele frequency...") # we only care for MAF
          
           if("EAF" %in% colnames(GWASDATA_RAWSELECTION)) {
  	cat("\n- calculating 'MAF' using 'effect allele frequency'...")
             GWASDATA_RAWSELECTION$MAF <- ifelse(GWASDATA_RAWSELECTION$EAF < 0.50, 
                                                 GWASDATA_RAWSELECTION$EAF, 1-GWASDATA_RAWSELECTION$EAF)
             
             } else if("RAF" %in% colnames(GWASDATA_RAWSELECTION)) {
  	cat("\n- calculating 'MAF' using 'risk allele frequency'...")
                GWASDATA_RAWSELECTION$MAF <- ifelse(GWASDATA_RAWSELECTION$RAF < 0.50, 
                                                    GWASDATA_RAWSELECTION$RAF, 1-GWASDATA_RAWSELECTION$RAF)
                colnames(GWASDATA_RAWSELECTION)[colnames(GWASDATA_RAWSELECTION) == "RAF"] <- "EAF"
                
                } else if("CAF" %in% colnames(GWASDATA_RAWSELECTION)) {
  	cat("\n- calculating 'MAF' using 'coded allele frequency'...")
                  GWASDATA_RAWSELECTION$MAF <- ifelse(GWASDATA_RAWSELECTION$CAF < 0.50, 
                                                      GWASDATA_RAWSELECTION$CAF, 1-GWASDATA_RAWSELECTION$CAF)
                  colnames(GWASDATA_RAWSELECTION)[colnames(GWASDATA_RAWSELECTION) == "CAF"] <- "EAF"
                  
                  } else {
  cat("\n\n*** ERROR *** Something is rotten in the City of Gotham. 'MAF', EAF', 'RAF', nor 'CAF' is present. Double back, please.", file=stderr()) # print error messages to stder
             } 

          } else {
  cat("\n\n*** ERROR *** Something is rotten in the City of Gotham. There's something wrong with the allele frequencies. Double back, please.", file=stderr()) # print error messages to stder
          
          } 
    
  cat("\n* calculating 'minor allele count' (MAC)...")
  # calculate MAC
  GWASDATA_RAWSELECTION$MAC <- (GWASDATA_RAWSELECTION$MAF*GWASDATA_RAWSELECTION$N*2)

  cat("\nCreating the final parsed dataset.")
  
  cat("\n- making empty dataframe...")
  col.Classes = c("character", "integer", "integer", "character", 
                 "character", "character", 
                 "numeric", "numeric", "numeric", "numeric", "numeric", 
                 "numeric", "numeric", "numeric", 
                 "integer", "integer", "integer", 
                 "character")
  col.Names = c("Marker", "CHR", "BP", "Strand", 
                "EffectAllele", "OtherAllele", 
                "EAF", "MAF", "MAC", "HWE_P", "Info",
                "Beta", "SE", "P",
                "N", "N_cases", "N_controls",
                "Imputed")
  num_rows = length(GWASDATA_RAWSELECTION$Marker)
  num_cols = length(col.Names)
  
  # function to create empty table
  create_empty_table <- function(num_rows, num_cols) {
    GWASDATA_PARSED <- data.frame(matrix(NA, nrow = num_rows, ncol = num_cols))
    
    return(GWASDATA_PARSED)
  }
  GWASDATA_PARSED <- create_empty_table(num_rows, num_cols)
  colnames(GWASDATA_PARSED) <- col.Names
  
  cat("\n- adding data to dataframe...")
  GWASDATA_PARSED$Marker <- GWASDATA_RAWSELECTION$Marker
  GWASDATA_PARSED$CHR <- ifelse(GWASDATA_RAWSELECTION$CHR != "NA", GWASDATA_RAWSELECTION$CHR, "NA")
  GWASDATA_PARSED$BP <- ifelse(GWASDATA_RAWSELECTION$BP != "NA", GWASDATA_RAWSELECTION$BP, "NA")
  GWASDATA_PARSED$Strand <- ifelse(("Strand" %in% colnames(GWASDATA_RAWSELECTION)) == TRUE, 
                                   GWASDATA_RAWSELECTION$Strand, "+") # we always assume that the +-strand was used
  
  GWASDATA_PARSED$EffectAllele <- ifelse(GWASDATA_RAWSELECTION$EffectAllele != "NA", GWASDATA_RAWSELECTION$EffectAllele, "NA")
  GWASDATA_PARSED$OtherAllele <- ifelse(GWASDATA_RAWSELECTION$OtherAllele != "NA", GWASDATA_RAWSELECTION$OtherAllele, "NA")
  
  GWASDATA_PARSED$EAF <- ifelse(GWASDATA_RAWSELECTION$EAF != "NA", GWASDATA_RAWSELECTION$EAF, "NA")
  GWASDATA_PARSED$MAF <- ifelse(GWASDATA_RAWSELECTION$MAF != "NA", GWASDATA_RAWSELECTION$MAF, "NA")
  GWASDATA_PARSED$MAC <- ifelse(GWASDATA_RAWSELECTION$MAC != "NA", GWASDATA_RAWSELECTION$MAC, "NA")
  GWASDATA_PARSED$HWE_P <- ifelse(("HWE_P" %in% colnames(GWASDATA_RAWSELECTION)) == TRUE, 
                                  GWASDATA_RAWSELECTION$HWE_P, "NA") # this is not always present
  GWASDATA_PARSED$Info <- ifelse(("Info" %in% colnames(GWASDATA_RAWSELECTION)) == TRUE, 
                                 GWASDATA_RAWSELECTION$Info, "1") # in case of genotyped data
  
  GWASDATA_PARSED$Beta <- ifelse(GWASDATA_RAWSELECTION$Beta != "NA", GWASDATA_RAWSELECTION$Beta, "NA")
  GWASDATA_PARSED$SE <- ifelse(GWASDATA_RAWSELECTION$SE != "NA", GWASDATA_RAWSELECTION$SE, "NA")
  GWASDATA_PARSED$P <- ifelse(GWASDATA_RAWSELECTION$P != "NA", GWASDATA_RAWSELECTION$P, "NA")
  
  GWASDATA_PARSED$N <- ifelse(GWASDATA_RAWSELECTION$N != "NA", GWASDATA_RAWSELECTION$N, "NA")
  GWASDATA_PARSED$N_cases <- ifelse(("N_cases" %in% colnames(GWASDATA_RAWSELECTION)) == TRUE, 
                                    GWASDATA_RAWSELECTION$N_cases, "NA") # in case of quantitative trait analyses
  GWASDATA_PARSED$N_controls <- ifelse(("N_controls" %in% colnames(GWASDATA_RAWSELECTION)) == TRUE, 
                                       GWASDATA_RAWSELECTION$N_controls, "NA") # in case of quantitative trait analyses
  
  GWASDATA_PARSED$Imputed <- ifelse(("Imputed" %in% colnames(GWASDATA_RAWSELECTION)) == TRUE, 
                                    GWASDATA_RAWSELECTION$Imputed, "0") # 1 = imputed, 0 = genotyped
  
  #--------------------------------------------------------------------------
  ### SAVE NEW DATA ###
  cat("\n\nSaving parsed data...\n")
  write.table(GWASDATA_PARSED, 
              paste0(ROOT_loc, "/", OUT_loc, "/", 
                     basename(opt$datagwas), 
                     ".pdat"),
              quote = FALSE , row.names = FALSE, col.names = TRUE, 
              sep = " ", na = "NA", dec = ".")
  
  #--------------------------------------------------------------------------
  ### CLOSING MESSAGE
  cat(paste("\nAll done parsing [",file_path_sans_ext(basename(opt$datagwas), compression = TRUE),"].\n"))
  cat(paste("\nToday's date is: ", Today, ".\n", sep = ''))
  
} else {
  cat("\n\n\n\n+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n")
  cat("\n*** ERROR *** You didn't specify all variables:\n
      - --p/projectdir    : Path to the project directory.
      - --d/datagwas      : Path to the GWAS data, relative to the project directory;
                            can be tab, comma, space or semicolon delimited, as well as gzipped.
      - --o/outputdir     : Path to output directory.",
      file=stderr()) # print error messages to stderr
}

cat("\n+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n")

# #--------------------------------------------------------------------------
# ### SAVE ENVIRONMENT | FOR DEBUGGING
# save.image(paste0(ROOT_loc, "/", OUT_loc, "/",
#                   Today,"_",
#                   basename(opt$datagwas),
#                   "_DEBUG_GWAS_Parser.RData"))


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

