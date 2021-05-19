import csv
import sys
import argparse
from collections import Counter
import numpy
import pysam
import random
import os

ap = argparse.ArgumentParser()
ap.add_argument('inBam', help='inBam')
ap.add_argument('out', help='out txt file')

args = ap.parse_args()


filename = os.path.basename(args.inBam)
sample=os.path.splitext(filename)[0]

print(sample)


samfile = pysam.AlignmentFile(args.inBam) # Change me
fileOut=open(args.out,"w")

n_unique_pe=0
n_unm1_pe=0
n_unm2_pe=0
n_unm_both_pe=0

for read in samfile.fetch(until_eof=True):

    if read.is_read1:
        if not read.is_secondary:
            n_unique_pe+=1
    
    
            #unmapped reads
            if read.is_unmapped and read.mate_is_unmapped:
                n_unm_both_pe+=1
            elif read.is_unmapped and not read.mate_is_unmapped:
                n_unm1_pe+=1
            elif not read.is_unmapped and read.mate_is_unmapped:
                n_unm2_pe+=1


samfile.close()


fileOut.write("sample,n_unique_pe,n_unm_both_pe,n_unm1_pe,n_unm2_pe\n")
fileOut.write(sample+","+str(n_unique_pe)+","+str(n_unm_both_pe)+","+str(n_unm1_pe)+","+str(n_unm2_pe))
fileOut.write("\n")

