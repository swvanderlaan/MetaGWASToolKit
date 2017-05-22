#!/usr/bin/perl
##########################################################################################
#
# Version               : 2.1.10"
#
# Last update			: 2017-05-22"
# Updated by			: Sander W. van der Laan | UMC Utrecht, s.w.vanderlaan-2@umcutrecht.nl);
#						  Jacco Schaap | UMC Utrecht, j.schaap-2@umcutrecht.nl);
#						  Jessica van Setten | UMC Utrecht, j.vansetten@umcutrecht.nl).
# Originally written by	: Paul I.W. de Bakker | UMC Utrecht, p.i.w.debakker-2@umcutrecht.nl; 
#						  Sara Pulit | UMC Utrecht, s.l.pulit@umcutrecht.nl);
#						  Jessica van Setten | UMC Utrecht, j.vansetten@umcutrecht.nl).
#
# Note					: Originally based on MANTEL.pl, but heavily edited to accomodate 
#						  the new era of 1000G and Haplotype Reference Consortium (HRC) 
#                         imputed GWAS.
#
# Website				: http://www.atheroexpress.nl/software
#        
# Thanks to Nikolaos Patsopoulos for help with the heterogeneity and random-effects code.
#
# This Perl script performs a meta-analysis across an arbitrary number of genome-wide studies, 
# where for each study association statistics are computed for a predefined set of variantss. The
# meta-analysis is based on Beta and SE statistics from a linear or logistic regression analysis
# for each study. The meta-analysis statistic is based on inverse-variance weighting
# as well as a sample-size weighting (correted for imputation qualtiy) under a fixed-effects model.   
# Tests for heterogeneity (Cochran's Q and I-squared) and random-effects statistics are optional.
#
##########################################################################################
#
# REQUIRED INPUT:
#
# 1) A plain-text file with association analysis results for all studies combined into a 
#    single file (one line per variant).
#
#    Expected file format (where the number indicates the column):
#
#	 VariantID CHR BP Beta SE P CodedAllele OtherAllele MAF  Info
#	 1         2   3  4    5  6 7            8           9    10
#
#    where:
#    - 'CHR' is the chromosome number, 
#    - 'BP' is the chromosomal basepair position of the variant, 
#	 - 'Beta' is the computed estimate parameter of the effect of the given variant,
#    - 'SE' is the standard error around that Beta estimate,
#    - 'CodedAllele' represents the effect allele that the Beta and SE are referring to, 
#    - 'OtherAllele' is the other allele,
#    - 'MAF' refers to the minor allele frequency relative to the effect allele (CodedAllele), 
#    - 'Info' is the ratio of the observed variance of the dosage to the expected (binomial) 
#    variance (i.e. the imputation quality, info-score).
#
#    Columns 2-10 are repeated (on the same line) for every additional GWAS that is part of the
#    meta-analysis.
#
#    The 'Info' is used to correct the weight of the contribution of each individual study 
#    depending on the imputation quality of the variant.  This is only necessary when 
#    imputation was used (set to 1 if all variants are genotyped experimentally). 
#    See [de Bakker PIW et al., Human Molecular Genetics, 2008] for more background 
#    information on this topic.
#
#	 Note #1: 	Here a VariantID can be a single-nucleotide polymorphism or another type of 
#           	variant such as a INDEL or other structural variant.
#	 Note #2: 	Here EAF is expected to be the minor allele frequency to maintain backward
#				compatibility with HapMap 2 data!
#
# 2) [--params]	A plain-text file that contains study-specific parameters 
#
#    Example file format:
#
#    cohort1		1.026	1118	1	EXAMPLE/OUT_051011/cohort1.129.all.txt
#    cohort2		1.051	5272	1	EXAMPLE/OUT_051011/cohort2.129.all.txt
#    cohort3		1.047	3608	1	EXAMPLE/OUT_051011/cohort3.129.all.txt
#
#    Column 1 : contains an alphanumeric name to identify the studies listed in the file specified
#               above
#    Column 2 : lists the genomic inflation factor (lambda) -- used for adjusting the SE on the fly
#               (set to 1 if the association results are already adjusted, or when lambda < 1)
#    Column 3 : lists the sample size of each study -- used for meta-analysis based on sample size-
#               weighted z-scores
#    Column 4 : lists the correction factor to standardize the BETA and SE estimates across all
#               studies to ensure the scale and units of the BETA and SE are identical (the BETA
#               and SE are divided by the given factor)
#				Note: alternatively, the analysis plan could provide the requirement to normalize
#				the phenotype prior to running the GWAS
#
#    Note that the order of the studies in this file is important -- it reflects the order of the
#    association results as they appear in the data file specified above.
#
# 3) [--variants]	Just a list of unique variants present across all cohorts.
#
# 4) [--dbsnp]	A Variant Annotation File which includes all the information known about the variants; 
#    can be based on HapMap or 1000G, or any other reference.
#
#    Expected file format:
#
#    Chr ChrStart ChrEnd VariantID Strand Alleles VariantClass VariantFunction
#    chr1 62914560 62914560 rs538775156 + -/T insertion intron
#    chr1 40370176 40370176 rs564192510 + -/T insertion unknown
#    chr1 61341695 61341699 rs146746778 + -/TTTA deletion unknown
#    chr1 71827455 71827460 rs774608072 + -/TCTTA deletion unknown
#    chr1 88342516 88342533 rs777906343 + -/ACATTTAGGTTATTTCC deletion unknown
#
# 5) [--freq ]	A file which is used as the reference to resolve ambiguities in allele 
#    coding; can be based on HapMap or 1000G, or any other reference.
#
#    HapMap version			1000G version
#    ColumnName	ColumNo.	ColumnName	ColumNo.
#    VariantID	1			VariantID	1
#    CHR_REF	2			CHR_REF		2
#    BP_REF		3			BP_REF		3
#    REF		4			REF			4
#    ALT		5			ALT			5
#    AF			6			ALLELEA		6
#    MAF		7			ALLELEB		7
#    						MINOR		8
#    						MAJOR		9
#    						AF			10
#    						MAF			11
#    
# 6) [--genes]	Gene annotations
#
#    Expected file format:
#
#    Chr TxStart		TxEnd		Gene		EnsemblID			Strand
#    1 	66999065 	67213982 	SGIP1 		ENST00000237247.6,ENST00000371039.1,ENST00000371035.3,ENST00000468286.1,ENST00000371036.3,ENST00000371037.4 	+
#    1 	8377885 	8404227 	SLC45A1 	ENST00000471889.1,ENST00000377479.2,ENST00000289877.8 	+
#    1 	16767166	16786573 	NECAP2 		ENST00000337132.5 	+
#
# 7) [--ref]	Reference to be used. This can either be [HM2/1Gp1/1Gp3/GoNL4/GoNL5/1Gp3GONL5],
#				for HapMap 2 (release 22), 1000G phase 1 (version 3), 1000G phase 3 (version 5),
#				 GoNL 4, GoNL5, or 1000G phase 3 with GoNL5 combined, respectively.
#
# 8) [--pop]	Population on which the reference frequencies are based. This can either be:
#               HM2			-- EUR/AFR/JPT/CHB
#               1Gp1		-- PAN/AFR/AMERICA/ASIAN
#               1Gp3		-- PAN/EUR/AFR/AMERICA/EAS/SAS
#               GoNL4		-- PAN
#               GoNL5		-- PAN
#               1Gp3GONL5	-- PAN
#
# OPTIONAL INPUT:
# [--out]				Name of the output-file.
# [--dist]				Maximal distance to a gene (in kilobase units) -- this is used in the final output as for
#    					every variant genes within the specified distance are listed. A reasonable choice is 100-200
#    					kilobases, the default is 200.
# [--freq-flip]			The frequency filter based on which the alleles will be flipped.
#
# [--freq-warning]		The frequency based on which a warning will be given for A/T & C/G SNPs.
#
# [--ext]				Extension of the input file.
# [--extract]			List of variants to extract -- the meta-analysis will only be done on these.
# [--no-header]			Use this if the input file doesn't have headers.
# [--random-effects]	To invoke the random-effects calculations and thus heterogeneity tests.
# [--verbose]			To get an verbose output, which adds the per-study BETA, SE, P, alleles, 
#						allele frequency, allele-flips, sign-flips, RATIO, effective sample size, 
#						for the given variant.
#
##########################################################################################

##########################################################################################
##########################################################################################
###
### SETTING THE SCENE
###
##########################################################################################
##########################################################################################

print STDOUT "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
print STDOUT "+             MetaGWASToolKit: Meta-Analysis of Genome-Wide Association Studies          +\n";
print STDOUT "+                                 version 2.0 | 11-05-2017                               +\n";
print STDOUT "+                              (formely known as [ MANTEL ])                             +\n";
print STDOUT "+                                                                                        +\n";
print STDOUT "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
print STDOUT "\n";
my $time = localtime; # scalar, i.e. non-numeric, context
print STDOUT "The current date and time is: $time.\n";
print STDOUT "\n";

