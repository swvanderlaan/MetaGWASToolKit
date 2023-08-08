#!/hpc/local/Rocky8/dhl_ec/software/tempMiniconda3envs/gwas/bin/python
### #!/usr/bin/python

#
# Merge two files into one.
#
# Description: 	merges two files based on some key-column into one file. The lines do not 
#               have to be sorted.
#
# Original written and published by:
# 		* Paul I.W. de Bakker, piwdebakker@mac.com
#		* 4 July 2009
#
# Written by: 	Bram van Es; Utrecht, the Netherlands
#				bramiozo@gmail.com
# Suggest by:	Sander W. van der Laan; Utrecht, the Netherlands; 
#               s.w.vanderlaan@gmail.com.
# Version:		2.0 beta 1
# Update date: 	2023-04-28
#
# Usage:		python3 mergeTables.py --in_file1 /file1.txt.gz --in_file2 /file2.txt.gz --indexID VariantID --out_file /joined.txt.gz [optional: --replace: add option to replace column contents, default: none; --verbose: add option to print verbose output (T/F), default: F]

# TO DO
# (optional: --replace) add option to replace column contents

# Import libraries
import os
import sys
import subprocess
import polars as pl
import argparse
import magic
import gzip
import time
import csv


# Check for required libraries and install them if not present
# https://stackoverflow.com/questions/12332975/installing-python-module-within-code
def install(package):
    subprocess.check_call([sys.executable, "-m", "pip", "install", package])

from argparse import RawTextHelpFormatter

# set starting time
start = time.time()

# detect file delimiter
def detect_delimiter(in_file):
    # Read first 10KB of the file to determine the delimiter
    sniffer = csv.Sniffer()
    lines = in_file.read(10000)
    delimiter = str(sniffer.sniff(lines).delimiter)
    return delimiter

# detect file delimiter
# def detect_delimiter(file_path):
#     with open(file_path, "rb") as f:
#         # Read first 10KB of the file to determine the delimiter
#         sample = f.read(10240)
#         if b" " in sample:
#             return " "
#         else:
#             return "\t"

# Parse arguments
if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='''
        + mergeTables 2.0 beta 1+

        This script joins `in_file1` and `in_file2` based on the `indexID` column. The index column must be
        the first column in both files. The `out_file` file will be compressed with gzip and written 
        in parquet-format when out_file ends with .parquet, otherwise a space-delimited .txt is written.
        The `replace` option adds the option to replace column contents. The `verbose` option adds the
        option to print verbose output (T/F), default: F.


        This is an example call:

        python3 mergeTables.py --in_file1 /file1.txt.gz --in_file2 /file2.txt.gz --indexID VariantID --out_file /joined.txt.gz [optional: --replace VariantID; --verbose: T/F]
        ''',
        epilog='''
        + Copyright 1979-2023. Bram van Es & Sander W. van der Laan | s.w.vanderlaan@gmail.com | https://vanderlaan.science +''', 
        formatter_class=RawTextHelpFormatter)

    parser.add_argument('--in_file1', type=str, required=True)
    parser.add_argument('--in_file2', type=str, required=True)
    parser.add_argument('--indexID', type=str, required=True)
    # parser.add_argument('--replace', type=str, required=False)
    parser.add_argument('--out_file', type=str, required=True)
    parser.add_argument('--verbose', type=str, required=False)

    args = parser.parse_args()

    in_file1 = args.in_file1 # parser.parse_args().in_file1
    in_file2 = args.in_file2 # parser.parse_args().in_file2
    indexID = args.indexID # parser.parse_args().indexID
    # replace = args.replace # parser.parse_args().replace
    out_file = args.out_file # parser.parse_args().out_file

    if args.verbose:
        verbose = args.verbose # parser.parse_args().verbose
    else:
        verbose = "F"

# Print some information
print("\n+ mergeTables 2.0 beta 1 +")
print(f"\n   Starting merging the following files:")
print(f"     > [{in_file1}]")
print(f"     > [{in_file2}]")
print(f"\n   Index set to [{indexID}]")
# print(f"\n   Column to replace [{replace}]")
print(f"\n   Output will be written to [{out_file}]")
if verbose == "T":
    print(f"\n   Verbose output is set to [{verbose}]. This will slow down the process, but prints times and file information.")
else:
    print(f"\n   Verbose output is set to [{verbose}] (default)")

# Detect file type using magic
# https://stackoverflow.com/questions/43580/how-do-i-check-the-file-type-of-a-file-in-python

mime = magic.Magic(mime=True)
mime_type_file1 = mime.from_file(in_file1) #== 'application/gzip'

if verbose == "T":
    is_gzip1_time = time.time()
    print(f"Elapsed time: {time.strftime('%H:%M:%S', time.gmtime(is_gzip1_time - start))}")

