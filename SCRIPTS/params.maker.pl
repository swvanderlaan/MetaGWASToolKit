#!/usr/bin/perl
print STDOUT "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
print STDOUT "+                                        PARAMS_MAKER                                    +\n";
print STDOUT "+                                 version 2.2 | 25-05-2023                               +\n";
print STDOUT "+                                                                                        +\n";
print STDOUT "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
print STDOUT "\n";
my $time = localtime; # scalar, i.e. non-numeric, context
print STDOUT "The current date and time is: $time.\n";
print STDOUT "\n";

use strict;
use FileHandle;


# example of .sh script:
# perl /hpc/dhl_ec/esmulders/SCRIPTS_own/params.maker.pl /hpc/dhl_ec/esmulders/metagwastoolkit.females_EUR.files.list /hpc/dhl_ec/svanderlaan/projects/consortia/ISGC_sex/meta_analysis/STROKE_FEMALES_EUR/females_eur.params /hpc/dhl_ec/svanderlaan/projects/consortia/ISGC_sex/meta_analysis/STROKE_FEMALES_EUR/females_eur/RAW /hpc/dhl_ec/svanderlaan/projects/consortia/ISGC_sex/meta_analysis/STROKE_FEMALES_EUR/females_eur/META


### List with parameters
my $cohort_file = $ARGV[0];
my $output = $ARGV[1];
my $cdat_input = $ARGV[2];
my $split_input = $ARGV[3];
my @n =();
my @z = ();
my $parameterFound = 0;
my $nstudies = 0;
my $one = 1 ;
my @correctionfactor = () ;
my @filename = ();
my @fh = ();
my @studyname = ();
my @splitfile = ();


### Print header line to output file
print STDERR "\nCreating output file...\n";
open OUT, ">$output" or die "Could not open $output, $!";


### Open cohort file and read in names of studies
print STDERR "\nReading cohort file [ $cohort_file ] ...\n";
open COHORT, $cohort_file or die "*** ERROR *** Could not open $cohort_file ! Please, double back. \n";
while(<COHORT>){
	    chomp;
	    my @fields = split;
	    $studyname[$nstudies] = $fields[0];
	    $correctionfactor[$nstudies] = $fields[3];
	    $filename[$nstudies] = "$cdat_input/$studyname[$nstudies]/$studyname[$nstudies].cdat.gz";
	    $splitfile[$nstudies] = "$split_input/$studyname[$nstudies]/$studyname[$nstudies].reorder.split";

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
	    # VariantID Marker MarkerOriginal CHR BP Strand EffectAllele OtherAllele MinorAllele MajorAllele EAF MAF MAC HWE_P Info Beta BetaMinor SE P 	N 	N_cases N_controls Imputed Reference VT
	    # 0         1      2              3   4  5      6            7           8           9           10  11  12  13    14   15   16        17 18	19	20      21         22      23		 24
		
			if ($_ =~ m/CHR/)  { 
			$parameterFound = 1 ;
			next;
			}
			if ($parameterFound == 1) {
				chomp;
				my @fields = split;
				if ($fields[17] ne "NA") { # Checks to see if the SE column is NA. Might need expansion.
					my $n_line = $fields[19];
					push @n, $n_line;				}
			}
	   	}
	
	    close IN;
	    
	    
### Calculate mean of N and lambda 
	    my $mean_n = sprintf("%.0f",(mean (@n))) ;
	    my $lambda = sprintf("%.3f",(median (@z) * median (@z)) / 0.4549364) ;
	    if ($lambda < 1.000) {
	    $lambda = sprintf("%.3f",(1.000));
	    }
	    print OUT join("\t",$studyname[$nstudies],$lambda,$mean_n,$correctionfactor[$nstudies],$splitfile[$nstudies])."\n";
	
	### Reset parameters, go to next study
	    $nstudies++;
	    $parameterFound = 0;
	    @n = ();
	    @z = ();
	
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


