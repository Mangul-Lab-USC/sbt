import pysam
import csv
import argparse
import os
import gzip
import sys

ap = argparse.ArgumentParser()
ap.add_argument('bam', help='--')
ap.add_argument('out', help='--')

args = ap.parse_args()

fileOut=open(args.out,"w")

n_reads=0

reads_set=set()

with pysam.AlignmentFile(args.bam, 'rb', check_sq=False) as input_fo:

   for read in input_fo.fetch(until_eof=True):

      number_mismatches = int(read.get_tag('NM'))

      read_length = int(read.infer_read_length())

      alignment_length = int(read.query_alignment_length)

      soft = read_length - alignment_length

      prc_mapped= alignment_length/read_length
    
      identity= 1-(number_mismatches)/float(alignment_length)

      if (prc_mapped>=0.8) and (identity>0.9):
         reads_set.add(read.query_name)
      
print ("Number of reads",len(reads_set))

for i in reads_set:
   fileOut.write(i)
   fileOut.write("\n")

fileOut.close()
print ("Done!")
