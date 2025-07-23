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
# parser.add_argument("-i", "--identifier", help="The VariantID identifier to use (" + ", ".join(["VariantID"] + alt_ids) + ").", type=str)
# parser.add_argument("-s", "--subsample", help="Number of rows to use for subsampling, when determining the optimal VariantID (default = 100,000)", type=int)

requiredNamed = parser.add_argument_group('required named arguments')

requiredNamed.add_argument("-g", "--gwas", help="The name of the GWAS study.", type=str)
requiredNamed.add_argument("-i", "--input", help="The file name of the GWAS study.", type=str)
requiredNamed.add_argument("-d", "--directory", help="The path to the results directory.", type=str)
requiredNamed.add_argument("-r", "--reference", help="The path to the references directory.", type=str)
requiredNamed.add_argument("-p", "--population", help="Population analysed.", type=str)
requiredNamed.add_argument("-f", "--figures", help="Make plots or not?(YES or NO).", type=str)
requiredNamed.add_argument("-q", "--qc", help="Perform Quality Control or not?(YES or NO).", type=str)
requiredNamed.add_argument("-n", "--onlyqc", help="Perform ONLY Quality Control or not? pickle file has to exist! (YES or NO).", type=str)
requiredNamed.add_argument("-l", "--leads", help="select lead SNPs and safe in file?(YES or NO).", type=str)
requiredNamed.add_argument("-o", "--output", help="File name for the output file to store the results.", type=str)
requiredNamed.add_argument("-a", "--daf", help="DAF filtering.", type=float, default=None)
requiredNamed.add_argument("-e", "--eaf", help="EAF filtering.", type=float, default=None)
requiredNamed.add_argument("-b", "--beta", help="BETA filtering.", type=float, default=None)
requiredNamed.add_argument("-s", "--se", help="SEA filtering.", type=float, default=None)
requiredNamed.add_argument("-u", "--info", help="INFO filtering.", type=float, default=None)
requiredNamed.add_argument("-w", "--hwe", help="HWE filtering.", type=float, default=None)
requiredNamed.add_argument("-m", "--mac", help="MAC filtering.", type=float, default=None)


args = parser.parse_args()

#reference_identifier = args.identifier
#### set some general defaults
PHENOTYPE = args.gwas
#PHENOTYPE = args.gwas
#PHENOTYPE = "cox_DEAD_ALL"  # option
SUBSTUDY_PHENO = f"{PHENOTYPE}"

POPULATION = args.population

perform_qc = args.qc

select_leads= args.leads
only_qc= args.onlyqc
# Reference data directory
REF_loc = args.reference
gl.options.set_option("data_directory",f"{REF_loc}")

#REF_loc = "/hpc/dhl_ec/esmulders/references"
print("Checking contents of the reference directory:")
print(check_output(["ls", os.path.join(REF_loc)]).decode("utf8"))

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

print("Checking contents of the GWAS results directory:")
print(check_output(["ls", os.path.join(GWAS_RES_loc)]).decode("utf8"))
#GWAS_RES_loc = "/hpc/dhl_ec/svanderlaan/projects/consortia/CHARGE_cIMT_Sex/CHARGE_cIMT_EUR/cimt_eur/META/"
print("Checking contents of the GWAS results directory:")
print(check_output(["ls", os.path.join(GWAS_RES_loc)]).decode("utf8"))

# #GWAS_DATASETS_loc = "/hpc/dhl_ec/esmulders/GENIUS_CHD/gwaslab/"
# print("Checking contents of the GWAS Datasets directory:")
# print(check_output(["ls", os.path.join(GWAS_DATASETS_loc)]).decode("utf8"))

#Check if the GWASCatalog directory exists within GWAS_RES_loc
if not os.path.exists(os.path.join(GWAS_RES_loc, "GWASCatalog")):
    # If it doesn't exist, create it
    os.makedirs(os.path.join(GWAS_RES_loc, "GWASCatalog"))

