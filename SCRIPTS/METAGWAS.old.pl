#!/usr/bin/perl
####################################################################################################
#
# Version: METAGWAS2.1.0"
#
# Last update:	2016-12-27"
# Written by:	Paul I.W. de Bakker | UMC Utrecht, p.i.w.debakker-2@umcutrecht.nl; 
#				Sara Pulit | UMC Utrecht, s.l.pulit@umcutrecht.nl);
#				Jessica van Setten | UMC Utrecht, j.vansetten@umcutrecht.nl);
#				Sander W. van der Laan | UMC Utrecht, s.w.vanderlaan-2@umcutrecht.nl)
#
# Note: 		Originally based on MANTEL.pl, but heavily edited to accomodate the new era of 1000G imputed GWAS.
#
# Website: 		http://www.atheroexpress.nl/software
#        
# Thanks to Nikolaos Patsopoulos for help with the heterogeneity and random-effects code.
#
# This Perl script performs a meta-analysis across an arbitrary number of genome-wide studies, 
# where for each study association statistics are computed for a predefined set of SNPs. The
# meta-analysis is based on BETA and SE statistics from a linear or logistic regression analysis
# for each study. The meta-analysis statistic is based on inverse-variance weighting
# as well as a sample-size weighting (correted for imputation qualtiy) under a fixed-effects model.   
# Tests for heterogeneity (Cochran's Q and I-squared) and random-effects statistics are optional.
#
####################################################################################################
#
# REQUIRED INPUT:
#
# 1) A plain-text file with association analysis results for all studies combined into a single file
#    (one line per variant).
#
#    Expected file format (where the number indicates the column):
#
### OLD
#	 SNP CHR POS BETA SE P CA A2 CAF RATIO MAF MAC N
#	   1   2   3    4  5 6  7  8   9    10  11  12 13
### OLD
#	 VariantID CHR BP Beta SE P EffectAllele OtherAllele Info EAF MAC N  N_cases N_controls Imputed VT Reference
#	 1         2   3  4    5  6 7            8           9    10  11  12 13      14         15      16 17
#
#    where 'CHR' is the chromosome number, 'BP' is the chromosomal basepair position of the variant,
#    'Beta' is the computed estimate parameter of the effect of the given variant,
#    'SE' is the standard error around that Beta estimate,
#    'EffectAllele' represents the effect allele that the Beta and SE are referring to, 'OtherAllele' is the other allele,
#    'EAF' refers to the allele frequency of the effect allele (EffectAllele), 
#    'Info' is the ratio of the observed variance of the dosage to the expected (binomial) 
#    variance (i.e. the imputation quality, info-score),
#    'MAC' is the minor allele count for the given variant, 
#    'N' is the total sample size for the given variant,
#    'N_cases' is the total number of cases for the given variant,
#    'N_controls' is the the total number of controls for the given variant,
#    'Imputed' indicates whether the given variant was imputed (1) or genotyped (0);
#    genotyped implies that missing data for some individuals may be imputed for that
#    particular variant,
#    'VT' indicates the variant type (SNV or INDEL), and
#    'Reference' indicates whether the given variant was present in the reference or not.
#
#    Columns 2-17 are repeated (on the same line) for every additional GWAS that is part of the
#    meta-analysis.
#
#    The 'Info' is used to correct the weight of the contribution of each individual study depending
#    on the imputation quality of the variant.  This is only necessary when imputation was used (set to
#    1 if all variants are genotyped experimentally). See de Bakker et al., Human Molecular Genetics,
#    2008 for more background information on this topic.
#
#	 Note: 	Here a variant can be a single-nucleotide polymorphism or another type of variant such as
#			a INDEL or other structural variant.
#
# 2) [--params]	A plain-text file that contains study-specific parameters 
#
#    Example file format:
#
#    studyname_1	1.023	7650	1
#    studyname_2	1.040	854		17.2755
#    studyname_3	1.034	4606	18.1075
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
# 3) [--snps]	A PLINK BIM file -- for variant positions 
#
#    Expected file format (note that a PLINK BIM file has NO header line!):
#
#    CHR  VariantID     MORGAN     POS  A    B
#      1    2          3       4  5    6
#
# 4) [--dbsnp]	A dbSNP annotations file which includes all the information known about the variants; 
#    can be based on HapMap or 1000G, or any other reference.
#
#    Expected file format:
#
#    chrom	chromStart	chromEnd	name		strand	observed			class	func
#	 chr1	6946796		6946821		rs57898978	+		A/G					single	intron
#	 chr1	8912885		8912910		rs57188530	+		C/G					single	unknown
#	 chr1	34340790	34340885	rs6143185	+		(LARGEDELETION)/-	named	intron
#	 chr1	102891517	102891542	rs56752146	+		A/G					single	unknown
#
# 5) [--freq ]	A PLINK generated file (--freq) which is used as the reference to resolve
#    ambiguities in allele coding; can be based on HapMap or 1000G, or any other reference.
#
#    Expected file format:
#
#    CHR          VariantID   A1   A2          MAF  NCHROBS
#      1            2    3    4            5        6
#
# 6) [--genes]	Gene annotations
#
#    Expected file format:
#
#    CHR START STOP GENE_SYMBOL
#
# 7) [--freq-filter]	The frequency filter based on which the alleles will be flipped.
#
# 8) [--freq-warning]	The frequency based on which a warning will be given for A/T & C/G SNPs.
#
# OPTIONAL INPUT:
# [--dist]				Maximal distance to a gene (in kilobase units) -- this is used in the final output as for
#    					every variant genes within the specified distance are listed. A reasonable choice is 100-200
#    					kilobases, the default is 200.
# [--ext]				
# [--extract]			
# [--no-header]			Use this if the input file doesn't have headers
# [--random-effects]	To invoke the random-effects calculations and thus heterogeneity tests
# [--verbose]			To get an verbose output, which adds the per-study BETA, SE, P, alleles, 
#						allele frequency, allele-flips, sign-flips, RATIO, effective sample size, 
#						for the given variant.
#
####################################################################################################

