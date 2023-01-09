#!/hpc/local/CentOS7/dhl_ec/software/python37/bin/python3 

"""
Python script that do some basic checks for cohort files
Written by Moezammin Baksi BSc.
Last edited: 16/03/2021
"""

"""
EXAMPLE Usage (BASH) + SLURM
-----------------------------
while IFS="" read -r p || [ -n "$p" ]
do
  B=$(basename "$p" .txt.gz)
  echo "fixing ${B}"
  sbatch --job-name=fix.${B} --time 01:00:00 -o example.${B}.log -e example.${B}.errors fixheaders.py --file ${p} --outdir DirToStore/
done < FileWithAllCohorts.txt
"""

import argparse
import datetime
import os
import sys

import pandas as pd


def main():
    """
    Main function that handles the general flow of the script
    """ 
    # Parse Arguments
    args = parse_arguments()

    # Print outdir
    print("Writing output to " + args.outdir)

    # Print start statement
    print('Starting script for ' + args.file + ' at ' +  str(datetime.datetime.now()), flush=True)

    # Put all the files in a function that will further handle the files as dataframe
    create_df(args.file, args.outdir)

    # Script is finished
    print('All done for ' + args.file + ' at ' +  str(datetime.datetime.now()), flush=True)


class ErrorMessage:
    """
    Create a class to create error messagges in the end
    """
    def __init__(self, namecol, samplesize, pandascheck):
        self.namecol = namecol
        self.samplesize = samplesize
        self.pandascheck = pandascheck



def check_n(df):
    """
    Function to determine the total samplesize if it is not present in the headers, fail if not enough information
    """
    # Check the N 
    if "N" not in df.columns:
        if "N_cases" and "N_controls" in df.columns:
            # Calculate and add N
            df['N'] = df['N_cases'].astype(float) + df['N_controls'].astype(float)
            fail_reason = "SAMPLESIZE;PASSED"
        else:
            # Not enough information about N
            fail_reason = "SAMPLESIZE;FAILED"
    else:
        fail_reason = "SAMPLESIZE;PASSED"
    return df, fail_reason


