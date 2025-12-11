# Import packages
import os
import glob
import importlib
import sys
from subprocess import check_output
import polars as pl
import gwaslab as gl
import argparse
from datetime import datetime
import pandas as pd
import pyarrow as pa
import pyarrow.parquet as pq
from scipy import stats
import numpy as np
import cmcrameri as ccm
from cmcrameri import cm
import matplotlib
import matplotlib.pyplot as plt
import seaborn as sns
import liftover
from liftover import get_lifter
import gzip
import shutil

parser = argparse.ArgumentParser(description="Parser commands.")

requiredNamed = parser.add_argument_group('required named arguments')

requiredNamed.add_argument("-g", "--gwas", help="The name of the GWAS study.", type=str)
requiredNamed.add_argument("-i", "--input", help="The file name of the GWAS study.", type=str)
requiredNamed.add_argument("-d", "--directory", help="The path to the results directory.", type=str)
requiredNamed.add_argument("-r", "--ref", help="The path to the references directory.", type=str)
requiredNamed.add_argument("-p", "--population", help="Population analysed.", type=str, default="EUR")
requiredNamed.add_argument("-f", "--figures", help="Make plots or not?(YES or NO).", type=str, default="YES")
requiredNamed.add_argument("-q", "--qc", help="Perform Quality Control or not?(YES or NO).", type=str, default="YES")
requiredNamed.add_argument("-n", "--onlyqc", help="Perform ONLY Quality Control or not? pickle file has to exist! (YES or NO).", type=str, default="YES")
requiredNamed.add_argument("-l", "--leads", help="select lead SNPs and safe in file?(YES or NO).", type=str, default="YES")
requiredNamed.add_argument("-o", "--output", help="File name for the output file to store the results.", type=str)
requiredNamed.add_argument("-a", "--daf", help="DAF filtering.", type=float, default=0.12)
requiredNamed.add_argument("-e", "--eaf", help="EAF filtering.", type=float, default=0.005)
requiredNamed.add_argument("-b", "--beta", help="BETA filtering.", type=float, default=5)
requiredNamed.add_argument("-s", "--se", help="SE filtering.", type=float, default=5)
requiredNamed.add_argument("-u", "--info", help="INFO filtering.", type=float, default=0.4)
requiredNamed.add_argument("-w", "--hwe", help="HWE filtering.", type=float, default=1E-3)
requiredNamed.add_argument("-m", "--mac", help="MAC filtering.", type=float, default=30)
requiredNamed.add_argument("-z", "--reference", help="Reference genome (hg19 or hg38)", type=str, default="19")


args = parser.parse_args()
gl.check_downloaded_ref()

#reference_identifier = args.identifier
#### set some general defaults
PHENOTYPE = args.gwas

SUBSTUDY_PHENO = f"{PHENOTYPE}"

POPULATION = args.population

perform_qc = args.qc

select_leads= args.leads
only_qc= args.onlyqc
# Reference data directory
REF_loc = args.ref
gl.options.set_option("data_directory",f"{REF_loc}")


REFERENCE = args.reference
DAF = args.daf
EAF = args.eaf
BETA = args.beta
SE = args.se
INFO = args.info
HWE = args.hwe
MAC = args.mac
# GWAS data directory

GWAS_RES_loc = args.directory
INPUT = args.input

#Check if the GWASCatalog directory exists within GWAS_RES_loc
if not os.path.exists(os.path.join(GWAS_RES_loc, "GWASCatalog")):
    # If it doesn't exist, create it
    os.makedirs(os.path.join(GWAS_RES_loc, "GWASCatalog"))

# GWAS Catalog directory
OUTPUT_loc = args.output

# List the files in the GWASCatalog directory
files = os.listdir(OUTPUT_loc)


make_plots=args.figures
#Check if the directory exists
if not (os.path.join(OUTPUT_loc, "PLOTS")):
    # If it doesn't exist, create it
    os.makedirs(os.path.join(OUTPUT_loc, "PLOTS"))
PLOTS_loc = os.path.join(OUTPUT_loc, "PLOTS/")

if only_qc=="YES":
	gwas_data_cohort = gl.load_pickle(
    os.path.join(
        os.path.join(OUTPUT_loc, f"{PHENOTYPE}.hg{REFERENCE}.gwaslab.pkl"),
    )
)

