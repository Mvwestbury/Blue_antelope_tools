#!/usr/bin/env Rscript

# Dr. Grau @ amedes 
# SEPT 2022

suppressPackageStartupMessages(require(optparse))

option_list <- list(
  
  make_option(c("-f", "--fastq"), action="store", 
              default="your fastq file", 
              type='character',
              help="your fastq file"),
  
  make_option(c("-N", "--number"), action="store", 
              default="number of reads you want to damage", 
              type='numeric',
              help="number of reads you want to damage"),
  
  make_option(c("-o", "--output"), action="store", 
              default="your output fastq file", 
              type='character',
              help="your ouputtfile")
  
  # help option -h/--help is included by optparse by default
)

opt = parse_args(OptionParser(option_list=option_list))

# R no scientirfic notation
options("scipen"=100, "digits"=4)

require (Biostrings)
library("ShortRead")

fastq<- opt$fastq
output<-opt$output
damage<-opt$number

# define read file 
fq <- readFastq(fastq)

# get number of reads
numreads <- length(sread (fq))
totalreads <- 1:numreads

damage <- sample (1:numreads ,damage, replace = FALSE)
damage_reads <- fq[damage]

nodamage <- totalreads[!(totalreads %in% damage)]
nodamage_reads <-fq[nodamage]


for (i in 1:length(damage_reads)) {
  
  r <- as.character (sread(damage_reads)[[i]])
  
  y <- gregexpr ("G", r )[[1]][1]
  
  if (y >= 2) {
    
    N<- as.character (sread(damage_reads)[[i]][y])
    
    if (N == "G") {
      
      print ("G>T")
      
      damage_reads@sread[[i]][y] <- "T"
      
      damage_reads@id[[i]] <- paste0(damage_reads@id[[i]], ":", y, "G>T")
    }
    
  } else {print ("No Gs in read")}
}

writeFastq(damage_reads, file=output)
writeFastq(nodamage_reads, file=output, mode = "a")


    