mime_type_file2 = mime.from_file(in_file2) #== 'application/gzip'

if verbose == "T":
    is_gzip2_time = time.time()
    print(f"Elapsed time: {time.strftime('%H:%M:%S', time.gmtime(is_gzip2_time - is_gzip1_time))}")

if verbose == "T":
    print(f"\n   Detected files types:")
    print(f"     > File1 gzipped? {mime_type_file1}")
    print(f"     > File2 gzipped? {mime_type_file2}")

# Detect file delimiter 
if mime_type_file1 == "application/gzip" or mime_type_file1 == "application/x-gzip":
    with gzip.open(in_file1, mode = 'rt') as f:
        file1_delimiter = detect_delimiter(f)
        file1 = pl.read_csv(in_file1, separator=file1_delimiter)
else:
    with open(in_file1) as f:
        file1_delimiter = detect_delimiter(f)
        file1 = pl.read_csv(in_file1, separator=file1_delimiter)

if verbose == "T":
    file1_delimiter_t = time.time()
    print(f"Elapsed time: {time.strftime('%H:%M:%S', time.gmtime(file1_delimiter_t - is_gzip2_time))}")

if mime_type_file2 == "application/gzip" or mime_type_file2 == "application/x-gzip":
    with gzip.open(in_file2, mode = 'rt') as f:
        file2_delimiter = detect_delimiter(f)
        file2 = pl.read_csv(in_file2, separator=file2_delimiter)
else:
    with open(in_file2) as f:
        file2_delimiter = detect_delimiter(f)
        file2 = pl.read_csv(in_file2, separator=file2_delimiter)

if verbose == "T":
    file2_delimiter_t = time.time()
    print(f"Elapsed time: {time.strftime('%H:%M:%S', time.gmtime(file2_delimiter_t - file1_delimiter_t))}")

if verbose == "T":
    print(f"\n   Detected the following delimiters:")
    print(f"     > File1: [{file1_delimiter}].")
    print(f"     > File2: [{file2_delimiter}].")

    print(f"\n   Detected the following heads and tails:")
    print(f"     > File1:")
    print(file1.head(3))
    print(file1.tail(3))

    print(f"     > File2:")
    print(file2.head(3))
    print(file2.tail(3))

# Read files using polars
# How to get rid of 'Polars found a filename. Ensure you pass a path to the file instead of a python file object when possible for best performance.'
# https://stackoverflow.com/questions/75690784/polars-for-python-how-to-get-rid-of-ensure-you-pass-a-path-to-the-file-instead

print(f"\n   Opening file1...")
if mime_type_file1 == "application/gzip" or mime_type_file1 == "application/x-gzip":
    file1 = pl.read_csv(gzip.open(in_file1).read(), separator=str(file1_delimiter))
else:
    file1 = pl.read_csv(in_file1, separator=str(file1_delimiter))

if verbose == "T":
    file1_t = time.time()
    print(f"Elapsed time: {time.strftime('%H:%M:%S', time.gmtime(file1_t - file2_delimiter_t))}")

print(f"\n   Opening file2...")
if mime_type_file2 == "application/gzip" or mime_type_file2  == "application/x-gzip":
    file2 = pl.read_csv(gzip.open(in_file2).read(), separator=str(file2_delimiter))
else:
    file2 = pl.read_csv(in_file2, separator=str(file2_delimiter))

if verbose == "T":
    file2_t = time.time()
    print(f"Elapsed time: {time.strftime('%H:%M:%S', time.gmtime(file2_t - file1_t))}")

new_df = file1.join(file2, on=indexID, how='inner')
if verbose == "T":
    new_df_t = time.time()
    print(f"Elapsed time: {time.strftime('%H:%M:%S', time.gmtime(new_df_t - file2_t))}")

if verbose == "T":
    print(f"\n   Detected the following heads and tails in the merge file:")
    print(new_df.head(3))
    print(new_df.tail(3))

# Write output file
print(f"\n   Writing output file...")
if out_file.endswith(".parquet"):
    new_df.write_parquet(out_file, 
                         compression='gzip',
                         statistics=True)
else:
    new_df.write_csv(out_file, 
                 has_header=True, separator=' ', null_value='NA',
                 batch_size=1024)

if verbose == "T":
    new_df_write_t = time.time()
    print(f"Elapsed time: {time.strftime('%H:%M:%S', time.gmtime(new_df_write_t - new_df_t))}")

end = time.time()
print(f"Total elapsed time: {time.strftime('%H:%M:%S', time.gmtime(end - start))}")

# Done
print("\n   Wow, all done. Let's have a beer buddy!\n")
print("+ Copyright 1979-2023. Bram van Es & Sander W. van der Laan | s.w.vanderlaan@gmail.com | https://vanderlaan.science +")

