#!/bin/bash

source $(dirname $0)/settings.sh || exit 1
source $(dirname $0)/argparse.bash || exit 1
argparse "$@" <<EOF || exit 1
parser.add_argument('in_fastq')
parser.add_argument('out_dir')
EOF

prefix=$(basename "$IN_FASTQ" .bam)
OUT=$OUT_DIR"/"$prefix

rm -fr $OUT_DIR
mkdir -p $OUT_DIR
cd $OUT_DIR

sample_name=$(basename "$IN_FASTQ"  _MT.fastq)


bam_mtDNA=${OUT}.mtDNA.sort.bam
header=${OUT}.header.txt
bam_mtDNA_unique=${OUT}.mtDNA.sort.unique.bam
cov=${OUT}.mtDNA.cov
bcf=${OUT}.mtDNA.bcf


$bowtie2  -x $dbDir/mtDNA.db/mtDNA --end-to-end $IN_FASTQ | samtools view -F 4 -bh - | samtools sort - >$bam_mtDNA
samtools index $bam_mtDNA
samtools view -H $bam_mtDNA >$header
samtools view -F 12  $bam_mtDNA | grep -v "XS:" | cat $header - | samtools view -b - > $bam_mtDNA_unique
samtools depth $bam_mtDNA_unique >$cov

#diversity
samtools mpileup -uf $dbDir/mtDNA.db/mtDNA.fasta $bam_mtDNA_unique | bcftools  call -mv -Oz >$bcf

cov=$(awk '{print $3}' $cov | awk '{s+=$1} END {print s/16569}')

echo "sample,mtDNA_dosage" >${OUT_DIR}/summary_mtDNA.csv
echo "${sample_name},$cov" >>${OUT_DIR}/summary_mtDNA.csv


rm -fr ${bam_mtDNA}
rm -fr ${bam_mtDNA}.bai
rm -fr ${bam_mtDNA_unique}
rm -fr $header
