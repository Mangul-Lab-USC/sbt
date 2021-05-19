#!/bin/bash
source $(dirname $0)/settings.sh || exit 1
source $(dirname $0)/argparse.bash || exit 1
argparse "$@" <<EOF || exit 1
parser.add_argument('bam')
parser.add_argument('out_dir')
EOF

prefix=$(basename "$BAM" .bam)
OUT=$OUT_DIR"/"$prefix

sample_name=$prefix


rm -rf $OUT_DIR
mkdir -p $OUT_DIR
cd $OUT_DIR


imrep=$imrepDir/imrep.py
clonality=$imrepDir/clonality.py


if [ $hg -eq 19 ]; then

    $python $imrep --hg19 --noCast --noOverlapStep --bam $BAM ${OUT}.cdr3

elif [ $hg -eq 38 ]; then

    $python $imrep  --chrFormat2 --hg38 --noCast --noOverlapStep --bam $BAM ${OUT}.cdr3
fi

$python $clonality ${OUT}.cdr3  $OUT_DIR

mv ${OUT_DIR}/summary.cdr3.txt  ${OUT_DIR}/summary_cdr3.csv
mv ${OUT_DIR}/summary.VJ.txt  ${OUT_DIR}/summary_VJ.csv


rm -f ${OUT_DIR}/${sample_name}_input.fasta
