#! usr/bin/perl -w

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
### perl se-n-lambda.pl path_to_studyfile path_to_outputfile [HM2/1000GEUR]
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
open OUT, ">$output" or die "Could not open $output, $!";
print OUT join("\t", "Study","Median_SE","Lambda","Mean_N")."\n";

### Open cohort file and read in names of studies
open C, $cohort_file;
while(<C>){
    chomp;
    my @fields = split;
    $filename[$nstudies] = $fields[0];
    $studyname[$nstudies] = $fields[1];
    my $file = $filename[$nstudies];

### Open individual study files and make arrays of SE/N/Z
    open IN, $file or die "Could not open $file, $!";
    while( <IN> ){
	if ($_ =~ /^chr/)  { $parameterFound = 1 ;}
	next if ($parameterFound == 0);
	chomp;
	my @fields = split;
	my $n_line = $fields[12];
	my $se_line = $fields[4];
	my $z_line = abs($fields[3]/$fields[4]);

	push @n, $n_line;
	push @se, $se_line;
	push @z, $z_line;

    }

    close IN;

### Calculate median of SE, mean of N, and lambda 
    if ($calibrationfactor eq "HM2") {# constant factor for HapMap 2 (CEU) imputed data
    	print "Reference is HM2, calibration factor is 1.75. Calculating inverse median(SE) for $studyname[$nstudies]...\n";
    	$median_se = sprintf("%.3f",1.75/(median (@se))) ;
    } elsif ($calibrationfactor eq "1000GEUR") {# constant factor for 1000G ('ALL') imputed data
    	print "Reference is 1000G, calibration factor is 8.86. Calculating inverse median(SE) for $studyname[$nstudies]...\n";
    	$median_se = sprintf("%.3f",8.86/(median (@se))) ;
    } else {
    	#print "Please supply the correct reference for the calibration factor...\n";
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
close C;

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