def check_headers(df, filename):
    """
    Function which will check the neccesary headers
    """
    print("Checking headers for: " + filename)
    read_message = ""

    original_colnames = df.columns.tolist()
    # good_colnames = ["Marker","Chr","Position","Effect_allele","Other_allele","Beta","SE","Pval","EAF","N","Imputed","Info","Information_type"]

    # Before actually checking the contents header, are there even headers?
    passed = False
    for col in original_colnames:
        if col.lower().strip() in ["name", "snp", "snpid", "id", "markername", "marker", "rsid"]:
            passed = True

    # Fail the check if the name column is not found, this is to stop the checks if there is a file without a header
    if not passed:
        # First check whether this is one of the files of Malik, where the columns were missing
        if filename.split('/')[-1].startswith('INTERSTROKE'):
            # Add column names and moveverything down
            first_data_row = df.columns.tolist()
            df.loc[-1] = first_data_row                 # adding a row
            df.index = df.index + 1                     # shifting index
            df = df.sort_index()                        # sorting by index
            df.columns = ["SNPID", "chr", "position", "coded_all", "noncoded_all", "strand_genome", "beta", "SE", "pval", "AF_coded_all", "n_cases", "n_controls", "imputed", "oevar_imp"]
            original_colnames = df.columns.tolist()
            read_message = read_message + "NAMECOLCHECK;CUSTOMCOLS" 

        elif filename.split('/')[-1].startswith('ASGC'):
            # Add column names and moveverything down
            first_data_row = df.columns.tolist()
            df.loc[-1] = first_data_row                 # adding a row
            df.index = df.index + 1                     # shifting index
            df = df.sort_index()                        # sorting by index
            df.columns = ["SNPID", "chr", "position", "n_cases", "n_controls", "coded_all", "noncoded_all", "AF_coded_all", "beta", "SE", "pval", "imputed", "info"]
            original_colnames = df.columns.tolist()
            read_message = read_message + "NAMECOLCHECK;CUSTOMCOLS" 

        else:
            # print("Something went wrong for " + filename)
            # print("Please make sure there are headers in the file and that there is a name/id/marker column")
            return df, "NAMECOLCHECK;FAILED"
    
    # Variable to hold all unknown columns
    unknown_cols = []

    # Loop over al colnames and rename it
    for index,col in enumerate(original_colnames):
        if col.lower().strip() in ["name", "snp", "snpid", "id", "markername", "marker", "rsid"]:
            original_colnames[index] = "Marker"

        elif col.lower().strip() in ["chromosome", "chr", "chrom"]:
            original_colnames[index] = "Chr"

        elif col.lower().strip() in ["pos", "position", "bp"]:
            original_colnames[index] = "Position"

        elif col.lower().strip() in ["effallele", "eff_allele", "effectallele", "effect_allele", "coded_all", "codedall", "allele1"]:
            original_colnames[index] = "Effect_allele"

        elif col.lower().strip() in ["noneffallele", "noneff_allele", "noneffectallele", "noneffect_allele", "non_coded_all", "noncoded_all", "noncodedall", "other_allele", "otherallele", "allele2"]:
            original_colnames[index] = "Other_allele"

        elif col.lower().strip() in ["beta"]:
            original_colnames[index] = "Beta"

        elif col.lower().strip() in ["se", "sebeta", "stderr"]:
            original_colnames[index] = "SE"

        elif col.lower().strip() in ["p", "pval", "p-value"]:
            original_colnames[index] = "Pval"

        elif col.lower().strip() in ["eaf", "freq1", "af_coded_all", "effallelefreq"]:
            original_colnames[index] = "EAF"

        elif col.lower().strip() in ["n", "ntot", "n_total"]:
            original_colnames[index] = "N"

        elif col.lower().strip() in ["ncase", "ncases", "n_case", "n_cases"]:
            original_colnames[index] = "N_cases"

        elif col.lower().strip() in ["ncontrol", "ncontrols", "n_control", "n_controls"]:
            original_colnames[index] = "N_controls"

        elif col.lower().strip() in ["imputed", "imp"]:
            original_colnames[index] = "Imputed"

        elif col.lower().strip() in ["inf", "info", "info_rsq", "rsqr"]:
            original_colnames[index] = "Info"

        elif col.lower().strip() in ["inf_type", "information_type"]:
            original_colnames[index] = "Information_type"

        # Not neccesary for the toolkit, but reduce the error messages
        elif col.lower().strip() in ["strand", "strand_genome"]:
            original_colnames[index] = "Strand"

        elif col.lower().strip() in ["oevar_imp"]:
            original_colnames[index] = "oevar_imp"

        elif col.lower().strip() in ["pval.t"]:
            original_colnames[index] = "pval.t"

        elif col.lower().strip() in ["df.t"]:
            original_colnames[index] = "df.t"

        elif col.lower().strip() in ["approxdf"]:
            original_colnames[index] = "approxdf"

        elif col.lower().strip() in ["or"]:
            original_colnames[index] = "OR"

        else:
            # print("Could not match the string: " + col)
            # print("Please make sure this column is handled correctly in the toolkit")
            unknown_cols.append(col)

    # Change column names
    df.columns = original_colnames

    # Write the unknown columns into the fail_reason variable
    if len(unknown_cols) > 0:
        read_message = read_message + "NAMECOLCHECK;PASSED" + " UNRECOGNIZED;" + ' '.join([str(elem) for elem in unknown_cols])
    else:
        read_message = read_message + "NAMECOLCHECK;PASSED"

    return df, read_message


