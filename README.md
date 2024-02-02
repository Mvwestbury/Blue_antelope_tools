# Blue_antelope_tools

## Adding G-T damage to fastq files
`Rscript mutator.R [options]`
 - Options:
        -f FASTQ, --fastq=FASTQ
                your fastq file
        -N NUMBER, --number=NUMBER
                number of reads you want to damage
        -o OUTPUT, --output=OUTPUT
                your ouputtfile
        -h, --help
                Show this help message and exit


## Heterozygosity
### Base calls using ANGSD

 - Perform the base calling in ANGSD specifying dumpcounts to print the counts and your filtering parameters of choice
   
`angsd -minq 20 -minmapq 20 -uniqueOnly 1 -remove_bads 1 -docounts 1 -dumpCounts 4 -i NRM590107.bam -out NRM590107 -setMinDepthInd 10 -rf Autosomes.txt -nthreads 10`
 - Unzip the output that countains all the site information
   
`gunzip NRM590107.pos.gz`
 - Open the base counts | remove the header | perform the base calling with our script | add the header | Paste together the base counts and the site position information
   
`zcat NRM590107.counts.gz | tail -n +2 | sh Basecalls_0.1.sh - | cat header.txt - | paste NRM590107.pos - > NRM590107.basecall.txt`

### Print the minor allele frequency by each specific heterozygosity type (for plotting)
 - Extract only the sites that have a heterozygous base call | print the base call and the frequency of the minor allele | count the output
   
`grep HET NRM590107.basecall.txt | awk '{split($0, arr); delete arr[1]; delete arr[2]; delete arr[3]; delete arr[8]; asort(arr); print arr[length(arr)-2],$8}' | sort | uniq -c > NRM590107.minorfreq2.txt`

 - Split each heterozygousity type into separate txt files
   
`grep AC NRM590107.minorfreq2.txt > NRM590107.minorfreq2_AC.txt`

`grep AG NRM590107.minorfreq2.txt > NRM590107.minorfreq2_AG.txt`

`grep AT NRM590107.minorfreq2.txt > NRM590107.minorfreq2_AT.txt`

`grep CG NRM590107.minorfreq2.txt > NRM590107.minorfreq2_CG.txt`

`grep CT NRM590107.minorfreq2.txt > NRM590107.minorfreq2_CT.txt`

`grep GT NRM590107.minorfreq2.txt > NRM590107.minorfreq2_GT.txt`


### Runs of homozygosity
 - Generate ROH counts from the original basecall file and specifying the thresholds. In this example we have calculate heterozygosity in 100kb windows, a window must have 25kb of data to be considered, and a window with a heterozygosity <0.0001 is considered for ROH
   
`python ROH.py NRM590107.basecall.txt 100000 25000 0.0001 > NRM590107.ROH`

## Scripts that were used to generate numbers for the SNP tracts 

1. Consensus sequences from samples mapped to the same reference were used as input for the script "findTracts.pl", which outputs biallelic sites and their genomic positions that are of topology ABBA (+1), BABA (-1), and BBAA (0). The script requires as input a transposed alignment.

2. From the resulting files, SNP tracts were computed with the script "countSNPs.pl" as described in the publication: At least 10 consecutively scored sites of a focal topology were extracted, but up to 4 consecutive sites of the other two topologies were allowed. From these, only tracts in which 75% of the positions were scored as the focal topology were kept. The script as provided computes ABBA tracts. Adjustments for BABA dn BBAA need to be made. 
