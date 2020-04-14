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

rm -fr $OUT_DIR
mkdir $OUT_DIR


while read line
do
chr=$(echo $line | awk '{print $1}')
x=$(echo $line | awk '{print $2}')
y=$(echo $line | awk '{print $3}')

n=0
n=$(samtools view -bh $BAM $chr:$x-$y | samtools  depth - | awk '{s+=$3} END {print s}')

echo $chr,$x,$y,$n >>${OUT}.offtarget.cov
done</PHShome/sv188/sbt/db.human/intergenic.regions/intergenic.regions.hg19.autosomes.bed





