#!/bin/bash

#paths to commands, and sbt and summary directories
python=python3
bwa=bwa
bowtie2=bowtie2
imrepDir="./imrep"
sbtDir="./sbt"
dbDir="./sbt/dbs"

# output files (csv) are store in this folder
summaryDir="."

#Human genome reference builds (19 or 38)
hg=38

#tools that are executed by the sbt pipeline
run_mtDNA=true
run_rDNA=true
run_needle=true
run_offcov=true
run_imrep=true
run_count_reads=true
