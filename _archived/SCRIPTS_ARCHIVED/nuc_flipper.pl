my $allele = "ATTGACTCATCTACATCTACACCTGCAGCAGCTAGTG";

my $flipped_allele = "";
print STDERR "Given allele: \t\t[ $allele ].\n";
for (my $i=0; $i < length($allele); $i++) {
    my $current_base = substr $allele, $i, 1;
    
#     print STDERR "The current base is: [ $current_base ].\n";
    
#     my $flipped_allele = $current_base =~ s/A/T/gr =~ s/C/Y/gr =~ s/G/C/gr =~ s/T/A/gr;
    
#     print STDERR "The flipped base is: [ $flipped_allele ].\n";
#     s/acgt/tgca/gr
    
    if ( $current_base eq "A" ) { $flipped_allele = $flipped_allele . $current_base =~ s/A/T/gr; }
    elsif ( $current_base eq "C" ) { $flipped_allele = $flipped_allele . $current_base =~ s/C/G/gr; }
    elsif ( $current_base eq "G" ) { $flipped_allele = $flipped_allele . $current_base =~ s/G/C/gr; }
    elsif ( $current_base eq "T" ) { $flipped_allele = $flipped_allele . $current_base =~ s/T/A/gr; }
    else { $flipped_allele .= $current_base; }
    
   
  }
print STDERR "The flipped base is: \t[ $flipped_allele ].\n";