####################################################################################################
####################################################################################################
###
### SETTING THE SCENE
###
####################################################################################################
####################################################################################################

use lib '.';
use strict;
use FileHandle;
use Getopt::Long;
use Statistics::Distributions;

my $paramsFile; # required
my $variantFile; # required
my $extractFile; # required
my $dbsnpFile; # required
my $reffreqFile; # required
my $genesFile; # required
#my $freqFilter; # required
#my $freqWarning; # required
my $gene_dist = 200; # optional [--dist]
my $extension = ""; # optional [--ext]
my $no_header = ''; # optional [--no-header]
my $random_effects = ''; # optional [--random-effects]
my $verbose = ''; # optional [--verbose]
my $outFile = "meta.out";

GetOptions(
			"params=s"       => \$paramsFile,
	   		"snps=s"         => \$variantFile,
			"extract=s"      => \$extractFile,
			"dbsnp=s"        => \$dbsnpFile,
			"freq=s"         => \$reffreqFile,
			"genes=s"        => \$genesFile,
			"dist=i"         => \$gene_dist,
			"out=s"          => \$outFile,
	   		"ext=s"          => \$extension,
	   		"no-header"      => \$no_header,
	   		"random-effects" => \$random_effects,
	   		"verbose"        => \$verbose
           );

#if ( ! $paramsFile || ! $variantFile || ! $dbsnpFile || ! $reffreqFile || ! $genesFile || ! $freqFilter || ! $freqWarning ) {
if ( ! $paramsFile || ! $variantFile || ! $dbsnpFile || ! $reffreqFile || ! $genesFile ) {
#print STDERR "Usage: mantel.pl --params [params_file] --snps [snps_file] --dbsnp [dbsnp_file] --freq [freq_file] --genes [genes_file] --freq-filter [freq_filter] --freq-filter [freq_warning]\n\n";
print STDERR "Usage: mantel.pl --params [params_file] --snps [snps_file] --dbsnp [dbsnp_file] --freq [freq_file] --genes [genes_file]\n\n";
}

print STDOUT "Using MANTEL2.0.20150224 (mantel.pl) by Paul I.W. de Bakker, last update: February 24th, 2015\n\n";
print STDOUT "Running with the following parameters:\n";
print STDOUT "  --params              = $paramsFile\n";
print STDOUT "  --snps                = $variantFile\n";
print STDOUT "  --dbsnp               = $dbsnpFile\n";
print STDOUT "  --freq                = $reffreqFile\n";
print STDOUT "  --genes               = $genesFile\n";
print STDOUT "  --dist                = $gene_dist\n";
#print STDOUT "  --freq-filter         = $freqFilter\n";
#print STDOUT "  --freq-warning        = $freqWarning\n";
print STDOUT "  --out                 = $outFile\n";

if ( $extension ne "" ) {
print STDOUT "  --ext                 = $extension\n";
}

if ( $extractFile ne "" ) {
print STDOUT "  --extract             = $extractFile\n";
}

if ( $no_header ) {
print STDOUT "  --no-header\n";
}

if ( $random_effects ) {
print STDOUT "  --random-effects\n";
}

if ( $verbose ) {
print STDOUT "  --verbose\n";
}

print STDOUT "\n";


####################################################################################################
####################################################################################################
###
### READ IN VARIANT LIST
###
####################################################################################################
####################################################################################################

my @snp_name = ();
my %snplist = ();
my $n_total_snps = 0;
my $header = 0;

