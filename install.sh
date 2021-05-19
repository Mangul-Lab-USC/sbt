#!/bin/bash

pip install pysam pandas

# dependencies
conda install -c bioconda bowtie2 bwa samtools bcftools

git clone https://github.com/Mangul-Lab-USC/imrep.git
cd imrep
./install.sh
cd ..
