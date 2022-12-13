#!/usr/bin/perl
# 
# VCF PARSER
#
# Description: 	this script parses VCF files of 1000G phase 1 or phase 3. It will make three
#               new files:
#               1) a list of alternate variantIDs to harmonize the GWAS cohorts,
#               2) a file containing frequencies of the chosen reference and population,
#               3) a reference-file used as a reference to map, allign, and annotate all GWAS to during meta-analysis. 
#
# Written by:	Vinicius Tragante dó Ó & Sander W. van der Laan; Utrecht, the 
#               Netherlands, s.w.vanderlaan@gmail.com.
# Edited by: 	Emma J.A. Smulders. 
# Version:		1.5.1
# Update date: 	2022-11-01
#
# Usage:		resource.VCFparser.pl --file [input.vcf.gz] --ref [reference] --pop [population] --out [output.basename]

# Starting parsing
print STDERR "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
print STDERR "+                                        VCF PARSER                                      +\n";
print STDERR "+                                          v1.5.0                                        +\n";
print STDERR "+                                                                                        +\n";
print STDERR "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
print STDERR "\n";
print STDERR "Hello. I am starting the overlapping of the files you've provided.\n";
my $time = localtime; # scalar context
print STDERR "The current date and time is: $time.\n";
print STDERR "\n";

use strict;
use warnings;
use Getopt::Long;
use Scalar::Util 'looks_like_number';

print STDERR "Reading options...\n";

my $file = ""; # input VCF file to generate output
my $reference = ""; # reference you want to create
my $population = ""; # population you want to use relative to the reference
my $output = ""; # output files generated: info-file; freq-file; variantID-harmonizer file

GetOptions(
           "file=s"	=> \$file,
           "ref=s"	=> \$reference,
           "pop=s"	=> \$population,
           "out=s"	=> \$output,
           );
### IF STATEMENT TO CHECK CORRECT INPUT
if ( $file eq "" || $reference eq "" || $population eq "" || $output eq "" ) {
print "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
print "Usage: 
resource.VCFparser.pl --file input.vcf.gz  --ref [reference] --pop [population] --out output.basename\n";
print "\n";
print "Parses the input file, expected to be a VCF file (format 4.1+) and outputs files  
containing alternate variantIDs, allele frequencies, and variant information. Depending on 
the reference, one needs to choose the proper population as the alleles and frequencies 
might differ between references and accross populations. Choices are:\n";
print "\n";
print "Reference     Population\n";
print "=========     ==========\n";
print "1Gp1          PAN, EUR, AFR, AMR, ASN\n";
print "1Gp3          PAN, EUR, AFR, AMR, EAS, SAS\n";
print "[GoNL4         NL] - not available\n";
print "[GoNL5         NL] - not available\n";
print "1Gp3GONL5     PAN\n";
print "\n";
print "The output files will contain the following:\n";
print "* Alternate VariantIDs: [ output.basename.INFO.txt ]\n";
print "* Reference and population specific allele information: [ output.basename.FREQ.txt ]\n";
print "* Variant information for alligning and annotating: [ output.basename.FUNC.txt ]\n";
print "";
print "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
print "The MIT License (MIT)\n";
print "Copyright (c) 2016-2022 Sander W. van der Laan & Vinicius Tragante dó Ó\n";
print "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
exit();
}

### Add in a function to:
### - check the right combination of reference and population
### - write out the ref/pop dependent alleles and allele frequencies