# GWAS Catalog directory
OUTPUT_loc = args.output

# List the files in the GWASCatalog directory
files = os.listdir(OUTPUT_loc)
print("Files in GWASCatalog directory:", files)

print(check_output(
    ["ls", os.path.join(OUTPUT_loc)]).decode("utf8"))

#general plotting directory

make_plots=args.figures
#Check if the directory exists
if not (os.path.join(OUTPUT_loc, "PLOTS")):
    # If it doesn't exist, create it
    os.makedirs(os.path.join(OUTPUT_loc, "PLOTS"))
PLOTS_loc = os.path.join(OUTPUT_loc, "PLOTS/")

# regional association plots directory
REG_PLOTS_loc = PLOTS_loc + "/Regional_Association_Plots"

# Check if the directory exists
if not os.path.exists(REG_PLOTS_loc):
    # If it doesn't exist, create it
    os.makedirs(REG_PLOTS_loc)

if only_qc=="YES":
	gwas_data_cohort = gl.load_pickle(
    os.path.join(
        os.path.join(OUTPUT_loc, f"{PHENOTYPE}.b37.gwaslab.pkl"),
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

# Now you can convert it to an integer type
	gwas_data["CHR"] = gwas_data["CHR"].astype("Int64")


	gwas_data[["BP"]] = gwas_data[["BP"]].astype("Int64")

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


# Create CAVEAT column
if 'CAVEAT' not in gwas_data.columns:
    gwas_data['CAVEAT'] = 'None'

gwas_data['CAVEAT'].fillna('None', inplace=True)



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
    ea="MinorAllele",
    nea="MajorAllele",
   # ref="MajorAllele",
   # alt="MinorAllele",
    #eaf="EAF",
    eaf="EAF",
    #beta="Beta",
    beta="BetaMinor",
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
         "Beta"
     ],
    build="19",
    verbose=True,
)
# Specify the columns:
gwas_data_cohort = gl.Sumstats(
    gwas_data,
    snpid="Marker",
    # rsid="RSID", # not available
    chrom="CHR",
    pos="BP",
    ea="EffectAllele",
    nea="OtherAllele",
   #  ref="MajorAllele",
#     alt="MinorAllele",
    eaf="EAF",
    #eaf="MAF",
    beta="Beta",
    #beta="BetaMinor",
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
    build="19",
    verbose=True,
)

	if make_plots == "YES":
    # CAF plot
		plt.figure()
		sns.histplot(
        data=gwas_data_cohort,
        x="EAF",
        bins=25,
        kde=False,
        stat="frequency",
        color="#1290D9",
    )
		plt.title("Histogram of Coded Allele Frequency")
		plt.savefig(
        os.path.join(PLOTS_loc, f"histogram.EAF.{PHENOTYPE}.png"),
        dpi=300,
        bbox_inches="tight",
        format="png",
    )
		plt.close()

    # BETA plot
		plt.figure()
		sns.histplot(
        data=gwas_data_cohort,
        x="BETA",
        bins=25,
        kde=False,
        stat="frequency",
        color="#E55738",
    )
		plt.title("Histogram of Beta Fixed")
		plt.savefig(
        os.path.join(PLOTS_loc, f"histogram.effect.{PHENOTYPE}.png"),
        dpi=300,
        bbox_inches="tight",
        format="png",
    )
		plt.close()
# clean up
del gwas_data


# Execute `basic_check` function - first we just make sure the data has the expected format, columns, and datatypes.
# full data
gwas_data_cohort.basic_check(verbose=True)

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
    ref_seq=REF_loc + "/hg19.fa",
    #   chr_dict=gl.get_number_to_NC(build="19")
)

