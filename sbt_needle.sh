#!/bin/bash

source $(dirname $0)/settings.sh || exit 1
source $(dirname $0)/argparse.bash || exit 1
argparse "$@" <<EOF || exit 1
parser.add_argument('unmapped')
parser.add_argument('out_dir')
EOF

prefix=$(basename "$UNMAPPED" .fastq)
OUT=$OUT_DIR"/"$prefix

sample_name=$(basename "$UNMAPPED" _extended_unmapped.fastq)

rm -rf $OUT_DIR
mkdir -p  $OUT_DIR

sample=$OUT_DIR/${prefix}


$bwa mem -a $dbDir/viral.db/NONFLU_All.fastq $UNMAPPED | samtools view -S -b -F 4 - | samtools sort - >${sample}.virus.bam
$bwa mem -a $dbDir/fungi.db/fungi.ncbi.february.3.2018.fasta $UNMAPPED | samtools view -S -b -F 4 - |  samtools sort - >${sample}.fungi.bam
$bwa mem -a $dbDir/protozoa.db/protozoa.ncbi.february.3.2018.fasta $UNMAPPED | samtools view -S -b -F 4 - | samtools sort - >${sample}.protozoa.bam

$python $sbtDir/count.microbiome.reads.py ${sample}.virus.bam ${OUT_DIR}/temp_viral_reads.txt
$python $sbtDir/count.microbiome.reads.py ${sample}.fungi.bam ${OUT_DIR}/temp_fungi_reads.txt
$python $sbtDir/count.microbiome.reads.py ${sample}.protozoa.bam ${OUT_DIR}/temp_protozoa_reads.txt

n_viral=$( cat ${OUT_DIR}/temp_viral_reads.txt | wc -l)
n_fungi=$( cat ${OUT_DIR}/temp_fungi_reads.txt | wc -l)
n_protozoa=$( cat ${OUT_DIR}/temp_protozoa_reads.txt | wc -l)

n_microbiome=$( cat ${OUT_DIR}/temp_viral_reads.txt ${OUT_DIR}/temp_fungi_reads.txt  ${OUT_DIR}/temp_protozoa_reads.txt | wc -l)

echo sample,n_viral,n_fungi,n_protozoa,n_microbiome>${OUT_DIR}/summary_microbiome.csv
echo ${sample_name},${n_viral},${n_fungi},${n_protozoa},${n_microbiome} >>${OUT_DIR}/summary_microbiome.csv


rm -f ${OUT_DIR}/temp*
