#!/usr/bin/perl

use strict;
use warnings;

my $interruption_limit = 4;

opendir (DIR, "tracts/") or die $!;          
my @files = grep /_t\.txt$/, readdir(DIR);    
close(DIR);

my $finalCountBABA = 0; 
my $collectBABA    = 0;
my $finalCountABBA = 0; 
my $collectABBA    = 0;

open  (OUTK, ">ABBAs_keep.txt") or die $!;   
open  (OUTS, ">ABBAs_skip.txt") or die $!;   

foreach my $inFile (@files) {
    
    my @col2;
    my @col1;
    open  (INFILE, "tracts/$inFile") or die $!;   
    
    while (my $line = <INFILE>) {
        chomp($line);
        my @linearray = split("\t", $line); 
        my $c1 = $linearray[0];
        my $c2 = $linearray[1];
        push @col1, $c1;
        push @col2, $c2;
    }

    my $row_count = @col1; 

    my $i = 0;
    my $start;
    my $end;

    while ($i < $row_count) {
        if ($col1[$i] == 1) {                                      # ABBA-mod
            $start = $i;
            my $j = $i + 1;
            my $interruption_count = 0;
            while ($j < $row_count) {
                if ($col1[$j] == 1) {                              # ABBA-mod
                    $collectABBA++;                                # ABBA-mod
                    $interruption_count = 0;
                } # end if the next one also is the same
                
                elsif ($col1[$j] == 0 || $col1[$j] == -1) {        # ABBA-mod
                    $interruption_count++;
                    if ( $col1[$j] == -1) {
                        $collectBABA++;
                    }
                    if ($interruption_count > $interruption_limit) {
                        last;
                    }
                } # end if the next is something else
            
                $j++;
            }
            $end = $j - $interruption_count; 
            #$end = $j - 1;
            if ($end - $start + 1 >= 10) {
                my $length = $col2[$end] - $col2[$start];
                $finalCountBABA = $finalCountBABA + $collectBABA;                # ABBA-mod
                $finalCountABBA = $finalCountABBA + $collectABBA + 1;            # ABBA-mod
                
                my $sum = $collectBABA+$collectABBA;
                my $pcnt = $collectBABA / $sum * 100;                            # ABBA-mod
                
                if ($pcnt <= 25) {
                    print OUTK "$length\t$collectABBA\t$collectBABA\t$pcnt\n";   # ABBA-mod
                } 
                else { 
                    print OUTS "$length\n"; 
                }
                                    
                $collectBABA = 0;  
                $collectABBA = 0;  
            }
            $i = $end;
        } # end if col contains =1
        $i++;
    }
    

}