# we make sure to flip the alleles based on the status code
gwas_data_cohort.flip_allele_stats()
# infer strand for palindromic SNPs/align indistinguishable indels
gwas_data_cohort.infer_strand(
    ref_infer= REF_loc + "/" + f"{POPULATION}.ALL.split_norm_af.1kgp3v5.hg19.vcf.gz",
    ref_alt_freq="AF",
    n_cores=8
)
gwas_data_cohort.flip_allele_stats()


# # Assign rsID by matching SNPID with CHR:POS:REF:ALT in the reference
# 	gwas_data_cohort.assign_rsid(
#     n_cores=8,
#     # this works for common variants
#     ref_rsid_tsv=REF_loc + "1kg_dbsnp151_hg19_auto.txt.gz",
#     # ref_rsid_vcf=gl.get_path("dbsnp_v156_hg19"),
#     chr_dict=gl.get_number_to_NC(
#         build="19"
#     ),  # this is needed as in the VCF file, the chromosome is in NC format
# )
gwas_data_cohort.assign_rsid(
    n_cores=8,
    # ref_rsid_tsv = gl.get_path("1kg_dbsnp151_hg19_auto"),
    ref_rsid_vcf= REF_loc + "/GCF_000001405.25.gz",  # this works when SNPID is in the format chr:pos
    chr_dict=gl.get_number_to_NC(
        build="19"
    ),  # this is needed as in the VCF file, the chromosome is in NC format
)

# Check if SNPIDs are correct
gwas_data_cohort.fix_id(
    fixid=True,
    forcefixid=True,
    overwrite=True,
)

gwas_data_cohort.check_af(
    ref_infer=REF_loc + "/" + f"{POPULATION}.ALL.split_norm_af.1kgp3v5.hg19.vcf.gz",
    ref_alt_freq="AF",
    n_cores=8,
)

gwas_data_cohort.data
#gwas_data_cohort.dtypes
#gwas_data_cohort.summary()
gl.dump_pickle(
    gwas_data_cohort,
    os.path.join(
        OUTPUT_loc + "/" + PHENOTYPE + ".b37.gwaslab.pkl",
    ),
    overwrite=True,
)

gwas_data_cohort.log.show()

# gwas_data_cohort.log.save(
#     os.path.join(
#         OUTPUT_loc + "/" + PHENOTYPE + ".b37.gwaslab.log",
#     )
# )
# 
# gwas_data_cohort.to_format(
#     os.path.join(OUTPUT_loc + "/" + PHENOTYPE + ".b37.gwaslab"),
#     fmt="ssf",
#     build="19",
# )
#plot allele frequency comparison plot against reference
if make_plots == "YES":
	gwas_data_cohort.plot_daf(threshold=0.12, save=os.path.join(PLOTS_loc, f"EAF.{PHENOTYPE}.png"))


# # select caveats in dataset
# 	temp = gwas_data_cohort.data["CAVEAT"].value_counts()
# 
# 	temp.to_csv(
#     os.path.join(
#         OUTPUT_loc + PHENOTYPE + ".b37.counts_caveats.csv",
#     )
# )
#	del temp



# manhattan and qq plot
if make_plots == "YES":
	gwas_data_cohort.plot_daf(threshold=0.12)
    # Manhattan and QQ plot
	gwas_data_cohort.plot_mqq(
        skip=2,
        cut=10,
        sig_line=True,
        sig_level=5e-8,
        anno="GENENAME",
        anno_style="right",
        windowsizekb=500,
        arm_offset=2,
        repel_force=0.02,  # default 0.01
        use_rank=True,
        build="19",
        stratified=True,
        drop_chr_start=True,
        title=f"{PHENOTYPE}",
        save=os.path.join(PLOTS_loc, f"manhattan.500kb.300dpi.{PHENOTYPE}.png"),
        saveargs={"dpi": 300},
        verbose=True,
    )