use lib '.';
use strict;
use FileHandle;
use Getopt::Long;
use Statistics::Distributions;

### Option list
my $paramsFile; # obligatory
my $variantFile; # obligatory
my $extractFile; # obligatory
my $dbsnpFile; # obligatory
my $freqFile; # obligatory
my $genesFile; # obligatory
my $extension = ''; # command-line option
my $gene_dist = '200'; # command-line option
my $reference; # obligatory
my $population; # obligatory
my $freq_flip = '0.30'; # command-line option
my $freq_warning = '0.45'; # command-line option
my $low_freq_warning = $freq_warning;
my $hifreq_warning = 1-$freq_warning;
my $no_header = ''; # command-line option
my $random_effects = ''; # command-line option
my $verbose = ''; # command-line option
my $outFile = "metagwas.out";

GetOptions(
	   "params=s"       => \$paramsFile,
	   "variants=s"     => \$variantFile,
	   "extract=s"      => \$extractFile,
	   "dbsnp=s"        => \$dbsnpFile,
	   "freq=s"         => \$freqFile,
	   "genes=s"        => \$genesFile,
	   "dist=i"         => \$gene_dist,
	   "ref=s"          => \$reference,
	   "pop=s"          => \$population,
	   "freq-flip=f"     => \$freq_flip,
	   "freq-warning=f"  => \$freq_warning,
	   "out=s"          => \$outFile,
	   "ext=s"          => \$extension,
	   "no-header"      => \$no_header,
	   "random-effects" => \$random_effects,
	   "verbose"        => \$verbose
           );

if ( ! $paramsFile || ! $variantFile || ! $dbsnpFile || ! $freqFile || ! $genesFile  || ! $reference  || ! $population ) {
	print STDERR "*** ERROR *** You didn't supply the required arguments.\n";
	print STDERR "\n";
	print STDERR "Usage: metagwas.pl --params params_file --variants variants_file --dbsnp dbsnp_file --freq freq_file --genes genes_file --ref reference --pop population\n";
	print STDERR "\n";
	print STDERR "OPTIONAL: \n";
	print STDERR "--dist           Maximal distance to a gene (in kilobase units); default is 200kb.\n";
	print STDERR "--freq-flip      The frequency filter based on which the alleles will be flipped; default is 0.30.\n";
	print STDERR "--freq-warning   The frequency based on which a warning will be given for A/T & C/G SNPs; default is 0.45.\n";
	print STDERR "--ext            Extension of the input file.\n";
	print STDERR "--extract        List of variants to extract -- the meta-analysis will only be done on these.\n";
	print STDERR "--no-header      Use this if the input file doesn't have headers.\n";
	print STDERR "--random-effects To invoke the random-effects calculations and thus heterogeneity tests.\n";
	print STDERR "--verbose        To get an verbose output; additional columns will be added. \n\n";
    exit();
}
print STDOUT "\n";
print STDOUT "Running with the following parameters:\n";
print STDOUT "  --params         : $paramsFile\n"; # contains cohortname, lambda, sample size and correction factor (for the beta)
print STDOUT "  --variants       : $variantFile\n"; # contains a list of all the variants across the cohorts
print STDOUT "  --dbsnp          : $dbsnpFile\n"; # contains per-variant annotations
print STDOUT "  --freq           : $freqFile\n"; # contains per-variant frequencies based on a reference
print STDOUT "  --genes          : $genesFile\n"; # a gene-list
print STDOUT "  --dist           : $gene_dist\n"; # distance to consider genes linked to variants (default = 2000kb)
print STDOUT "  --ref            : $reference\n"; # reference to be used
print STDOUT "  --pop            : $population\n"; # population within the reference
print STDOUT "  --freq-flip       : $freq_flip\n"; # frequency at which alleles are flipped
print STDOUT "  --freq-warning    : $freq_warning\n"; # frequency at which a warning is given
print STDOUT "  --out            : $outFile\n"; # name of the output file

if ( $extension ne "" ) {
print STDOUT "  --ext            : $extension\n";
}

if ( $extractFile ne "" ) {
print STDOUT "  --extract        : $extractFile\n";
}

if ( $no_header ) {
print STDOUT "  --no-header      : input files without headers.\n";
}

if ( $random_effects ) {
print STDOUT "  --random-effects : also perform analysis using random-effects model.\n";
}

if ( $verbose ) {
print STDOUT "  --verbose        : add per-cohort summary statistics to meta-analysis output.\n";
}

print STDOUT "\n";
print STDOUT "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";

##########################################################################################
##########################################################################################
###
### read in Variant list
###
##########################################################################################
##########################################################################################
print STDOUT "\n";
print STDOUT "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
print STDOUT "Reading in variant list.\n";
print STDOUT "\n";

my @variant_name = ();
my %variantlist = ();
my $n_total_variants = 0;
my $header = 0;

my $variantFilename = $variantFile;
if ( $extension ne "" ) { $variantFilename .= ".$extension"; }
open (VARIANT, $variantFilename) or die "*** ERROR *** Cannot open [ $variantFilename ]. Please double back.\n";
print STDOUT "* Reading variant list from: [ $variantFilename ]...\n";
while(my $c = <VARIANT>){
  chomp $c;
  $c =~ s/^\s+//;
  my @fields = split /\s+/, $c;
 
  if ( $header == 0 && ! $no_header ) { $header = 1; next; }

  $variant_name[$n_total_variants] = $fields[0];
  $variantlist{$fields[0]} = 1;

  $n_total_variants++;
}
close(VARIANT);

print STDOUT "Number of variants ready for meta-analysis: $n_total_variants.\n";

##########################################################################################
##########################################################################################
###
### read in VARIANT extract list ( if given )
###
##########################################################################################
##########################################################################################
my %extract = ();
my $n_extract_variants = 0;

if ( $extractFile ) {
print STDOUT "\n";
print STDOUT "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
print STDOUT "Reading in variant extraction list.\n";
print STDOUT "\n";

  open (VARIANT, $extractFile) or die "*** ERROR *** Cannot open [ $extractFile ]. Please double back.\n";
  print STDOUT "* Reading variant extract list from: [ $extractFile ]...\n";
  while(my $c = <VARIANT>){
    chomp $c;
    $c =~ s/^\s+//;
    my @fields = split /\s+/, $c;

    $extract{$fields[0]} = 1;
    $n_extract_variants++;
  }
  close(VARIANT);
  print STDOUT "Extracting variants from: [ $n_extract_variants ].\n";
}

##########################################################################################
##########################################################################################
###
### read in study parameters
###
##########################################################################################
##########################################################################################
print STDOUT "\n";
print STDOUT "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
print STDOUT "Reading in study parameters.\n";
print STDOUT "\n";

my @study_name = ();
my @filename = ();
my @lambda = ();
my @sample_size = ();
my @correction_factor = ();
my @allele_flips = ();
my @sign_flips = ();
my @n_informative_variants = ();
my @fh = ();

my $nstudies = 0;
my $total_sample_size = 0;

open (PARAMS, $paramsFile) or die "*** ERROR *** Cannot open [ $paramsFile ]. Please double back.\n";

print STDOUT "* Reading parameter file: [ $paramsFile ]...\n";
print STDOUT "\n";
print STDOUT "          Study name     Lambda     Sample size     Correction factor     Number of variants     File name\n";
print STDOUT "          ----------     ------     -----------     -----------------     ------------------     ---------\n";
 
