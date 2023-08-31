#!/usr/bin/perl
#
####################################################################################################
# 
# CLUMP PARSER
#
# Description: 	this script parses a PLINK v1.05+ or PLINK v1.9 generated 'clumped'-file
#               and extracts the relevant data for a given variant.
#
# Written by:	Paul I.W. de Bakker; Utrecht, the Netherlands. 
#               Division of Genetics, Brigham and Women's Hospital, 
#               Program in Medical and Population Genetics, Broad Institute of MIT and Harvard, 
#               Boston (MA), United States of America.
# Edited by:    Sander W. van der Laan; Utrecht, the Netherlands, s.w.vanderlaan@gmail.com.
# Version:		1.2.1
# Update date: 	2018-08-09
#
# Usage:		parseClumps.pl --file [clumped-file] --variant [variant-to-clump]

# Starting parsing
print STDERR "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
print STDERR "+                                      CLUMP PARSER                                      +\n";
print STDERR "+                                         v1.2.1                                         +\n";
print STDERR "+                                                                                        +\n";
print STDERR "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
print STDERR "\n";
print STDERR "Hello. I am extracting the necessary data per variant from the clumped data.\n";
my $time = localtime; # scalar context
print STDERR "The current date and time is: $time.\n";
print STDERR "\n";
use strict;
use Getopt::Long;

my $index;
my $clumpFile;

GetOptions(
	   "file=s"       => \$clumpFile,
	   "variant=s"         => \$index,
     "clumpfield=s"       => \$metaModel,
           );

if ( $clumpFile eq "" || $index eq "" ) { 
print "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
print "Usage: 
parse_clumps.pl --file clump_file --variant index_snp --clumpfield meta_model (FIXED, SQRTN, RANDOM)\n";
print "\n";
print "Parses a PLINK v1.05+ or PLINK v1.9 generated 'clumped'-file and extracts the 
relevant data for a given variant.\n";
print "";
print "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
print "The MIT License (MIT)\n";
print "Copyright (c) 2009-2018 Paul I.W. de Bakker & Sander W. van der Laan\n";
print "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
exit();
}

print STDERR "\nReading clumped file...\n";
my $toggle = 0;

################################################################################
################################################################################
###
### read in clumps
###
################################################################################
################################################################################

#
# CHR    F             SNP         BP          P    TOTAL   NSIG    S05    S01   S001  S0001
#  22    1      rs61334258   38819717   1.76e-09        1      0      0      0      1      0 
#
#                                  KB      RSQ  ALLELES    F            P        ANNOT
#  (INDEX)      rs61334258          0    1.000        T    1     1.76e-09 T, C, 0.008, 0.01, 700.6, 1.3478, 0.2239, 6.0187, 0.909, 1.787, RP3-434P1.6, ENST00000433230.1, +, PLA2G6,MAFF,TMEM184B,RP1-5O6.5,RN7SL704P,AL020993.1,CSNK1E,RP3-449O17.1,RP1-5O6.4,RP3-434P1.6,KCNJ4,KDELR3,DDX17,DMC1,FAM227A,CBY1,RP3-508I15.10,RP3-508I15.9, near-gene-5, NA
#
#               rs59210869       2.62    0.263    TC/CT    1     0.000803 C, T, 0.013, 0.0040, 1217.6, 0.4308, 0.1285, 3.3519, 0.179, 0.683, RP3-434P1.6, ENST00000433230.1, +, PLA2G6,MAFF,TMEM184B,RP1-5O6.5,RN7SL704P,AL020993.1,CSNK1E,RP3-449O17.1,RP1-5O6.4,RP3-434P1.6,KCNJ4,KDELR3,DDX17,DMC1,FAM227A,CBY1,RP3-508I15.10,RP3-508I15.9, intron,untranslated-3, NA
#
# CHR    F             SNP         BP          P    TOTAL   NSIG    S05    S01   S001  S0001
#   8    1      rs72684477   82405041   3.55e-08      162      0     38     29     14     81 
#
#                                  KB      RSQ  ALLELES    F            P        ANNOT
#  (INDEX)      rs72684477          0    1.000        A    1     3.55e-08 A, C, 0.178, 0.16, 7769.9, -0.0893, 0.0162, -5.5120, -0.121, -0.058, RP11-157I4.4, ENST00000524085.2, +, RP11-363E6.4,RP11-363E6.3,FABP5,RP11-157I4.4,PMP2,FABP9,FABP4,RP11-257P3.3,FABP12,IMPA1P,IMPA1,SLC10A5,ZFAND1,CHMP4C, unknown, NA
#
#               rs16908964       -139    0.369    AT/CA    1       0.0038 T, A, 0.231, 0.19, 6967.0, -0.0446, 0.0154, -2.8942, -0.075, -0.014, FABP5, ENST00000297258.6, +, PAG1,RP11-1149M10.2,RP11-363E6.4,RP11-363E6.3,FABP5,RP11-157I4.4,PMP2,FABP9,FABP4,RP11-257P3.3,FABP12, unknown, NA
#               rs12234970       -138    0.369    AA/CC    1      0.00408 A, C, 0.229, 0.19, 7134.7, -0.0439, 0.0153, -2.8722, -0.074, -0.014, FABP5, ENST00000297258.6, +, PAG1,RP11-1149M10.2,RP11-363E6.4,RP11-363E6.3,FABP5,RP11-157I4.4,PMP2,FABP9,FABP4,RP11-257P3.3,FABP12, unknown, NA