### 1000G phase 1, version 3
if ( $reference eq "1Gp1" ) {
	#### SETTING OTHER VARIABLES -- see below for header of VCF-file
	print STDERR "Setting variables...\n";
	
	# File #1: a list of alternate variantIDs to harmonize the GWAS cohorts
	# Note: the alleles in the name are minor/major alleles
	my $vid = ""; # type 1: 'rs[xxxx]' or 'chr[X]:bp[XXXXX]:A1_A2'
	my $vid1 = ""; # type 2: 'chr[X]:bp[XXXXX]:A1_A2'
	my $vid2 = ""; # type 3: 'chr[X]:bp[XXXXX]:[I/D]_[D/I]'
	my $vid3 = ""; # type 4: 'chr[X]:bp[XXXXX]:R_[D/I]'
	
	# File #2: containing frequencies of the chosen reference and population
	my $chr = "";
	my $bp = "";
	my $REF = ""; # reference allele
	my $ALT = ""; # other allele
	my $AlleleA = ""; # reference allele, with [I/D] nomenclature
	my $AlleleB = ""; # other allele, with [I/D] nomenclature
	my $Minor = ""; # minor allele
	my $Major = ""; # major allele
	my $INFO = ""; # needed to grep additional variant information
	my $AF = ""; # ALT allele frequency!!!
	my $MAF = ""; # minor allele frequency based on the population specific AF
	my $ref_indel = "R";
	
	# File #3: a reference-file used as a reference to map, allign, and annotate all GWAS to during meta-analysis
	my $strand = "+"; # all these references are by definition on the PLUS(+)-strand
	my $chrstart = "";
	my $chrend = "";
	my $alleles = ""; # these will be the alt/ref
	my $variantclass = ""; # variant type
	my $variantfunction = "unknown"; # variant function
	
	### READING INPUT FILE
	print STDERR "\nReading input file...\n";
	if ($file =~ /.gz$/) {
		open(IN, "gunzip -c $file | grep -v '##' | ") or die " *** ERROR *** Cannot open pipe to [ $file ]!\n";
		} else {
			open(IN, "cat $file | grep -v '##' | ") or die " *** ERROR *** Cannot open [ $file ]!\n";
	}
	
	### CREATING OUTPUT FILE
	print STDERR "\nCreating output files...\n";
	my $output_info = $output . "." . $population . ".INFO.txt";
	my $output_freq = $output . "." . $population . ".FREQ.txt";
	my $output_func = $output . "." . $population . ".FUNC.txt";
	
	print STDERR "* File #1: a list of alternate variantIDs to harmonize the GWAS cohorts...\n";
	open(OUT_INFO, '>', $output_info) or die " *** ERROR *** Could not create the [ $output_info ] file!\n";
	print STDERR "* File #2: containing frequencies of the chosen reference and population...\n";
	open(OUT_FREQ, '>', $output_freq) or die " *** ERROR *** Could not create the [ $output_freq ] file!";
	print STDERR "* File #3: a reference-file used to map, allign, and annotate all GWAS to during meta-analysis...\n";
	open(OUT_FUNC, '>', $output_func) or die " *** ERROR *** Could not create the [ $output_func ] file!";
	
	print STDERR "* Create header...\n";
	print OUT_INFO "VariantID\tVariantID_alt1\tVariantID_alt2\tVariantID_alt3\n";
	print OUT_FREQ "VariantID\tCHR_REF\tBP_REF\tREF\tALT\tAlleleA\tAlleleB\tMinorAllele\tMajorAllele\tAF\tMAF\n";
	print OUT_FUNC "Chr\tChrStart\tChrEnd\tVariantID\tStrand\tAlleles\tVariantClass\tVariantFunction\n";
	
	print STDERR "* Looping over file to extract relevant data...\n";
	my $dummy=<IN>;
	my $tmp = "";
	while (my $row = <IN>) {
	### General part needed for all files
		chomp $row;
		my @vareach=split(/(?<!,)\t/,$row); # splitting based on tab '\t'
		$chr = $vareach[0]; # chromosome
		$bp = $vareach[1]; # base pair position
		$REF = $vareach[3]; # reference allele
		$ALT = $vareach[4]; # alternate allele
		$INFO = $vareach[7]; # info column -- refer to below for information
	
	### get allele frequencies
	if ( $INFO =~ m/(?:^|;)AF=([^;]*)/ ){
# 	print " ***DEBUG*** allele frequency = $1 for  [ $vareach[2] ].\n";
		$AF = $1;
  	} else {
  		print STDERR " *** WARNING *** Could not find the allele frequency for [ $vareach[2] ]. Check your reference-file.\n"; 
  		$AF = "NA";
  	}
		
	### get allele frequencies
	if ( $population eq "PAN" ){
# 		print " ***DEBUG*** Population: $population. So looking for AF in $INFO for $vareach[2]; should be: $1. \n";
		$tmp = $AF; 
		$AF = $tmp;
		
		} elsif ( $population eq "EUR" ){
			if ( $INFO =~ m/(?:^|;)EUR_AF=([^;]*)/ ){
# 			print " ***DEBUG*** Population: $population. So looking for EUR_AF in $INFO for $vareach[2]; should be: $1. \n";
			$AF = $1;
  			}
  			} elsif ( $population eq "AFR" ){
				if ($INFO =~ m/(?:^|;)EUR_AF=([^;]*)/){
# 				print " ***DEBUG*** Population: $population. So looking for AFR_AF in $INFO for $vareach[2]; should be: $1. \n";
				$AF = $1;
  				}
  				} elsif ( $population eq "AMR" ){
					if ($INFO =~ m/(?:^|;)EUR_AF=([^;]*)/){
# 					print " ***DEBUG*** Population: $population. So looking for AMR_AF in $INFO for $vareach[2]; should be: $1. \n";
					$AF = $1;
  					}
  					} elsif ( $population eq "ASN" ){
						if ($INFO =~ m/(?:^|;)EUR_AF=([^;]*)/){
# 						print " ***DEBUG*** Population: $population. So looking for ASN_AF in $INFO for $vareach[2]; should be: $1. \n";
						$AF = $1;
  						}
  						} else {
  	  						print STDERR " *** WARNING *** Could not find the population allele frequency for [ $vareach[2] ] and population [ $population ] where info: $INFO. Check your reference-file.\n"; 
  							$tmp = $AF; 
							$AF = $tmp;
  	}

	### adjust the key variantID type 1 -- # 'rs[xxxx]' or 'chr[X]:bp[XXXXX]:A1_A2'
	if( looks_like_number($AF) ) {
		if ( $vareach[2] =~ m/(\.)/ and $AF < 0.50 ){
	  	$vid = "chr$chr\:$bp\:$ALT\_$REF";
	  } elsif ( $vareach[2] =~ m/(\.)/ and $AF > 0.50 ) {
	  		$vid = "chr$chr\:$bp\:$REF\_$ALT";
	  		}	else {
	  				$vid = $vareach[2]; # the variant has a code either "rs", or "esv", or similar
	  				}
	} else { 
		$vid = $vareach[2]; # the variant has a code either "rs", or "esv", or similar
		}
		
	### SPECIFIC TO FILE #1
	### adjust the key variantID type 2 -- # 'chr[X]:bp[XXXXX]:A1_A2'
	if( looks_like_number($AF) ) {
	  if ( length($REF) == 1 and length($ALT) == 1 and $AF < 0.50 ){ # meaning REF is a SNP, but is *NOT* the minor allele!
	  	$vid1 = "chr$chr\:$bp\:$ALT\_$REF";
	  	} elsif ( length($REF) > 1 and $AF < 0.50 ){ # meaning REF = INSERTION, but is *NOT* the minor allele!
	  			$vid1 = "chr$chr\:$bp\:$ALT\_$REF";
	  			} elsif ( length($REF) > 1  and $AF > 0.50 ){ # meaning REF = INSERTION, but is the minor allele!
	  				$vid1 = "chr$chr\:$bp\:$REF\_$ALT";
	  				} elsif ( length($ALT) > 1 and $AF < 0.50 ){ # meaning ALT = INSERTION, but is the minor allele!
			  			$vid1 = "chr$chr\:$bp\:$ALT\_$REF";
	  					} elsif ( length($ALT) > 1 and $AF > 0.50 ){ # meaning ALT = INSERTION, but is *NOT* the minor allele!
	  						$vid1 = "chr$chr\:$bp\:$REF\_$ALT";
	  						} else { 
	  							$vid1 = "chr$chr\:$bp\:$REF\_$ALT"; # meaning REF is a SNP, but is the minor allele!
	  							}
	} else { 
		$vid1 = "chr$chr\:$bp\:$REF\_$ALT"; # meaning REF is a SNP, but is the minor allele!
		}
	
	### adjust the key variantID type 3 -- # 'chr[X]:bp[XXXXX]:[I/D]_[D/I]'
	if( looks_like_number($AF) ) {
	  if ( length($REF) == 1 and length($ALT) == 1 and $AF < 0.50 ){ # meaning REF is a SNP, but is *NOT* the minor allele!
	  	$vid2 = "chr$chr\:$bp\:$ALT\_$REF";
	  } elsif ( length($REF) > 1 and $AF < 0.50 ){ # meaning REF = I, but is *NOT* the minor allele!
	  		$vid2 = "chr$chr\:$bp\:D\_I";
	  		} elsif ( length($REF) > 1 and $AF > 0.50 ){ # meaning REF = I, but is the minor allele!
	  			$vid2 = "chr$chr\:$bp\:I\_D";
	  			} elsif ( length($ALT) > 1 and $AF < 0.50 ){ # meaning ALT = I, but is the minor allele!
		  			$vid2 = "chr$chr\:$bp\:I\_D";
	  				} elsif ( length($ALT) > 1 and $AF > 0.50 ){ # meaning ALT = I, but is *NOT* the minor allele!
	  					$vid2 = "chr$chr\:$bp\:D\_I";
	  					} else { 
	  						$vid2 = "chr$chr\:$bp\:$REF\_$ALT"; # meaning REF is a SNP, but is the minor allele!
	  						}
	} else { 
		$vid2 = "chr$chr\:$bp\:$REF\_$ALT"; # meaning REF is a SNP, but is the minor allele!
		}
	
	### adjust the key variantID type 4 -- # 'chr[X]:bp[XXXXX]:R_[D/I]'
	if( looks_like_number($AF) ) {
	  if ( length($REF) == 1 and length($ALT) == 1 and $AF < 0.50 ){ # meaning REF is a SNP, but is *NOT* the minor allele!
	  	$vid3 = "chr$chr\:$bp\:$ALT\_$REF";
	  } elsif ( length($REF) > 1 and $AF < 0.50 ){ # meaning REF = I, but is *NOT* the minor allele!
	  		$vid3 = "chr$chr\:$bp\:D\_$ref_indel";
	  		} elsif ( length($REF) > 1 and $AF > 0.50 ){ # meaning REF = I, but is the minor allele!
	  			$vid3 = "chr$chr\:$bp\:$ref_indel\_D";
	  			} elsif ( length($ALT) > 1 and $AF < 0.50 ){ # meaning ALT = I, but is the minor allele!
		  			$vid3 = "chr$chr\:$bp\:I\_$ref_indel";
	  				} elsif ( length($ALT) > 1 and $AF > 0.50 ){ # meaning ALT = I, but is *NOT* the minor allele!
	  					$vid3 = "chr$chr\:$bp\:$ref_indel\_I";
	  					} else { 
	  						$vid3 = "chr$chr\:$bp\:$REF\_$ALT"; # meaning REF is a SNP, but is the minor allele!
	  						}
	} else { 
		$vid3 = "chr$chr\:$bp\:$REF\_$ALT"; # meaning REF is a SNP, but is the minor allele!
		}
			
	### SPECIFIC TO FILE #2
	### adjust alleleA and alleleB when variantID is an INDEL
	if ( length($REF) == 1 and length($ALT) == 1 ){
		$AlleleA = $vareach[3];
		$AlleleB = $vareach[4];
	} elsif ( length($REF) > 1 ){ 
		$AlleleA = "I";
		$AlleleB = "D";
		} elsif ( length($ALT) > 1 ){ 
			$AlleleA = "D";
			$AlleleB = "I";
			} else { 
				$AlleleA = $vareach[3];
				$AlleleB = $vareach[4];
	}
	
	## adjust Minor and Major when ALT is the minor allele
	if( looks_like_number($AF) ) {
		if ( $AF < 0.50 ){
			$Minor = $vareach[4]; # ALT allele is the minor allele
			$Major = $vareach[3];
		} elsif ( $AF > 0.50 ) {
			$Minor = $vareach[3]; # REF allele is the minor allele
			$Major = $vareach[4]; #
			} else {
				$Minor = $vareach[3]; # REF allele is the minor allele
				$Major = $vareach[4]; #
		}
	} else { 
		$Minor = $vareach[3]; # REF allele is the minor allele
		$Major = $vareach[4]; #
	}
		
	## get minor allele frequencies based on AF
	if ( looks_like_number($AF) ) {
		if ( $AF < 0.50 ){
			$MAF = $AF;
		} else {
			$MAF = 1-$AF;
		} 
	} else { 
		$tmp = $AF; 
		$AF = $tmp;
		$MAF = $tmp;
	}
			
	### SPECIFIC TO FILE #3
	### get alleles
	$alleles = $REF . "/" . $ALT; # REF allele/ALT alleles
		
	### get variant length
	if (length($REF) == 1 and length($ALT) == 1){
		$chrstart = $bp; # base pair start position
		$chrend = $bp; # base pair end position
	
	} elsif (length($REF) > 1){ 
		$chrstart = $bp; # base pair start position
		$chrend = $bp + length($REF); # base pair end position
		
		} elsif (length($ALT) > 1){ 
		$chrstart = $bp; # base pair start position
		$chrend = $bp + length($ALT); # base pair end position
		
			} else { 
				$chrstart = $bp; # base pair start position
				$chrend = $bp; # base pair end position
	}
	
	### get variant type
	if ( $INFO =~ m/VT\=(SNP.*?)/ ){
		$variantclass = "SNP";
	} elsif ( $INFO =~ m/VT\=(INDEL.*?)/ ){
		$variantclass = "INDEL";
		} else {
			$variantclass = "NA";
	}
	
	print OUT_INFO "$vid\t$vid1\t$vid2\t$vid3\n";
	print OUT_FREQ "$vid\t$chr\t$bp\t$REF\t$ALT\t$AlleleA\t$AlleleB\t$Minor\t$Major\t$AF\t$MAF\n";
	print OUT_FUNC "$chr\t$chrstart\t$chrend\t$vid\t$strand\t$alleles\t$variantclass\t$variantfunction\n";
	}
	### Closing output files
	close OUT_INFO;
	close OUT_FREQ;
	close OUT_FUNC;
	
	### Closing input file
	close IN;


### 1000G phase 3, version 5
} elsif ( $reference eq "1Gp3" ) {
	#### SETTING OTHER VARIABLES -- see below for header of VCF-file
	print STDERR "Setting variables...\n";
	
	# File #1: a list of alternate variantIDs to harmonize the GWAS cohorts
	# Note: the alleles in the name are minor/major alleles
	my $vid = ""; # type 1: 'rs[xxxx]' or 'chr[X]:bp[XXXXX]:A1_A2'
	my $vid1 = ""; # type 2: 'chr[X]:bp[XXXXX]:A1_A2'
	my $vid2 = ""; # type 3: 'chr[X]:bp[XXXXX]:[I/D]_[D/I]'
	my $vid3 = ""; # type 4: 'chr[X]:bp[XXXXX]:R_[D/I]'
	
	# File #2: containing frequencies of the chosen reference and population
	my $chr = "";
	my $bp = "";
	my $REF = ""; # reference allele
	my $ALT = ""; # other allele
	my $AlleleA = ""; # reference allele, with [I/D] nomenclature
	my $AlleleB = ""; # other allele, with [I/D] nomenclature
	my $Minor = ""; # minor allele
	my $Major = ""; # major allele
	my $INFO = ""; # needed to grep additional variant information
	my $AF = ""; # ALT allele frequency!!!
	my $AF1 = ""; # ALT allele frequency!!!
	my $AF2 = ""; # ALT allele frequency!!!
	my $MAF = ""; # minor allele frequency based on the population specific AF
	my $ref_indel = "R";
	
	# File #3: a reference-file used as a reference to map, allign, and annotate all GWAS to during meta-analysis
	my $strand = "+"; # all these references are by definition on the PLUS(+)-strand
	my $chrstart = "";
	my $chrend = "";
	my $alleles = ""; # these will be the alt/ref
	my $variantclass = ""; # variant type
	my $variantfunction = "unknown"; # variant function
	
	### READING INPUT FILE
	print STDERR "\nReading input file...\n";
	if ($file =~ /.gz$/) {
		open(IN, "gunzip -c $file | grep -v '##' | ") or die " *** ERROR *** Cannot open pipe to [ $file ]!\n";
		} else {
			open(IN, "cat $file | grep -v '##' | ") or die " *** ERROR *** Cannot open [ $file ]!\n";
	}
	
	### CREATING OUTPUT FILE
	print STDERR "\nCreating output files...\n";
	my $output_info = $output . "." . $population . ".INFO.txt";
	my $output_freq = $output . "." . $population . ".FREQ.txt";
	my $output_func = $output . "." . $population . ".FUNC.txt";
	
	print STDERR "* File #1: a list of alternate variantIDs to harmonize the GWAS cohorts...\n";
	open(OUT_INFO, '>', $output_info) or die " *** ERROR *** Could not create the [ $output_info ] file!\n";
	print STDERR "* File #2: containing frequencies of the chosen reference and population...\n";
	open(OUT_FREQ, '>', $output_freq) or die " *** ERROR *** Could not create the [ $output_freq ] file!";
	print STDERR "* File #3: a reference-file used to map, allign, and annotate all GWAS to during meta-analysis...\n";
	open(OUT_FUNC, '>', $output_func) or die " *** ERROR *** Could not create the [ $output_func ] file!";
	
	print STDERR "* Create header...\n";
	print OUT_INFO "VariantID\tVariantID_alt1\tVariantID_alt2\tVariantID_alt3\n";
	print OUT_FREQ "VariantID\tCHR_REF\tBP_REF\tREF\tALT\tAlleleA\tAlleleB\tMinorAllele\tMajorAllele\tAF\tMAF\n";
	print OUT_FUNC "Chr\tChrStart\tChrEnd\tVariantID\tStrand\tAlleles\tVariantClass\tVariantFunction\n";
	
	print STDERR "* Looping over file to extract relevant data...\n";
	my $dummy=<IN>;
	my $tmp = "";
	while (my $row = <IN>) {
	### General part needed for all files
		chomp $row;
		my @vareach=split(/(?<!,)\t/,$row); # splitting based on tab '\t'
		$chr = $vareach[0]; # chromosome
		$bp = $vareach[1]; # base pair position
		$REF = $vareach[3]; # reference allele
		$ALT = $vareach[4]; # alternate allele
		$INFO = $vareach[7]; # info column -- refer to below for information
	
	### get allele frequencies
	if ( $INFO =~ m/(?:^|;)AF=([^;]*)/ ){
# 	print " ***DEBUG*** allele frequency = $1 for  [ $vareach[2] ].\n";
		$AF = $1;
  	} else {
  		print STDERR " *** WARNING *** Could not find the allele frequency for [ $vareach[2] ]. Check your reference-file.\n"; 
  		$AF = "NA";
  	}
		
	### get allele frequencies
	if ( $population eq "PAN" ){
# 		print " ***DEBUG*** Population: $population. So looking for AF in $INFO for $vareach[2]; should be: $1. \n";
		$tmp = $AF; 
		$AF = $tmp;
		
		} elsif ( $population eq "EUR" ){
			if ( $INFO =~ m/(?:^|;)EUR_AF=([^;]*)/ ){
# 			print " ***DEBUG*** Population: $population. So looking for EUR_AF in $INFO for $vareach[2]; should be: $1. \n";
			$AF = $1;
  			}
  			} elsif ( $population eq "AFR" ){
				if ($INFO =~ m/(?:^|;)EUR_AF=([^;]*)/){
# 				print " ***DEBUG*** Population: $population. So looking for AFR_AF in $INFO for $vareach[2]; should be: $1. \n";
				$AF = $1;
  				}
  				} elsif ( $population eq "AMR" ){
					if ($INFO =~ m/(?:^|;)EUR_AF=([^;]*)/){
# 					print " ***DEBUG*** Population: $population. So looking for AMR_AF in $INFO for $vareach[2]; should be: $1. \n";
					$AF = $1;
  					}
#   					} elsif ( $population eq "ASN" ){
# 						if ($INFO =~ m/(?:^|;)EUR_AF=([^;]*)/){
# # 						print " ***DEBUG*** Population: $population. So looking for ASN_AF in $INFO for $vareach[2]; should be: $1. \n";
# 						$AF = $1;
#   						}
  					} elsif ( $population eq "EAS" ){
						if ($INFO =~ m/(?:^|;)EUR_AF=([^;]*)/){
# 						print " ***DEBUG*** Population: $population. So looking for ASN_AF in $INFO for $vareach[2]; should be: $1. \n";
						$AF = $1;
  						}
  						} elsif ( $population eq "SAS" ){
						if ($INFO =~ m/(?:^|;)EUR_AF=([^;]*)/){
# 						print " ***DEBUG*** Population: $population. So looking for ASN_AF in $INFO for $vareach[2]; should be: $1. \n";
						$AF = $1;
  							}
  							} else {
  	  						print STDERR " *** WARNING *** Could not find the population allele frequency for [ $vareach[2] ] and population [ $population ] where info: $INFO. Check your reference-file.\n"; 
  							$tmp = $AF; 
							$AF = $tmp;
  	}

my $split_info= (split /,/, $ALT);
my $multisplit= (split /,/, $ALT); 
my @afsplit= (split /,/, $AF);
my $AF1 = $afsplit[0];
my $AF2 = $afsplit[1];
my $AF3 = $afsplit[2];
my $AF4 = $afsplit[3];
my $AF_INFO = $AF;

### adjust the key variantID type 1 -- # 'rs[xxxx]' or 'chr[X]:bp[XXXXX]:A1_A2'
while ($split_info >= 1) {

	foreach (split /,/, $ALT) {

    if ($multisplit == 4){
     	if ($split_info == 4) {
     	$AF_INFO = $AF1;
     	} elsif ($split_info == 3) {
     	$AF_INFO = $AF2;
     	} elsif ($split_info == 2) {
     	$AF_INFO = $AF3;
     	} else {
     	$AF_INFO = $AF4;
     		}
     	if ($ALT =~ $Minor) {
     		$Minor = "$_";
     	} elsif ($ALT =~ $Major) {
    		$Major = "$_";
     		}
     		
     } elsif ($multisplit == 3){
     		if ($split_info == 3) {
     		$AF_INFO = $AF1;
     		} elsif ($split_info == 2) {
     		$AF_INFO = $AF2;
     		} else {
     		$AF_INFO = $AF3;
     		}
     		 if ($ALT =~ $Minor) {
     		$Minor = "$_";
     			} elsif ($ALT =~ $Major) {
    			 $Major = "$_";
     		}
     }
     
     		elsif ($multisplit == 2){
     			if ($split_info == 2) {
     			$AF_INFO = $AF1;
     			} elsif ($split_info == 1) {
     			$AF_INFO = $AF2;
     			}    
      		  if ($Minor =~ m/$_/) {
  			   $Minor = "$_";
  			   } else {
  			   $Major = "$_";
    			 }
     }
     if ($ALT !~ m/,/){
		$AF_INFO = $AF1;
		}
		
     $split_info -= 1;
     my $ALT_INFO = "$_";
     
	if( looks_like_number($AF_INFO) ) {
		if ( $vareach[2] =~ m/(\.)/ and $AF_INFO < 0.50 ){
	  	$vid = "chr$chr\:$bp\:$ALT_INFO\_$REF";
	  } elsif ( $vareach[2] =~ m/(\.)/ and $AF_INFO > 0.50 ) {
	  		$vid = "chr$chr\:$bp\:$REF\_$ALT_INFO";
	  		}	else {
	  				$vid = $vareach[2]; # the variant has a code either "rs", or "esv", or similar
	  				}
	} else { 
		$vid = $vareach[2]; # the variant has a code either "rs", or "esv", or similar
		}
		
### SPECIFIC TO FILE #1
	### adjust the key variantID type 2 -- # 'chr[X]:bp[XXXXX]:A1_A2'
	
 if( looks_like_number($AF_INFO) ) {
	  if ( length($REF) == 1 and length($ALT) == 1 and $AF_INFO < 0.50 ){ # meaning REF is a SNP, but is *NOT* the minor allele!
	  	$vid1 = "chr$chr\:$bp\:$ALT_INFO\_$REF";
	  	} elsif ( length($REF) > 1 and $AF_INFO < 0.50 ){ # meaning REF = INSERTION, but is *NOT* the minor allele!
	  			$vid1 = "chr$chr\:$bp\:$ALT_INFO\_$REF";
	  			} elsif ( length($REF) > 1  and $AF_INFO > 0.50 ){ # meaning REF = INSERTION, but is the minor allele!
	  				$vid1 = "chr$chr\:$bp\:$REF\_$ALT_INFO";
	  				} elsif ( length($ALT) > 1 and $AF_INFO < 0.50 ){ # meaning ALT = INSERTION, but is the minor allele!
			  			$vid1 = "chr$chr\:$bp\:$ALT_INFO\_$REF";
	  					} elsif ( length($ALT) > 1 and $AF_INFO > 0.50 ){ # meaning ALT = INSERTION, but is *NOT* the minor allele!
	  						$vid1 = "chr$chr\:$bp\:$REF\_$ALT_INFO";
	  						} else {
	  							$vid1 = "chr$chr\:$bp\:$REF\_$ALT_INFO"; # meaning REF is a SNP, but is the minor allele!
	  							}
	} else {
		$vid1 = "chr$chr\:$bp\:$REF\_$ALT_INFO"; # meaning REF is a SNP, but is the minor allele!
		}
	
	
	### adjust the key variantID type 3 -- # 'chr[X]:bp[XXXXX]:[I/D]_[D/I]'
	if( looks_like_number($AF_INFO) ) {
	  if ( length($REF) == 1 and length($ALT) == 1 and $AF_INFO < 0.50 ){ # meaning REF is a SNP, but is *NOT* the minor allele!
	  	$vid2 = "chr$chr\:$bp\:$ALT_INFO\_$REF";
	  } elsif ( length($REF) > 1 and $AF_INFO < 0.50 ){ # meaning REF = I, but is *NOT* the minor allele!
	  		$vid2 = "chr$chr\:$bp\:D\_I";
	  		} elsif ( length($REF) > 1 and $AF_INFO > 0.50 ){ # meaning REF = I, but is the minor allele!
	  			$vid2 = "chr$chr\:$bp\:I\_D";
	  			} elsif ( length($ALT) > 1 and $AF_INFO < 0.50 ){ # meaning ALT = I, but is the minor allele!
		  			$vid2 = "chr$chr\:$bp\:I\_D";
	  				} elsif ( length($ALT) > 1 and $AF_INFO > 0.50 ){ # meaning ALT = I, but is *NOT* the minor allele!
	  					$vid2 = "chr$chr\:$bp\:D\_I";
	  					} else {
	  						$vid2 = "chr$chr\:$bp\:$REF\_$ALT_INFO"; # meaning REF is a SNP, but is the minor allele!
	  						}
	} else {
		$vid2 = "chr$chr\:$bp\:$REF\_$ALT_INFO"; # meaning REF is a SNP, but is the minor allele!
		}
	
	
	### adjust the key variantID type 4 -- # 'chr[X]:bp[XXXXX]:R_[D/I]'
	if( looks_like_number($AF_INFO) ) {
	  if ( length($REF) == 1 and length($ALT) == 1 and $AF_INFO < 0.50 ){ # meaning REF is a SNP, but is *NOT* the minor allele!
	  	$vid3 = "chr$chr\:$bp\:$ALT_INFO\_$REF";
	  } elsif ( length($REF) > 1 and $AF_INFO < 0.50 ){ # meaning REF = I, but is *NOT* the minor allele!
	  		$vid3 = "chr$chr\:$bp\:D\_$ref_indel";
	  		} elsif ( length($REF) > 1 and $AF_INFO > 0.50 ){ # meaning REF = I, but is the minor allele!
	  			$vid3 = "chr$chr\:$bp\:$ref_indel\_D";
	  			} elsif ( length($ALT) > 1 and $AF_INFO < 0.50 ){ # meaning ALT = I, but is the minor allele!
		  			$vid3 = "chr$chr\:$bp\:I\_$ref_indel";
	  				} elsif ( length($ALT) > 1 and $AF_INFO > 0.50 ){ # meaning ALT = I, but is *NOT* the minor allele!
	  					$vid3 = "chr$chr\:$bp\:$ref_indel\_I";
	  					} else {
	  						$vid3 = "chr$chr\:$bp\:$REF\_$ALT_INFO"; # meaning REF is a SNP, but is the minor allele!
	  						}
	} else {
		$vid3 = "chr$chr\:$bp\:$REF\_$ALT_INFO"; # meaning REF is a SNP, but is the minor allele!
		}
	# generate INFO file	
	print OUT_INFO "$vid1\t$vid\t$vid2\t$vid3\n";	
        }
	}
	
	### SPECIFIC TO FILE #2
	### adjust alleleA and alleleB when variantID is an INDEL
	if ( length($REF) == 1 and length($ALT) == 1 ){
		$AlleleA = $vareach[3];
		$AlleleB = $vareach[4];
	} elsif ( length($REF) > 1 ){ 
		$AlleleA = "I";
		$AlleleB = "D";
		} elsif ( length($ALT) > 1 ){ 
			$AlleleA = "D";
			$AlleleB = "I";
			} else { 
				$AlleleA = $vareach[3];
				$AlleleB = $vareach[4];
	}
	
	### adjust Minor and Major when ALT is the minor allele
	if( looks_like_number($AF) ) {
		if ( $AF < 0.50 ){
			$Minor = $vareach[4]; # ALT allele is the minor allele
			$Major = $vareach[3];
		} elsif ( $AF > 0.50 ) {
			$Minor = $vareach[3]; # REF allele is the minor allele
			$Major = $vareach[4]; #
			} else {
				$Minor = $vareach[3]; # REF allele is the minor allele
				$Major = $vareach[4]; #
		}
	} else { 
		$Minor = $vareach[3]; # REF allele is the minor allele
		$Major = $vareach[4]; #
	}
		
	## get minor allele frequencies based on AF
	if ( looks_like_number($AF) ) {
		if ( $AF < 0.50 ){
			$MAF = $AF;
		} else {
			$MAF = 1-$AF;
		} 
	} else { 
		$tmp = $AF; 
		$AF = $tmp;
		$MAF = $tmp;
	}	

my $split_freq = (split /,/, $ALT);
my $AF_FREQ = $AF;
	
	### generate FREQ output file
	while ($split_freq >= 1) {

    foreach (split /,/, $ALT) {

    if ($multisplit == 4){
     	if ($split_freq == 4) {
     	$AF_FREQ = $AF1;
     		if ( $AF1 < 0.50 ){
			$MAF = $AF1;
			} else {
			$MAF = 1-$AF1;
			} 
     	} elsif ($split_freq == 3) {
     	$AF_FREQ = $AF2;
     		if ( $AF2 < 0.50 ){
			$MAF = $AF2;
			} else {
			$MAF = 1-$AF2;
		} 
     	} elsif ($split_freq == 2) {
     	$AF_FREQ = $AF3;
     		if ( $AF3 < 0.50 ){
			$MAF = $AF3;
			} else {
			$MAF = 1-$AF3;
			} 
     	} else {
     	$AF_FREQ = $AF4;
     		if ( $AF4 < 0.50 ){
			$MAF = $AF4;
			} else {
			$MAF = 1-$AF4;
			} 
     		}
     	if ($ALT =~ $Minor) {
     		$Minor = "$_";
     	} elsif ($ALT =~ $Major) {
    		$Major = "$_";
     		}
     		
     } elsif ($multisplit == 3){
     		if ($split_freq == 3) {
     		$AF_FREQ = $AF1;
     			if ( $AF1 < 0.50 ){
				$MAF = $AF1;
				} else {
				$MAF = 1-$AF1;
				} 
     		} elsif ($split_freq == 2) {
     		$AF_FREQ = $AF2;
     			if ( $AF2 < 0.50 ){
				$MAF = $AF2;
				} else {
				$MAF = 1-$AF2;
				} 
     		} else {
     		$AF_FREQ = $AF3;
     			if ( $AF3 < 0.50 ){
				$MAF = $AF3;
				} else {
				$MAF = 1-$AF3;
			} 
     		}
     		 if ($ALT =~ $Minor) {
     		$Minor = "$_";
     			} elsif ($ALT =~ $Major) {
    			 $Major = "$_";
     		}
     }
     
     		elsif ($multisplit == 2){
     			if ($split_freq == 2) {
     			$AF_FREQ = $AF1;
     				if ( $AF1 < 0.50 ){
					$MAF = $AF1;
					} else {
					$MAF = 1-$AF1;
				} 
     			} elsif ($split_freq == 1) {
     			$AF_FREQ = $AF2;
					if ( $AF2 < 0.50 ){
					$MAF = $AF2;
					} else {
					$MAF = 1-$AF2;
				}
     			}    
      		  if ($Minor =~ m/$_/) {
  			   $Minor = "$_";
  			   } else {
  			   $Major = "$_";
    			 }
     }
     if ($ALT !~ m/,/){
		$AF_FREQ = $AF1;
		if ( $AF1 < 0.50 ){
			$MAF = $AF1;
		} else {
			$MAF = 1-$AF1;
			} 
		}
		
     $split_freq -= 1;
     my $ALT_FREQ = "$_";     

	  if( looks_like_number($AF_FREQ) ) {
	  if ( length($REF) == 1 and length($ALT) == 1 and $AF_FREQ < 0.50 ){ # meaning REF is a SNP, but is *NOT* the minor allele!
	  	$vid1 = "chr$chr\:$bp\:$ALT_FREQ\_$REF";
	  	} elsif ( length($REF) > 1 and $AF_FREQ < 0.50 ){ # meaning REF = INSERTION, but is *NOT* the minor allele!
	  			$vid1 = "chr$chr\:$bp\:$ALT_FREQ\_$REF";
	  			} elsif ( length($REF) > 1  and $AF_FREQ > 0.50 ){ # meaning REF = INSERTION, but is the minor allele!
	  				$vid1 = "chr$chr\:$bp\:$REF\_$ALT_FREQ";
	  				} elsif ( length($ALT) > 1 and $AF_FREQ < 0.50 ){ # meaning ALT = INSERTION, but is the minor allele!
			  			$vid1 = "chr$chr\:$bp\:$ALT_FREQ\_$REF";
	  					} elsif ( length($ALT) > 1 and $AF_FREQ > 0.50 ){ # meaning ALT = INSERTION, but is *NOT* the minor allele!
	  						$vid1 = "chr$chr\:$bp\:$REF\_$ALT_FREQ";
	  						} else {
	  							$vid1 = "chr$chr\:$bp\:$REF\_$ALT_FREQ"; # meaning REF is a SNP, but is the minor allele!
	  							}
	} else {
		$vid1 = "chr$chr\:$bp\:$REF\_$ALT_FREQ"; # meaning REF is a SNP, but is the minor allele!
		}
   
    print OUT_FREQ "$vid1\t$chr\t$bp\t$REF\t$ALT_FREQ\t$AlleleA\t$AlleleB\t$Minor\t$Major\t$AF_FREQ\t$MAF\n"; 
    }
	}

	### SPECIFIC TO FILE #3
	### get alleles
 	$alleles = $REF . "/" . $ALT ; # REF allele/ALT alleles
		
	### get variant length
	if (length($REF) == 1 and length($ALT) == 1){
		$chrstart = $bp; # base pair start position
		$chrend = $bp; # base pair end position
	
	} elsif (length($REF) > 1){ 
		$chrstart = $bp; # base pair start position
		$chrend = $bp + length($REF); # base pair end position
		
		} elsif (length($ALT) > 1){ 
		$chrstart = $bp; # base pair start position
		$chrend = $bp + length($ALT); # base pair end position
		
			} else { 
				$chrstart = $bp; # base pair start position
				$chrend = $bp; # base pair end position
	}
	
	### get variant type
	if ( $INFO =~ m/VT\=(SNP.*?)/ ){
		$variantclass = "SNP";
	} elsif ( $INFO =~ m/VT\=(INDEL.*?)/ ){
		$variantclass = "INDEL";
	} elsif ( $INFO =~ m/SV/ ){
  		$variantclass = "SV";
		} else {
			$variantclass = "NA";
	}

	### add information on CNV/multi-allelic variants
	if ( $INFO =~ m/MULTI_ALLELIC/ ){
  		$variantfunction = "multi-allelic";
	} elsif ( $INFO =~ m/CNV/ ){
  		$variantfunction = "Copy-number variant";
	} elsif ( $INFO =~ m/LINE1/ ){
  		$variantfunction = "line-1";
  	} elsif ( $INFO =~ m/EX_TARGET/ ){
  		$variantfunction = "ex-target";
  	} elsif ( $INFO =~ m/ALU/ ){
  		$variantfunction = "ALU";
  	} elsif ( $INFO =~ m/SVA/ ){
  		$variantfunction = "SVA";
  	} elsif ( $INFO =~ m/MT/ ){
  		$variantfunction = "MT";
  	} elsif ( $INFO =~ m/INV/ ){
  		$variantfunction = "inversion";
	} else {
			$variantfunction = "unknown";
	}
	
my $split_func = (split /,/, $ALT);
my $AF_FUNC = $AF;	
	
	### generate FUNC output file
	while ($split_func >= 1) {

	foreach (split /,/, $ALT) {

    if ($multisplit == 4){
     	if ($split_func == 4) {
     	$AF_FUNC = $AF1;
     	} elsif ($split_func == 3) {
     	$AF_FUNC = $AF2;
     	} elsif ($split_func == 2) {
     	$AF_FUNC = $AF3;
     	} else {
     	$AF_FUNC = $AF4;
     		}
     } elsif ($multisplit == 3){
     		if ($split_func == 3) {
     		$AF_FUNC = $AF1;
     		} elsif ($split_func == 2) {
     		$AF_FUNC = $AF2;
     		} else {
     		$AF_FUNC = $AF3;
     		}
     }
     
     		elsif ($multisplit == 2){
     			if ($split_func == 2) {
     			$AF_FUNC = $AF1;
     			} elsif ($split_func == 1) {
     			$AF_FUNC = $AF2;
     			}    
     }
     if ($ALT !~ m/,/){
		$AF_FUNC = $AF1;
		}
		
     $split_func -= 1;
     my $ALT_FUNC = "$_";
     
	$alleles = $REF . "/" . $ALT_FUNC ; # REF allele/ALT alleles
	 if( looks_like_number($AF_FUNC) ) {
	  if ( length($REF) == 1 and length($ALT) == 1 and $AF_FUNC < 0.50 ){ # meaning REF is a SNP, but is *NOT* the minor allele!
	  	$vid1 = "chr$chr\:$bp\:$ALT_FUNC\_$REF";
	  	} elsif ( length($REF) > 1 and $AF_FUNC < 0.50 ){ # meaning REF = INSERTION, but is *NOT* the minor allele!
	  			$vid1 = "chr$chr\:$bp\:$ALT_FUNC\_$REF";
	  			} elsif ( length($REF) > 1  and $AF_FUNC > 0.50 ){ # meaning REF = INSERTION, but is the minor allele!
	  				$vid1 = "chr$chr\:$bp\:$REF\_$ALT_FUNC";
	  				} elsif ( length($ALT) > 1 and $AF_FUNC < 0.50 ){ # meaning ALT = INSERTION, but is the minor allele!
			  			$vid1 = "chr$chr\:$bp\:$ALT_FUNC\_$REF";
	  					} elsif ( length($ALT) > 1 and $AF_FUNC > 0.50 ){ # meaning ALT = INSERTION, but is *NOT* the minor allele!
	  						$vid1 = "chr$chr\:$bp\:$REF\_$ALT_FUNC";
	  						} else {
	  							$vid1 = "chr$chr\:$bp\:$REF\_$ALT_FUNC"; # meaning REF is a SNP, but is the minor allele!
	  							}
	} else {
		$vid1 = "chr$chr\:$bp\:$REF\_$ALT_FUNC"; # meaning REF is a SNP, but is the minor allele!
		}
	print OUT_FUNC "$chr\t$chrstart\t$chrend\t$vid1\t$strand\t$alleles\t$variantclass\t$variantfunction\n";
	}
	}	
	}
	
	### Closing output files
	close OUT_INFO;
	close OUT_FREQ;
	close OUT_FUNC;
	
	### Closing input file
	close IN;


### 1000G phase 3, version 5 + GoNL5
} elsif ( $reference eq "1Gp3GONL5" ) {
	#### SETTING OTHER VARIABLES -- see below for header of VCF-file
	print STDERR "Setting variables...\n";
	
	# File #1: a list of alternate variantIDs to harmonize the GWAS cohorts
	# Note: the alleles in the name are minor/major alleles
	my $vid = ""; # type 1: 'rs[xxxx]' or 'chr[X]:bp[XXXXX]:A1_A2'
	my $vid1 = ""; # type 2: 'chr[X]:bp[XXXXX]:A1_A2'
	my $vid2 = ""; # type 3: 'chr[X]:bp[XXXXX]:[I/D]_[D/I]'
	my $vid3 = ""; # type 4: 'chr[X]:bp[XXXXX]:R_[D/I]'
	
	# File #2: containing frequencies of the chosen reference and population
	my $chr = "";
	my $bp = "";
	my $REF = ""; # reference allele
	my $ALT = ""; # other allele
	my $AlleleA = ""; # reference allele, with [I/D] nomenclature
	my $AlleleB = ""; # other allele, with [I/D] nomenclature
	my $Minor = ""; # minor allele
	my $Major = ""; # major allele
	my $INFO = ""; # needed to grep additional variant information
	my $AF = ""; # ALT allele frequency!!!
	my $MAF = ""; # minor allele frequency based on the population specific AF
	my $ref_indel = "R";
	
	# File #3: a reference-file used as a reference to map, allign, and annotate all GWAS to during meta-analysis
	my $strand = "+"; # all these references are by definition on the PLUS(+)-strand
	my $chrstart = "";
	my $chrend = "";
	my $alleles = ""; # these will be the alt/ref
	my $variantclass = ""; # variant type
	my $variantfunction = "unknown"; # variant function
	
	### READING INPUT FILE
	print STDERR "\nReading input file...\n";
	if ($file =~ /.gz$/) {
		open(IN, "gunzip -c $file | grep -v '##' | ") or die " *** ERROR *** Cannot open pipe to [ $file ]!\n";
		} else {
			open(IN, "cat $file | grep -v '##' | ") or die " *** ERROR *** Cannot open [ $file ]!\n";
	}
	
	### CREATING OUTPUT FILE
	print STDERR "\nCreating output files...\n";
	my $output_info = $output . "." . $population . ".INFO.txt";
	my $output_freq = $output . "." . $population . ".FREQ.txt";
	my $output_func = $output . "." . $population . ".FUNC.txt";
	
	print STDERR "* File #1: a list of alternate variantIDs to harmonize the GWAS cohorts...\n";
	open(OUT_INFO, '>', $output_info) or die " *** ERROR *** Could not create the [ $output_info ] file!\n";
	print STDERR "* File #2: containing frequencies of the chosen reference and population...\n";
	open(OUT_FREQ, '>', $output_freq) or die " *** ERROR *** Could not create the [ $output_freq ] file!";
	print STDERR "* File #3: a reference-file used to map, allign, and annotate all GWAS to during meta-analysis...\n";
	open(OUT_FUNC, '>', $output_func) or die " *** ERROR *** Could not create the [ $output_func ] file!";
	
	print STDERR "* Create header...\n";
	print OUT_INFO "VariantID\tVariantID_alt1\tVariantID_alt2\tVariantID_alt3\n";
	print OUT_FREQ "VariantID\tCHR_REF\tBP_REF\tREF\tALT\tAlleleA\tAlleleB\tMinorAllele\tMajorAllele\tAF\tMAF\n";
	print OUT_FUNC "Chr\tChrStart\tChrEnd\tVariantID\tStrand\tAlleles\tVariantClass\tVariantFunction\n";
	
	print STDERR "* Looping over file to extract relevant data...\n";
	my $dummy=<IN>;
	my $tmp = "";
	while (my $row = <IN>) {
	### General part needed for all files
		chomp $row;
		my @vareach=split(/(?<!,)\t/,$row); # splitting based on tab '\t'
		$chr = $vareach[0]; # chromosome
		$bp = $vareach[1]; # base pair position
		$REF = $vareach[3]; # A allele
		$ALT = $vareach[4]; # B allele
		$Minor = $vareach[5]; # minor allele
		$Major = $vareach[6]; # major allele
		$MAF = $vareach[7]; # MAF column
	
	### get allele frequencies
	if ( $Minor == $REF ){
# 	print " ***DEBUG*** allele frequency = $1 for  [ $vareach[2] ].\n";
		$AF = $MAF;
  	} else {
  		print STDERR " *** WARNING *** Could not find the allele frequency for [ $vareach[2] ]. Check your reference-file.\n"; 
  		$AF = 1-$MAF;
  	}
 		
# 	### get allele frequencies
# 	if ( $population eq "PAN" ){
# # 		print " ***DEBUG*** Population: $population. So looking for AF in $INFO for $vareach[2]; should be: $1. \n";
# 		$tmp = $AF; 
# 		$AF = $tmp;
# 		
# 		} else {
#   	  		print STDERR " *** WARNING *** Could not find the population allele frequency for [ $vareach[2] ] and population [ $population ] where info: $INFO. Check your reference-file.\n"; 
#   			$tmp = $AF; 
# 			$AF = $tmp;
#   	}

	### adjust the key variantID type 1 -- # 'rs[xxxx]' or 'chr[X]:bp[XXXXX]:A1_A2'
	if( looks_like_number($AF) ) {
		if ( $vareach[2] =~ m/(\.)/ and $AF < 0.50 ){
	  	$vid = "chr$chr\:$bp\:$ALT\_$REF";
	  } elsif ( $vareach[2] =~ m/(\.)/ and $AF > 0.50 ) {
	  		$vid = "chr$chr\:$bp\:$REF\_$ALT";
	  		}	else {
	  				$vid = $vareach[2]; # the variant has a code either "rs", or "esv", or similar
	  				}
	} else { 
		$vid = $vareach[2]; # the variant has a code either "rs", or "esv", or similar
		}
		
	### SPECIFIC TO FILE #1
	### adjust the key variantID type 2 -- # 'chr[X]:bp[XXXXX]:A1_A2'
	if( looks_like_number($AF) ) {
	  if ( length($REF) == 1 and length($ALT) == 1 and $AF < 0.50 ){ # meaning REF is a SNP, but is *NOT* the minor allele!
	  	$vid1 = "chr$chr\:$bp\:$ALT\_$REF";
	  	} elsif ( length($REF) > 1 and $AF < 0.50 ){ # meaning REF = INSERTION, but is *NOT* the minor allele!
	  			$vid1 = "chr$chr\:$bp\:$ALT\_$REF";
	  			} elsif ( length($REF) > 1  and $AF > 0.50 ){ # meaning REF = INSERTION, but is the minor allele!
	  				$vid1 = "chr$chr\:$bp\:$REF\_$ALT";
	  				} elsif ( length($ALT) > 1 and $AF < 0.50 ){ # meaning ALT = INSERTION, but is the minor allele!
			  			$vid1 = "chr$chr\:$bp\:$ALT\_$REF";
	  					} elsif ( length($ALT) > 1 and $AF > 0.50 ){ # meaning ALT = INSERTION, but is *NOT* the minor allele!
	  						$vid1 = "chr$chr\:$bp\:$REF\_$ALT";
	  						} else { 
	  							$vid1 = "chr$chr\:$bp\:$REF\_$ALT"; # meaning REF is a SNP, but is the minor allele!
	  							}
	} else { 
		$vid1 = "chr$chr\:$bp\:$REF\_$ALT"; # meaning REF is a SNP, but is the minor allele!
		}
	
	### adjust the key variantID type 3 -- # 'chr[X]:bp[XXXXX]:[I/D]_[D/I]'
	if( looks_like_number($AF) ) {
	  if ( length($REF) == 1 and length($ALT) == 1 and $AF < 0.50 ){ # meaning REF is a SNP, but is *NOT* the minor allele!
	  	$vid2 = "chr$chr\:$bp\:$ALT\_$REF";
	  } elsif ( length($REF) > 1 and $AF < 0.50 ){ # meaning REF = I, but is *NOT* the minor allele!
	  		$vid2 = "chr$chr\:$bp\:D\_I";
	  		} elsif ( length($REF) > 1 and $AF > 0.50 ){ # meaning REF = I, but is the minor allele!
	  			$vid2 = "chr$chr\:$bp\:I\_D";
	  			} elsif ( length($ALT) > 1 and $AF < 0.50 ){ # meaning ALT = I, but is the minor allele!
		  			$vid2 = "chr$chr\:$bp\:I\_D";
	  				} elsif ( length($ALT) > 1 and $AF > 0.50 ){ # meaning ALT = I, but is *NOT* the minor allele!
	  					$vid2 = "chr$chr\:$bp\:D\_I";
	  					} else { 
	  						$vid2 = "chr$chr\:$bp\:$REF\_$ALT"; # meaning REF is a SNP, but is the minor allele!
	  						}
	} else { 
		$vid2 = "chr$chr\:$bp\:$REF\_$ALT"; # meaning REF is a SNP, but is the minor allele!
		}
	
	### adjust the key variantID type 4 -- # 'chr[X]:bp[XXXXX]:R_[D/I]'
	if( looks_like_number($AF) ) {
	  if ( length($REF) == 1 and length($ALT) == 1 and $AF < 0.50 ){ # meaning REF is a SNP, but is *NOT* the minor allele!
	  	$vid3 = "chr$chr\:$bp\:$ALT\_$REF";
	  } elsif ( length($REF) > 1 and $AF < 0.50 ){ # meaning REF = I, but is *NOT* the minor allele!
	  		$vid3 = "chr$chr\:$bp\:D\_$ref_indel";
	  		} elsif ( length($REF) > 1 and $AF > 0.50 ){ # meaning REF = I, but is the minor allele!
	  			$vid3 = "chr$chr\:$bp\:$ref_indel\_D";
	  			} elsif ( length($ALT) > 1 and $AF < 0.50 ){ # meaning ALT = I, but is the minor allele!
		  			$vid3 = "chr$chr\:$bp\:I\_$ref_indel";
	  				} elsif ( length($ALT) > 1 and $AF > 0.50 ){ # meaning ALT = I, but is *NOT* the minor allele!
	  					$vid3 = "chr$chr\:$bp\:$ref_indel\_I";
	  					} else { 
	  						$vid3 = "chr$chr\:$bp\:$REF\_$ALT"; # meaning REF is a SNP, but is the minor allele!
	  						}
	} else { 
		$vid3 = "chr$chr\:$bp\:$REF\_$ALT"; # meaning REF is a SNP, but is the minor allele!
		}
			
	### SPECIFIC TO FILE #2
	### adjust alleleA and alleleB when variantID is an INDEL
	if ( length($REF) == 1 and length($ALT) == 1 ){
		$AlleleA = $vareach[3];
		$AlleleB = $vareach[4];
	} elsif ( length($REF) > 1 ){ 
		$AlleleA = "I";
		$AlleleB = "D";
		} elsif ( length($ALT) > 1 ){ 
			$AlleleA = "D";
			$AlleleB = "I";
			} else { 
				$AlleleA = $vareach[3];
				$AlleleB = $vareach[4];
	}
 	
# 	### adjust Minor and Major when ALT is the minor allele
# 	if( looks_like_number($AF) ) {
# 		if ( $AF < 0.50 ){
# 			$Minor = $vareach[4]; # ALT allele is the minor allele
# 			$Major = $vareach[3];
# 		} elsif ( $AF > 0.50 ) {
# 			$Minor = $vareach[3]; # REF allele is the minor allele
# 			$Major = $vareach[4]; #
# 			} else {
# 				$Minor = $vareach[3]; # REF allele is the minor allele
# 				$Major = $vareach[4]; #
# 		}
# 	} else { 
# 		$Minor = $vareach[3]; # REF allele is the minor allele
# 		$Major = $vareach[4]; #
# 	}
# 		
# 	## get minor allele frequencies based on AF
# 	if ( looks_like_number($AF) ) {
# 		if ( $AF < 0.50 ){
# 			$MAF = $AF;
# 		} else {
# 			$MAF = 1-$AF;
# 		} 
# 	} else { 
# 		$tmp = $AF; 
# 		$AF = $tmp;
# 		$MAF = $tmp;
# 	}
			
	### SPECIFIC TO FILE #3
	### get alleles
	$alleles = $REF . "/" . $ALT; # REF allele/ALT alleles
		
	### get variant length
	if (length($REF) == 1 and length($ALT) == 1){
		$chrstart = $bp; # base pair start position
		$chrend = $bp; # base pair end position
	
	} elsif (length($REF) > 1){ 
		$chrstart = $bp; # base pair start position
		$chrend = $bp + length($REF); # base pair end position
		
		} elsif (length($ALT) > 1){ 
		$chrstart = $bp; # base pair start position
		$chrend = $bp + length($ALT); # base pair end position
		
			} else { 
				$chrstart = $bp; # base pair start position
				$chrend = $bp; # base pair end position
	}
	
	### get variant type
	if ( length($REF) > 1 ){
		$variantclass = "INDEL";
	} elsif ( length($ALT) > 1 ){
		$variantclass = "INDEL";
		} else {
			$variantclass = "SNP";
	}
	
	print OUT_INFO "$vid\t$vid1\t$vid2\t$vid3\n";
	print OUT_FREQ "$vid\t$chr\t$bp\t$REF\t$ALT\t$AlleleA\t$AlleleB\t$Minor\t$Major\t$AF\t$MAF\n";
	print OUT_FUNC "$chr\t$chrstart\t$chrend\t$vid\t$strand\t$alleles\t$variantclass\t$variantfunction\n";
	}
	### Closing output files
	close OUT_INFO;
	close OUT_FREQ;
	close OUT_FUNC;
	
	### Closing input file
	close IN;
	}
	
	elsif ( $reference eq "GoNL4" or $reference eq "GoNL5") {		
 	die " *** ERROR *** Parsing of GoNL4/GoNL5 is not implemented yet.\n";		
 		} else {		
 		die " *** ERROR *** You must supply the proper reference and accompanying population. Please double back.\n";		
 		}
	