my $snpFilename = $variantFile;
if ( $extension ne "" ) { $snpFilename .= ".$extension"; }
open (VARIANT, $snpFilename) or die "Cannot open $snpFilename\n";
print STDOUT "Reading variant list from: $snpFilename\n";
while(my $c = <VARIANT>){
  chomp $c;
  $c =~ s/^\s+//;
  my @fields = split /\s+/, $c;
 
  if ( $header == 0 && ! $no_header ) { $header = 1; next; }
#  if ( $#fields != 2 ) { print STDERR "number of columns in the $variantFile must be 3!\n";  exit; }

  $snp_name[$n_total_snps] = $fields[0];
  $variantlist{$fields[0]} = 1;

  $n_total_snps++;
}
close(VARIANT);

print STDOUT "Number of variants ready for meta-analysis: $n_total_snps\n";


####################################################################################################
####################################################################################################
###
### READ IN VARIANT EXTRACT LIST ( if given )
###
####################################################################################################
####################################################################################################

my %extract = (); # optional [--extract]
my $n_extract_snps = 0;

if ( $extractFile ) {
  open (VARIANT, $extractFile) or die "Cannot open $extractFile\n";
  print STDOUT "Reading variant extract list from: $extractFile\n";
  while(my $c = <VARIANT>){
    chomp $c;
    $c =~ s/^\s+//;
    my @fields = split /\s+/, $c;

    $extract{$fields[0]} = 1;
    $n_extract_snps++;
  }
  close(VARIANT);
  print STDOUT "Extracting variants: $n_extract_snps\n";
}


####################################################################################################
####################################################################################################
###
### READ IN STUDY PARAMETERS
###
####################################################################################################
####################################################################################################

my @study_name = ();
my @filename = ();
my @lambda = ();
my @sample_size = ();
my @correction_factor = ();
my @allele_flips = ();
my @sign_flips = ();
my @n_informative_snps = ();
my @fh = ();

my $nstudies = 0;
my $total_sample_size = 0;

open (PARAMS, $paramsFile) or die "Cannot open $paramsFile\n";

print STDOUT "Reading parameter file: $paramsFile\n";
print STDOUT "\n";
print STDOUT "          Study name     Lambda     Sample size     Correction factor     Number of SNPs     File name\n";
print STDOUT "          ----------     ------     -----------     -----------------     --------------     ---------\n";
 
while(my $c = <PARAMS>){
  chomp $c;
  $c =~ s/^\s+//;
  my @fields = split /\s+/, $c;

  if ( $#fields != 4 ) { die "Number of columns in the $paramsFile must be 5!\n"; }

  $study_name[$nstudies] = $fields[0];
  $lambda[$nstudies] = $fields[1];
  if ( $fields[1] < 1 ) { 
    die "Lambda $fields[0] cannot be less than 1\n";
  }
  $sample_size[$nstudies] = $fields[2];
  $total_sample_size += $fields[2];
  $correction_factor[$nstudies] = $fields[3];
  $filename[$nstudies] = $fields[4];
  if ( $extension ne "" ) {
    $filename[$nstudies] .= ".$extension";
  }

  $fh[$nstudies] = new FileHandle;
  $fh[$nstudies]->open($filename[$nstudies]) || die "$filename[$nstudies] did not open\n";
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
    if ( $cols[0] ne $snp_name[$counter] ) { die "$filename[$nstudies] not in order with $variantFile\n"; }

    $counter++;
  }
  close($FILE);

#  print STDOUT "read $filename[$nstudies] with $counter SNPs\n";

  ### reopen it and skip first line (if --no_header is not specified)
  $fh[$nstudies]->open($filename[$nstudies]) || die "$filename[$nstudies] did not open\n";
  if ( ! $no_header ) { 
    my $FILE = $fh[$nstudies];
    my $ignore = <$FILE>; 
  }

  printf STDOUT "%20s %10.5f %15d %21.5f %18d     %s [verified]\n", $study_name[$nstudies], $lambda[$nstudies], $sample_size[$nstudies], $correction_factor[$nstudies], $counter, $filename[$nstudies];

  $allele_flips[$nstudies] = 0;
  $sign_flips[$nstudies] = 0;
  $n_informative_snps[$nstudies] = 0;

  $nstudies++;
}
close(PARAMS);

print STDOUT "                                    ===========\n";
printf STDOUT "                                    %11d\n", $total_sample_size;
print STDOUT "\n";
print STDOUT "Total number of studies: $nstudies\n";


####################################################################################################
####################################################################################################
###
### READ IN dbSNP ANNOTATIONS FILE ( to get inventory of markers, positions and annotation )
###
####################################################################################################
####################################################################################################

