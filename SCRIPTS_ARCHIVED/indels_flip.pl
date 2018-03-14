

#sub indels_flip($)
#{
	my $indel_a1 = "R";
	my $indel_a2 = "D";
	my $flipped_indel_a1 = "";
	my $flipped_indel_a2 = "";
	print STDERR "Given alleles: \t\t[ $indel_a1 / $indel_a2 ].\n";
	for (my $i=0; $i < length($indel_a1); $i++) {
		my $current_base_indel_a1 = substr $indel_a1, $i, 1;
		my $current_base_indel_a2 = substr $indel_a2, $i, 1;
		if ( $current_base_indel_a1 eq "D" && $current_base_indel_a2 eq "I" ) { $flipped_indel_a1 .= "I"; $flipped_indel_a2 .= "D"; }
		elsif ( $current_base_indel_a1 eq "I" && $current_base_indel_a2 eq "D" ) { $flipped_indel_a1 .= "D"; $flipped_indel_a2 .= "I"; }
 		elsif ( $current_base_indel_a1 eq "R" && $current_base_indel_a2 eq "D" ) { $flipped_indel_a1 .= "D"; $flipped_indel_a2 .= "R"; }
 		elsif ( $current_base_indel_a1 eq "R" && $current_base_indel_a2 eq "I" ) { $flipped_indel_a1 .= "I"; $flipped_indel_a2 .= "R"; }
		else { $flipped_indel .= $current_base; }
# 		print STDERR "T ***DEBUG*** he allele was flipped from [ $current_base ] to [ $flipped_indel ].\n";
		}
#	return $flipped_indel;
#}
print STDERR "The flipped base is: \t[ $flipped_indel_a1 / $flipped_indel_a2 ].\n";


#print STDERR "Given allele: \t\t[ $allele ].\n";
#for (my $i=0; $i < length($allele); $i++) {
#    my $current_base = substr $allele, $i, 1;
#    
##     print STDERR "The current base is: [ $current_base ].\n";
#    
##     my $flipped_allele = $current_base =~ s/A/T/gr =~ s/C/Y/gr =~ s/G/C/gr =~ s/T/A/gr;
#    
##     print STDERR "The flipped base is: [ $flipped_allele ].\n";
##     s/acgt/tgca/gr
#    
#    if ( $current_base eq "A" ) { $flipped_allele = $flipped_allele . $current_base =~ s/A/T/gr; }
#    elsif ( $current_base eq "C" ) { $flipped_allele = $flipped_allele . $current_base =~ s/C/G/gr; }
#    elsif ( $current_base eq "G" ) { $flipped_allele = $flipped_allele . $current_base =~ s/G/C/gr; }
#    elsif ( $current_base eq "T" ) { $flipped_allele = $flipped_allele . $current_base =~ s/T/A/gr; }
#    else { $flipped_allele .= $current_base; }
#    
#   
#  }
#print STDERR "The flipped base is: \t[ $flipped_allele ].\n";