print STDERR "\n";
print STDERR "Wow. That was a lot of work. I'm glad it's done. Let's have beer, buddy!\n";
my $newtime = localtime; # scalar context
print STDERR "The current date and time is: $newtime.\n";
print STDERR "\n";
print STDERR "\n";
print STDERR "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
print STDERR "+ The MIT License (MIT)                                                                  +\n";
print STDERR "+ Copyright (c) 2016-2022 Sander W. van der Laan & Vinicius Tragante dó Ó                +\n";
print STDERR "+                                                                                        +\n";
print STDERR "+ Permission is hereby granted, free of charge, to any person obtaining a copy of this   +\n";
print STDERR "+ software and associated documentation files (the \"Software\"), to deal in the         +\n";
print STDERR "+ Software without restriction, including without limitation the rights to use, copy,    +\n";
print STDERR "+ modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,    +\n";
print STDERR "+ and to permit persons to whom the Software is furnished to do so, subject to the       +\n";
print STDERR "+ following conditions:                                                                  +\n";
print STDERR "+                                                                                        +\n";
print STDERR "+ The above copyright notice and this permission notice shall be included in all copies  +\n";
print STDERR "+ or substantial portions of the Software.                                               +\n";
print STDERR "+                                                                                        +\n";
print STDERR "+ THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,  +\n";
print STDERR "+ INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A          +\n";
print STDERR "+ PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT     +\n";
print STDERR "+ HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF   +\n";
print STDERR "+ CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE   +\n";
print STDERR "+ OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                                          +\n";
print STDERR "+                                                                                        +\n";
print STDERR "+ Reference: http://opensource.org.                                                      +\n";
print STDERR "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";


