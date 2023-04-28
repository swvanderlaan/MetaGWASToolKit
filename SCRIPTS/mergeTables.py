#!/usr/bin/python
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
# Version:		2.0
# Update date: 	2023-04-26
#
# Usage:		python mergeTables.py --file1 [INPUT_FILE_1] --file2 [INPUT_FILE_2] --out-file [OUTPUT_FILE] (optional: --help)

# TO DO
# --index [INDEX_STRING] add name of index column
# --format [GZIP1/GZIP2/GZIPB/NORM] add format 
# (optional: --replace) add option to replace column contents
# Starting merging
import polars as pl
import argparse
import magic
import gzip
import time

from argparse import RawTextHelpFormatter

start = time.time()

def detect_delimiter(file_path):
    with open(file_path, "rb") as f:
        # Read first 10KB of the file to determine the delimiter
        sample = f.read(10240)
        if b" " in sample:
            return " "
        else:
            return "\t"

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='''
        + mergeTables 2.0 +

        This script joins file1 and file2 based on the VariantID column. The VariantID column must be
        the first column in both files. The output file will be compressed with gzip.

        This is an example call:

        python3 mergeTables.py --in_file1 /variants.txt.gz --in_file2 /sumstats.txt.gz --indexID VariantID --out_file /joined.txt.gz [optional --replace replaces contents of given column with overlapping file1/2 column]
        ''',
        epilog='''
        + Copyright 1979-2023. Bram van Es & Sander W. van der Laan | s.w.vanderlaan@gmail.com | https://vanderlaan.science +''', 
        formatter_class=RawTextHelpFormatter)

    parser.add_argument('--in_file1', type=str, required=True)
    parser.add_argument('--in_file2', type=str, required=True)
    parser.add_argument('--indexID', type=str, required=True)
    parser.add_argument('--replace', type=str, required=False)
    parser.add_argument('--out_file', type=str, required=True)

    args = parser.parse_args()

    in_file1 = args.in_file1
    in_file2 = args.in_file2
    indexID = args.indexID
    out_file = args.out_file

    print("\n+ mergeTables 2.0 +")
    print(f"\n   Starting merging the following files:")
    print(f"     > [{in_file1}]")
    print(f"     > [{in_file2}]")
    print(f"\n   Index set to [{indexID}]")
    print(f"\n   Output will be written to [{out_file}]")

    # Detect file type using magic
    mime = magic.Magic(mime=True)
    is_gzip1 = mime.from_file(in_file1) == 'application/x-gzip'
    is_gzip1_time = time.time()
    print(f"Elapsed time: {is_gzip1_time - start}")

    is_gzip2 = mime.from_file(in_file2) == 'application/x-gzip'
    is_gzip2_time = time.time()
    print(f"Elapsed time: {is_gzip2_time - is_gzip1_time}")

    # Detect file delimiter 
    if is_gzip1:
        with gzip.open(in_file1) as f:
            file1_delimiter = detect_delimiter(in_file1)
            file1 = pl.read_csv(in_file1, separator=file1_delimiter)
    else:
        with open(in_file1) as f:
            file1_delimiter = detect_delimiter(in_file1)
            file1 = pl.read_csv(in_file1, separator=file1_delimiter)
    
    file1_delimiter_t = time.time()
    print(f"Elapsed time: {file1_delimiter_t - is_gzip2_time}")

    if is_gzip2:
        with gzip.open(in_file2) as f:
            file2_delimiter = detect_delimiter(in_file2)
            file2 = pl.read_csv(in_file1, separator=file2_delimiter)
    else:
        with open(in_file2) as f:
            file2_delimiter = detect_delimiter(in_file2)
            file2 = pl.read_csv(in_file1, separator=file2_delimiter)
   
    file2_delimiter_t = time.time()
    print(f"Elapsed time: {file2_delimiter_t - file1_delimiter_t}")

    print(f"\n   Detected files types:")
    print(f"     > File1 gzipped? {is_gzip1}")
    print(f"     > File2 gzipped? {is_gzip1}")

    print(f"\n   Detected the following delimiters:")
    print(f"     > File1: [{file1_delimiter}].")
    print(f"     > File2: [{file2_delimiter}].")

    # Read files using polars
    print(f"\n   Opening file1...")
    if is_gzip1:
        file1 = pl.read_csv(gzip.open(in_file1), separator=str(file1_delimiter))
    else:
        file1 = pl.read_csv(in_file1, separator=str(file1_delimiter))

    file1_t = time.time()
    print(f"Elapsed time: {file1_t - file2_delimiter_t}")

    print(f"\n   Opening file2...")
    if is_gzip1:
        file2 = pl.read_csv(gzip.open(in_file1), separator=str(file1_delimiter))
    else:
        file2 = pl.read_csv(in_file2, separator=str(file1_delimiter))
    file2_t = time.time()
    print(f"Elapsed time: {file2_t - file1_t}")

    new_df = file1.join(file2, on=indexID, how='inner')

    new_df.write_csv(out_file, 
                         has_header=True, separator=' ', null_value='NA',
                         batch_size=1024)
    new_df_t = time.time()
    print(f"Elapsed time: {new_df_t - file2_t}")

    end = time.time()
    print(f"Elapsed time: {end - start}")

print("\n   Wow, all done. Let's have a beer buddy!\n")
print("+ Copyright 1979-2023. Bram van Es & Sander W. van der Laan | s.w.vanderlaan@gmail.com | https://vanderlaan.science +")
