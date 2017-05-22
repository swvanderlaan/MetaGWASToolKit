#!/hpc/local/CentOS7/common/lang/python/2.7.10/bin/python
# coding=UTF-8

# Alternative shebang for local Mac OS X: #!/usr/bin/python
# Linux version for HPC: #!/hpc/local/CentOS7/common/lang/python/2.7.10/bin/python

### ADD-IN:
### - dynamically determine the proper chr-bp based on the reference, like with the VariantID/Marker

print "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
print "                                          GWAS TO REFERENCE HARMONIZER "
print ""
print "* Version          : v2.2.7"
print ""
print "* Last update      : 2017-05-22"
print "* Written by       : Tim Bezemer (t.bezemer-2@umcutrecht.nl)."
print "* Suggested for by : Sander W. van der Laan | s.w.vanderlaan-2@umcutrecht.nl"
print ""
print "* Description      : This script will set the VariantID of a GWAS dataset relative to a reference "
print "                     (e.g. 1000G phase 1 or phase 3). In addition it will collect the allele frequencies of "
print "                     the reference for downstream comparison."
print ""
print "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

### ADD-IN: 
### - requirement check
### - if not present install
### - report that the requirements are met
import pandas as pd
from sys import exit, argv
from os.path import isfile
import argparse
from time import strftime
import random
import operator

alt_ids = ["VariantID_alt1", "VariantID_alt2", "VariantID_alt3"]
load_columns = ["VariantID","VariantID_alt1","VariantID_alt2","VariantID_alt3"]

parser = argparse.ArgumentParser(description="Look up 'Marker' in GWAS dataset and find associated data in 1000G reference.")
parser.add_argument("-i", "--identifier", help="The VariantID identifier to use (" + ", ".join(["VariantID"] + alt_ids) + ").", type=str)
parser.add_argument("-s", "--subsample", help="Number of rows to use for subsampling, when determining the optimal VariantID (default = 100,000)", type=int)

requiredNamed = parser.add_argument_group('required named arguments')

requiredNamed.add_argument("-g", "--gwasdata", help="The GWAS dataset.", type=str)
requiredNamed.add_argument("-r", "--reference", help="The 1000 genomes reference file.", type=str)
requiredNamed.add_argument("-o", "--output", help="File name for the output file to store the results.", type=str)
args = parser.parse_args()

s = 100000 if not args.subsample else args.subsample

if not args.gwasdata or not args.reference or not args.output:

    print "Usage: " + argv[0] + " --help"
    print "Exiting..."
    exit()

if not isfile(args.gwasdata): print "No such file <\"" + args.gwasdata + "\">."; exit()

if not isfile(args.reference): print "No such file <\"" + args.reference + "\">."; exit()

if not args.identifier:
	### Draw a subsampling from the GWAS data:

	print "Parameter flag -i/--identifier not set: Determining best VariantID for match (iterative lookup on subsampling)"
	print "...using " + str(s) + " samples."

	print "\t ..." + strftime("%a, %H:%M:%S") + " Loading GWAS subsampling: " + args.gwasdata

	n = sum(1 for line in open(args.gwasdata)) - 1 ### number of records in file (excludes header)

	skip = sorted(random.sample(xrange(1,n+1),n-s)) ### the 0-indexed header will not be included in the skip list

	GWAS_SAMPLE = pd.read_table(args.gwasdata, skiprows=skip, index_col=False,  sep='\t', na_values = ["NA", "NaN", "."])

	variantid_matches = {}

	for variantid in alt_ids + ["VariantID"]:

		print "\t ..." + strftime("%a, %H:%M:%S") + " for " + variantid

		### We use the list(...) constructor here because else the object are passed by reference, and not by value.
		test_alt_ids = list(alt_ids)
		test_load_columns = list(load_columns)

		if variantid in test_alt_ids: test_alt_ids.remove(variantid);

		### Remove the unused VariantID_alt# from the load_columns (the list of columns to load into memory),
		### This speeds up loading and parsing, and conserves memory.
		[test_load_columns.remove(alt_id) for alt_id in test_alt_ids if alt_id in test_load_columns]

		print "\t\t ... Loading reference for subsampling" 
		reference_header = pd.read_table(args.reference, index_col=False, sep='\t', nrows=0).columns.values
		test_load_columns = list( set.intersection( set(reference_header), set(test_load_columns) ) ) 

		test_thousandGenomes = pd.read_table(args.reference, index_col=False,  sep='\t', usecols=test_load_columns)

		if variantid not in test_thousandGenomes.columns.values:

			print "\t\t ... Skipping, " + variantid + " not contained in reference file"
			continue

		print "\t\t ... Performing look-up"

		print "\t\t ... Performing Left Join 'Marker' -> '" + variantid + "'"

		### Do the join on 'Marker' column in GWASDATA and reference_identifier.
		test_result = pd.merge(left=GWAS_SAMPLE, right=test_thousandGenomes, how='left', left_on='Marker', right_on=variantid)

		n_matches = sum( pd.notnull( test_result['VariantID'] ) )

		print "\t\t ... " + variantid + " yielded " + str(n_matches) + " matches."

		variantid_matches[variantid] = n_matches

	GWAS_SAMPLE = None

	reference_identifier = max(variantid_matches.iteritems(), key=operator.itemgetter(1))[0]
	print "Best VariantID = " + reference_identifier
	print ""

