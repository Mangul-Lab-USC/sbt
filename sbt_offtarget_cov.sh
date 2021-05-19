#!/bin/bash
source $(dirname $0)/settings.sh || exit 1
source $(dirname $0)/argparse.bash || exit 1
argparse "$@" <<EOF || exit 1
parser.add_argument('bam')
parser.add_argument('out_dir')
EOF

prefix=$(basename "$BAM" .bam)
OUT=$OUT_DIR"/"$prefix


rm -rf $OUT_DIR
mkdir $OUT_DIR
cd $OUT_DIR

if [ $hg -eq 19 ]; then

    intergenic_regions=$dbDir/intergenic.regions/intergenic.regions.hg19.autosomes.bed
    chr_name=""

elif [ $hg -eq 38 ]; then

    intergenic_regions=$dbDir/intergenic.regions/intergenic.regions.hg38.autosomes.bed
    chr_name="chr"

fi

while read line
do
  chr=$(echo $line | awk '{print $1}')
  x=$(echo $line | awk '{print $2}')
  y=$(echo $line | awk '{print $3}')

  n=0
  n=$(samtools view -bh $BAM ${chr_name}$chr:$x-$y | samtools  depth - | awk '{s+=$3} END {print s}')

  echo $chr,${x},${y},${n} >>${OUT}.offtarget.cov

done < $intergenic_regions

offcov=$(awk 'BEGIN {FS=","; sum1=0; sum2=0;} {sum1+=$3-$2; sum2+=$4} END {print sum2/sum1}' < ${OUT}.offtarget.cov)

echo "sample,offcov" > ${OUT_DIR}/summary_offcov.csv
echo "$prefix,$offcov" >> ${OUT_DIR}/summary_offcov.csv