# Perform Quality Control if required
if perform_qc == "YES" or only_qc == "YES":
	filters = []
	if EAF is not None:
		filters.append(f'(EAF >= {EAF} & EAF < {1 - EAF})')
	else:
		filters.append('(EAF >= 0.01 & EAF < 0.99)')  # default range if EAF is not specified
	if DAF is not None:
		filters.append(f'(DAF < {DAF} & DAF > {-DAF})')
	if BETA is not None:
		filters.append(f'(BETA <= {BETA})')
	if SE is not None:
		filters.append(f'(SE <= {SE})')
	if INFO is not None:
		filters.append(f'(INFO >= {INFO})')
	if HWE is not None:
		filters.append(f'(HWE <= {HWE})')
	if MAC is not None:
		filters.append(f'(MAC >= {MAC})')
    # Join active filters
	expr = ' & '.join(filters)
	print("Applying filter with expression:")
	print(expr)
    # Apply filtering
	gwas_data_cohort_qc = gwas_data_cohort.filter_value(expr=expr)
# 	gwas_data_cohort_qc = gwas_data_cohort.filter_value(
#     f'(EAF >= 0.01 & EAF < 0.99) & (DAF < {DAF} & DAF > (-1 * {DAF})) & '
#     f'(BETA <= {BETA}) & (SE <= {SE}) & (INFO >= {INFO}) & (HWE <= {HWE}) & (MAC >= {MAC})'
# )
	gl.dump_pickle(
        gwas_data_cohort_qc,
        os.path.join(OUTPUT_loc, f"{PHENOTYPE}.b37.gwaslab.qc.pkl"),
        overwrite=True,
    )
	gwas_data_cohort_qc.log.show()

	gwas_data_cohort_qc.log.save(
        os.path.join(OUTPUT_loc, f"{PHENOTYPE}.b37.gwaslab.qc.log")
    )

	gwas_data_cohort_qc.to_format(
        os.path.join(OUTPUT_loc, f"{PHENOTYPE}.b37.gwaslab.qc"),
        fmt="ssf",
        build="19",
    )

# # Step 1: Load the pickled DataFrame using pandas
# df = pd.read_pickle(os.path.join(OUTPUT_loc, f"{PHENOTYPE}.b37.gwaslab.qc.pkl"))
temp_table = pa.Table.from_pandas(gwas_data_cohort_qc.data)
pq.write_table(
    temp_table,
    os.path.join(
        OUTPUT_loc, f"{PHENOTYPE}.b37.gwaslab.qc.parquet",
    ),
    compression="BROTLI",
)

# Load the raw Parquet file
df = pd.read_parquet(os.path.join(
        OUTPUT_loc, f"{PHENOTYPE}.b37.gwaslab.qc.parquet",
    ))
print(df)
print(df.columns.tolist())
# Reformat to your custom format

df["VariantID"] = df["SNPID"] if "SNPID" in df.columns else df["MarkerOriginal"]

# BetaMinor logic
if "BetaMinor" not in df.columns and "BETA" in df.columns:
    df["BetaMinor"] = df["BETA"]

# MAF logic
if "MAF" not in df.columns and "EAF" in df.columns:
    df["MAF"] = df["EAF"]
# df = df.rename(columns={
#     "CHR": "CHR",
#     "POS": "BP",
#     "SE": "SE",
#     "P": "P",
#     "EA": "MinorAllele",
#     "NEA": "MajorAllele",
#     "INFO": "Info"
# })
# Rename core fields
df = df.rename(columns={
    "CHR": "CHR",
    "POS": "BP",
     "EA": "EffectAllele",
     "NEA": "OtherAllele",
    "INFO": "Info",
    "BETA": "Beta"
})

