#!/usr/bin/perl -w
#
# SOLUTION 1
# https://stackoverflow.com/questions/21754569/how-to-efficiently-get-10-of-random-lines-out-of-the-large-file-in-linux

# For a large enough $ratio, assuming a uniform distribution of rand's outputs.
# 
# Assuming you call this random_select_ratio.pl, run it like this to get 10% of the lines:
# 
# random_select_ratio.pl 10 my_file
# or
# 
# cat my_file | random_select_ratio.pl 10

use strict;

my $ratio = shift;

while (<>) {
	print if ((rand) <= 1 / $ratio);
}

# SOLUTION 2
# http://data-analytics-tools.blogspot.com/2009/09/reservoir-sampling-algorithm-in-perl.html
# https://stackoverflow.com/questions/692312/randomly-pick-lines-from-a-file-without-slurping-it-with-unix

#!/usr/bin/perl -sw

# $IN = 'STDIN' if (@ARGV == 1);
# open($IN, '<'.$ARGV[1]) if (@ARGV == 2);
# die "Usage:  perl random_select_ratio.pl <lines> <?file>\n" if (!defined($IN));
# 
# $N = $ARGV[0];
# @sample = ();
# 
# while (<$IN>) {
# 	if ($. <= $N) {
# 		$sample[$.-1] = $_;
# 	} elsif (($. > $N) && (rand() < $N/$.)) {
# 		$replace = int(rand(@sample));
# 		$sample[$replace] = $_;
# 	}
# }
# 
# print foreach (@sample);
# close($IN);
