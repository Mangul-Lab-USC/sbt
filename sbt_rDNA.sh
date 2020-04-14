#!/bin/bash

source $(dirname $0)/argparse.bash || exit 1
argparse "$@" <<EOF || exit 1
parser.add_argument('in_fastq_unm')
parser.add_argument('in_fastq_cand_rdna')

parser.add_argument('out_dir')
EOF

prefix=$(basename "$IN_FASTQ_UNM" .bam)
OUT=$OUT_DIR"/"$prefix

mkdir $OUT_DIR
cd $OUT_DIR





module load samtools
module load bowtie2
module load bcftools

bam_rDNA=${OUT}.rDNA.sort.rDNA.bam
header=${OUT}.header.txt
bam_rDNA_unique=${OUT}.rDNA.sort.rDNA.unique.bam
cov=${OUT}.rDNA.cov
bcf=${OUT}.rDNA.bcf

rm -fr $OUT_DIR
mkdir $OUT_DIR


echo "input"
ls -lh $IN_FASTQ_UNM
ls -lh $IN_FASTQ_CAND_RDNA


cat $IN_FASTQ_UNM $IN_FASTQ_CAND_RDNA | bowtie2  -x /PHShome/sv188/sbt/rDNA.db/rDNA_ref --end-to-end - | samtools view -F 4 -bh - | samtools sort - >$bam_rDNA

ls -lh $bam_rDNA


samtools index $bam_rDNA

samtools view -H $bam_rDNA >$header
samtools view -F 12  $bam_rDNA | grep -v "XS:" | cat $header - | samtools view -b - > $bam_rDNA_unique
samtools depth $bam_rDNA_unique >$cov

cov_28S=$(awk '{if ($1=="M11167.1") print $3}' $cov | awk '{s+=$1} END {print s/5025}')
cov_18S=$(awk '{if ($1=="X03205.1") print $3}' $cov | awk '{s+=$1} END {print s/1869}')
cov_5S=$(awk '{if ($1=="X12811.1") print $3}' $cov | awk '{s+=$1} END {print s/2231}')

echo "sample,rDNA_unit,rDNA_ID,dosage" >${OUT_DIR}/summary_rDNA.csv
echo "${OUT},28S,M11167.1,$cov_28S" >>${OUT_DIR}/summary_rDNA.csv
echo "${OUT},18S,X03205.1,$cov_18S">>${OUT_DIR}/summary_rDNA.csv
echo "${OUT},5S,X12811.1,$cov_5S">>${OUT_DIR}/summary_rDNA.csv

rm -fr $IN_FASTQ_CAND_RDNA

#M11167.1
#X03205.1
#X12811.1



rm -fr $bam_rDNA
rm -fr ${bam_rDNA}.bai
rm -fr $header
rm -fr $bam_rDNA_unique