# # Define all desired columns
# desired_columns = [
#     "VariantID", "MarkerOriginal", "rsID", "CHR", "BP", "Strand",
#     "EffectAllele", "OtherAllele", "MinorAllele", "MajorAllele",
#     "EAF", "MAF", "MAC", "HWE_P", "Info",
#     "Beta", "BetaMinor", "SE", "P",
#     "N", "N_cases", "N_controls", "Imputed"
# ]
# 
# # Only keep columns that exist in your DataFrame
# available_columns = [col for col in desired_columns if col in df.columns]
# 
# # Select those
# df = df[available_columns]
# # df = df[[
# #     "VariantID", "CHR", "BP", "BetaMinor", "SE", "P",
# #     "MinorAllele", "MajorAllele", "MAF", "Info", "N_cases", "N_controls", "Imputed", "MAC", "HWE_P", "Strand", "rsID"
# # ]]
# df = df[[
#     "VariantID", "MarkerOriginal", "rsID", "CHR", "BP", "Strand", "EffectAllele", "OtherAllele",  "MinorAllele", "MajorAllele",  
#      "EAF","MAF", "MAC", "HWE_P", "Info", "Beta", "BetaMinor", "SE", "P",  "N", "N_cases", "N_controls", "Imputed"
# ]]

# Define all desired columns
desired_columns = [
    "VariantID", "MarkerOriginal", "rsID", "CHR", "BP", "Strand",
    "EffectAllele", "OtherAllele", "MinorAllele", "MajorAllele",
    "EAF", "MAF", "MAC", "HWE_P", "Info",
    "Beta", "BetaMinor", "SE", "P",
    "N", "N_cases", "N_controls", "Imputed"
]

# Only keep columns that exist in your DataFrame
available_columns = [col for col in desired_columns if col in df.columns]

# Select those
df = df[available_columns]
# Add "NA" to categories for all categorical columns
for col in df.select_dtypes(include="category").columns:
    df[col] = df[col].cat.add_categories(["NA"])

# Now fill missing values safely
df = df.fillna("NA")

# # Save reformatted version
# df.to_csv(os.path.join(
#          OUTPUT_loc, f"{PHENOTYPE}.b37.gwaslab.qc.tsv"),sep="\t", index=False)
         
# Save the file
output_file = os.path.join(OUTPUT_loc, f"{PHENOTYPE}.b37.gwaslab.qc.tsv")
df.to_csv(output_file, sep="\t", index=False)
# Compress it using gzip
gzipped_file = output_file + ".gz"
with open(output_file, 'rb') as f_in, gzip.open(gzipped_file, 'wb') as f_out:
    shutil.copyfileobj(f_in, f_out)         

os.remove(output_file)
# Step 2: Export to TSV
# # Rename and select the desired columns
# df_reformatted = df.rename(columns={
#     "variant_id": "VariantID",
#     "rsid": "VariantID",  # Use this only if variant_id is missing
#     "chromosome": "CHR",
#     "base_pair_location": "BP",
#     "beta": "BetaMinor",
#     "standard_error": "SE",
#     "p_value": "P",
#     "effect_allele": "MinorAllele",
#     "other_allele": "MajorAllele",
#     "effect_allele_frequency": "MAF",
#     "info": "Info"
# })
# # Step 2: Convert to Polars DataFrame
# df = pl.from_pandas(df_pd)
# 
# # Step 3: Create or rename necessary columns
# # Create VariantID (from SNPID or MarkerOriginal)
# if "SNPID" in df.columns:
#     df = df.with_columns([
#         pl.col("SNPID").alias("VariantID")
#     ])
# elif "MarkerOriginal" in df.columns:
#     df = df.with_columns([
#         pl.col("MarkerOriginal").alias("VariantID")
#     ])
# 
# # BetaMinor (from BetaMinor or BETA)
# if "BetaMinor" in df.columns:
#     df = df.with_columns([
#         pl.col("BetaMinor").alias("Beta_final")
#     ])
# else:
#     df = df.with_columns([
#         pl.col("BETA").alias("Beta_final")
#     ])
# 
# # MAF (from MAF or EAF)
# if "MAF" in df.columns:
#     df = df.with_columns([
#         pl.col("MAF").alias("MAF_final")
#     ])
# else:
#     df = df.with_columns([
#         pl.col("EAF").alias("MAF_final")
#     ])
# 
# # Step 4: Rename and select desired columns
# df_final = df.rename({
#     "CHR": "CHR",
#     "POS": "BP",
#     "SE": "SE",
#     "P": "P",
#     "EA": "MinorAllele",
#     "NEA": "MajorAllele",
#     "INFO": "Info",
#     "Beta_final": "BetaMinor",
#     "MAF_final": "MAF"
# }).select([
#     "VariantID", "CHR", "BP", "BetaMinor", "SE", "P",
#     "MinorAllele", "MajorAllele", "MAF", "Info"
# ])
# 
# # Step 5: Save to TSV
# df_final.write_csv(os.path.join(OUTPUT_loc,"reformatted_summary_stats.tsv", separator="\t"))