open (DBSNP, $dbsnpFile) or die "Cannot open $dbsnpFile\n";
print STDOUT "Reading dbSNP annotations file: $dbsnpFile\n";

my $n_dbsnp_annotations = 0;
my %skip_list = ();
my %dbsnp_chr = ();
my %dbsnp_pos = ();
#my %dbsnp_alleles = ();
my %dbsnp_a1 = ();
my %dbsnp_a2 = ();
my %dbsnp_function = ();
my %caveat = ();

while(my $c = <DBSNP>){
  chomp $c;
  $c =~ s/^\s+//;
  my @fields = split /\s+/, $c;
  my $variant = $fields[3];

  ### skipping SNPs that map to alternate chromosome (e.g. chr6_qbl) 
  if ( $fields[0] =~ m/_/ ) { next; }
  
  if ( defined( $variantlist{$variant} ) && ( ( ! $extractFile ) || defined( $extract{$variant} ) ) ) {

    if ( defined( $dbsnp_a1{$variant} ) ) {
#      print STDERR "$variant appears more than once -- skipping it\n";
      $caveat{$variant} = "not_unique_position";
#      $skip_list{$variant} = 1;
      next;
    }
    
    my @alleles = split /\//, $fields[5];
   
    if ( $#alleles > 1 ) { 
      print STDERR "$variant has more than 2 alleles [" . $fields[5] . "] -- skipping it\n";
      $skip_list{$variant} = 1;
      next;
    } 
   if ( $fields[5] =~ m/lengthTooLong/ ) {
      print STDERR "$variant has alleles with lengthTooLong -- skipping it\n";
      $skip_list{$variant} = 1;
      next;
    }
    if ( $#alleles == 0 ) { 
      print STDERR "$variant has only 1 allele [" . $fields[5] . "] -- skipping it\n";
      $skip_list{$variant} = 1;
      next;
    } 

    $fields[0] =~ s/chr//;
    $dbsnp_chr{$variant} = $fields[0];
    $dbsnp_pos{$variant} = $fields[1] + 1;
    $dbsnp_function{$variant} = $fields[7];
#    $dbsnp_alleles{$variant} = [ @alleles ];
    $dbsnp_a1{$variant} = $alleles[0];
    $dbsnp_a2{$variant} = $alleles[1];

#    print "from dbsnp read $variant with $dbsnp_alleles{$variant}[0] $dbsnp_alleles{$variant}[1] alleles strand = $strand\n";
    
    my $strand = $fields[4]; 
    if ( $strand eq "-" ) { 
#      @{$dbsnp_alleles{$variant}} = ();
#      foreach my $allele ( @alleles ) { 
#        push @{$dbsnp_alleles{$variant}}, allele_flip( $allele );
#      }
      $dbsnp_a1{$variant} = allele_flip( $dbsnp_a1{$variant} );
      $dbsnp_a2{$variant} = allele_flip( $dbsnp_a2{$variant} );
    }
#    print "from dbsnp read $variant with $dbsnp_alleles{$variant}[0] $dbsnp_alleles{$variant}[1] alleles strand = $strand function = $dbsnp_function{$variant}\n";
 
    $n_dbsnp_annotations++;
  }
}
close (DBSNP);

print STDOUT "Number of annotated SNPs: $n_dbsnp_annotations\n";


####################################################################################################
####################################################################################################
###
### CHECK ALL VARIANTS ON THE LIST FOR ANNOTATION IN dbSNP
###
####################################################################################################
####################################################################################################

for (my $nsnp; $nsnp < $n_total_snps; $nsnp++) {
  my $variant = $snp_name[$nsnp];
  if ( ! defined( $skip_list{$variant} ) && ( ( ! $extractFile ) || defined( $extract{$variant} ) ) && ! defined( $dbsnp_chr{$variant} ) ) {
    print STDERR "$variant in $variantFile is not annotated in dbSNP -- skipping it\n";
    $skip_list{$variant} = 1;
  }
}


####################################################################################################
####################################################################################################
###
### READ IN MINOR AND MAJOR ALLELE FROM REFERENCE
### (nothing is done currently with those - but may need them later for A/T and C/G SNPs)
###
####################################################################################################
####################################################################################################

open (HM, $reffreqFile) or die "Cannot open $reffreqFile\n";
print STDOUT "Reading reference frequency file: $reffreqFile\n";

#my %reference_a1 = ();
#my %reference_a2 = ();
my %reference_a1_freq = ();


