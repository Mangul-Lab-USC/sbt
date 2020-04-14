#!/bin/bash

source $(dirname $0)/argparse.bash || exit 1
argparse "$@" <<EOF || exit 1
parser.add_argument('bam')
parser.add_argument('out_dir')
EOF

prefix=$(basename "$BAM" .bam)
OUT=$OUT_DIR"/"$prefix

mkdir $OUT_DIR
cd $OUT_DIR





module load samtools
module load bowtie2
module load bcftools
module load python/2.7.3 
module load pysam/0.9.1.4


pip install jellyfish --user


imrep=/PHShome/sv188/imrep/imrep.py
python $imrep --noCast --noOverlapStep --bam $BAM ${OUT}.cdr3


rm -fr ${OUT}_input.fasta
