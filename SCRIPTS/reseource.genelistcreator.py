#!/usr/bin/python
from sys import exit
import pandas as pd

import argparse
parser = argparse.ArgumentParser()
parser.add_argument("input", help="The input file to inspect (text/gzipped)")
parser.add_argument("output", help="The name of the output file to write")
parser.add_argument("type", help="The reference type <gencode/refseq>")

args = parser.parse_args()

args.type = args.type.lower()

GENECODE_header = ["chr", "start", "end", "gene", "ensembl", "strand"]
REFSEQ_header = ["gene", "chr", "strand", "start", "end", "exonstart", "exonend"]

if args.type == "gencode":
    header_to_use = GENECODE_header 
elif args.type == "refseq":
    header_to_use = REFSEQ_header 
else:
    print "Invalid reference type! <gencode/refseq>"
    exit()
    

df = pd.read_table(args.input, sep='\s+', names=header_to_use).sample(100)

genes = list( set(df.gene) )

list_of_dicts = []

for gene in genes:
    
    this_gene = df[ df.gene == gene ]
    
    ind_lowest_start = this_gene.start.idxmin()
    ind_highest_end = this_gene.end.idxmax()
    
    some_row = this_gene.ix[ this_gene.first_valid_index() ]
    
    short_row = {}
    short_row['gene'] = gene
    short_row['chr'] = some_row.chr
    short_row['start'] = this_gene.ix[ind_lowest_start].start
    short_row['end'] = this_gene.ix[ind_highest_end].end
    short_row['strand'] = some_row.strand
    if args.type == "gencode": short_row['transcripts'] = ",".join(set(this_gene.ensembl))

    list_of_dicts.append(short_row)
    
result = pd.DataFrame(list_of_dicts)

result = result[["chr", "start", "end", "gene", "strand", "transcripts"]] if args.type == "gencode" else result[["chr", "start", "end", "gene", "strand"]]

result.to_csv(args.output, sep=" ", index=False, header=False)