def create_df(f, outdir):
    """
    Function to parse the cohorts into a pandas df, which will be used to fix them
    """
    # Limit RAM usage by specifying chunksize, which is the number of rows in a df
    chunksize = 10 ** 3

    # Create ErrorMessage object, with the default failed
    readme_txt = ErrorMessage("NAMECOLCHECK;FAILED", "SAMPLESIZE;FAILED", "PANDAS;PASSED")

    # Save some variables
    colnames = []                   # So you only have the fix the columns once, and not for each chunk 
    first_chunk = True              # Boolean to determine whether its the first chunk
    passed = False                  # Boolean to determine whether the cohort passed, other chunks are not necccesary if failed
    delimeter = None                # Auto determine delimiter
    fail_reason = ""                # Empty string

    # First check whether its space or tab delimited, requires special pandas parameter. Assume that when there is one column, its space delimited
    df = pd.read_csv(f, nrows=1)
    if len(df.columns) == 1:
        delimeter = "\t"
        df = pd.read_csv(f, nrows=1, delimiter=delimeter)
        if len(df.columns) == 1:
            delimeter = " "

    try:
        # Now process the files, Requires pandas version lower than 1.2!!
        for df in pd.read_csv(f, chunksize=chunksize, delimiter=delimeter):
            if first_chunk:
                # Change boolean
                first_chunk = False
                
                # Check the headers
                df, fail_reason  = check_headers(df, f)
                readme_txt.namecol = fail_reason

                # Save colnames
                colnames = df.columns

                # Check and fix the sample size
                df, fail_reason = check_n(df)
                readme_txt.samplesize = fail_reason

                # Save as zipped space delimited file
                if "FAILED" not in readme_txt.namecol:
                    if "FAILED" not in readme_txt.samplesize:
                        passed = True
                        name = f.split(".gz")[0].split('/')[-1]
                        df.to_csv(outdir + "/" + name + "_cols_edit.gz", 
                            sep=" ",
                            index=False,
                            na_rep='NA', 
                            compression="gzip")
            else:
                # Only continue if the cohort passed, if the number of columns is wrong down the file it will error out here
                if passed:
                    # Rename columns
                    df.columns = colnames

                    # Fix N
                    df, fail_reason = check_n(df)
                    readme_txt.samplesize = fail_reason

                    # Append output to existing file without header
                    name = f.split(".gz")[0].split('/')[-1]
                    df.to_csv(outdir + "/" + name + "_cols_edit.gz", 
                        sep=" ",
                        index=False,
                        na_rep='NA', 
                        compression="gzip",
                        mode='a', 
                        header=False)

    except Exception as e:
        # This happens when the N columns isn't the same everywhere
        # Save some messsages
        readme_txt.pandascheck = "PANDAS;FAILED;" + str(e)

    # Save some messsages
    write_message(f, readme_txt, outdir)


def parse_arguments():
    """
    Function to handle the arguments
    """
    parser = argparse.ArgumentParser()
    parser.add_argument("-f", "--file", help="file with the cohort you want to check / fix", type=str, required=True)
    parser.add_argument("-o", "--outdir", help="where should the files and the result readme be stored?", type=str, required=True)
    return parser.parse_args()


def write_message(f, readme_txt, outdir):
    """
    Function to write the failed / passed message to the readme and delete if failed
    """
    name = f.split(".gz")[0].split('/')[-1]
    rf = open(outdir + "/" + str(name) + "_README.txt", "a")
    to_write = " " + str(readme_txt.pandascheck) + " " + str(readme_txt.samplesize) + " " + str(readme_txt.namecol)
    rf.write(str(f) +  to_write + "\n")
    rf.close()

    # Remove file if there is FAILED in error message
    if 'FAILED' in to_write:
        name = f.split(".gz")[0].split('/')[-1]
        if os.path.exists(outdir + "/" + name + "_cols_edit.gz"):
            os.remove(outdir + "/" + name + "_cols_edit.gz")



if __name__ == '__main__':
    main()
