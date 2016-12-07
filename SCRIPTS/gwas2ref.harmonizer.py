#!/hpc/local/CentOS7/common/lang/python/2.7.10/bin/python
# coding=UTF-8

# Alternative shebang for local Mac OS X: #!/usr/bin/python
# Linux version for HPC: #!/hpc/local/CentOS7/common/lang/python/2.7.10/bin/python


print "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
print "                               GWAS TO REFERENCE HARMONIZER "
print ""
print "* Version: GWAS2REF.HARMONIZER.v1.2.2"
print ""
print "* Last update      : 2016-12-05"
print "* Written by       : Tim Bezemer (t.bezemer-2@umcutrecht.nl)."
print "* Suggested for by : Sander W. van der Laan | s.w.vanderlaan-2@umcutrecht.nl"
print ""
print "* Description      : This script will set the VariantID of a GWAS dataset relative"
print "                     to a reference (either 1000G phase 1 or phase 3). In addition"
print "                     it will collect the allele frequencies of 1000G for comparison."
print ""
print "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

import pandas as pd
from sys import exit, argv
from os.path import isfile
import argparse
from time import strftime

alt_ids = ["VariantID_alt1", "VariantID_alt2", "VariantID_alt3", "VariantID_alt4", "VariantID_alt5", "VariantID_alt6", "VariantID_alt7", "VariantID_alt8", "VariantID_alt9", "VariantID_alt10", "VariantID_alt11", "VariantID_alt12", "VariantID_alt13"]
load_columns = ["VariantID","VariantID_alt1","VariantID_alt2","VariantID_alt3","VariantID_alt4","VariantID_alt5","VariantID_alt6","VariantID_alt7","VariantID_alt8","VariantID_alt9","VariantID_alt10","VariantID_alt11","VariantID_alt12","VariantID_alt13","CHR_REF","BP_REF","REF","ALT","AlleleA","AlleleB","VT","AF","EURAF","AFRAF","AMRAF","ASNAF","EASAF","SASAF"]

parser = argparse.ArgumentParser(description="Look up 'Marker' in GWAS dataset and find associated data in 1000G reference.")
requiredNamed = parser.add_argument_group('required named arguments')

requiredNamed.add_argument("-g", "--gwasdata", help="The GWAS dataset.", type=str)
requiredNamed.add_argument("-r", "--reference", help="The 1000 genomes reference file.", type=str)
requiredNamed.add_argument("-i", "--identifier", help="The VariantID identifier to use (" + ", ".join(["VariantID"] + alt_ids) + ").", type=str)
requiredNamed.add_argument("-o", "--output", help="File name for the output file to store the results.", type=str)
args = parser.parse_args()

if not args.gwasdata or not args.reference or not args.identifier or not args.output:

    print "Usage: " + argv[0] + " --help"
    print "Exiting..."
    exit()

#Check if the Marker was properly set
if args.identifier not in ["VariantID"] + alt_ids:
        
    print "Please select one of the following VariantID's"
    print "\n".join( ["\t" + variant_id for variant_id in ["VariantID"] + alt_ids] )
    print "Exiting..."
    exit()

else:

    if args.identifier in alt_ids: alt_ids.remove(args.identifier);

if not isfile(args.gwasdata): print "No such file <\"" + args.gwasdata + "\">."; exit()

if not isfile(args.reference): print "No such file <\"" + args.reference + "\">."; exit()

print "Matching 'Marker' from: " + args.gwasdata
msg = "to '" + args.identifier + "' from: " + args.reference

print msg
print "".join(["-"] * len(msg))


#Remove the unused VariantID_alt# from the load_columns (the list of columns to load into memory)
#This speeds up loading and parsing, and conserves memory
[load_columns.remove(alt_id) for alt_id in alt_ids]