### HEADER of VCF-file, version 4.1 -- 1000G, PHASE 1
### ##fileformat=VCFv4.1
### ##INFO=<ID=LDAF,Number=1,Type=Float,Description="MLE Allele Frequency Accounting for LD">
### ##INFO=<ID=AVGPOST,Number=1,Type=Float,Description="Average posterior probability from MaCH/Thunder">
### ##INFO=<ID=RSQ,Number=1,Type=Float,Description="Genotype imputation quality from MaCH/Thunder">
### ##INFO=<ID=ERATE,Number=1,Type=Float,Description="Per-marker Mutation rate from MaCH/Thunder">
### ##INFO=<ID=THETA,Number=1,Type=Float,Description="Per-marker Transition rate from MaCH/Thunder">
### ##INFO=<ID=CIEND,Number=2,Type=Integer,Description="Confidence interval around END for imprecise variants">
### ##INFO=<ID=CIPOS,Number=2,Type=Integer,Description="Confidence interval around POS for imprecise variants">
### ##INFO=<ID=END,Number=1,Type=Integer,Description="End position of the variant described in this record">
### ##INFO=<ID=HOMLEN,Number=.,Type=Integer,Description="Length of base pair identical micro-homology at event breakpoints">
### ##INFO=<ID=HOMSEQ,Number=.,Type=String,Description="Sequence of base pair identical micro-homology at event breakpoints">
### ##INFO=<ID=SVLEN,Number=1,Type=Integer,Description="Difference in length between REF and ALT alleles">
### ##INFO=<ID=SVTYPE,Number=1,Type=String,Description="Type of structural variant">
### ##INFO=<ID=AC,Number=.,Type=Integer,Description="Alternate Allele Count">
### ##INFO=<ID=AN,Number=1,Type=Integer,Description="Total Allele Count">
### ##ALT=<ID=DEL,Description="Deletion">
### ##FORMAT=<ID=GT,Number=1,Type=String,Description="Genotype">
### ##FORMAT=<ID=DS,Number=1,Type=Float,Description="Genotype dosage from MaCH/Thunder">
### ##FORMAT=<ID=GL,Number=.,Type=Float,Description="Genotype Likelihoods">
### ##INFO=<ID=AA,Number=1,Type=String,Description="Ancestral Allele, ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/pilot_data/technical/reference/ancestral_alignments/README">
### ##INFO=<ID=AF,Number=1,Type=Float,Description="Global Allele Frequency based on AC/AN">
### ##INFO=<ID=AMR_AF,Number=1,Type=Float,Description="Allele Frequency for samples from AMR based on AC/AN">
### ##INFO=<ID=ASN_AF,Number=1,Type=Float,Description="Allele Frequency for samples from ASN based on AC/AN">
### ##INFO=<ID=AFR_AF,Number=1,Type=Float,Description="Allele Frequency for samples from AFR based on AC/AN">
### ##INFO=<ID=EUR_AF,Number=1,Type=Float,Description="Allele Frequency for samples from EUR based on AC/AN">
### ##INFO=<ID=VT,Number=1,Type=String,Description="indicates what type of variant the line represents">
### ##INFO=<ID=SNPSOURCE,Number=.,Type=String,Description="indicates if a snp was called when analysing the low coverage or exome alignment data">
### ##reference=GRCh37
### #CHROM	POS	ID	REF	ALT	QUAL	FILTER	INFO
### 1	10583	rs58108140	G	A	100	PASS	AVGPOST=0.7707;RSQ=0.4319;LDAF=0.2327;ERATE=0.0161;AN=2184;VT=SNP;AA=.;THETA=0.0046;AC=314;SNPSOURCE=LOWCOV;AF=0.14;ASN_AF=0.13;AMR_AF=0.17;AFR_AF=0.04;EUR_AF=0.21
### 1	10611	rs189107123	C	G	100	PASS	AN=2184;THETA=0.0077;VT=SNP;AA=.;AC=41;ERATE=0.0048;SNPSOURCE=LOWCOV;AVGPOST=0.9330;LDAF=0.0479;RSQ=0.3475;AF=0.02;ASN_AF=0.01;AMR_AF=0.03;AFR_AF=0.01;EUR_AF=0.02
### 1	13302	rs180734498	C	T	100	PASS	THETA=0.0048;AN=2184;AC=249;VT=SNP;AA=.;RSQ=0.6281;LDAF=0.1573;SNPSOURCE=LOWCOV;AVGPOST=0.8895;ERATE=0.0058;AF=0.11;ASN_AF=0.02;AMR_AF=0.08;AFR_AF=0.21;EUR_AF=0.14
### 1	13327	rs144762171	G	C	100	PASS	AVGPOST=0.9698;AN=2184;VT=SNP;AA=.;RSQ=0.6482;AC=59;SNPSOURCE=LOWCOV;ERATE=0.0012;LDAF=0.0359;THETA=0.0204;AF=0.03;ASN_AF=0.02;AMR_AF=0.03;AFR_AF=0.02;EUR_AF=0.04
### 1	13957	rs201747181	TC	T	28	PASS	AA=TC;AC=35;AF=0.02;AFR_AF=0.02;AMR_AF=0.02;AN=2184;ASN_AF=0.01;AVGPOST=0.8711;ERATE=0.0065;EUR_AF=0.02;LDAF=0.0788;RSQ=0.2501;THETA=0.0100;VT=INDEL
### 1	13980	rs151276478	T	C	100	PASS	AN=2184;AC=45;ERATE=0.0034;THETA=0.0139;RSQ=0.3603;LDAF=0.0525;VT=SNP;AA=.;AVGPOST=0.9221;SNPSOURCE=LOWCOV;AF=0.02;ASN_AF=0.02;AMR_AF=0.02;AFR_AF=0.01;EUR_AF=0.02
### 1	30923	rs140337953	G	T	100	PASS	AC=1584;AA=T;AN=2184;RSQ=0.5481;VT=SNP;THETA=0.0162;SNPSOURCE=LOWCOV;ERATE=0.0183;LDAF=0.6576;AVGPOST=0.7335;AF=0.73;ASN_AF=0.89;AMR_AF=0.80;AFR_AF=0.48;EUR_AF=0.73
### 1	46402	rs199681827	C	CTGT	31	PASS	AA=.;AC=8;AF=0.0037;AFR_AF=0.01;AN=2184;ASN_AF=0.0017;AVGPOST=0.8325;ERATE=0.0072;LDAF=0.0903;RSQ=0.0960;THETA=0.0121;VT=INDEL
### 1	47190	rs200430748	G	GA	192	PASS	AA=G;AC=29;AF=0.01;AFR_AF=0.06;AMR_AF=0.0028;AN=2184;AVGPOST=0.9041;ERATE=0.0041;LDAF=0.0628;RSQ=0.2883;THETA=0.0153;VT=INDEL
### 1	51476	rs187298206	T	C	100	PASS	ERATE=0.0021;AA=C;AC=18;AN=2184;VT=SNP;THETA=0.0103;LDAF=0.0157;SNPSOURCE=LOWCOV;AVGPOST=0.9819;RSQ=0.5258;AF=0.01;ASN_AF=0.01;AMR_AF=0.01;AFR_AF=0.01;EUR_AF=0.01
### 1	51479	rs116400033	T	A	100	PASS	RSQ=0.7414;AVGPOST=0.9085;AA=T;AN=2184;THETA=0.0131;AC=235;VT=SNP;LDAF=0.1404;SNPSOURCE=LOWCOV;ERATE=0.0012;AF=0.11;ASN_AF=0.0035;AMR_AF=0.16;AFR_AF=0.03;EUR_AF=0.22
### 1	51914	rs190452223	T	G	100	PASS	ERATE=0.0004;AVGPOST=0.9985;THETA=0.0159;AA=T;AN=2184;VT=SNP;SNPSOURCE=LOWCOV;AC=1;RSQ=0.4089;LDAF=0.0012;AF=0.0005;ASN_AF=0.0017


