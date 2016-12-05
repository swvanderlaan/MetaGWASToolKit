#!/usr/bin/perl
#
# Author: Paul de Bakker, debakker@broad.mit.edu
#
# Last update: 21 March 2009
#

use strict;
use Getopt::Long;

my @Columns = ();
my $Sep = " ";
my $noheader = '';

GetOptions(     
           "col=s"       => \@Columns,
           "sep=s"       => \$Sep, 
           "no-header"   => \$noheader 
           );

@Columns = split(/,/, join(',',@Columns));

if ( $#Columns < 0 ) {
    print "usage: %>parse_table.pl --col COL1[,COL2,COL3,...] \n";
    print "prints specified columns from STDIN\n";
    exit();
}   

my @column_index = ();

for ( my $i=0; $i <= $#Columns; $i++ ) {
  $column_index[$i] = -1;
#  print "$Columns[$i] \n";
}


my $linecount = 0;

while(my $c = <STDIN>) {
  $c=~s/\s+$//;
  $c=~s/^\s+//;
  my @fields = split /\s+/, $c;

  if ( $linecount == 0 ) {
    for (my $i=0; $i<=$#fields; $i++) {
      for (my $j=0; $j<=$#Columns; $j++) {
        if ( $fields[$i] eq $Columns[$j] ) {
          $column_index[$j] = $i;  
          next;
        }
      } 
    }

    for (my $j=0; $j<=$#Columns; $j++) {
      if ( $column_index[$j] == -1 ) { die "$Columns[$j] not recognized\n"; }
      if ( ! $noheader ) { 
        print STDOUT $j>0 ? $Sep : "", $Columns[$j];
      }
    }
    if ( ! $noheader ) { print STDOUT "\n"; }
  }
  else {
    for (my $i=0; $i<=$#Columns; $i++) {
      print STDOUT $i>0 ? $Sep : "", $fields[$column_index[$i]];
    }
    print STDOUT "\n";
  } 

  $linecount++;
}


