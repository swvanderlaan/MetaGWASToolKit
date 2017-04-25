#!/usr/bin/env perl
#
# Overlap some data with some other data
#
# Description: 	this script can overlap data. Provided with one file (LOOKUP.txt) it will
#               lookup something in [COLUMN#] in another file [SOURCE.txt] in a certain
#               [COLUMN#]. The whole line of the [SOURCE.txt] will be printed to the 
#               standard out
#
# Written by:	Jessica van Setten & Sander W. van der Laan; UMC Utrecht, Utrecht, the 
#               Netherlands, j.vansetten@umcutrecht.nl or s.w.vanderlaan-2@umcutrecht.nl.
#
# Version:		2.0
# Update date: 	2017-04-17
#
# Usage:		perl overlap.pl --file1 [INPUT_FILE_1] --col1 [COLUMN#] --file2 [INPUT_FILE_2] --col2 [COLUMN#] --format [GZIP/NORM] [optional: --neg [DIFF] ]

# Overlapping
print STDERR "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
print STDERR "+                                       OVERLAP FILES                                    +\n";
print STDERR "+                                            V2.0                                        +\n";
print STDERR "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
print STDERR "+ \n";
print STDERR "+ Hello. I am reviewing the overlap (or difference) between two files.\n";
my $time = localtime; # scalar, i.e. non-numeric, context
print STDERR "+ The current date and time is: $time.\n";
print STDERR "+ \n";

use strict;
use warnings;
use Getopt::Long;

# Four (or five) arguments are required: 
# - the first input file (FILE1)
# - the column to match to in FILE1
# - the second input file (FILE2)
# - the column to match to in FILE2
# - whether the input file is zipped (GZIP/NORM)
# - optional: --neg to find the difference between files
my $Table1 = ""; # first argument
my $Column1 = ""; # second argument
my $Table2 = ""; # third argument
my $Column2 = ""; # fourth argument
my $zipped = ""; # fourth argument: four options: GZIP (both files gzipped) NORM (none gzipped)
my $neg = "";

my %present = ();
my @fields;

GetOptions(
           "file1=s"     => \$Table1,
           "col1=s"      => \$Column1,
           "file2=s"     => \$Table2,
           "col2=s"      => \$Column2,
           "format=s"    => \$zipped,
           "neg"        => \$neg
           );
# IF STATEMENT TO CHECK CORRECT INPUT
if ( $Table1 eq "" || $Column1 eq "" || $Table2 eq "" || $Column2 eq "" || $zipped eq "" ) {
    print "Usage: %>overlap.pl --file1 [INPUT_FILE_1] --col1 [COLUMN#] --file2 [INPUT_FILE_2] --col2 [COLUMN#] --format [GZIP/NORM] [optional: --neg [DIFF] ].\n";
    print "";
    print "Finds the overlap between file1 and file2 based on column_file1 and column_file2.\n";
    print "The argument --format indicates which of the files are gzipped.\n";
    print "If --neg is specified with '-v' the difference between the files is given.\n";
    exit();
}

### IF/ELSE STATEMENTS to determine the GZIPPED nature of the file1
if ($zipped eq "GZIP") {
	open (F1, "gunzip -c $Table1 |") or die "*** ERROR ***  Couldn't open input file 1: $!";
	while(<F1>){
		chomp;
		@fields = split;
    	$present{ $fields[$Column1-1] } = 1;
    	}
    close F1;
    
	open (F2, "gunzip -c $Table2 |") or die "*** ERROR ***  Couldn't open input file 1: $!";
	while (<F2>){
    	chomp;
    	@fields = split;
    	if ( ( $neg eq "DIFF" && ! exists $present{$fields[$Column2-1]} ) || ( $neg eq "" && exists $present{$fields[$Column2-1]} ) ) { print "$_\n"; }
    }
	close F2;
	
} elsif ($zipped eq "NORM") {
	open (F1, $Table1) or die "*** ERROR *** Couldn't open input file 1: $!";
	while(<F1>){
		chomp;
		@fields = split;
    	$present{ $fields[$Column1-1] } = 1;
    	}
    close F1;
    
	open (F2, $Table2) or die "*** ERROR ***  Couldn't open input file 1: $!";
	while (<F2>){
    	chomp;
    	@fields = split;
    	if ( ( $neg eq "DIFF" && ! exists $present{$fields[$Column2-1]} ) || ( $neg eq "" && exists $present{$fields[$Column2-1]} ) ) { print "$_\n"; }
    }
	close F2;

} else {
    die "*** ERROR ***  Please, indicate the type of input file: gzipped [GZIP1/2/B] or uncompressed [NORM]! (Arguments are case-sensitive.)\n";
}

print STDERR "+ \n";
print STDERR "+ Wow. That was a lot of work. I'm glad it's done. Let's have beer, buddy!\n";
my $newtime = localtime; # scalar context
print STDERR "+ The current date and time is: $newtime.\n";
print STDERR "+ \n";
print STDERR "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
print STDERR "+ The MIT License (MIT)                                                                  +\n";
print STDERR "+ Copyright (c) 2016-2017 Sander W. van der Laan                                         +\n";
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

