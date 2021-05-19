import pandas as pd

import csv
import argparse
import os
import sys

ap = argparse.ArgumentParser()
ap.add_argument('prefix', help='inBam')
ap.add_argument('out_dir', help='out txt file')
ap.add_argument('summary_dir', help='inBam')

args = ap.parse_args()

print(args.prefix)

result  = pd.DataFrame(columns = ['sample'])
result = result.append({'sample': args.prefix}, ignore_index=True)

print(result)

if os.path.exists(args.out_dir+"/summary_mtDNA.csv"):
    mtDNA = pd.read_csv(args.out_dir+"/summary_mtDNA.csv")
    result = result.merge(mtDNA, on='sample', how='left')

if os.path.exists(args.out_dir+"/summary_rDNA.csv"):
    rDNA = pd.read_csv(args.out_dir+"/summary_rDNA.csv")
    result = result.merge(rDNA, on='sample', how='left')

if os.path.exists(args.out_dir+"/summary_microbiome.csv"):
    microbiome= pd.read_csv(args.out_dir+"/summary_microbiome.csv")
    result = result.merge(microbiome, on='sample', how='left')

if os.path.exists(args.out_dir+"/summary_cdr3.csv"):
    imrep = pd.read_csv(args.out_dir+"/summary_cdr3.csv")
    result = result.merge(imrep, on='sample', how='left')

if os.path.exists(args.out_dir+"/summary_offcov.csv"):
    offcov = pd.read_csv(args.out_dir+"/summary_offcov.csv")
    result = result.merge(offcov, on='sample', how='left')

if os.path.exists(args.out_dir+"/summary_reads.csv"):
    reads = pd.read_csv(args.out_dir+"/summary_reads.csv")
    result = result.merge(reads, on='sample', how='left')

result.to_csv(args.summary_dir+"/summary_"+args.prefix+".csv",index=False)