# df = pd.read_pickle(os.path.join(OUTPUT_loc, f"{PHENOTYPE}.b37.gwaslab.qc.pkl"))
# 
# # Decide which column to use for VariantID
# if "SNPID" in df.columns:
#     df["VariantID"] = df["SNPID"]
# elif "MarkerOriginal" in df.columns:
#     df["VariantID"] = df["MarkerOriginal"]
# 
# # Choose MAF column preference
# if "MAF" in df.columns:
#     df["MAF_final"] = df["MAF"]
# elif "EAF" in df.columns:
#     df["MAF_final"] = df["EAF"]
# 
# # Choose Beta preference
# if "BetaMinor" in df.columns:
#     df["Beta_final"] = df["BetaMinor"]
# else:
#     df["Beta_final"] = df["BETA"]
# 
# # Build reformatted DataFrame
# df_reformatted = df.rename(columns={
#     "CHR": "CHR",
#     "POS": "BP",
#     "SE": "SE",
#     "P": "P",
#     "EA": "MinorAllele",
#     "NEA": "MajorAllele",
#     "INFO": "Info"
# })
# 
# # Select and reorder columns
# df_reformatted = df_reformatted[
#     ["VariantID", "CHR", "BP", "Beta_final", "SE", "P",
#      "MinorAllele", "MajorAllele", "MAF_final", "Info"]
# ]
# 
# # Rename the columns for final output
# df_reformatted.columns = [
#     "VariantID", "CHR", "BP", "BetaMinor", "SE", "P",
#     "MinorAllele", "MajorAllele", "MAF", "Info"
# ]
# 
# # Save to TSV
# df_reformatted.to_csv(os.path.join(OUTPUT_loc,"reformatted_summary_stats.tsv", sep="\t", index=False))
# 

#     # Generate plots if required
if make_plots == "YES":
	        gwas_data_cohort_qc.plot_mqq(
            skip=2,
            cut=10,
            sig_line=True,
            sig_level=5e-8,
            anno="GENENAME",
            anno_style="right",
            windowsizekb=500,
            arm_offset=2,
            repel_force=0.02,  # default 0.01
            use_rank=True,
            build="19",
            stratified=True,
            drop_chr_start=True,
            save=os.path.join(PLOTS_loc, f"manhattan.500kb.300dpi.{PHENOTYPE}.qc.png"),
            saveargs={"dpi": 300},
            verbose=True,
        )

if select_leads=="YES":
		gwas_data_cohort_leads = gwas_data_cohort.get_lead(anno=True, windowsizekb=0, sig_level=5e-8, verbose=True, gls=True)
		gwas_data_cohort_leads.to_format(
    os.path.join(OUTPUT_loc + "/" + PHENOTYPE + ".b37.gwaslab.significant_snps"),
    fmt="ssf",
    build="19",
)

if select_leads=="YES":
		gwas_data_cohort_leads = gwas_data_cohort.get_lead(anno=True, sig_level=5e-8, verbose=True)
		gwas_data_cohort_leads.to_format(
    os.path.join(OUTPUT_loc + "/" + PHENOTYPE + ".b37.gwaslab.leads"),
    fmt="ssf",
    build="19",
)