while(my $c = <HM>){
  chomp $c;
  $c =~ s/^\s+//;
  my @fields = split /\s+/, $c;
  my $variant = $fields[1]; 
  if ( $variant eq "VARIANT" ) { next; }

  if ( ( ! defined( $skip_list{$variant} ) ) && defined( $variantlist{$variant} ) && ( ( ! $extractFile ) || defined( $extract{$variant} ) ) ) {

    my $a1 = $fields[2];  # minor allele (can be 0 if monomorphic - but these should be removed prior to meta-analysis)
    my $a2 = $fields[3];  # major allele

    $reference_a1_freq{$variant} = $fields[4];
    

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
    else {
      print STDERR "For $variant, cannot determine reference frequency for alleles $a1 and $a2 and annotated alleles $dbsnp_a1{$variant} $dbsnp_a2{$variant} -- skipping it\n";
      $skip_list{$variant} = 1;
    }
  }
}
close (HM);


####################################################################################################
####################################################################################################
###
### READ IN THE GENES
### 
####################################################################################################
####################################################################################################

open (GENE, $genesFile) or die "Cannot open $genesFile\n";
print STDOUT "Reading file: $genesFile\n";

my $ngenes = 0;
my @gene = ();
my @gene_chr = ();
my @gene_start = ();
my @gene_stop = ();

while(my $c = <GENE>){
  chomp $c;
  my @fields = split /\s+/, $c;

  $gene_chr[$ngenes] = $fields[0];
  $gene_start[$ngenes] = $fields[1];
  $gene_stop[$ngenes] = $fields[2];
  $gene[$ngenes] = $fields[3];
  $ngenes++;
}
close (GENE);

print STDOUT "Number of annotated genes: $ngenes\n";
print STDOUT "Maximal distance to genes: $gene_dist KB\n";


####################################################################################################
####################################################################################################
###
### PREPARE OUTPUT FILE -- write out the header line
###
####################################################################################################
####################################################################################################

open (OUT, ">$outFile") or die "Cannot open $outFile\n";
print OUT "VARIANT CHR POS CodedAllele OtherAllele CAF_Reference";

if ( $verbose ) {
  for (my $i=0; $i < $nstudies; $i++) {
    print OUT " CODED_AL_$study_name[$i] NONCODED_AL_$study_name[$i] ALLELES_FLIPPED_$study_name[$i] SIGN_FLIPPED_$study_name[$i] CAF_$study_name[$i] BETA_$study_name[$i] SE_$study_name[$i] P_$study_name[$i] RATIO_$study_name[$i] NEFF_$study_name[$i]";
  }
}

print OUT " CODED_ALLELE NONCODED_ALLELE CODED_ALLELE_FREQ N_EFF Z_SQRTN P_SQRTN BETA_FIXED SE_FIXED Z_FIXED P_FIXED BETA_LOW95CI_FIXED BETA_UP95CI_FIXED ";
if ( $random_effects ) {
  print OUT "BETA_RANDOM SE_RANDOM Z_RANDOM P_RANDOM BETA_LOW95CI_RANDOM BETA_UP95CI_RANDOM COCHRANS_Q DF P_COCHRANS_Q I_SQUARED TAU_SQUARED ";
}
print OUT "DIRECTIONS GENES_" . $gene_dist . "KB NEAREST_GENE FUNCTION CAVEAT\n";


####################################################################################################
####################################################################################################
###
### LOOP OVER ALL VARIANTS FROM THE LIST -- and do some work
###
####################################################################################################
####################################################################################################

print STDOUT "Now running meta-analysis...\n";

my $nsnps_in_meta = 0;
my $not_on_reference = 0;
my $skip = 0;
my $n_skipped_uninformative = 0;
my %reference_present = ();