print "\t ..." + strftime("%a, %H:%M:%S") + " Loading reference: " + args.reference 
thousandGenomes = pd.read_table(args.reference, index_col=False, usecols=load_columns)
#thousandGenomes = pd.read_table(args.reference, index_col=False, usecols=load_columns, 
#dtype = {"BP" : "int32"})

print "\t ..." + strftime("%a, %H:%M:%S") + " Loading GWAS dataset: " + args.gwasdata
GWASDATA = pd.read_table(args.gwasdata, index_col=False, sep=' ', na_values = ["NA", "NaN", "."])
#GWASDATA = pd.read_table(args.gwasdata, index_col=False, sep=' ', na_values = ["NA", "NaN", "."], 
#dtype = {"CHR" : "int32", "BP" : "int32"})

print "\t ..." + strftime("%a, %H:%M:%S") + " Performing Left Join 'Marker' -> '" + args.identifier + "': "
#Do the join on 'Marker' column in GWASDATA and args.identifier
result = pd.merge(left=GWASDATA,right=thousandGenomes, how='left', left_on='Marker', right_on=args.identifier)

print "\t ..." + strftime("%a, %H:%M:%S") + " Dropping redundant column..."
#Drop the remaining args.identifier column as well, since we don't need it anymore
if args.identifier != "VariantID": result.drop(args.identifier, axis=1, inplace=True)

print "\t ..." + strftime("%a, %H:%M:%S") + " Create 'Reference' column (for easy reference)..."
#Create a column indicating whether the Marker was in the reference (if VariantID == NA/Null, it was not in the reference)
result['Reference'] = pd.isnull( result['VariantID'] )

#Mask the reference to convert True/False to "in_reference", note: this may be time consuming.
#Tip: Don't change the name of "Reference" column --> If you change it and opt to not perform the True/False --> "not_in_reference"/"in_reference" conversion,
#you may forget that 'True' means that the Marker was not found in the reference, causing confusion.
result['Reference'] = result['Reference'].apply(lambda x: "no" if x == True else "yes")

print "\t ..." + strftime("%a, %H:%M:%S") + " Fill empty VariantID with Marker value..."

result['VariantID'] = result.apply(lambda x: x['Marker'] if pd.isnull(x['VariantID']) else x['VariantID'], axis=1) 

print "\t ..." + strftime("%a, %H:%M:%S") + " Reordering columns to make 'VariantID' the first column..."
#Change order of columns to make VariantID the first one (this step may also decrease performance)
reordered_cols = list(result.columns.values); reordered_cols.remove("VariantID")
reordered_cols = ["VariantID"] + reordered_cols
result = result.ix[:,reordered_cols]

print "\t ..." + strftime("%a, %H:%M:%S") + " Storing results..."
#Save the results in TSV format (The output format can easily be changed through pandas (check the Docs) ).
result.to_csv(args.output, sep='\t', index=False)

print "\t ..." + strftime("%a, %H:%M:%S") + " All done! 🍺"

print "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
print "+ The MIT License (MIT)                                                                  +"
print "+ Copyright (c) 2016 Tim Bezemer, Sander W. van der Laan                                 +"
print "+                                                                                        +"
print "+ Permission is hereby granted, free of charge, to any person obtaining a copy of this   +"
print "+ software and associated documentation files (the \"Software\"), to deal in the         +"
print "+ Software without restriction, including without limitation the rights to use, copy,    +"
print "+ modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,    +"
print "+ and to permit persons to whom the Software is furnished to do so, subject to the       +"
print "+ following conditions:                                                                  +"
print "+                                                                                        +"
print "+ The above copyright notice and this permission notice shall be included in all copies  +"
print "+ or substantial portions of the Software.                                               +"
print "+                                                                                        +"
print "+ THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,  +"
print "+ INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A          +"
print "+ PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT     +"
print "+ HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF   +"
print "+ CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE   +"
print "+ OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                                          +"
print "+                                                                                        +"
print "+ Reference: http://opensource.org.                                                      +"
print "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