### Load data
if only_qc=="NO":
	temp = pl.read_csv(
    source=os.path.join(
        GWAS_RES_loc
        + "/" + f"{INPUT}",
    ),
    has_header=True,
    separator="\t",
    ignore_errors=False,
    # n_rows=1000, # for debugging
    quote_char=None,
    # necessary to fix issues with missing values when reading data
    null_values=["NA"],
    # There is an error at import (from temp to pandas()):
    # Could not parse `X` as dtype `i64` at column 'CHR' (column number 2)
    # https://stackoverflow.com/questions/75797640/how-to-specify-column-types-in-python-polars-read-csv
    # https://stackoverflow.com/questions/71790235/switching-between-dtypes-within-a-dataframe
    # https://pola-rs.github.io/polars/user-guide/concepts/data-types/
    dtypes={"CHR": pl.Utf8},
)


# change polars dataframe to pandas dataframe
	gwas_data = temp.to_pandas()
	del temp
#     
    
### FIX COLUMNS
# Convert CHR column to string type to handle non-numeric chromosomes
	gwas_data["CHR"] = gwas_data["CHR"].astype(str)

# Optionally map non-numeric chromosomes to integers if required
	chromosome_mapping = {
    'X': '23',
    'Y': '24',
    'MT': '25'
}

	gwas_data["CHR"] = gwas_data["CHR"].replace(chromosome_mapping)
#	gwas_data['CHR'] = gwas_data['CHR'].astype(str).replace({'X': '23'})

# Now you can convert it to an integer type
	gwas_data["CHR"] = gwas_data["CHR"].astype("Int64")


	gwas_data["BP"] = gwas_data[["BP"]].astype("Int64")
	
	gwas_data["EffectAllele"] = gwas_data["EffectAllele"].astype(str)
	gwas_data["OtherAllele"] = gwas_data["OtherAllele"].astype(str)
	
	# Filter out rows with very long alleles (likely structural variants or parsing errors)
	gwas_data = gwas_data[gwas_data["EffectAllele"].str.len() < 10]
	gwas_data = gwas_data[gwas_data["OtherAllele"].str.len() < 10]

# create new SNPID column based on chromosome, position, and alleles
# down the road we need an SNPID column to merge with the reference data and which does not contain 'ID' because this is not correctly interpreted by GWASLab
	gwas_data["SNPID"] = (
    gwas_data["CHR"].astype(str)
    + ":"
    + gwas_data["BP"].astype(str)
    + ":"
    + gwas_data["OtherAllele"].astype(str)
    + ":"
    + gwas_data["EffectAllele"].astype(str)
)

	gwas_data.rename(columns={"SNP": "VariantID"}, inplace=True)
	

### GWASLAB - create variable
# Specify the columns:
import gwaslab as gl



# Specify the columns:
gwas_data_cohort = gl.Sumstats(
    gwas_data,
    snpid="Marker",
    # rsid="RSID", # not available
    chrom="CHR",
    pos="BP",
    ea="EffectAllele",
    nea="OtherAllele",
    eaf="EAF",
    beta="Beta",
    se="SE",
    p="P",
    # direction="Direction",  # only for meta-GWAS
    n="N",
    info="Info", # not available
     other=[
         "DF",
         "CAVEAT",
         "HWE_P",
         "N_cases",
         "N_controls",
         "MAF",
         "MAC",
         "Strand",
         "MarkerOriginal",
         "BetaMinor",
         "Imputed",
         "MajorAllele",
         "MinorAllele"
     ],
    build=f"{REFERENCE}",
    verbose=True,
)


# clean up
del gwas_data


# Execute `basic_check` function - first we just make sure the data has the expected format, columns, and datatypes.
# full data
gwas_data_cohort.basic_check(verbose=True)
print(gwas_data_cohort.data.columns)
print(gwas_data_cohort.data.head())

# Remove duplicates
gwas_data_cohort.remove_dup(
    mode="md",  # remove multi-allelic and duplicate variants
    remove=False,  # remove NAs
    keep_col="P",
    keep_ascend=True,
    # keep the first variant, with the lowest p-value (sorted by that column)
    keep="first",
)


# .check_ref(): Check if NEA is aligned with the reference sequence. After checking, the tracking status code will be changed accordingly.