for (my $nsnp; $nsnp < $n_total_snps; $nsnp++) {

  my $variant = $snp_name[$nsnp];
 
  ### skip this VARIANT if it is not on the extract hash 
  if ( $skip_list{$variant} || ( $extractFile && ! defined( $extract{$variant} ) ) ) { $skip++; next; }
  
  my $refchr = defined($dbsnp_chr{$variant}) ? $dbsnp_chr{$variant} : "NA";
  my $refpos = defined($dbsnp_pos{$variant}) ? $dbsnp_pos{$variant} : "NA";
#  my $ref1 = "0";
#  my $ref2 = "0";
  my $ref1 = $dbsnp_a1{$variant};
  my $ref2 = $dbsnp_a2{$variant};
  my $coded_allele = $ref1;
  my $noncoded_allele = $ref2;
  my @study_okay = ();
  my @flip_alleles = ();
  my @sample_size_eff = (); # [THIS SHOULD BE BASED ON THE INPUT FILE COLUMN!!!]
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
  my @a1 = ();
  my @a2 = ();
  my @af1 = ();
  my @ratio = ();
  #my @maf = ();
  #my @mac = ();
  #my @sample_size_N = ();
 
  ###
  ### first read in the data
  ###
  for ( my $study = 0; $study < $nstudies; $study++ ) {
    my $FILE = $fh[$study]; 
    for ( my $a = 0; $a < $skip; $a++ ) { my $void = <$FILE>; }
    my $c = <$FILE>;
    chomp $c;
    my @fields = split /\s+/, $c;

    if ( $fields[0] ne $variant ) { die "$filename[$study] not in order with $variantFile -- was expecting $variant but got $fields[0]\n"; }

    if ( $fields[1] eq "X" ) { $chr[$study] = 23; }
    elsif ( $fields[1] eq "Y" ) { $chr[$study] = 24; }
    elsif ( $fields[1] eq "XY" ) { $chr[$study] = 25; }
    elsif ( $fields[1] eq "MT" ) { $chr[$study] = 26; }
    else { $chr[$study] = $fields[1]; }

    $pos[$study] = $fields[2];
    $beta[$study] = $fields[3];
    $se[$study] = $fields[4];
    $pval[$study] = $fields[5];
    $a1[$study] = allele_1234_to_ACGT( $fields[6] );
    $a2[$study] = allele_1234_to_ACGT( $fields[7] );
    $af1[$study] = $fields[8];  

    if ( $#fields == 9 ) { $ratio[$study] = $fields[9]; } else { $ratio[$study] = 1; }
  }

  ### reset skip 
  $skip = 0;
   
  ### check if this VARIANT has a reference frequency 
  if ( ! defined( $reference_a1_freq{$variant} ) ) {
    $not_on_reference++;
    $reference_present{$variant} = 0;
    $caveat{$variant} .= "reference_present";
  }
  else {
      $reference_present{$variant} = 1;
  }
  
  ###
  ### walk through studies to see who's present
  ###
  for ( my $study=0; $study < $nstudies; $study++ ) {  
      
    ### first assume the study is okay
    $study_okay[$study] = 1;
   
    ### since we do not use the p-value it is not strictly essential to have p-value in the input file
    #if ( $beta[$study] eq "NA" || $se[$study] eq "NA" || $af1[$study] eq "NA" || $ratio[$study] eq "NA" || $pval[$study] eq "NA" || $a1[$study] eq "NA" || $a2[$study] eq "NA" || $se[$study] == 0 ) {
    if ( $beta[$study] eq "NA" || $se[$study] eq "NA" || $af1[$study] eq "NA" || $ratio[$study] eq "NA" || $a1[$study] eq "NA" || $a2[$study] eq "NA" || $se[$study] == 0 ) {

      $study_okay[$study] = 0;

    } else {

      ### allele a1 and allele a2 match the two reference alleles 
      if ( ( $a1[$study] eq $ref1 && $a2[$study] eq $ref2 ) || ( $a1[$study] eq $ref2 && $a2[$study] eq $ref1 ) ) { 
        $flip_alleles[$study] = 0;

		### frequency-based test for A/T or C/G SNPs [THE CUTOFF FOR ALLELE FREQUENCY MATCHING SHOULD BE OPTIONAL]
		if ( ( $a1[$study] eq "A" && $a2[$study] eq "T" ) || ( $a1[$study] eq "T" && $a2[$study] eq "A" ) || ( $a1[$study] eq "C" && $a2[$study] eq "G" ) || ( $a1[$study] eq "G" && $a2[$study] eq "C" ) ) {
			if ( $reference_present{$variant} = 1 ) {
				if ( $a1[$study] eq $ref1 && ( $af1[$study] > ( $reference_a1_freq{$variant} - 0.15 ) ) && ( $af1[$study] < ( $reference_a1_freq{$variant} + 0.15 ) ) ) {
			}
			elsif ( $a2[$study] eq $ref1 && ( $af1[$study] > ( 1 - $reference_a1_freq{$variant} - 0.15 ) ) && ( $af1[$study] < ( 1 - $reference_a1_freq{$variant} + 0.15 ) ) ) {
			}
			elsif ( $a1[$study] eq allele_flip( $ref1 ) && ( $af1[$study] > ( $reference_a1_freq{$variant} - 0.15 ) ) && ( $af1[$study] < ( $reference_a1_freq{$variant} + 0.15 ) ) ) {
				$flip_alleles[$study] = 1;
			}
			elsif ( $a2[$study] eq allele_flip( $ref1 ) && ( $af1[$study] > ( 1 - $reference_a1_freq{$variant} - 0.15 ) ) && ( $af1[$study] < ( 1 - $reference_a1_freq{$variant} + 0.15 ) ) ) {
				$flip_alleles[$study] = 1;
			}
		else {
		    print STDERR "In $study_name[$study], $variant alleles ($a1[$study]/$a2[$study]) match the reference, but has allele frequencies inconsistent with the reference frequencies -- skipping this A/T or C/G VARIANT for this study\n";
		    $study_okay[$study] = 0;
		}
	    }
	}
               
       ### frequency-based test for non-A/T and non-C/G SNPs [THE CUTOFF FOR ALLELE FREQUENCY MATCHING SHOULD BE OPTIONAL]
        else {
	    if ( $reference_present{$variant} =1 ) {
		if ( $a1[$study] eq $ref1 && ( $af1[$study] > ( $reference_a1_freq{$variant} - 0.15 ) ) && ( $af1[$study] < ( $reference_a1_freq{$variant} + 0.15 ) ) ) {
		}
		elsif ( $a2[$study] eq $ref1 && ( $af1[$study] > ( 1 - $reference_a1_freq{$variant} - 0.15 ) ) && ( $af1[$study] < ( 1 - $reference_a1_freq{$variant} + 0.15 ) ) ) {
		}
		else {
		    print STDERR "In $study_name[$study], $variant alleles ($a1[$study]/$a2[$study]) match the reference, but has allele frequencies inconsistent with the reference frequencies -- skipping this non-A/T or non-C/G VARIANT for this study\n";
		    $study_okay[$study] = 0;
		}
	    }
        
	}

      ### Warning for allele frequencies between 0.45 and 0.55 for A/T and C/G SNPs [THE CUTOFF FOR ALLELE FREQUENCY WARNING SHOULD BE OPTIONAL]
      if ( ( ( $a1[$study] eq "A" && $a2[$study] eq "T" ) || ( $a1[$study] eq "T" && $a2[$study] eq "A" ) || ( $a1[$study] eq "C" && $a2[$study] eq "G" ) || ( $a1[$study] eq "G" && $a2[$study] eq "C" ) ) && ( ( $af1[$study] > 0.45 && $af1[$study] < 0.55 ) || ( $reference_a1_freq{$variant} > 0.45 && $reference_a1_freq{$variant} < 0.55 ) ) ) {
	  $caveat{$variant} .= "A/T_or_C/G_SNP_with_0.45<CAF<0.55";
      }

    }

      ### allele a1 and allele a2 do not match the two reference alleles 
      elsif ( ( $a1[$study] eq allele_flip( $ref1 ) && $a2[$study] eq allele_flip( $ref2 ) ) || ( $a1[$study] eq allele_flip( $ref2 ) && $a2[$study] eq allele_flip( $ref1 ) ) ) { 
        $flip_alleles[$study] = 1;
      
      ### frequency-based test for non-A/T and non-C/G SNPs [THE CUTOFF FOR ALLELE FREQUENCY MATCHING SHOULD BE OPTIONAL]
        if ( $reference_present{$variant} =1 ) {
	    if ( $a1[$study] eq allele_flip( $ref1 ) && ( $af1[$study] > ( $reference_a1_freq{$variant} - 0.15 ) ) && ( $af1[$study] < ( $reference_a1_freq{$variant} + 0.15 ) ) ) {
	    }
	    elsif ( $a2[$study] eq allele_flip( $ref1 ) && ( $af1[$study] > ( 1 - $reference_a1_freq{$variant} - 0.15 ) ) && ( $af1[$study] < ( 1 - $reference_a1_freq{$variant} + 0.15 ) ) ) {
	    }
	    else {
		print STDERR "In $study_name[$study], $variant alleles ($a1[$study]/$a2[$study]) do not match the reference, and has allele frequencies inconsistent with the reference frequencies -- skipping this non-A/T and non-C/G VARIANT for this study\n";
		$study_okay[$study] = 0;
	    }
        }
    }
      ### the coded allele (a1) and the noncoded allele do not match the two reference alleles -- even after flipping
      else {
        print STDERR "In $study_name[$study], $variant has alleles ($a1[$study]/$a2[$study]) inconsistent with reference alleles $ref1 $ref2 -- skipping this VARIANT for this study\n"; 
        $study_okay[$study] = 0;
      }
    } 

    if ( $study_okay[$study] == 1 ) {
      $sample_size_eff[$study] = $sample_size[$study] * ( $ratio[$study] > 1 ? 1 : $ratio[$study] );
      $n_eff += $sample_size_eff[$study];
      $n_okay_studies++;
    }
  }

  if ( $n_okay_studies == 0 ) { 
    print STDERR "For $variant no information from any study -- so skipping this VARIANT\n";
    $n_skipped_uninformative++;
  }
  
  if ( $n_eff == 0 ) { 
    print STDERR "For $variant effective sample size = 0 -- so skipping this VARIANT\n";
    $n_skipped_uninformative++;
  }

  if ( $n_okay_studies > 0 && $n_eff > 0 ) {  

    ###
    ### we can now print out VARIANT information (based on reference, if available)
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

        $n_informative_snps[$study] += 1;

        ### put BETA and SE on same scale across studies and correct SE for inflation 
        $beta[$study] = $beta[$study] / $correction_factor[$study];
        $se[$study] = $se[$study] * sqrt($lambda[$study]) / $correction_factor[$study];

        my $sign = 1;
        my $alleles_flipped = "N";

        if ( $flip_alleles[$study] == 1 ) {
          $a1[$study] = allele_flip( $a1[$study] );
          $a2[$study] = allele_flip( $a2[$study] );
          $alleles_flipped = "Y";
          $allele_flips[$study]++;
        }

        if ( $a1[$study] eq $coded_allele && $a2[$study] eq $noncoded_allele ) {
#		if ( $a1[$study] eq $ref1 && $a2[$study] eq $ref2 ) {
         #$sign = 1;
        }
        elsif ( $a1[$study] eq $noncoded_allele && $a2[$study] eq $coded_allele ) {
#		elsif ( $a1[$study] eq $ref2 && $a2[$study] eq $ref1 ) { 
         # change the sign of the beta if the coded/noncoded alleles are reversed compared to the first study
          print STDERR "flipped sign for $a1 $a2\n";
          $sign = -1; 
          $sign_flips[$study]++;
        } 
        else {
	    print STDERR "For $variant in study $study coded/non-coded alleles $a1[$study] $a2[$study] do not match reference alleles $ref1 $ref2\n";
          die "Internal error: coded/non-coded alleles do not match reference alleles\n";
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
    printf OUT " %s %s %.3f", $coded_allele, $noncoded_allele, $af_weighted;
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
            $gene_length_temp = $gene_length;
            $nearest_distance = 0;
          }
          elsif ( $dist_left > 0 && $dist_left < $nearest_distance ) {
            $nearest_gene = $gene[$i];
            $nearest_distance = $dist_left;
          }
          elsif ( $dist_right > 0 && $dist_right < $nearest_distance ) {
            $nearest_gene = $gene[$i];
            $nearest_distance = $dist_right;
          }
#          print "gene = $gene[$i]   $dist_left  $dist_right  nearest gene = $nearest_gene   nearest_distance = $nearest_distance   gene_length_temp = $gene_length_temp\n"; 
        }
      }
    }

    if ( $yes_genes == 0 ) {
      print OUT " NA";
    }
     
    print OUT " $nearest_gene $dbsnp_function{$variant}";
    
    if ( defined( $caveat{$variant} ) ) { print OUT " $caveat{$variant}"; } else { print OUT " NA"; }

    print OUT "\n";
  
    $nsnps_in_meta++;
  }

}
close(OUT);
 
