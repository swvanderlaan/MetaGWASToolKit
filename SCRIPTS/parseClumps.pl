#!/usr/bin/perl
####################################################################################################
#
# Author: Paul de Bakker, pdebakker@rics.bwh.harvard.edu
#         Division of Genetics, Brigham and Women's Hospital
#         Program in Medical and Population Genetics, Broad Institute of MIT and Harvard
#        
# Last update: 22 March 2009
#
#
####################################################################################################
#
# Required input:
#
#
####################################################################################################

use strict;
use Getopt::Long;

my $index;
my $clumpFile;

GetOptions(
	   "file=s"       => \$clumpFile,
	   "snp=s"         => \$index,
           );

if ( $clumpFile eq "" || $index eq "" ) { 
  print STDERR "Usage: %> parse_clumps.pl --file clump_file --snp index_snp\n";
  exit;
}

my $toggle = 0;

################################################################################
################################################################################
###
### read in clumps
###
################################################################################
################################################################################

#
# CHR    F          SNP         BP          P    TOTAL   NSIG    S05    S01   S001  S0001
#   1    1    rs2880058  160281256      1e-99       95      9      0      0      0     86 
#
#                               KB      RSQ  ALLELES    F            P        ANNOT
#  (INDEX)    rs2880058          0    1.000        G    1        1e-99 G, 0.332, 46602.6, 2.676, 0.126, OLFML2B, unknown
#
#            rs12120347      -36.9     0.27    GA/AT    1     2.23e-24 A, 0.157, 40115.4, 1.755, 0.172, OLFML2B, intron
#              rs885092      -10.8    0.272    GA/AG    1     4.74e-18 A, 0.150, 44464.5, 1.476, 0.170, OLFML2B, unknown

print "SNP KB RSQR P CODED_ALLELE CODED_ALLELE_FREQ N_EFF BETA_FIXED SE_FIXED NEAREST_GENE FUNCTION\n"; 

open (CLUMP, $clumpFile) or die "cannot open $clumpFile\n";
while(my $c = <CLUMP>){
  chomp $c;
  $c =~ s/^\s+//;
  $c =~ s/,//g;
  my @fields = split /\s+/, $c;

  if ( $fields[0] eq "(INDEX)" && $index eq $fields[1] ) { 
    shift @fields;
#    print join " ", @fields;   
    print "$fields[0] $fields[1] $fields[2] $fields[5] $fields[6] $fields[7] $fields[8] $fields[9] $fields[10] $fields[11] $fields[12]\n";
    $toggle = 1; 
    my $void = <CLUMP>; 
    next;
  }

  if ( $toggle == 1 ) { 
    if ( $#fields > 2 ) { 
      print "$fields[0] $fields[1] $fields[2] $fields[5] $fields[6] $fields[7] $fields[8] $fields[9] $fields[10] $fields[11] $fields[12]\n";
    } else { $toggle = 0; }
  } 
}
close(CLUMP);


