#!/usr/bin/perl -w

use strict;
use Data::Dumper;
use Bio::SeqIO; 
use Bio::AlignIO; 
use Bio::SimpleAlign;
use Bio::Index::Fasta; 


# get IDs
my @ids = qx(grep ">" data3/oryx.fasta);

opendir (DIR, "data3") or die $!;
my @fastas = grep /.*\.fasta$/, readdir(DIR);  
close(DIR);
my $inx = Bio::Index::Fasta->new(-filename => "fastaINDX",  -write_flag => 1);
foreach my $infile (@fastas) {
     print "indexing $infile\n";
     $inx->make_index("data3/$infile");
}

foreach my $id (@ids) {
    chomp($id); 
    $id =~ s/>//;
    my $seq_or = $inx->get_Seq_by_id($id); 
    my $seqStrg_or = $seq_or->seq;
    my $length = length($seqStrg_or);
    if ($length >= 10000) { 
        my $out = $id . "_t.txt";
        $out =~ s/or_//;
        print "$out\n";
        open  (OUT, ">tractsST/$out") or die $! ;
        
        $id =~ s/or_//;
        my $id_bl = "bl_" . $id; 
        my $id_ro = "ro_" . $id; 
        my $id_sa = "sa_" . $id; 
        
        my $seq_bl = $inx->get_Seq_by_id($id_bl); 
        my $seq_ro = $inx->get_Seq_by_id($id_ro); 
        my $seq_sa = $inx->get_Seq_by_id($id_sa); 
        
        my $seqStrg_bl = $seq_bl->seq;
        my $seqStrg_ro = $seq_ro->seq;
        my $seqStrg_sa = $seq_sa->seq;
        
        for (my $i = 0; $i < $length; $i++) {
            my @nts = ();
            my $column = substr($seqStrg_bl, $i, 1) . substr($seqStrg_sa, $i, 1) . substr($seqStrg_ro, $i, 1) . substr($seqStrg_or, $i, 1);
            if  ($column =~ /-/)  { next; }
            
            my $bl = substr($seqStrg_bl, $i, 1); push(@nts,$bl);
            my $sa = substr($seqStrg_sa, $i, 1); push(@nts,$sa);
            my $ro = substr($seqStrg_ro, $i, 1); push(@nts,$ro);
            my $or = substr($seqStrg_or, $i, 1); push(@nts,$or);
            
            undef my %saw;
            my @uniq = grep(!$saw{$_}++, @nts);  
            my $howMany = @uniq;
            
            if ($howMany == 1) {
                # all Ns, break discordant stretch and use 0
                if ($uniq[0] eq "N") {
                    print OUT "2 \t$i\n";    
                }
            } elsif ($howMany == 2) {       # need biallelic
            my $containsN = 0; 
                foreach my $j (@uniq) {
                    if ($j eq "N") {
                        $containsN = 1; 
                    }
                }
                
                my %counts;
                foreach my $nt (@nts) {
                    $counts{$nt}++;
                }
                my $check = ""; 
                foreach my $element (keys %counts) {
                    $check = $check . "_" . $counts{$element};
                }
                                    
                if (  ($check eq "_2_2") && ($containsN == 0)  ){    # need two of each nt
                    if ($bl ne $sa ) {    
                        if ($ro ne $or) { 
                            if    ($ro eq $bl) { print OUT "-1\t$i\n"; }   # BABA
                            elsif ($ro eq $sa) { print OUT "+1\t$i\n"; }   # ABBA
                        } # end $bl ne $sa
                    } # end $bl ne $sa
                
                    else { 
                        print OUT "0\t$i\n"; 
                    } # end if it's not ABBA or BABA or BBAA
                
                } elsif (  ($check eq "_2_2") && ($containsN == 1)  )  { 
                    # skip, it has two Ns and two bases
                } else  {  # but if it's not "_2_2"
                    if ( ($bl eq $sa) && ($bl eq $ro) ) {
                        print OUT "2\t$i\n";    
                   }  # end check the 3:1 sites
                } # end for the 2:2 / 3:1 checks         
            } # end if biallelic
        } # end for each column
    } # end if >= 50000
} # end foreach id
    
    

