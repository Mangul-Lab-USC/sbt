#!/bin/bash

which python

source $(dirname $0)/settings.sh || exit 1
source $(dirname $0)/argparse.bash || exit 1
argparse "$@" <<EOF || exit 1
parser.add_argument('bam')
parser.add_argument('out_dir')
EOF

echo "OutputDir "$OUT_DIR

mkdir -p $OUT_DIR
cd $OUT_DIR

PREFIX=$(basename "$BAM" .bam)

FASTQ_UNM=${OUT_DIR}/${PREFIX}_extended_unmapped.fastq
FASTQ_MT=${OUT_DIR}/${PREFIX}_MT.fastq
FASTQ_RDNA_CANDIDATE=${OUT_DIR}/${PREFIX}_rdna_candidate.fastq

rm -fr master_${PREFIX}.sh

rm -fr $OUT_DIR/*
rm -fr $FASTQ_UNM
rm -fr $FASTQ_MT
rm -f $FASTQ_RDNA_CANDIDATE

if [ $run_rDNA = true ] | [ $run_needle = true ]; then

    samtools view -H $BAM  | grep SN | awk '{print $2}' | awk -F ":" '{if ($1=="SN") print $2}' | sort | uniq | grep -v chr  | grep -v "^[1-9]$" | grep -v "^[1-9][0-9]$" | grep -v "^MT$" | grep -v "^X$" | grep -v "^Y$" | grep -v "GL000">non.human.references.txt


    echo "Number of non human references"
    wc -l non.human.references.txt

    #unmapped reads
    while read line
    do
      echo $line
      echo "samtools view -bh $BAM $line | samtools fastq - >> $FASTQ_UNM">>master_${PREFIX}.sh

    done<non.human.references.txt

    echo "samtools view -f4 -bh $BAM | samtools fastq - >>$FASTQ_UNM">>master_${PREFIX}.sh

fi

if [ $run_rDNA = true ]; then

    echo "cat $FASTQ_UNM > $FASTQ_RDNA_CANDIDATE">>master_${PREFIX}.sh

    if [ $hg -eq 19 ]; then

        while read line; do

          chr=$(echo $line | awk -F "," '{print $1}');
          x=$(echo $line | awk -F "," '{print $2}');
          y=$(echo $line | awk -F "," '{print $3}');
          echo "samtools view -bh $BAM $chr:$x-$y | samtools fastq - >> $FASTQ_RDNA_CANDIDATE">>master_${PREFIX}.sh

        done < $dbDir/rDNA.db/rDNA_filter_hg19_k75.txt

    elif [ $hg -eq 38 ]; then

        while read line; do

          chr=$(echo $line | awk -F "," '{print $1}');
          x=$(echo $line | awk -F "," '{print $2}');
          y=$(echo $line | awk -F "," '{print $3}');
          echo "samtools view -bh $BAM chr$chr:$x-$y | samtools fastq - >> $FASTQ_RDNA_CANDIDATE">>master_${PREFIX}.sh

        done < $dbDir/rDNA.db/rDNA_filter_hg38_k75.txt
    fi

fi

#mtDNA
if [ $run_mtDNA = true ]; then

    if [ $hg -eq 19 ]; then

          samtools view -bh $BAM MT | samtools fastq - >$FASTQ_MT

    elif [ $hg -eq 38 ]; then

          samtools view -bh $BAM chrM | samtools fastq - >$FASTQ_MT
    fi

fi

if [ $run_mtDNA = true ]; then
    echo $sbtDir"/sbt_mtDNA.sh $FASTQ_MT ${OUT_DIR}/${PREFIX}_mtDNA/">>master_${PREFIX}.sh
fi

if [ $run_rDNA = true ]; then
    echo $sbtDir"/sbt_rDNA.sh $FASTQ_RDNA_CANDIDATE ${OUT_DIR}/${PREFIX}_rDNA/">>master_${PREFIX}.sh
fi

if [ $run_needle = true ] ; then
    echo $sbtDir"/sbt_needle.sh $FASTQ_UNM ${OUT_DIR}/${PREFIX}_needle/">>master_${PREFIX}.sh
fi

if [ $run_imrep = true ]; then
    echo $sbtDir"/sbt_imrep.sh ${BAM} ${OUT_DIR}/${PREFIX}_imrep/">>master_${PREFIX}.sh
fi

if [ $run_offcov = true ]; then
    echo $sbtDir"/sbt_offtarget_cov.sh ${BAM} ${OUT_DIR}/${PREFIX}_offcov/">>master_${PREFIX}.sh
fi

if [ $run_count_reads = true ]; then
    echo "$python $sbtDir/number.reads.bam.py $BAM ${OUT_DIR}/summary_reads.csv">>master_${PREFIX}.sh
fi


chmod 755 master_${PREFIX}.sh

./master_${PREFIX}.sh

$python $sbtDir/merge_summaries.py  ${PREFIX} ${OUT_DIR} $summaryDir
