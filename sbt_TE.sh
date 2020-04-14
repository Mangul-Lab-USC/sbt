#!/bin/bash

source $(dirname $0)/argparse.bash || exit 1
argparse "$@" <<EOF || exit 1
parser.add_argument('in_fastq1')
parser.add_argument('in_fastq2')
parser.add_argument('out_dir')
EOF

prefix=$(basename "$IN_FASTQ1" .bam)
OUT=$OUT_DIR"/"$prefix

mkdir $OUT_DIR
cd $OUT_DIR





module load samtools
module load bowtie2
module load bcftools

bam=${OUT}.TE.sort.bam
header=${OUT}.header.txt
bamU=${OUT}.TE.sort.unique.bam
cov=${OUT}.TE.cov

rm -fr $OUT_DIR
mkdir $OUT_DIR


bowtie2  -x /PHShome/sv188/sbt/db.human/repeats/repbase.fa --end-to-end -1 $IN_FASTQ1 -2 $IN_FASTQ2 | samtools view -F 4 -bh - | samtools sort - >$bam




samtools index $bam

samtools view -H $bam >$header
samtools view -F 4  $bam | grep -v "XS:" | cat $header - | samtools view -b - > $bamU
samtools depth $bamU >$cov


rm -fr $bam
rm -fr ${bam}.bai
rm -fr $header
rm -fr $bamU



