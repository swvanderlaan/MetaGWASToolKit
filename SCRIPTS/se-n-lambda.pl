#!/usr/bin/perl
print STDOUT "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
print STDOUT "+                              MedianSE-Lambda-Mean_N CALCULATOR                         +\n";
print STDOUT "+                                 version 2.1 | 11-05-2017                               +\n";
print STDOUT "+                                                                                        +\n";
print STDOUT "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
print STDOUT "\n";
my $time = localtime; # scalar, i.e. non-numeric, context
print STDOUT "The current date and time is: $time.\n";
print STDOUT "\n";

use strict;
use FileHandle;

###############
###
### This script is designed to calculate the inverse median of all SE values, mean of sample size, and lambda
### Adapted from EasyQC by Thomas Winkler and Mathias Gorski.
### website: http://www.uni-regensburg.de/medizin/epidemiologie-praeventivmedizin/genetische-epidemiologie/software/index.html
### citation: http://www.nature.com/nprot/journal/v9/n5/full/nprot.2014.071.html
### Constant:	Three options are available to calibrate the results:
###			-HM2:		1.75 - calibration factor (c), for GWAS chip data imputed
###						on HapMap2, CEU reference
###			-1000GEUR:  8.86 - calibration factor (c), for GWAS chip data imputed
###			            on 1000G, ALL reference
###			Data from Table 3, Winkler TW ea, Nature Protocols, 2014.
###
### Last update: 2015-02-19
### Written by: Jessica van Setten (j.vansetten@umcutrecht.nl), Sander W. van der Laan (s.w.vanderlaan-2@umcutrecht.nl)
### 
### Usage:
### perl se-n-lambda.pl path_to_studyfile path_to_outputfile [HM2/1Gp1]
###
### Studyfile:
### This (white space delimited) file contains the paths to all studies in the first column and the names of the studies in the second. E.g.:
### /hpc/cog_gonl/jessica/study1 Study1
### /hpc/cog_gonl/jessica/study2_clean Study2 
###
### Output file:
### The output file contains these columns: Study Median_SE Lambda Mean_N
###
###############

### List with parameters
my $cohort_file = $ARGV[0];
my $output = $ARGV[1];
my $calibrationfactor = $ARGV[2];
my @se = ();
my @n =();
my @z = ();
my $median_se = ();
my $parameterFound = 0;
my $nstudies = 0;
my @filename = ();
my @fh = ();
my @studyname = ();

### Print header line to output file
print STDERR "\nCreating output file...\n";
open OUT, ">$output" or die "Could not open $output, $!";
print OUT join("\t", "Study","Median_SE","Lambda","Mean_N")."\n";

### Open cohort file and read in names of studies
print STDERR "\nReading cohort file [ $cohort_file ] ...\n";
open COHORT, $cohort_file or die "*** ERROR *** Could not open $cohort_file ! Please, double back. \n";
while(<COHORT>){
	    chomp;
	    my @fields = split;
	    $filename[$nstudies] = $fields[0];
	    $studyname[$nstudies] = $fields[1];
	    my $file = $filename[$nstudies];
	
		print STDERR "Analyzing file [ $filename[$nstudies] ] for study [ $studyname[$nstudies] ]. \n";
	### Open individual study files and make arrays of SE/N/Z
		print STDERR "\nReading input file...\n";
		if ($file =~ /.gz$/) {
			open(IN, "gunzip -c $file |") or die "*** ERROR *** Could not open [ $file ]! We expect a gzipped file. \n";
			} else {
				open(IN, "cat $file |") or die "*** ERROR *** Could not open [ $file ]! We expect a gzipped file. \n";
		}
	       
	    while( <IN> ){
	    ### Head of CDAT file
	    # VariantID	Marker	MarkerOriginal	CHR	BP	Strand	EffectAllele	OtherAllele	MinorAllele	MajorAllele	EAF	MAF	MAC	HWE_P	Info	Beta	BetaMinor	SE	P	N	N_cases	N_controls	Imputed	Reference
	    # 0         1       2               3   4   5       6               7           8           9           10  11  12  13      14      15      16          17  18  19  20      21          22      23
		
			if ($_ =~ m/CHR/)  { 
			$parameterFound = 1 ;
			next 
			}
			if ($parameterFound == 0) {
				chomp;
				my @fields = split;
				my $n_line = $fields[19];
				print STDERR "Sample size: $n_line\n";
				my $se_line = $fields[17];
				print STDERR "Standard error: $se_line\n";
				my $z_line = abs($fields[16]/$fields[17]);
				print STDERR "Z-score: $z_line\n";
			
				push @n, $n_line;
				push @se, $se_line;
				push @z, $z_line;
			}
	   	}
	
	    close IN;
	
	### Calculate median of SE, mean of N, and lambda 
		print STDERR "Calculating median of SE, mean of N, and lambda...\n";
	    if ($calibrationfactor eq "HM2") {# constant factor for HapMap 2 (CEU) imputed data
	    	print "* Reference is HM2, calibration factor is 1.75. Calculating inverse median(SE) for $studyname[$nstudies]...\n";
	    	$median_se = sprintf("%.3f",1.75/(median (@se))) ;
	    	} elsif ($calibrationfactor eq "1Gp1" || $calibrationfactor eq "1Gp3" || $calibrationfactor eq "GoNL4" || $calibrationfactor eq "GoNL5" || $calibrationfactor eq "1Gp3GONL5" ) {# constant factor for 1000G ('ALL') imputed data
	    		print "* Reference is 1000G or GoNL, calibration factor is 8.86. Calculating inverse median(SE) for $studyname[$nstudies]...\n";
	    		$median_se = sprintf("%.3f",8.86/(median (@se))) ;
				} else {
	    			die "*** ERROR *** Please supply the correct reference for the calibration factor...\n";
	    }
	    my $mean_n = sprintf("%.3f",mean (@n)) ;
	    my $lambda = sprintf("%.3f",(median (@z) * median (@z)) / 0.4549364) ;
	    print OUT join("\t",$studyname[$nstudies],$median_se,$lambda,$mean_n)."\n";
	
	### Reset parameters, go to next study
	    $nstudies++;
	    $parameterFound = 0;
	    @se = ();
	    @n = ();
	    @z = ();
	    $median_se = 0; 
	
	}
	print STDERR "\nClosing cohort file...\n";
close COHORT;

### Calculations
sub mean { # mean of values in an array
    my $sum = 0 ;
    foreach my $x (@_) {
	$sum += $x ;
    }
    return $sum/@_ ;
}

sub median { # median of values in an array
    my @sorted = sort {$a <=> $b} (@_) ;
  if (1 == @sorted % 2) # Odd number of elements
  {return $sorted[(@sorted-1)/2]}
  else                   # Even number of elements
  {return ($sorted[@sorted/2-1]+$sorted[@sorted/2]) / 2}
}


print STDERR "\n";
print STDERR "Wow. That was a lot of work. I'm glad it's done. Let's have beer, buddy!\n";
my $newtime = localtime; # scalar context
print STDERR "The current date and time is: $newtime.\n";
print STDERR "\n";
print STDERR "\n";
print STDERR "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
print STDERR "+ The MIT License (MIT)                                                                  +\n";
print STDERR "+ Copyright (c) 2016-2017 Sander W. van der Laan & Vinicius Tragante dó Ó                +\n";
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
