#!/bin/bash

source $(dirname $0)/argparse.bash || exit 1
argparse "$@" <<EOF || exit 1
parser.add_argument('unmapped')
parser.add_argument('out_dir')
EOF

prefix=$(basename "$UNMAPPED" .fastq)
OUT=$OUT_DIR"/"$prefix

mkdir $OUT_DIR


sample=$OUT_DIR/${prefix}


module load samtools
module load bowtie2
module load bcftools


pwd

DB=/PHShome/sv188/needle/db_human/


echo $sample


module load bwa 

bwa mem -a ${DB}/viral.vipr/NONFLU_All.fastq $UNMAPPED | samtools view -S -b -F 4 - | samtools sort - >${sample}.virus.bam
bwa mem -a ${DB}/fungi/fungi.ncbi.february.3.2018.fasta $UNMAPPED | samtools view -S -b -F 4 - |  samtools sort - >${sample}.fungi.bam
bwa mem -a ${DB}/protozoa/protozoa.ncbi.february.3.2018.fasta $UNMAPPED | samtools view -S -b -F 4 - | samtools sort - >${sample}.protozoa.bam


/PHShome/sv188//anaconda3/bin/python /PHShome/sv188/sbt/count.microbiome.reads.py ${sample}.virus.bam ${OUT_DIR}/temp_viral_reads.txt
/PHShome/sv188//anaconda3/bin/python /PHShome/sv188/sbt/count.microbiome.reads.py ${sample}.fungi.bam ${OUT_DIR}/temp_fungi_reads.txt
/PHShome/sv188//anaconda3/bin/python /PHShome/sv188/sbt/count.microbiome.reads.py ${sample}.protozoa.bam ${OUT_DIR}/temp_protozoa_reads.txt



n_viral=$( cat ${OUT_DIR}/temp_viral_reads.txt | wc -l)
n_fungi=$( cat ${OUT_DIR}/temp_fungi_reads.txt | wc -l)
n_protozoa=$( cat ${OUT_DIR}/temp_protozoa_reads.txt | wc -l)

n_microbiome=$( cat ${OUT_DIR}/temp_viral_reads.txt ${OUT_DIR}/temp_fungi_reads.txt  ${OUT_DIR}/temp_protozoa_reads.txt | wc -l)

echo n_viral,n_fungi,n_protozoa,n_microbiome>${OUT_DIR}/summary_microbiome.csv
echo $n_viral,$n_fungi,$n_protozoa,$n_microbiome>>${OUT_DIR}/summary_microbiome.csv

rm -fr ${OUT_DIR}/temp*







#rm -fr ${OUT_DIR}_temp