### HEADER of VCF-file, version 4.1 -- 1000G, PHASE 3, VERSION 5
### ##fileformat=VCFv4.1
### ##FILTER=<ID=PASS,Description="All filters passed">
### ##fileDate=20150218
### ##reference=ftp://ftp.1000genomes.ebi.ac.uk//vol1/ftp/technical/reference/phase2_reference_assembly_sequence/hs37d5.fa.gz
### ##source=1000GenomesPhase3Pipeline
### ##contig=<ID=1,assembly=b37,length=249250621>
### ##contig=<ID=2,assembly=b37,length=243199373>
### ##contig=<ID=3,assembly=b37,length=198022430>
### ##contig=<ID=4,assembly=b37,length=191154276>
### ##contig=<ID=5,assembly=b37,length=180915260>
### ##contig=<ID=6,assembly=b37,length=171115067>
### ##contig=<ID=7,assembly=b37,length=159138663>
### ##contig=<ID=8,assembly=b37,length=146364022>
### ##contig=<ID=9,assembly=b37,length=141213431>
### ##contig=<ID=10,assembly=b37,length=135534747>
### ##contig=<ID=11,assembly=b37,length=135006516>
### ##contig=<ID=12,assembly=b37,length=133851895>
### ##contig=<ID=13,assembly=b37,length=115169878>
### ##contig=<ID=14,assembly=b37,length=107349540>
### ##contig=<ID=15,assembly=b37,length=102531392>
### ##contig=<ID=16,assembly=b37,length=90354753>
### ##contig=<ID=17,assembly=b37,length=81195210>
### ##contig=<ID=18,assembly=b37,length=78077248>
### ##contig=<ID=19,assembly=b37,length=59128983>
### ##contig=<ID=20,assembly=b37,length=63025520>
### ##contig=<ID=21,assembly=b37,length=48129895>
### ##contig=<ID=22,assembly=b37,length=51304566>
### ##contig=<ID=GL000191.1,assembly=b37,length=106433>
### <<< HERE ARE MANY GLs - REMOVED THESE FOR LEGIBILITY >>>
### ##contig=<ID=GL000249.1,assembly=b37,length=38502>
### ##contig=<ID=MT,assembly=b37,length=16569>
### ##contig=<ID=NC_007605,assembly=b37,length=171823>
### ##contig=<ID=X,assembly=b37,length=155270560>
### ##contig=<ID=Y,assembly=b37,length=59373566>
### ##contig=<ID=hs37d5,assembly=b37,length=35477943>
### ##ALT=<ID=CNV,Description="Copy Number Polymorphism">
### ##ALT=<ID=DEL,Description="Deletion">
### ##ALT=<ID=DUP,Description="Duplication">
### ##ALT=<ID=INS:ME:ALU,Description="Insertion of ALU element">
### ##ALT=<ID=INS:ME:LINE1,Description="Insertion of LINE1 element">
### ##ALT=<ID=INS:ME:SVA,Description="Insertion of SVA element">
### ##ALT=<ID=INS:MT,Description="Nuclear Mitochondrial Insertion">
### ##ALT=<ID=INV,Description="Inversion">
### ##ALT=<ID=CN0,Description="Copy number allele: 0 copies">
### <<< HERE ARE MANY CNs - REMOVED THESE FOR LEGIBILITY >>>
### ##ALT=<ID=CN124,Description="Copy number allele: 124 copies">
### ##INFO=<ID=CIEND,Number=2,Type=Integer,Description="Confidence interval around END for imprecise variants">
### ##INFO=<ID=CIPOS,Number=2,Type=Integer,Description="Confidence interval around POS for imprecise variants">
### ##INFO=<ID=CS,Number=1,Type=String,Description="Source call set.">
### ##INFO=<ID=END,Number=1,Type=Integer,Description="End coordinate of this variant">
### ##INFO=<ID=IMPRECISE,Number=0,Type=Flag,Description="Imprecise structural variation">
### ##INFO=<ID=MC,Number=.,Type=String,Description="Merged calls.">
### ##INFO=<ID=MEINFO,Number=4,Type=String,Description="Mobile element info of the form NAME,START,END<POLARITY; If there is only 5' OR 3' support for this call, will be NULL NULL for START and END">
### ##INFO=<ID=MEND,Number=1,Type=Integer,Description="Mitochondrial end coordinate of inserted sequence">
### ##INFO=<ID=MLEN,Number=1,Type=Integer,Description="Estimated length of mitochondrial insert">
### ##INFO=<ID=MSTART,Number=1,Type=Integer,Description="Mitochondrial start coordinate of inserted sequence">
### ##INFO=<ID=SVLEN,Number=.,Type=Integer,Description="SV length. It is only calculated for structural variation MEIs. For other types of SVs, one may calculate the SV length by INFO:END-START+1, or by finding the difference between lengthes of REF and ALT alleles">
### ##INFO=<ID=SVTYPE,Number=1,Type=String,Description="Type of structural variant">
### ##INFO=<ID=TSD,Number=1,Type=String,Description="Precise Target Site Duplication for bases, if unknown, value will be NULL">
### ##INFO=<ID=AC,Number=A,Type=Integer,Description="Total number of alternate alleles in called genotypes">
### ##INFO=<ID=AF,Number=A,Type=Float,Description="Estimated allele frequency in the range (0,1)">
### ##INFO=<ID=NS,Number=1,Type=Integer,Description="Number of samples with data">
### ##INFO=<ID=AN,Number=1,Type=Integer,Description="Total number of alleles in called genotypes">
### ##INFO=<ID=EAS_AF,Number=A,Type=Float,Description="Allele frequency in the EAS populations calculated from AC and AN, in the range (0,1)">
### ##INFO=<ID=EUR_AF,Number=A,Type=Float,Description="Allele frequency in the EUR populations calculated from AC and AN, in the range (0,1)">
### ##INFO=<ID=AFR_AF,Number=A,Type=Float,Description="Allele frequency in the AFR populations calculated from AC and AN, in the range (0,1)">
### ##INFO=<ID=AMR_AF,Number=A,Type=Float,Description="Allele frequency in the AMR populations calculated from AC and AN, in the range (0,1)">
### ##INFO=<ID=SAS_AF,Number=A,Type=Float,Description="Allele frequency in the SAS populations calculated from AC and AN, in the range (0,1)">
### ##INFO=<ID=DP,Number=1,Type=Integer,Description="Total read depth; only low coverage data were counted towards the DP, exome data were not used">
### ##INFO=<ID=AA,Number=1,Type=String,Description="Ancestral Allele. Format: AA|REF|ALT|IndelType. AA: Ancestral allele, REF:Reference Allele, ALT:Alternate Allele, IndelType:Type of Indel (REF, ALT and IndelType are only defined for indels)">
### ##INFO=<ID=VT,Number=.,Type=String,Description="indicates what type of variant the line represents">
### ##INFO=<ID=EX_TARGET,Number=0,Type=Flag,Description="indicates whether a variant is within the exon pull down target boundaries">
### ##INFO=<ID=MULTI_ALLELIC,Number=0,Type=Flag,Description="indicates whether a site is multi-allelic">
### ##INFO=<ID=OLD_VARIANT,Number=1,Type=String,Description="old variant location. Format chrom:position:REF_allele/ALT_allele">
### #CHROM	POS	ID	REF	ALT	QUAL	FILTER	INFO
### 1	10177	rs367896724	A	AC	100	PASS	AC=2130;AF=0.425319;AN=5008;NS=2504;DP=103152;EAS_AF=0.3363;AMR_AF=0.3602;AFR_AF=0.4909;EUR_AF=0.4056;SAS_AF=0.4949;AA=|||unknown(NO_COVERAGE);VT=INDEL
### 1	10235	rs540431307	T	TA	100	PASS	AC=6;AF=0.00119808;AN=5008;NS=2504;DP=78015;EAS_AF=0;AMR_AF=0.0014;AFR_AF=0;EUR_AF=0;SAS_AF=0.0051;AA=|||unknown(NO_COVERAGE);VT=INDEL
### 1	10352	rs555500075	T	TA	100	PASS	AC=2191;AF=0.4375;AN=5008;NS=2504;DP=88915;EAS_AF=0.4306;AMR_AF=0.4107;AFR_AF=0.4788;EUR_AF=0.4264;SAS_AF=0.4192;AA=|||unknown(NO_COVERAGE);VT=INDEL
### 1	10505	rs548419688	A	T	100	PASS	AC=1;AF=0.000199681;AN=5008;NS=2504;DP=9632;EAS_AF=0;AMR_AF=0;AFR_AF=0.0008;EUR_AF=0;SAS_AF=0;AA=.|||;VT=SNP
### 1	10506	rs568405545	C	G	100	PASS	AC=1;AF=0.000199681;AN=5008;NS=2504;DP=9676;EAS_AF=0;AMR_AF=0;AFR_AF=0.0008;EUR_AF=0;SAS_AF=0;AA=.|||;VT=SNP
### 1	10511	rs534229142	G	A	100	PASS	AC=1;AF=0.000199681;AN=5008;NS=2504;DP=9869;EAS_AF=0;AMR_AF=0.0014;AFR_AF=0;EUR_AF=0;SAS_AF=0;AA=.|||;VT=SNP
### 1	10539	rs537182016	C	A	100	PASS	AC=3;AF=0.000599042;AN=5008;NS=2504;DP=9203;EAS_AF=0;AMR_AF=0.0014;AFR_AF=0;EUR_AF=0.001;SAS_AF=0.001;AA=.|||;VT=SNP
### 1	10542	rs572818783	C	T	100	PASS	AC=1;AF=0.000199681;AN=5008;NS=2504;DP=9007;EAS_AF=0.001;AMR_AF=0;AFR_AF=0;EUR_AF=0;SAS_AF=0;AA=.|||;VT=SNP
### 1	10579	rs538322974	C	A	100	PASS	AC=1;AF=0.000199681;AN=5008;NS=2504;DP=5502;EAS_AF=0;AMR_AF=0;AFR_AF=0.0008;EUR_AF=0;SAS_AF=0;AA=.|||;VT=SNP
### 1	15274	rs62636497	A	G,T	100	PASS	AC=1739,3210;AF=0.347244,0.640974;AN=5008;NS=2504;DP=23255;EAS_AF=0.4812,0.5188;AMR_AF=0.2752,0.7205;AFR_AF=0.323,0.6369;EUR_AF=0.2922,0.7078;SAS_AF=0.3497,0.6472;AA=g|||;VT=SNP;MULTI_ALLELIC
### 1	66381	rs538833530;rs545426917	TATATA	AATATA,T	100	PASS	AC=55,30;AF=0.0109824,0.00599042;AN=5008;NS=2504;DP=1165;EAS_AF=0,0.003;AMR_AF=0.0058,0;AFR_AF=0.0386,0.0204;EUR_AF=0,0;SAS_AF=0,0;VT=SNP,INDEL;MULTI_ALLELIC
### 1	536895	rs202171574	T	C,G	100	PASS	AC=173,31;AF=0.0345447,0.0061901;AN=5008;NS=2504;DP=17880;EAS_AF=0.0079,0;AMR_AF=0.0144,0.0029;AFR_AF=0.1142,0.0219;EUR_AF=0.001,0;SAS_AF=0.0031,0;AA=T|||;VT=SNP;MULTI_ALLELIC
### 1	565736	rs547638081	A	G,T	100	PASS	AC=3,15;AF=0.000599042,0.00299521;AN=5008;NS=2504;DP=425888;EAS_AF=0.002,0;AMR_AF=0,0;AFR_AF=0,0.003;EUR_AF=0.001,0;SAS_AF=0,0.0112;AA=-|||;VT=SNP;MULTI_ALLELIC
### 1	567747	rs532762852	C	A,T	100	PASS	AC=50,4;AF=0.00998403,0.000798722;AN=5008;NS=2504;DP=558565;EAS_AF=0.0228,0;AMR_AF=0.0375,0;AFR_AF=0.0008,0.003;EUR_AF=0,0;SAS_AF=0,0;AA=-|||;VT=SNP;MULTI_ALLELIC
### 1	569333	rs544971870	A	G,T	100	PASS	AC=29,3;AF=0.00579073,0.000599042;AN=5008;NS=2504;DP=1083257;EAS_AF=0,0;AMR_AF=0,0;AFR_AF=0.0091,0;EUR_AF=0,0;SAS_AF=0.0174,0.0031;AA=-|||;VT=SNP;MULTI_ALLELIC
### 1	680024	rs560732492	G	A,T	100	PASS	AC=5,27;AF=0.000998403,0.00539137;AN=5008;NS=2504;DP=13364;EAS_AF=0,0;AMR_AF=0.0014,0.0014;AFR_AF=0.0023,0.0182;EUR_AF=0.001,0;SAS_AF=0,0.002;AA=.|||;VT=SNP;MULTI_ALLELIC
### 1	706332	rs373669380	G	C,T	100	PASS	AC=14,4;AF=0.00279553,0.000798722;AN=5008;NS=2504;DP=20243;EAS_AF=0,0;AMR_AF=0,0;AFR_AF=0.0106,0.003;EUR_AF=0,0;SAS_AF=0,0;AA=.|||;VT=SNP;MULTI_ALLELIC
### 1	720968	rs184456771	G	C,T	100	PASS	AC=20,11;AF=0.00399361,0.00219649;AN=5008;NS=2504;DP=10780;EAS_AF=0,0;AMR_AF=0,0.0014;AFR_AF=0.0144,0.0076;EUR_AF=0.001,0;SAS_AF=0,0;AA=.|||;VT=SNP;MULTI_ALLELIC
### 1	723753	rs576104692;rs373480363	AGAGAGAGG	AGAGAGAGGGAGAGAGG,A	100	PASS	AC=41,96;AF=0.0081869,0.0191693;AN=5008;NS=2504;DP=23051;EAS_AF=0,0.0327;AMR_AF=0.0043,0.0058;AFR_AF=0.0287,0.0227;EUR_AF=0,0.0139;SAS_AF=0,0.0153;VT=INDEL;MULTI_ALLELIC
