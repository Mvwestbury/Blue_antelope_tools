# Blue_antelope_tools


## Heterozygosity
### Base calls using ANGSD
angsd -minq 20 -minmapq 20 -uniqueOnly 1 -remove_bads 1 -docounts 1 -dumpCounts 4 -i $line.bam -out NRM590107 -setMinDepthInd 10 -rf Autosomes.txt -nthreads 10

gunzip NRM590107.pos.gz

zcat NRM590107.counts.gz | tail -n +2 | sh Basecalls_0.05.sh - | cat header.txt - | paste Mega_MG3_merge.pos - > NRM590107.basecall.txt

### Print the minor allele frequency by het type (for plotting)
ls *.basecall.txt |sed 's/.basecall.txt//g' |while read -r line

do

grep HET $line.basecall.txt | awk '{split($0, arr); delete arr[1]; delete arr[2]; delete arr[3]; delete arr[8]; asort(arr); print arr[length(arr)-2],$8}' | sort | uniq -c > $line.minorfreq2.txt

grep AC $line.minorfreq2.txt > $line.minorfreq2_AC.txt

grep AG $line.minorfreq2.txt > $line.minorfreq2_AG.txt

grep AT $line.minorfreq2.txt > $line.minorfreq2_AT.txt

grep CG $line.minorfreq2.txt > $line.minorfreq2_CG.txt

grep CT $line.minorfreq2.txt > $line.minorfreq2_CT.txt

grep GT $line.minorfreq2.txt > $line.minorfreq2_GT.txt

done

### Runs of homozygosity
python ROH.py NRM590107.basecall.txt 100000 25000 0.0001 > NRM590107.ROH