# Column #
#	   0         1  2    5       6   7 	 8     9     10    	11       12          13   14       15        16          17            18               19     20       21		  22		  23		 24			 25			  26		27					 28				  29             30            31

if ( $metaModel == "P_FIXED" ) {
  my $BETA = "BETA_FIXED";
  my $SE = "SE_FIXED";
  my $BETA_LOWER = "BETA_LOWER_FIXED";
  my $BETA_UPPER = "BETA_UPPER_FIXED";
  my $ZSCORE = "Z_FIXED";
  my $PVALUE = "P_FIXED";
} elsif ( $metaModel == "P_SQRTN" ) {
  my $BETA = "BETA_FIXED";
  my $SE = "SE_FIXED";
  my $BETA_LOWER = "BETA_LOWER_FIXED";
  my $BETA_UPPER = "BETA_UPPER_FIXED";
  my $ZSCORE = "Z_SQRTN";
  my $PVALUE = "P_SQRTN";
} elsif ( $metaModel == "P_RANDOM" ) {
  my $BETA = "BETA_RANDOM";
  my $SE = "SE_RANDOM";
  my $BETA_LOWER = "BETA_LOWER_RANDOM";
  my $BETA_UPPER = "BETA_UPPER_RANDOM";
  my $ZSCORE = "Z_RANDOM";
  my $PVALUE = "P_RANDOM";
} else {
  print STDERR "Incorrect or no clumpfield option supplied, defaulting to a FIXED model.\n";
  my $BETA = "BETA_FIXED";
  my $SE = "SE_FIXED";
  my $BETA_LOWER = "BETA_LOWER_FIXED";
  my $BETA_UPPER = "BETA_UPPER_FIXED";
  my $ZSCORE = "Z_FIXED";
}

print "VARIANTID KB RSQR P_FIXED CHR POS MINOR MAJOR MAF CODEDALLELE OTHERALLELE CAF N_EFF BETA_FIXED SE_FIXED BETA_LOWER_FIXED BETA_UPPER_FIXED Z_FIXED COCHRANS_Q DF P_COCHRANS_Q I_SQUARED TAU_SQUARED DIRECTIONS GENES_250KB NEAREST_GENE NEAREST_GENE_ENSEMBLID NEAREST_GENE_STRAND VARIANT_FUNCTION CAVEAT\n"; 

open (CLUMP, $clumpFile) or die " *** ERROR *** Cannot open open [ $clumpFile ]!\n";
while(my $c = <CLUMP>){
  chomp $c;
  $c =~ s/^\s+//;
  $c =~ s/,//g;
  my @fields = split /\s+/, $c;

  if ( $fields[0] eq "(INDEX)" && $index eq $fields[1] ) { 
    shift @fields;
#    print join " ", @fields;   
    print "$fields[0] $fields[1] $fields[2] $fields[5] $fields[6] $fields[7] $fields[8] $fields[9] $fields[10] $fields[11] $fields[12] $fields[13] $fields[14] $fields[15] $fields[16] $fields[17] $fields[18] $fields[19] $fields[20] $fields[21] $fields[22] $fields[23] $fields[24] $fields[25] $fields[26] $fields[27] $fields[28] $fields[29] $fields[30] $fields[31]\n";
    $toggle = 1; 
    my $void = <CLUMP>; 
    next;
  }

  if ( $toggle == 1 ) { 
    if ( $#fields > 2 ) { 
      print "$fields[0] $fields[1] $fields[2] $fields[5] $fields[6] $fields[7] $fields[8] $fields[9] $fields[10] $fields[11] $fields[12] $fields[13] $fields[14] $fields[15] $fields[16] $fields[17] $fields[18] $fields[19] $fields[20] $fields[21] $fields[22] $fields[23] $fields[24] $fields[25] $fields[26] $fields[27] $fields[28] $fields[29] $fields[30] $fields[31]\n";
    } else { $toggle = 0; }
  } 
}
close(CLUMP);

print STDERR "\n";
print STDERR "Wow. That was a lot of work. I'm glad it's done. Let's have beer, buddy!\n";
my $newtime = localtime; # scalar context
print STDERR "The current date and time is: $newtime.\n";
print STDERR "\n";
print STDERR "\n";
print STDERR "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
print STDERR "+ The MIT License (MIT)                                                                  +\n";
print STDERR "+ Copyright (c) 2009-2018 Paul I.W. de Bakker & Sander W. van der Laan                   +\n";
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