else:

	reference_identifier = args.identifier


print "Matching 'Marker' from: " + args.gwasdata
msg = "to '" + reference_identifier + "' from: " + args.reference

print msg
print "".join(["-"] * len(msg))

### Remove the unused VariantID_alt* from the load_columns (the list of columns to load into memory).
### This speeds up loading and parsing, and conserves memory.

[load_columns.remove(alt_id) for alt_id in alt_ids if alt_id in load_columns and alt_id != reference_identifier]

reference_header = pd.read_table(args.reference, index_col=False, sep='\t', nrows=0).columns.values
load_columns = list( set.intersection( set(reference_header), set(load_columns) ) ) 

print "\t ..." + strftime("%a, %H:%M:%S") + " Loading reference: " + args.reference 
thousandGenomes = pd.read_table(args.reference, index_col=False, usecols=load_columns)


print "\t ..." + strftime("%a, %H:%M:%S") + " Loading GWAS dataset: " + args.gwasdata
GWASDATA = pd.read_table(args.gwasdata, index_col=False, sep='\t', na_values = ["NA", "NaN", "."])

print "\t ..." + strftime("%a, %H:%M:%S") + " Performing Left Join 'Marker' -> '" + reference_identifier + "': "

### Do the join on 'Marker' column in GWASDATA and reference_identifier.
result = pd.merge(left=GWASDATA, right=thousandGenomes, how='left', left_on='Marker', right_on=reference_identifier, sort=False)

print "\t ..." + strftime("%a, %H:%M:%S") + " Dropping redundant column..."
### Drop the remaining reference_identifier column as well, since we don't need it anymore.
if reference_identifier != "VariantID": result.drop(reference_identifier, axis=1, inplace=True)

print "\t ..." + strftime("%a, %H:%M:%S") + " Create 'Reference' column (for easy reference)..."
### Create a column indicating whether the Marker was in the reference (if VariantID == NA/Null, it was not in the reference).
result['Reference'] = pd.isnull(result['VariantID'] )

### Mask the reference to convert True/False to "in_reference", note: this may be time consuming.
### Tip: Don't change the name of "Reference" column.
###      If you change it and opt to not perform the True/False, "not_in_reference"/"in_reference" conversion, 
###      you may forget that 'True' means that the Marker was not found in the reference, causing confusion.
###      So: True = no = not in the reference
###          False = yes = found in the reference
result['Reference'] = result['Reference'].apply(lambda x: "no" if x == True else "yes") 

print "\t ..." + strftime("%a, %H:%M:%S") + " Fill empty VariantID with Marker value..."

result['VariantID'] = result.apply(lambda x: x['Marker'] if pd.isnull(x['VariantID']) else x['VariantID'], axis=1)

### Fill the missing values after merging.
result.fillna('NA', inplace=True)

print "\t ..." + strftime("%a, %H:%M:%S") + " Reordering columns to make 'VariantID' the first column..."
### Change order of columns to make VariantID the first one (this step may also decrease performance).
reordered_cols = list(result.columns.values); reordered_cols.remove("VariantID")
reordered_cols = ["VariantID"] + reordered_cols
result = result.ix[:,reordered_cols]

print "\t ..." + strftime("%a, %H:%M:%S") + " Storing results..."
### Save the results in TSV format (The output format can easily be changed through pandas (check the Docs)).
result.to_csv(args.output, sep='\t', index=False)

print "\t ..." + strftime("%a, %H:%M:%S") + " All done harmonizing. Let's have a beer, buddy!"

print "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
print "+ The MIT License (MIT)                                                                                      +"
print "+ Copyright (c) 2016-2017 Tim Bezemer, Sander W. van der Laan | UMC Utrecht, Utrecht, the Netherlands        +"
print "+                                                                                                            +"
print "+ Permission is hereby granted, free of charge, to any person obtaining a copy of this software and          +"
print "+ associated documentation files (the \"Software\"), to deal in the Software without restriction, including  +"
print "+ without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell    +"
print "+ copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the   +"
print "+ following conditions:                                                                                      +"
print "+                                                                                                            +"
print "+ The above copyright notice and this permission notice shall be included in all copies or substantial       +"
print "+ portions of the Software.                                                                                  +"
print "+                                                                                                            +"
print "+ THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT    +"
print "+ LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO  +"
print "+ EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER  +"
print "+ IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR    +"
print "+ THE USE OR OTHER DEALINGS IN THE SOFTWARE.                                                                 +"
print "+                                                                                                            +"
print "+ Reference: http://opensource.org.                                                                          +"
print "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
