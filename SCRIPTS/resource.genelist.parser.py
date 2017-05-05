#!/hpc/local/CentOS7/common/lang/python/2.7.10/bin/python
# coding=UTF-8

# Alternative shebang for local Mac OS X: #!/usr/bin/python
# Linux version for HPC: #!/hpc/local/CentOS7/common/lang/python/2.7.10/bin/python

### ADD-IN:
### - dynamically determine the proper chr-bp based on the reference, like with the VariantID/Marker

print "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
print "                                         MetaGWASToolKit: GeneList Parser"
print ""
print "* Version          : v1.0.0"
print ""
print "* Last update      : 2017-05-05"
print "* Written by       : Tim Bezemer (t.bezemer-2@umcutrecht.nl)."
print "* Suggested for by : Sander W. van der Laan | s.w.vanderlaan-2@umcutrecht.nl"
print ""
print "* Description      : This script will parse GENCODE and refseq GeneLists to have only 1 row per gene."
print ""
print "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

### ADD-IN: 
### - requirement check
### - if not present install
### - report that the requirements are met
from sys import exit
import pandas as pd
from time import strftime

import argparse
parser = argparse.ArgumentParser(description="Parse GeneList to have only 1 row per gene.")
parser.add_argument("-i", "--input", help="The input file to inspect (text/gzipped).", type=str)
parser.add_argument("-o", "--output", help="The name of the output file to write.", type=str)
parser.add_argument("-t", "--type", help="The reference type <gencode/refseq>.", type=str)

print "* All arguments passed."
args = parser.parse_args()

args.type = args.type.lower()

GENECODE_header = ["chr", "start", "end", "gene", "ensembl", "strand"]
REFSEQ_header = ["gene", "chr", "strand", "start", "end", "exonstart", "exonend"]

if args.type == "gencode":
    header_to_use = GENECODE_header 
elif args.type == "refseq":
    header_to_use = REFSEQ_header 
else:
    print "Invalid reference type! Please double back. <gencode/refseq>"
    exit()

print "* Loading data ..."
df = pd.read_table(args.input, sep='\s+', names=header_to_use).sample(100)

genes = list( set(df.gene) )

list_of_dicts = []

print "* Looping over GeneList and uniquefying rows per gene ..."
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

print "* Collecting parsed data ..."
result = pd.DataFrame(list_of_dicts)

result = result[["chr", "start", "end", "gene", "strand", "transcripts"]] if args.type == "gencode" else result[["chr", "start", "end", "gene", "strand"]]

print "* Writing parsed data ..."
result.to_csv(args.output, sep=" ", index=False, header=False)

print "* " + strftime("%a, %H:%M:%S") + " All done parsing GeneList. Let's have a beer, buddy! 🖖"

print "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
print "+ The MIT License (MIT)                                                                                      +"
print "+ Copyright (c) 2017 Tim Bezemer, Sander W. van der Laan | UMC Utrecht, Utrecht, the Netherlands        +"
print "+                                                                                                            +"
print "+ Permission is hereby granted, free of charge, to any person obtaining a copy of this software and          +"
print "+ associated documentation files (the \"Software\"), to deal in the Software without restriction, including    +"
print "+ without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell    +"
print "+ copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the   +"
print "+ following conditions:                                                                                      +"
print "+                                                                                                            +"
print "+ The above copyright notice and this permission notice shall be included in all copies or substantial       +"
print "+ portions of the Software.                                                                                  +"
print "+                                                                                                            +"
print "+ THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT      +"
print "+ LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO  +"
print "+ EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER  +"
print "+ IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR    +"
print "+ THE USE OR OTHER DEALINGS IN THE SOFTWARE.                                                                 +"
print "+                                                                                                            +"
print "+ Reference: http://opensource.org.                                                                          +"
print "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