####################################################################################################
####################################################################################################
###
### PRINTING SUMMARY AND CLOSE EVERYTHING
###
####################################################################################################
####################################################################################################

print STDOUT "Number of variants in meta-analysis: $nsnps_in_meta\n";
print STDOUT "Number of variants not in reference: $not_on_reference\n";
print STDOUT "Number of uninformative variants skipped: $n_skipped_uninformative\n";
print STDOUT "\n";
print STDOUT "          Study name     Allele flips     Sign flips     Informative variants\n";
print STDOUT "          ----------     ------------     ----------     --------------------\n";

for (my $study = 0; $study < $nstudies; $study++) {
  close $fh[$study]; 
  printf STDOUT "%20s %16d %14d %20d\n", $study_name[$study], $allele_flips[$study], $sign_flips[$study], $n_informative_snps[$study];
}

print STDOUT "\n";
print STDOUT "Successfully finished. Let's get a beer, buddy!!!\n";

####################################################################################################
####################################################################################################
###
### FUNCTIONS FOR FLIPPING AND RECODING ALLELES
###
####################################################################################################
####################################################################################################

sub allele_flip($)
{
  my $allele = shift;
  my $flipped_allele = "";
  if ( $allele eq "(LARGEDELETION)" || $allele eq "lengthTooLong" ) { return $allele; }

  for (my $i=0; $i < length($allele); $i++) {
    my $current_base = substr $allele, $i, 1;
    if ( $current_base eq "A" ) { $flipped_allele .= "T"; }
    elsif ( $current_base eq "C" ) { $flipped_allele .= "G"; }
    elsif ( $current_base eq "G" ) { $flipped_allele .= "C"; }
    elsif ( $current_base eq "T" ) { $flipped_allele .= "A"; }
    else { $flipped_allele .= $current_base; }    
  }

  return $flipped_allele;
}

sub allele_1234_to_ACGT($)
{
	my $allele = shift;
	if ( $allele eq "1" ) { return "A"; }
	if ( $allele eq "2" ) { return "C"; }
	if ( $allele eq "3" ) { return "G"; }
	if ( $allele eq "4" ) { return "T"; }
	return $allele;
}