# full dataset
gwas_data_cohort.check_ref(
    ref_seq=REF_loc + f"/hg{REFERENCE}.fa",
    #   chr_dict=gl.get_number_to_NC(build="19")
)

# we make sure to flip the alleles based on the status code
gwas_data_cohort.flip_allele_stats()
# infer strand for palindromic SNPs/align indistinguishable indels
gwas_data_cohort.infer_strand(
    ref_infer= REF_loc + "/" + f"{POPULATION}.ALL.split_norm_af.1kgp3v5.hg{REFERENCE}.vcf.gz",
    ref_alt_freq="AF",
    n_cores=8
)
gwas_data_cohort.flip_allele_stats()


if REFERENCE == "19":
	gwas_data_cohort.assign_rsid(
	n_cores=8,
	ref_rsid_vcf= REF_loc + "/GCF_000001405.25.gz",  # this works when SNPID is in the format chr:pos
	chr_dict=gl.get_number_to_NC(
	build=f"{REFERENCE}"
	),  # this is needed as in the VCF file, the chromosome is in NC format
	)

if REFERENCE == "38":
	gwas_data_cohort.assign_rsid(
	n_cores=8,
	ref_rsid_vcf= REF_loc + "/GCF_000001405.40.gz",  # this works when SNPID is in the format chr:pos
	chr_dict=gl.get_number_to_NC(
	build=f"{REFERENCE}"
	),  # this is needed as in the VCF file, the chromosome is in NC format
	)



# Check if SNPIDs are correct
gwas_data_cohort.fix_id(
    fixid=True,
    forcefixid=True,
    overwrite=True,
)

gwas_data_cohort.check_af(
    ref_infer=REF_loc + "/" + f"{POPULATION}.ALL.split_norm_af.1kgp3v5.hg{REFERENCE}.vcf.gz",
    ref_alt_freq="AF",
    n_cores=8,
)

gwas_data_cohort.data

# # Step 1: Load the pickled DataFrame using pandas
temp_table = pa.Table.from_pandas(gwas_data_cohort.data)
pq.write_table(
    temp_table,
    os.path.join(
        OUTPUT_loc, f"{INPUT}.hg{REFERENCE}.gwaslab.parquet",
    ),
    compression="BROTLI",
)

# Load the raw Parquet file
df = pd.read_parquet(os.path.join(
        OUTPUT_loc, f"{INPUT}.hg{REFERENCE}.gwaslab.parquet",
    ))
print(df)
print(df.columns.tolist())
# Reformat to your custom format

df["VariantID"] = df["SNPID"] if "SNPID" in df.columns else df["MarkerOriginal"]
# 
# BetaMinor logic
if "BetaMinor" not in df.columns and "BETA" in df.columns:
    df["BetaMinor"] = df["BETA"]

# MAF logic
if "MAF" not in df.columns and "EAF" in df.columns:
    df["MAF"] = df["EAF"]

# Rename core fields
df = df.rename(columns={
    "CHR": "CHR",
    "POS": "BP",
     "EA": "EffectAllele",
     "NEA": "OtherAllele",
    "INFO": "Info",
    "BETA": "Beta"
})



# Define all desired columns
desired_columns = [
    "VariantID", "MarkerOriginal", "rsID", "CHR", "BP", "Strand",
    "EffectAllele", "OtherAllele", "MinorAllele", "MajorAllele",
    "EAF", "MAF", "MAC", "HWE_P", "Info",
    "Beta", "BetaMinor", "SE", "P",
    "N", "N_cases", "N_controls", "Imputed"
]
# 
# Only keep columns that exist in your DataFrame
available_columns = [col for col in desired_columns if col in df.columns]

# Select those
df = df[available_columns]
# Add "NA" to categories for all categorical columns
for col in df.select_dtypes(include="category").columns:
    df[col] = df[col].cat.add_categories(["NA"])

# Now fill missing values safely
df = df.fillna("NA")


# Save the file
output_file = os.path.join(OUTPUT_loc, f"{INPUT}.hg{REFERENCE}.gwaslab.tsv")
df.to_csv(output_file, sep="\t", index=False)
# Compress it using gzip
gzipped_file = output_file + ".gz"
with open(output_file, 'rb') as f_in, gzip.open(gzipped_file, 'wb') as f_out:
    shutil.copyfileobj(f_in, f_out)         

os.remove(output_file)
