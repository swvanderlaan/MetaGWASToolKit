#!/usr/bin/perl
####################################################################################################
#
# Author: Paul de Bakker, pdebakker@rics.bwh.harvard.edu
#         Division of Genetics, Brigham and Women's Hospital
#         Program in Medical and Population Genetics, Broad Institute of MIT and Harvard
#        
# Last update: 25 March 2009
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
use FileHandle;


my $assocFile;
my $snpsFile;
my $outFile = "loci.txt";
my $dist = 1000;

GetOptions(
	   "file=s"         => \$assocFile,
	   "snps=s"         => \$snpsFile,
	   "dist=n"         => \$dist,
	   "out=s"          => \$outFile
           );

if ( $assocFile eq "" || $snpsFile eq "" ) { 
  print STDERR "Usage: %> parse_loci.pl --file assoc_file --snps list_of_dbsnp_annotation_for_index_snps [--dist distance_in_kb]\n";
  exit;
}


open (DBSNP, $snpsFile) or die "cannot open $snpsFile\n";
open (OUT, ">$outFile") or die "cannot open $outFile\n";

my $nsnp = 0;
my @chr = ();
my @start = ();
my @stop = ();
my @snp = ();

#chrom  chromStart      chromEnd        name    strand  observed        class   func
#chr1   6946796 6946821 rs57898978      +       A/G     single  intron
##chr1  8912885 8912910 rs57188530      +       C/G     single  unknown
#chr1   34340790        34340885        rs6143185       +       (LARGEDELETION)/-       named   intron
#chr1   102891517       102891542       rs56752146      +       A/G     single  unknown

while(my $c = <DBSNP>){
  chomp $c;
  $c =~ s/^\s+//;
  my @fields = split /\s+/, $c;
  $fields[0] =~ s/chr//;
  
  $snp[$nsnp] = $fields[3];
  $chr[$nsnp] = $fields[0];
  $start[$nsnp] = $fields[1] - $dist * 1000;
  $stop[$nsnp] = $fields[1] + $dist * 1000;
   
  print "taking all SNPs around $snp[$nsnp] on $chr[$nsnp]:$start[$nsnp]-$stop[$nsnp]\n";

  $nsnp++;
}
close(DBSNP);


################################################################################
################################################################################
###
### read in association results
###
################################################################################
################################################################################

my $header = 0;

open (ASSOC, $assocFile) or die "cannot open $assocFile\n";
while(my $c = <ASSOC>){
  chomp $c;
  $c =~ s/^\s+//;
  my @fields = split /\s+/, $c;

  if ( $header == 0 ) { 
    for (my $i = 0; $i < $nsnp; $i++) {
      print OUT "$snp[$i] $c\n"; 
    }
    $header = 1; 
    next;
  }

  for ( my $i = 0; $i < $nsnp; $i++) { 
    if ( $fields[1] eq $chr[$i] && $fields[2] > $start[$i] && $fields[2] < $stop[$i] ) {
      print OUT "$snp[$i] $c\n";
    }
  }
}
close(ASSOC);

close(OUT);

