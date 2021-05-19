#!/bin/bash

source $(dirname $0)/settings.sh || exit 1
source $(dirname $0)/argparse.bash || exit 1
argparse "$@" <<EOF || exit 1
parser.add_argument('in_fastq_unm')

parser.add_argument('out_dir')
EOF

prefix=$(basename "$IN_FASTQ_UNM" _rdna_candidate.fastq)
OUT=$OUT_DIR"/"$prefix

sample=$prefix

rm -rf $OUT_DIR
mkdir $OUT_DIR

cd $OUT_DIR


bam_rDNA=${OUT}.rDNA.sort.rDNA.bam
header=${OUT}.header.txt
bam_rDNA_unique=${OUT}.rDNA.sort.rDNA.unique.bam
cov=${OUT}.rDNA.cov
bcf=${OUT}.rDNA.bcf


$bowtie2 -x $dbDir/rDNA.db/rDNA_ref --end-to-end $IN_FASTQ_UNM | samtools view -F 4 -bh - | samtools sort - >$bam_rDNA


samtools index $bam_rDNA

samtools view -H $bam_rDNA >$header
samtools view -F 12  $bam_rDNA | grep -v "XS:" | cat $header - | samtools view -b - > $bam_rDNA_unique
samtools depth $bam_rDNA_unique >$cov

cov_28S=$(awk '{if ($1=="M11167.1") print $3}' $cov | awk '{s+=$1} END {print s/5025}')
cov_18S=$(awk '{if ($1=="X03205.1") print $3}' $cov | awk '{s+=$1} END {print s/1869}')
cov_5S=$(awk '{if ($1=="X12811.1") print $3}' $cov | awk '{s+=$1} END {print s/2231}')


echo "sample,5S_dosage,18S_dosage,28S_dosage" >${OUT_DIR}/summary_rDNA.csv
echo "${sample},${cov_5S},${cov_18S},${cov_28S}" >>${OUT_DIR}/summary_rDNA.csv


rm -fr $bam_rDNA
rm -fr ${bam_rDNA}.bai
rm -fr $header
rm -fr $bam_rDNA_unique
