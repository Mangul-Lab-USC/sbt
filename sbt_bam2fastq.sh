#!/bin/bash

source $(dirname $0)/argparse.bash || exit 1
argparse "$@" <<EOF || exit 1
parser.add_argument('bam')
parser.add_argument('out')
EOF

echo "------------- ... Extract unmapped reads from " $BAM "-------------"

module load samtools
samtools fastq $BAM -1 ${OUT}_1.fastq -2 ${OUT}_2.fastq



echo "Unmapped reads were extracted to ",${OUT}



# Human gammaherpesvirus 4 -- NC_007605