while(my $c = <PARAMS>){
  chomp $c;
  $c =~ s/^\s+//;
  my @fields = split /\s+/, $c;

  if ( $#fields != 4 ) { die "*** ERROR *** Number of columns in the $paramsFile must be 4! Please double back.\n"; }

  $study_name[$nstudies] = $fields[0];
  $lambda[$nstudies] = $fields[1];
  if ( $fields[1] < 1 ) { 
    die "*** ERROR *** Lambda $fields[0] cannot be less than 1. Please double back.\n";
  }
  $sample_size[$nstudies] = $fields[2];
  $total_sample_size += $fields[2];
  $correction_factor[$nstudies] = $fields[3];
  $filename[$nstudies] = $fields[4];
  if ( $extension ne "" ) {
    $filename[$nstudies] .= ".$extension";
  }

  $fh[$nstudies] = new FileHandle;
  $fh[$nstudies]->open($filename[$nstudies]) || die "*** ERROR *** [ $filename[$nstudies] ] did not open. Please double back.\n";
  my $FILE = $fh[$nstudies];

  my $counter = 0;
  my $header = 0;
  
  while(<$FILE>) {
    my $line = $_;
    chomp($line); 
    $line =~ s/^\s+//;
    my @cols = split /\s+/, $line;
   
    if ( $header == 0 && ! $no_header ) { $header = 1; next; }
#    if ( $#cols != 9 ) { die "number of columns in $filename[$nstudies] must be 10\n"; }
    if ( $cols[0] ne $variant_name[$counter] ) { die "*** ERROR *** [ $filename[$nstudies] ] not in order with [ $variantFile ]. Please double back.\n"; }

    $counter++;
  }
  close($FILE);

  ### reopen it and skip first line (if --no_header is not specified)
  $fh[$nstudies]->open($filename[$nstudies]) || die "*** ERROR *** [ $filename[$nstudies] ] did not open. Please double back.\n";
  if ( ! $no_header ) { 
    my $FILE = $fh[$nstudies];
    my $ignore = <$FILE>; 
  }

  printf STDOUT "%20s %10.5f %15d %21.5f     %18d     %s [verified]\n", $study_name[$nstudies], $lambda[$nstudies], $sample_size[$nstudies], $correction_factor[$nstudies], $counter, $filename[$nstudies];

  $allele_flips[$nstudies] = 0;
  $sign_flips[$nstudies] = 0;
  $n_informative_variants[$nstudies] = 0;

  $nstudies++;
}
close(PARAMS);

print STDOUT "                                    ===========\n";
printf STDOUT "                                    %11d\n", $total_sample_size;
print STDOUT "\n";
print STDOUT "Total number of studies: $nstudies.\n";


##########################################################################################
##########################################################################################
###
### read in a Variant Annotation File to get inventory of markers, positions and annotation
###
##########################################################################################
##########################################################################################
#
# This Variant Annotation File contains a list of variants with associated annotation data; 
# it could be manually generated using a reference, for instance 1000G phase 1 or phase 3.
# Among others it is used to:
# - check the existence of a variant in the respective GWAS in the reference
# - obtain functional information on the variant and add this to an annotated meta-analysis
#   output
#
# NOTE: dbSNP only contains variants which have been assigned a rs-identifier; in many
#       references (GoNL4, GoNL5, 1000G phase 1, 1000G phase 3) variants exist that were 
#       submitted to dbSNP but have had no rs-identifier assigned yet. This implies that 
#       relying solely on the dbSNP database may not be appropriate for your specific 
#       meta-analysis of GWAS.
# 
# Expected format of such a Variant Annotation File is the following:
#
#	Chr ChrStart ChrEnd VariantID Strand Alleles VariantClass VariantFunction
#	chr1 62914560 62914560 rs538775156 + -/T insertion intron
#	chr1 40370176 40370176 rs564192510 + -/T insertion unknown
#	chr1 61341695 61341699 rs146746778 + -/TTTA deletion unknown
#	chr1 71827455 71827460 rs774608072 + -/TCTTA deletion unknown
#	chr1 88342516 88342533 rs777906343 + -/ACATTTAGGTTATTTCC deletion unknown
#
print STDOUT "\n";
print STDOUT "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
print STDOUT "Reading in Variant Annotation File.\n"; 
print STDOUT "\n";

open (DBSNP, "gunzip -c $dbsnpFile |") or die "*** ERROR *** Cannot open [ $dbsnpFile ]. Please double back.\n";
print STDOUT "* Reading: [ $dbsnpFile ]...\n";

my $n_dbsnp_annotations = 0;
my %skip_list = ();
my %dbsnp_chr = ();
my %dbsnp_pos = ();
# my %dbsnp_alleles = ();
my %dbsnp_a1 = ();
my %dbsnp_a2 = ();
my %dbsnp_function = ();
my %caveat = ();

while(my $c = <DBSNP>){
  chomp $c;
  $c =~ s/^\s+//;
  my @fields = split /\s+/, $c;
  my $variant = $fields[3];

  ### skipping SNPs that map to alternate chromosomes (e.g. chr6_qbl) 
  if ( $fields[0] =~ m/_/ ) { next; }
  
  if ( defined( $variantlist{$variant} ) && ( ( ! $extractFile ) || defined( $extract{$variant} ) ) ) {

	### should probably be removed, as SNPs and INDELs can exist on the same basepair position(s)
     if ( defined( $dbsnp_a1{$variant} ) ) {
      	print STDERR "$variant appears more than once -- skipping it\n";
     	$caveat{$variant} = "not_unique_position";
#  		$skip_list{$variant} = 1;
  		next;
     }
    
    my @alleles = split /\//, $fields[5];
   
    ### Checking how many 'elements' exist in @alleles: if '2' elements, '1' is returned
    if ( $#alleles > 1 ) { 
      print STDERR "* $variant has more than 2 alleles [" . $fields[5] . "] -- skipping it.\n";
      $skip_list{$variant} = 1;
      next;
    } 

   if ( $fields[5] =~ m/lengthTooLong/ ) {
      print STDERR "* $variant has alleles with [ lengthTooLong ] -- skipping it.\n";
      $skip_list{$variant} = 1;
      next;
    }
    
    if ( $#alleles == 0 ) { 
      print STDERR "* $variant has only 1 allele [" . $fields[5] . "] -- skipping it.\n";
      $skip_list{$variant} = 1;
      next;
    } 

    $fields[0] =~ s/chr//;
    $dbsnp_chr{$variant} = $fields[0];
    $dbsnp_pos{$variant} = $fields[1] + 1;
    $dbsnp_function{$variant} = $fields[7];
#     $dbsnp_alleles{$variant} = [ @alleles ];
    $dbsnp_a1{$variant} = $alleles[0]; # reference allele
    $dbsnp_a2{$variant} = $alleles[1]; # alternative allele, equals to AlleleB in 1000G and thus the coded/effect allele of 1000G imputed data
    
	my $strand = $fields[4]; 
#     if ( $strand eq "+" ) { 
#       	print STDERR " ***DEBUG***  From dbSNP read $variant, with [ $dbsnp_alleles{$variant}[0] / $dbsnp_alleles{$variant}[1] ] alleles, has strand [ $strand ] and function [ $dbsnp_function{$variant} ].\n";
# 		next; 
# 	}
    if ( $strand eq "-" ) { 
#    		print STDERR " ***DEBUG***  From dbSNP read $variant, with [ $dbsnp_alleles{$variant}[0] / $dbsnp_alleles{$variant}[1] ] alleles, has strand [ $strand ]. Correcting.\n";		
		$dbsnp_a1{$variant} = allele_flip( $dbsnp_a1{$variant} );
		$dbsnp_a2{$variant} = allele_flip( $dbsnp_a2{$variant} );
    }
  }
  $n_dbsnp_annotations++;
}
close (DBSNP);

print STDOUT "Number of annotated variants: $n_dbsnp_annotations.\n";

##########################################################################################
##########################################################################################
###
### check all variants on the list if they are in Variant Annotation File 
###
##########################################################################################
##########################################################################################
print STDOUT "\n";
print STDOUT "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
print STDOUT "Checking existence in the Variant Annotation File of variants listed in this meta-analysis.\n";
print STDOUT "\n";

for (my $nvariant; $nvariant < $n_total_variants; $nvariant++) {
  my $variant = $variant_name[$nvariant];
  if ( ! defined( $skip_list{$variant} ) && ( ( ! $extractFile ) || defined( $extract{$variant} ) ) && ! defined( $dbsnp_chr{$variant} ) ) {
    print STDERR "* $variant in [ $variantFile ] is not present in the Variant Annotation File  -- skipping it.\n";
    $skip_list{$variant} = 1;
  }
}

##########################################################################################
##########################################################################################
###
### read in the reference and alternative alleles from the Reference Frequency File 
### (nothing is done currently with those - but may need them later for A/T and C/G SNPs)
###
##########################################################################################
##########################################################################################
#
# Expected format of such a RefFreq HAPMAP file is the following:
#
# 	0		  	1	    2       3           4           5   6
#	VariantID	CHR_REF	BP_REF	MinorAllele	MajorAllele	AF	MAF
#	rs58108140	1	10583	A	G	0.14	0.14
#	rs189107123	1	10611	G	C	0.02	0.02
#	rs180734498	1	13302	T	C	0.11	0.11
#	rs144762171	1	13327	C	G	0.03	0.03
#	rs201747181	1	13957	T	TC	0.02	0.02
#	rs151276478	1	13980	C	T	0.02	0.02
#	rs140337953	1	30923	G	T	0.73	0.27
#	rs199681827	1	46402	CTGT	C	0.0037	0.0037
#	rs200430748	1	47190	GA	G	0.01	0.01
#
# Expected format of such a RefFreq file is the following:
#
# 	0		  	1	    2       3   4   5       6       7           8           9     10
#	VariantID	CHR_REF	BP_REF	REF	ALT	AlleleA	AlleleB	MinorAllele	MajorAllele	AF	MAF
#	rs58108140	1	10583	G	A	G	A	A	G	0.14	0.14
#	rs189107123	1	10611	C	G	C	G	G	C	0.02	0.02
#	rs180734498	1	13302	C	T	C	T	T	C	0.11	0.11
#	rs144762171	1	13327	G	C	G	C	C	G	0.03	0.03
#	rs201747181	1	13957	TC	T	I	D	T	TC	0.02	0.02
#	rs151276478	1	13980	T	C	T	C	C	T	0.02	0.02
#	rs140337953	1	30923	G	T	G	T	G	T	0.73	0.27
#	rs199681827	1	46402	C	CTGT	D	I	CTGT	C	0.0037	0.0037
#	rs200430748	1	47190	G	GA	D	I	GA	G	0.01	0.01
#
print STDOUT "\n";
print STDOUT "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
print STDOUT "Reading in alleles from Reference Frequency File.\n";
print STDOUT "\n";

open (REFFREQ, "gunzip -c $freqFile |") or die "*** ERROR *** Cannot open [ $freqFile ]. Please double back.\n";
print STDOUT "* Reading Reference Frequency File: [ $freqFile ]...\n";

my %reference_a1_freq = ();
  
while(my $c = <REFFREQ>){
  chomp $c;
  $c =~ s/^\s+//;
  
  my @fields = split /\s+/, $c; 
  my $variant = $fields[0]; 
  if ( $variant eq "VariantID" ) { next; }

  my $a1 = "";
  my $a2 = "";
  
  if ( ( ! defined( $skip_list{$variant} ) ) && defined( $variantlist{$variant} ) && ( ( ! $extractFile ) || defined( $extract{$variant} ) ) ) {
   
    # HapMap 2 based
    if ( $reference eq "HM2") {
		my $a1 = $fields[3];  # minor allele (can be 0 if monomorphic)
		my $a2 = $fields[4];  # major allele
		$reference_a1_freq{$variant} = $fields[6];
 	
      	### Checking allele compared to reference
		if ( $a1 eq $dbsnp_a1{$variant} && $a2 eq $dbsnp_a2{$variant} ) {
			my $tmp1 = $dbsnp_a1{$variant};
			my $tmp2 = $dbsnp_a2{$variant};
			$dbsnp_a1{$variant} = $tmp1;
			$dbsnp_a2{$variant} = $tmp2;
		}
		elsif ( $a2 eq $dbsnp_a1{$variant} && $a1 eq $dbsnp_a2{$variant} ) {
			my $tmp = $dbsnp_a1{$variant};
			$dbsnp_a1{$variant} = $dbsnp_a2{$variant};
			$dbsnp_a2{$variant} = $tmp;
		}
		elsif ( allele_flip( $a2 ) eq $dbsnp_a1{$variant} && allele_flip( $a1 ) eq $dbsnp_a2{$variant} ) {
			my $tmp = $dbsnp_a1{$variant};
			$dbsnp_a1{$variant} = $dbsnp_a2{$variant};
			$dbsnp_a2{$variant} = $tmp;
		}
		elsif ( $a1 eq "0" && $a2 eq $dbsnp_a1{$variant} ) { 
			my $tmp = $dbsnp_a1{$variant};
			$dbsnp_a1{$variant} = $dbsnp_a2{$variant};
			$dbsnp_a2{$variant} = $tmp;
		}
		elsif ( $a1 eq "0" && $a2 eq $dbsnp_a2{$variant} ) {
			$dbsnp_a1{$variant} = $dbsnp_a1{$variant};
			$dbsnp_a2{$variant} = $dbsnp_a2{$variant};
		}
		elsif ( $a1 eq "0" && allele_flip( $a2 ) eq $dbsnp_a1{$variant} ) { 
			my $tmp = $dbsnp_a1{$variant};
			$dbsnp_a1{$variant} = $dbsnp_a2{$variant};
			$dbsnp_a2{$variant} = $tmp;
		}
# 	print STDOUT " *** DEBUG *** The $variant has allele frequency = $reference_a1_freq{$variant} and allele A1 = $a1; allele A2 = $a2.\n";
	}
    # 1000G based
    elsif ( $reference eq "1Gp1" || $reference eq "1Gp3" || $reference eq "GoNL4" || $reference eq "GoNL5" || $reference eq "1Gp3GONL5" ) {
		my $a1 = $fields[7];  # minor allele; could be alternative or reference allele
		my $a2 = $fields[8];  # major allele
		$reference_a1_freq{$variant} = $fields[10];

		### Checking allele compared to reference	
		if ( $a1 eq $dbsnp_a1{$variant} && $a2 eq $dbsnp_a2{$variant} ) {
		  my $tmp1 = $dbsnp_a1{$variant};
		  my $tmp2 = $dbsnp_a2{$variant};
		  $dbsnp_a1{$variant} = $tmp1;
		  $dbsnp_a2{$variant} = $tmp2;
		}
		elsif ( $a2 eq $dbsnp_a1{$variant} && $a1 eq $dbsnp_a2{$variant} ) {
		  my $tmp = $dbsnp_a1{$variant};
		  $dbsnp_a1{$variant} = $dbsnp_a2{$variant};
		  $dbsnp_a2{$variant} = $tmp;
		}
		# We have edited the allele_flip() function such that it will also handle INDELs of the form [ATCG]_[ATCG]
		elsif ( allele_flip( $a2 ) eq $dbsnp_a1{$variant} && allele_flip( $a1 ) eq $dbsnp_a2{$variant} ) {
		  my $tmp = $dbsnp_a1{$variant};
		  $dbsnp_a1{$variant} = $dbsnp_a2{$variant};
		  $dbsnp_a2{$variant} = $tmp;
		}
		elsif ( $a1 eq "0" && $a2 eq $dbsnp_a1{$variant} ) { 
		  my $tmp = $dbsnp_a1{$variant};
		  $dbsnp_a1{$variant} = $dbsnp_a2{$variant};
		  $dbsnp_a2{$variant} = $tmp;
		}
		elsif ( $a1 eq "0" && $a2 eq $dbsnp_a2{$variant} ) {
		  $dbsnp_a1{$variant} = $dbsnp_a1{$variant};
		  $dbsnp_a2{$variant} = $dbsnp_a2{$variant};
		}
		# We have edited the allele_flip() function such that it will also handle INDELs of the form [ATCG]_[ATCG]
		elsif ( $a1 eq "0" && allele_flip( $a2 ) eq $dbsnp_a1{$variant} ) { 
		  my $tmp = $dbsnp_a1{$variant};
		  $dbsnp_a1{$variant} = $dbsnp_a2{$variant};
		  $dbsnp_a2{$variant} = $tmp;
		}
#  	print STDOUT " *** DEBUG *** The $variant has allele frequency = $reference_a1_freq{$variant} and allele A/A1/ALT = $a1; allele B/A2/REF = $a2.\n";
	}
    else {
      print STDERR "* For the $variant, we cannot determine the Reference Frequency for alleles [ $a1/$a2 ] and annotated alleles [ $dbsnp_a1{$variant}/$dbsnp_a2{$variant} ] -- skipping it. Reference: [ $reference ]; population: [ $population ].\n";
      $skip_list{$variant} = 1;
    }
  }
}
close (REFFREQ);

##########################################################################################
##########################################################################################
###
### read in the genes from GENCODE
### 
##########################################################################################
##########################################################################################
#
# MetaGWASToolKit uses GENCODE -- obviously other flavours are possible.
#
# Expected format of such a genes file is the following:
#
# Column 	Chr TxStart		TxEnd		Gene		EnsemblID			Strand
# Column# 	0	1	        2         	3			4					5
#			1 	66999065 	67213982 	SGIP1 		ENST00000237247.6,ENST00000371039.1,ENST00000371035.3,ENST00000468286.1,ENST00000371036.3,ENST00000371037.4 	+
#			1 	8377885 	8404227 	SLC45A1 	ENST00000471889.1,ENST00000377479.2,ENST00000289877.8 	+
#			1 	16767166	16786573 	NECAP2 		ENST00000337132.5 	+
#
print STDOUT "\n";
print STDOUT "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
print STDOUT "Reading in genes.\n";
print STDOUT "\n";

open (GENE, "gunzip -c $genesFile |") or die "*** ERROR *** Cannot open $genesFile. Please double back.\n";
print STDOUT "* Reading file: $genesFile...\n";

my $ngenes = 0;
my @gene = (); # gene name, official HUGO
my @gene_chr = (); # chromosome
my @gene_start = (); # transcription start position
my @gene_stop = (); # transcription end position
my @gene_ensembl = (); # Ensembl ID
my @gene_strand = (); # gene strand position

while(my $c = <GENE>){
  chomp $c;
  my @fields = split /\s+/, $c;

  $gene_chr[$ngenes] = $fields[0];
  $gene_start[$ngenes] = $fields[1];
  $gene_stop[$ngenes] = $fields[2];
  $gene[$ngenes] = $fields[3];
  $gene_ensembl[$ngenes] = $fields[4];
  $gene_strand[$ngenes] = $fields[5];
  $ngenes++;
}
close (GENE);

print STDOUT "Number of annotated genes: $ngenes\n";
print STDOUT "Maximal distance to genes: $gene_dist KB\n";

##########################################################################################
##########################################################################################
###
### prepare output file -- write out the header line
###
##########################################################################################
##########################################################################################
print STDOUT "\n";
print STDOUT "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
print STDOUT "Starting the meta-analysis.\n";
print STDOUT "\n";
print STDOUT "Preparing the output file...\n";

open (OUT, ">$outFile") or die "*** ERROR *** Cannot open [ $outFile ]. Please double back and check permissions.\n";
if ( $reference eq "HM2") {
    print OUT "VARIANTID CHR POS MINOR MAJOR MAF"; # these are based on the reference!
}
elsif ( $reference eq "GoNL4" || $reference eq "GoNL5" || $reference eq "1Gp3GONL5" || $reference eq "1Gp1" || $reference eq "1Gp3" ) {
    print OUT "VARIANTID CHR POS MINOR MAJOR MAF"; # these are based on the reference/population!
}
else {
    die "*** ERROR *** You did not specify the reference (--ref); now we cannot properly print the header. Please double back.\n";
}

if ( $verbose ) {
  for (my $i=0; $i < $nstudies; $i++) {
    print OUT " CODEDALLELE_$study_name[$i] OTHERALLELE_$study_name[$i] ALLELES_FLIPPED_$study_name[$i] SIGN_FLIPPED_$study_name[$i] CAF_$study_name[$i] BETA_$study_name[$i] SE_$study_name[$i] P_$study_name[$i] Info_$study_name[$i] NEFF_$study_name[$i]";
  }
}

print OUT " CODEDALLELE OTHERALLELE CAF N_EFF Z_SQRTN P_SQRTN BETA_FIXED SE_FIXED Z_FIXED P_FIXED BETA_LOWER_FIXED BETA_UPPER_FIXED ";
if ( $random_effects ) {
  print OUT "BETA_RANDOM SE_RANDOM Z_RANDOM P_RANDOM BETA_LOWER_RANDOM BETA_UPPER_RANDOM COCHRANS_Q DF P_COCHRANS_Q I_SQUARED TAU_SQUARED ";
}
print OUT "DIRECTIONS GENES_" . $gene_dist . "KB NEAREST_GENE NEAREST_GENE_ENSEMBLID NEAREST_GENE_STRAND VARIANT_FUNCTION CAVEAT\n";


##########################################################################################
##########################################################################################
###
### now loop over all variants from the list - and do some work
###
##########################################################################################
##########################################################################################
#
# Expected input file format
#
# Column#	0		  1	  2  3    4  5 6            7           8   9
#			VariantID CHR BP Beta SE P CodedAllele OtherAllele MAF Info
#			rs61769339 1 662622 0.064738 0.151472 0.669216 A G 0.0813265 0.314296
#			rs61769350 1 693731 0.0809252 0.125964 0.520777 G A 0.0959278 0.395173
#			rs189800799 1 701835 -0.29061 0.256943 0.258402 C T 0.0204806 0.419007
#			rs28457007 1 712930 -0.2485 0.267268 0.352784 C T 0.0195845 0.404344
#			chr1:713131:AT_A 1 713131 -0.22227 0.228877 0.331793 AT A 0.0220612 0.485933
#			rs114983708 1 714019 -0.0590389 0.179203 0.741906 G A 0.0527746 0.335025

print STDOUT "Meta-analyzing this shizzle...\n";
my $nvariants_in_meta = 0;
my $not_on_reference = 0;
my $skip = 0;
my $n_skipped_uninformative = 0;
my %reference_present = ();

for (my $nvariant; $nvariant < $n_total_variants; $nvariant++) {

  my $variant = $variant_name[$nvariant];
 
  ### skip this variant if it is not on the extract hash 
  if ( $skip_list{$variant} || ( $extractFile && ! defined( $extract{$variant} ) ) ) { $skip++; next; }
  
  my $refchr = defined($dbsnp_chr{$variant}) ? $dbsnp_chr{$variant} : "NA";
  my $refpos = defined($dbsnp_pos{$variant}) ? $dbsnp_pos{$variant} : "NA";
#  my $ref1 = "0";
#  my $ref2 = "0";
  my $ref1 = $dbsnp_a1{$variant};
  my $ref2 = $dbsnp_a2{$variant};
  my $coded_allele = $ref1;
  my $other_allele = $ref2;
  my @study_okay = ();
  my @flip_alleles = ();
  my @flip_indels = (); # for INDELs of the form R/D/I
  my @sample_size_eff = ();
  my $n_okay_studies = 0;
  my $total_weight = 0;
  my $total_weight_squared = 0;
  my $total_weighted_beta = 0;
  my $total_weighted_beta_squared = 0;
  my $n_eff = 0;
  my $z_sqrtn = 0;
  my $af_weighted = 0;

  my @chr = ();
  my @pos = ();
  my @beta = ();
  my @se = ();
  my @pval = ();
  my @a1 = (); # coded/effect allele, i.e. minor allele
  my @a2 = ();
  my @af1 = (); # coded/effect allele frequency; i.e. minor allele frequency
  my @ratio = (); # i.e. imputation quality
 
  ###
  ### first read in the data
  ###
  for ( my $study = 0; $study < $nstudies; $study++ ) {
    my $FILE = $fh[$study]; 
    for ( my $a = 0; $a < $skip; $a++ ) { my $void = <$FILE>; }
    my $c = <$FILE>;
    chomp $c;
    my @fields = split /\s+/, $c;

    if ( $fields[0] ne $variant ) { die "*** ERROR *** [ $filename[$study] ] is not in order with [ $variantFile ] -- was expecting [ $variant ] but got [ $fields[0] ]. \n"; }

    if ( $fields[1] eq "X" ) { $chr[$study] = 23; }
    elsif ( $fields[1] eq "Y" ) { $chr[$study] = 24; }
    elsif ( $fields[1] eq "XY" ) { $chr[$study] = 25; }
    elsif ( $fields[1] eq "MT" ) { $chr[$study] = 26; }
    else { $chr[$study] = $fields[1]; }

    $pos[$study] = $fields[2];
    $beta[$study] = $fields[3];
    $se[$study] = $fields[4];
    $pval[$study] = $fields[5];
    $a1[$study] = allele_1234_to_ACGT( $fields[6] ); # coded/effect allele which is compared to the minor allele from HapMap2 or ALT-allele from 1000G
    $a2[$study] = allele_1234_to_ACGT( $fields[7] ); # other/reference allele
    $af1[$study] = $fields[8];  

	# checking how many fields we have to determine the value of $ratio
#     print STDERR " ***DEBUG***  A column with a measure of imputation quality exists for [ $variant ] in [ $study_name[$study] ]; checking contents and setting to 1 if needed (genotyped and NA only).\n";
    if ( $#fields == 9 ) { 
    	if ( $fields[9] != "NA" ) {
#      		print STDERR " - Imputation quality = [ $fields[9] ].\n";
    		$ratio[$study] = $fields[9];
#      		print STDERR " ***DEBUG***  ratio = $ratio[$study].\n"
    		} else {
#      		print STDERR " - Imputation quality = [ $fields[9] ]. Setting to 1.\n";
    		$ratio[$study] = 1; 
#      		print STDERR " ***DEBUG***  ratio = $ratio[$study].\n"
    		}
    	} else { 
#      		print STDERR "* There is no measure of imputation quality for [ $variant ] in [ $study_name[$study] ]. Assuming the data is genotyped. Setting to 1.\n";
    		$ratio[$study] = 1; 
#      		print STDERR " ***DEBUG***  ratio = $ratio[$study].\n"
    }
    
  }

  ### reset skip 
  $skip = 0;
   
  ### check if this variant has a Reference frequency 
  if ( ! defined( $reference_a1_freq{$variant} ) ) {
    print STDERR " ***DEBUG***  This [ $variant ] does not have a reference frequency.\n";
    $not_on_reference++;
    $reference_present{$variant} = 0;
    $caveat{$variant} .= "not_in_reference";
  }
  else {
      $reference_present{$variant} = 1;
  }
  
  ###
  ### walk through studies to see who's present
  ###
  for ( my $study=0; $study < $nstudies; $study++ ) {  ### START OF FOR-LOOP
    ### first assume the study is okay
    $study_okay[$study] = 1;
    ### since we do not use the p-value it is not strictly essential to have p-value in the input file
    #if ( $beta[$study] eq "NA" || $se[$study] eq "NA" || $af1[$study] eq "NA" || $ratio[$study] eq "NA" || $pval[$study] eq "NA" || $a1[$study] eq "NA" || $a2[$study] eq "NA" || $se[$study] == 0 ) {
    if ( $beta[$study] eq "NA" || $se[$study] eq "NA" || $af1[$study] eq "NA" || $ratio[$study] eq "NA" || $a1[$study] eq "NA" || $a2[$study] eq "NA" || $se[$study] == 0 ) {
      $study_okay[$study] = 0;
    } else { ### START OF THIS ELSE
    	  ### START CHECK #1: allele a1 and allele a2 match the two reference alleles 
    	  	if ( ( $a1[$study] eq $ref1 && $a2[$study] eq $ref2 ) || ( $a1[$study] eq $ref2 && $a2[$study] eq $ref1 ) ) { 
    		    $flip_alleles[$study] = 0;
    		  ### frequency-based test for A/T or C/G SNPs
    		    if ( ( $a1[$study] eq "A" && $a2[$study] eq "T" ) || ( $a1[$study] eq "T" && $a2[$study] eq "A" ) || ( $a1[$study] eq "C" && $a2[$study] eq "G" ) || ( $a1[$study] eq "G" && $a2[$study] eq "C" ) ) {
				    if ( $reference_present{$variant} = 1 ) {
						if ( $a1[$study] eq $ref1 && ( $af1[$study] > ( $reference_a1_freq{$variant} - $freq_flip ) ) && ( $af1[$study] < ( $reference_a1_freq{$variant} + $freq_flip ) ) ) {
						}
						elsif ( $a2[$study] eq $ref1 && ( $af1[$study] > ( 1 - $reference_a1_freq{$variant} - $freq_flip ) ) && ( $af1[$study] < ( 1 - $reference_a1_freq{$variant} + $freq_flip ) ) ) {
						}
						elsif ( $a1[$study] eq allele_flip( $ref1 ) && ( $af1[$study] > ( $reference_a1_freq{$variant} - $freq_flip ) ) && ( $af1[$study] < ( $reference_a1_freq{$variant} + $freq_flip ) ) ) {
						    $flip_alleles[$study] = 1;
						}
						elsif ( $a2[$study] eq allele_flip( $ref1 ) && ( $af1[$study] > ( 1 - $reference_a1_freq{$variant} - $freq_flip ) ) && ( $af1[$study] < ( 1 - $reference_a1_freq{$variant} + $freq_flip ) ) ) {
						    $flip_alleles[$study] = 1;
						}
						else {
						    print STDERR "* In $study_name[$study], $variant has allele frequencies for A/T or C/G variants inconsistent with Reference frequencies -- skipping this variant for this study.\n";
						    $study_okay[$study] = 0;
						}
				    }
				}   
    		   ### frequency-based test for non-A/T and non-C/G SNPs 
    		    else {
				    if ( $reference_present{$variant} =1 ) {
						if ( $a1[$study] eq $ref1 && ( $af1[$study] > ( $reference_a1_freq{$variant} - $freq_flip ) ) && ( $af1[$study] < ( $reference_a1_freq{$variant} + $freq_flip ) ) ) {
						}
						elsif ( $a2[$study] eq $ref1 && ( $af1[$study] > ( 1 - $reference_a1_freq{$variant} - $freq_flip ) ) && ( $af1[$study] < ( 1 - $reference_a1_freq{$variant} + $freq_flip ) ) ) {
						}
						else {
						    print STDERR "* In $study_name[$study], $variant has matching alleles with Reference, but an allele frequency inconsistent with Reference frequencies -- skipping this variant for this study.\n";
						    $study_okay[$study] = 0;
						}
				    }
				}
    		### Warning for allele frequencies between $low_freq_warning and $hifreq_warning for A/T and C/G SNPs
    		  if ( ( ( $a1[$study] eq "A" && $a2[$study] eq "T" ) || ( $a1[$study] eq "T" && $a2[$study] eq "A" ) || ( $a1[$study] eq "C" && $a2[$study] eq "G" ) || ( $a1[$study] eq "G" && $a2[$study] eq "C" ) ) && ( ( $af1[$study] > $freq_warning && $af1[$study] < 1-$freq_warning ) || ( $reference_a1_freq{$variant} > $freq_warning && $reference_a1_freq{$variant} < 1-$freq_warning ) ) ) {
			  	$caveat{$variant} .= "ATCG_variant_with_$low_freq_warning<EAF<$hifreq_warning";
    		  }
    	  	} ### END CHECK #1
    	  	### START CHECK #2: allele a1 and allele a2 do NOT match the two reference alleles 
    		elsif ( ( $a1[$study] eq allele_flip( $ref1 ) && $a2[$study] eq allele_flip( $ref2 ) ) || ( $a1[$study] eq allele_flip( $ref2 ) && $a2[$study] eq allele_flip( $ref1 ) ) ) { 
    			    $flip_alleles[$study] = 1;
    			  
    		  ### frequency-based test for non-A/T and non-C/G SNPs
    		  if ( $reference_present{$variant} =1 ) {
				 	if ( $a1[$study] eq allele_flip( $ref1 ) && ( $af1[$study] > ( $reference_a1_freq{$variant} - $freq_flip ) ) && ( $af1[$study] < ( $reference_a1_freq{$variant} + $freq_flip ) ) ) {
				 	}
				 	elsif ( $a2[$study] eq allele_flip( $ref1 ) && ( $af1[$study] > ( 1 - $reference_a1_freq{$variant} - $freq_flip ) ) && ( $af1[$study] < ( 1 - $reference_a1_freq{$variant} + $freq_flip ) ) ) {
				 	}
				 	else {
					print STDERR "* In $study_name[$study], $variant has non-matching alleles with Reference, and an allele frequency inconsistent with Reference frequencies -- skipping this variant for this study.\n";
					$study_okay[$study] = 0;
				 	}
    		    }
    		} ### END CHECK #2
	    	### START CHECK #3: in case of studies that have D/I coding for INDELs
	    	elsif ( ( $a1[$study] eq "D" && $a2[$study] eq "I" && length($ref1) < length($ref2) ) || ( $a1[$study] eq "I" && $a2[$study] eq "D" && length($ref1) > length($ref2) ) ) {
#  	    		print STDERR "*** DEBUG *** In $study_name[$study], $variant has alleles [ $a1[$study]/$a2[$study] ] which is the same as the Reference alleles [ $ref1/$ref2 ].\n";
	    		$flip_alleles[$study] = 0;
	    	} ### END CHECK #3
	    	
	    	### START CHECK #4
	    	elsif ( ( $a1[$study] eq "D" && $a2[$study] eq "I" && length($ref1) > length($ref2) ) || ( $a1[$study] eq "I" && $a2[$study] eq "D" && length($ref1) < length($ref2) ) ) {
 	    		print STDERR "* In $study_name[$study], $variant has alleles [ $a1[$study]/$a2[$study] ], while the Reference has alleles [ $ref1/$ref2 ]. Flipping these.\n";
	    		$flip_indels[$study] = 1;
	    	} ### START CHECK #4
	    	
	    	
	    	### START CHECK #5: in case of studies that have R/D/I coding for INDELs
	    	elsif ( ( $a1[$study] eq "R" && $a2[$study] eq "D" && length($ref1) > length($ref2) ) || ( $a1[$study] eq "D" && $a2[$study] eq "R" && length($ref1) < length($ref2) ) ) {
#  	    		print STDERR "*** DEBUG *** In $study_name[$study], $variant has alleles [ $a1[$study]/$a2[$study] ] which is the same as the Reference alleles [ $ref1/$ref2 ].\n";
	    		$flip_alleles[$study] = 0;
	    	} ### END CHECK #5
	    	### START CHECK #6: in case of studies that have R/D/I coding for INDELs
	    	elsif ( ( $a1[$study] eq "R" && $a2[$study] eq "I" && length($ref1) < length($ref2) ) || ( $a1[$study] eq "I" && $a2[$study] eq "R" && length($ref1) > length($ref2) ) ) {
#  	    		print STDERR "*** DEBUG *** In $study_name[$study], $variant has alleles [ $a1[$study]/$a2[$study] ] which is the same as the Reference alleles [ $ref1/$ref2 ].\n";
	    		$flip_alleles[$study] = 0;
	    	} ### END CHECK #6
	    	### START CHECK #7
	    	elsif ( ( $a1[$study] eq "R" && $a2[$study] eq "D" && length($ref1) < length($ref2) ) || ( $a1[$study] eq "D" && $a2[$study] eq "R" && length($ref1) > length($ref2) ) ) {
	    		print STDERR "* In $study_name[$study], $variant has alleles [ $a1[$study]/$a2[$study] ], while the Reference has alleles [ $ref1/$ref2 ]. Flipping these.\n";
	    		$flip_indels[$study] = 1;
	    	} ### START CHECK #7
	    	### START CHECK #8
	    	elsif ( ( $a1[$study] eq "R" && $a2[$study] eq "I" && length($ref1) > length($ref2) ) || ( $a1[$study] eq "I" && $a2[$study] eq "R" && length($ref1) < length($ref2) ) ) {
	    		print STDERR "* In $study_name[$study], $variant has alleles [ $a1[$study]/$a2[$study] ], while the Reference has alleles [ $ref1/$ref2 ]. Flipping these.\n";
	    		$flip_indels[$study] = 1;
	    	} ### START CHECK #8
	    	
    	  	### the coded allele (a1) and the noncoded allele do not match the two reference alleles -- even after flipping
    	  	else {
    	    print STDERR "* In $study_name[$study], $variant has alleles $a1[$study] $a2[$study] inconsistent with Reference alleles $ref1 $ref2 -- skipping this variant for this study.\n"; 
    	    $study_okay[$study] = 0;
    	  	}
    	} ### END OF THIS ELSE
    if ( $study_okay[$study] == 1 ) {
#        print STDERR " *** DEBUG *** Examining sample size for [ $study_name[$study] ]: n = $sample_size[$study] and info = $ratio[$study].\n";
      $sample_size_eff[$study] = $sample_size[$study] * ( $ratio[$study] > 1 ? 1 : $ratio[$study] );
      $n_eff += $sample_size_eff[$study];
      $n_okay_studies++;
    }
  } ### END OF FOR-LOOP

  if ( $n_okay_studies == 0 ) { 
    $n_skipped_uninformative++;
    print STDERR "* For $variant there is information from one study or none -- so skipping this variant.\n";
  }
  
  if ( $n_eff == 0 ) { 
    $n_skipped_uninformative++;
    print STDERR "* For $variant the effective sample size = 0 -- so skipping this variant.\n";
  }

  if ( $n_okay_studies > 0 && $n_eff > 0 ) {  

    ###
    ### we can now print out variant information (based on the Reference, if available)
    ###
    print OUT "$variant $refchr $refpos $ref1 $ref2 ";
    if ( defined( $reference_a1_freq{$variant} ) ) { print OUT "$reference_a1_freq{$variant}"; } else { print OUT "NA"; }

    my @signed_beta = ();
    my @weight = (); 


    ###
    ### iterate over the association results from all studies
    ###
    for ( my $study = 0; $study < $nstudies; $study++ ) {  

      ### if everything is really okay, proceed
      if ( $study_okay[$study] == 1 ) {

        $n_informative_variants[$study] += 1;

        ### put BETA and SE on same scale across studies and correct SE for inflation 
        $beta[$study] = $beta[$study] / $correction_factor[$study];
        $se[$study] = $se[$study] * sqrt($lambda[$study]) / $correction_factor[$study];

        my $sign = 1;
        my $alleles_flipped = "N";

		### how to handle A/T/C/G variants including INDELs and implicitly the sign (of the effect size)
        if ( $flip_alleles[$study] == 1 ) {
          $a1[$study] = allele_flip( $a1[$study] );
          $a2[$study] = allele_flip( $a2[$study] );
          $alleles_flipped = "Y";
          $allele_flips[$study]++;
          $sign = -1; 
          $sign_flips[$study]++;
        }
        
        ### how to handle INDELs of the form R/D/I and implicitly the sign (of the effect size)
        if ( $flip_indels[$study] == 1 ) {
          $a1[$study] = indel_flip( $a1[$study], $a2[$study], "a1" );
          $a2[$study] = indel_flip( $a1[$study], $a2[$study], "a2" );
          $alleles_flipped = "Y";
          $allele_flips[$study]++;
          $sign = -1; 
          $sign_flips[$study]++;
        }

        ### inverse variance weighted z-score
        $signed_beta[$study] = $sign * $beta[$study];
        $weight[$study] = 1 / ( $se[$study] * $se[$study] );
        my $weighted_beta = $signed_beta[$study] * $weight[$study];
        $total_weighted_beta += $weighted_beta;
        $total_weight += $weight[$study];
        $total_weight_squared += $weight[$study] * $weight[$study];

        ### sample-size weighted z-score
        my $z_weight = sqrt( $sample_size_eff[$study] / $n_eff ); 
        my $z = ( $signed_beta[$study] / $se[$study] );
        $z_sqrtn += ($z * $z_weight);
      
        ### sample-size weighted allele frequency
        my $af_weight = $sample_size_eff[$study] / $n_eff; 

        if ( $sign == -1 ) {
          $af_weighted += ( (1-$af1[$study]) * $af_weight ); 
          if ( $verbose ) {
            ## don't forget to give the complementary allele frequency now that we have flipped the sign!
            print OUT sprintf(" %s %s %s Y %.4f %.4f %.4f %.2e %.4f %.1f", $a1[$study], $a2[$study], $alleles_flipped, 1-$af1[$study], $signed_beta[$study], $se[$study], $pval[$study], $ratio[$study], $sample_size_eff[$study]);
          }
        } else {
          $af_weighted += ( $af1[$study] * $af_weight ); 
          if ( $verbose ) {
            print OUT sprintf(" %s %s %s N %.4f %.4f %.4f %.2e %.4f %.1f", $a1[$study], $a2[$study], $alleles_flipped, $af1[$study], $signed_beta[$study], $se[$study], $pval[$study], $ratio[$study], $sample_size_eff[$study]);
          }
        }
      }
      else {
        if ( $verbose ) {
          print OUT " NA NA NA NA NA NA NA NA NA NA";
        }
      }
    }

    ###
    ### print out the overall summary and annotated genes
    ###

    ### fixed effects
    my $weighted_mean_beta = $total_weighted_beta / $total_weight;
    my $se_mean_beta = sqrt( 1 / $total_weight );
    my $z = $weighted_mean_beta / $se_mean_beta;
    my $beta_lower = $weighted_mean_beta - 1.96 * ( $se_mean_beta );
    my $beta_upper = $weighted_mean_beta + 1.96 * ( $se_mean_beta );
    my $p = Statistics::Distributions::chisqrprob( 1, $z * $z );
    my $p_sqrtn = Statistics::Distributions::chisqrprob( 1, $z_sqrtn * $z_sqrtn );

    ### print stuff out
    printf OUT " %s %s %.3f", $coded_allele, $other_allele, $af_weighted;
    printf OUT " %.1f %.4f %.4e", $n_eff, $z_sqrtn, $p_sqrtn;
    printf OUT " %.4f %.4f %.4f %.4e %.3f %.3f ", $weighted_mean_beta, $se_mean_beta, $z, $p, $beta_lower, $beta_upper;

    if ( $random_effects ) { 
      my $df = $n_okay_studies - 1;

      my $cochran_q = 0;
      my $p_cochran = 1;
      my $i_squared = 0;
      my $tau_squared = 0;

      ### by default, set the random-effects results equal to the fixed-effects results
      my $weighted_mean_beta_random = $weighted_mean_beta;
      my $se_mean_beta_random = $se_mean_beta;
      my $z_random = $z;
      my $beta_lower_random = $beta_lower;
      my $beta_upper_random = $beta_upper;
      my $p_random = $p;

      ### 
      ### only test heterogeneity when >2 studies
      ###
      if ( $n_okay_studies > 2 ) {

        ### Cochran's Q
        for (my $study = 0; $study < $nstudies; $study++) {
          if ( $study_okay[$study] == 1 ) {
            $cochran_q += $weight[$study] * ( $signed_beta[$study] - $weighted_mean_beta ) * ( $signed_beta[$study] - $weighted_mean_beta );
          }
        }
        $p_cochran = Statistics::Distributions::chisqrprob($df, $cochran_q);

        ### I-squared
        $i_squared = 100.0 * ( $cochran_q - $df ) / $cochran_q;
        if ( $i_squared < 0 ) { $i_squared = 0; }

        ### random effects
        my $total_weighted_beta_random = 0;
        my $total_weight_random = 0;

        my $mean_weight = $total_weight / $n_okay_studies;
        my $variance_weights = ( 1 / $df ) * ( $total_weight_squared - ( $n_okay_studies * ( $mean_weight * $mean_weight ) ) ); # this is the variance of the FE weights
        my $U = $df * ( $mean_weight - ( $variance_weights / ( $n_okay_studies * $mean_weight ) ) ); # U is used in the calculation of tau2

        ### tau-squared 
        $tau_squared = ( $cochran_q - $df ) / $U;
        if ( $cochran_q <= $df ) { $tau_squared = 0; }


        for (my $study = 0; $study < $nstudies; $study++) {
          if ( $study_okay[$study] == 1 ) {
            my $weight_random = 1 / ( ( 1 / $weight[$study] ) + $tau_squared ); 
            $total_weighted_beta_random += $signed_beta[$study] * $weight_random;
            $total_weight_random += $weight_random;
          }
        }
 
        $weighted_mean_beta_random = $total_weighted_beta_random / $total_weight_random;
        $se_mean_beta_random = sqrt( 1 / $total_weight_random );
        $z_random = $weighted_mean_beta_random / $se_mean_beta_random;
        $beta_lower_random = $weighted_mean_beta_random - 1.96 * ( $se_mean_beta_random );
        $beta_upper_random = $weighted_mean_beta_random + 1.96 * ( $se_mean_beta_random );
        $p_random = Statistics::Distributions::chisqrprob(1, $z_random * $z_random);  
      }

      printf OUT "%.3f %.3f %.3f %.4e %.3f %.3f ", $weighted_mean_beta_random, $se_mean_beta_random, $z_random, $p_random, $beta_lower_random, $beta_upper_random;
      printf OUT "%.3f %d %.4e %.1f %.3f ", $cochran_q, $df, $p_cochran, $i_squared, $tau_squared;
    }
    
    ### print out the directions for each study
    for (my $study = 0; $study < $nstudies; $study++) {
      if ( $study_okay[$study] == 1 ) { 
        if ( $signed_beta[$study] > 0 ) { printf OUT "+"; } else { printf OUT "-"; }  
      } 
      else { 
        printf OUT ".";
      }
    }
  
    ### print out any nearby genes
    my $yes_genes = 0;
    my %listed_genes = ();
    my $nearest_gene = "NA";
    my $nearest_gene_ensembl = "NA";
    my $nearest_gene_strand = "NA";
    my $nearest_distance = 10000000000;
    my $gene_length_temp = 10000000000;
    my $left_most = $refpos - ($gene_dist * 1000);
    my $right_most = $refpos + ($gene_dist * 1000);

    for (my $i = 0; $i < $ngenes; $i++) {
      if ( $gene_chr[$i] eq $refchr && ! defined( $listed_genes{$gene[$i]} ) ) {
        if ( ( $gene_start[$i] > $left_most && $gene_start[$i] < $right_most ) || ( $gene_stop[$i] > $left_most && $gene_stop[$i] < $right_most ) ) {
          if ( $yes_genes == 1 ) { print OUT ","; } else { print OUT " "; }
          print OUT "$gene[$i]"; 
          $yes_genes = 1;
          $listed_genes{$gene[$i]} = 1;
        
          my $gene_length = $gene_stop[$i] - $gene_start[$i];
          my $dist_left = $refpos - $gene_stop[$i]; 
          my $dist_right = $gene_start[$i] - $refpos;

          if ( $refpos > $gene_start[$i] && $refpos < $gene_stop[$i] && $gene_length < $gene_length_temp ) { 
            $nearest_gene = $gene[$i];
            $nearest_gene_ensembl = $gene_ensembl[$i];
            $nearest_gene_strand = $gene_strand[$i];
            $gene_length_temp = $gene_length;
            $nearest_distance = 0;
          }
          elsif ( $dist_left > 0 && $dist_left < $nearest_distance ) {
            $nearest_gene = $gene[$i];
            $nearest_gene_ensembl = $gene_ensembl[$i];
            $nearest_gene_strand = $gene_strand[$i];
            $nearest_distance = $dist_left;
          }
          elsif ( $dist_right > 0 && $dist_right < $nearest_distance ) {
            $nearest_gene = $gene[$i];
            $nearest_gene_ensembl = $gene_ensembl[$i];
            $nearest_gene_strand = $gene_strand[$i];
            $nearest_distance = $dist_right;
          }
#          print "gene = $gene[$i]   $dist_left  $dist_right  nearest gene = $nearest_gene   nearest_distance = $nearest_distance   gene_length_temp = $gene_length_temp\n"; 
        }
      }
    }

    if ( $yes_genes == 0 ) {
      print OUT " NA";
    }
     
    print OUT " $nearest_gene $nearest_gene_ensembl $nearest_gene_strand $dbsnp_function{$variant}";
    
    if ( defined( $caveat{$variant} ) ) { print OUT " $caveat{$variant}"; } else { print OUT " NA"; }

    print OUT "\n";
  
    $nvariants_in_meta++;
  }

}
close(OUT);
 
################################################################################
################################################################################
###
### print summary and close everything 
###
################################################################################
################################################################################
print STDOUT "\n";
print STDOUT "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
print STDOUT "Summarizing this meta-analysis.\n";
print STDOUT "\n";
print STDOUT "* Number of variants in meta-analysis       : $nvariants_in_meta.\n";
print STDOUT "* Number of variants not in the Reference   : $not_on_reference.\n";
print STDOUT "* Number of uninformative variants skipped  : $n_skipped_uninformative.\n";
print STDOUT "\n";
print STDOUT "          Study name     Allele flips     Sign [beta] flips     Informative variants\n";
print STDOUT "          ----------     ------------     -----------------     --------------------\n";

for (my $study = 0; $study < $nstudies; $study++) {
  close $fh[$study]; 
  printf STDOUT "%20s %16d %21d %24d\n", $study_name[$study], $allele_flips[$study], $sign_flips[$study], $n_informative_variants[$study];
}

print STDOUT "\n";
print STDOUT "This meta-analysis of GWAS was successfully finished!!!\n";

##########################################################################################
##########################################################################################
###
### FUNCTIONS FOR FLIPPING AND RECODING ALLELES
###
##########################################################################################
##########################################################################################

### Function for flipping alleles with A/T/C/G
sub allele_flip($)
{
	my $allele = shift;
	my $flipped_allele = "";
	# probably legacy - it doesn't appear to be part of dbSNP anymore
 	if ( $allele eq "(LARGEDELETION)" || $allele eq "lengthTooLong" ) { return $allele; } 

	if ( length($allele) == 1 ) {
#         print STDERR " ***DEBUG*** Given allele: \t\t[ $allele ].\n";
        
		for (my $i=0; $i < length($allele); $i++) {
			my $current_base = substr $allele, $i, 1;
			if ( $current_base eq "A" ) { $flipped_allele .= "T"; }
			elsif ( $current_base eq "C" ) { $flipped_allele .= "G"; }
			elsif ( $current_base eq "G" ) { $flipped_allele .= "C"; }
			elsif ( $current_base eq "T" ) { $flipped_allele .= "A"; }
			else { $flipped_allele .= $current_base; }
#  			print STDERR " ***DEBUG*** The allele was flipped from [ $current_base ] to [ $flipped_allele ].\n";
		}
	return $flipped_allele;
    }

	if ( length($allele) > 1 ) {
#  		print STDERR " ***DEBUG*** Given allele has length >1 and is: \t\t[ $allele ].\n";
		
		for (my $i=0; $i < length($allele); $i++) {
            my $current_base = substr $allele, $i, 1;
            if ( $current_base eq "A" ) { $flipped_allele = $flipped_allele . $current_base =~ s/A/T/gr; }
            elsif ( $current_base eq "C" ) { $flipped_allele = $flipped_allele . $current_base =~ s/C/G/gr; }
            elsif ( $current_base eq "G" ) { $flipped_allele = $flipped_allele . $current_base =~ s/G/C/gr; }
            elsif ( $current_base eq "T" ) { $flipped_allele = $flipped_allele . $current_base =~ s/T/A/gr; }
            else { $flipped_allele .= $current_base; }
		}
# 		print STDERR " ***DEBUG*** The flipped base is: \t[ $flipped_allele ].\n";
        return $flipped_allele;
    }
} ### END OF allele_flip

### Function for flipping INDELs of the form R/D/I
sub indel_flip($)
{
	my $indel_a1 = shift;
	my $indel_a2 = shift;
	my $indel_pos = shift;

# 	print STDERR " ***DEBUG*** Given alleles: \t\t[ $indel_a1 / $indel_a2 ].\n";
	my $flipped_indel_a1 = $indel_a2;
	my $flipped_indel_a2 = $indel_a1;

#  	print STDERR " ***DEBUG*** The allele was flipped from [ $indel_a1 / $indel_a2 ] to [ $flipped_indel_a1 / $flipped_indel_a2 ].\n";

	if( $indel_pos eq "a1" ) {
        return $flipped_indel_a1;
	} elsif( $indel_pos eq "a2" ) {
        return $flipped_indel_a2;
	} else {
        return "Oh_crap_something_is_wrong_with_flipping_this_INDEL.";
	}
}

### Function to convert alleles encoding of 1/2/3/4 to A/C/G/T -- which is PLINK old-style
sub allele_1234_to_ACGT($)
{
	my $allele = shift;
	if ( $allele eq "1" ) { return "A"; }
	if ( $allele eq "2" ) { return "C"; }
	if ( $allele eq "3" ) { return "G"; }
	if ( $allele eq "4" ) { return "T"; }
	return $allele;
}
