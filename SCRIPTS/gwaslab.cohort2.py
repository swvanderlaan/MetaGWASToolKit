# Import packages
import os
import glob
import importlib
import sys
from subprocess import check_output
#import polars as pl
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
#PHENOTYPE = args.gwas
#PHENOTYPE = "cox_DEAD_ALL"  # option
SUBSTUDY_PHENO = f"{PHENOTYPE}"

POPULATION = args.population

perform_qc = args.qc

select_leads= args.leads
only_qc= args.onlyqc
# Reference data directory
REF_loc = args.ref
gl.options.set_option("data_directory",f"{REF_loc}")

#REF_loc = "/hpc/dhl_ec/esmulders/references"
# print("Checking contents of the reference directory:")
# print(check_output(["ls", os.path.join(REF_loc)]).decode("utf8"))
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

print("Checking contents of the GWAS results directory:")
print(check_output(["ls", os.path.join(GWAS_RES_loc)]).decode("utf8"))


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


if only_qc == "NO":
	gwas_data = pd.read_csv(
	os.path.join(GWAS_RES_loc, INPUT),
	sep="\t",
	header=0,
	na_values=["NA"],
	dtype={"CHR": "string"},   # matches your intention for CHR
	engine="pyarrow",          # faster if pyarrow is available; else drop this line
	)
	
# # change polars dataframe to pandas dataframe
# 	gwas_data = temp.to_pandas()
# 	del temp
	
	if make_plots == "YES":
    # CAF plot
		plt.figure()
		sns.histplot(
        data=gwas_data,
        x="EAF",
        bins=25,
        kde=False,
        stat="frequency",
        color="#1290D9",
    )
		plt.title("Histogram of Effect Allele Frequency")
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
        data=gwas_data,
        x="Beta",
        bins=25,
        kde=False,
        stat="frequency",
        color="#E55738",
    )
		plt.title("Histogram of Effect-Sizes")
		plt.savefig(
        os.path.join(PLOTS_loc, f"histogram.effect.{PHENOTYPE}.png"),
        dpi=300,
        bbox_inches="tight",
        format="png",
    )
		plt.close()


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
    snpid="VariantID",
    rsid="rsID", # not available
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
         "MinorAllele",
         "DAF"
     ],
    build=f"{REFERENCE}",
    verbose=True,
)

#VariantID	MarkerOriginal	rsID	CHR	BP	Strand	EffectAllele	OtherAllele	MinorAllele	MajorAllele	EAF	MAF	MAC	HWE_P	Info	Beta	BetaMinor	SE	P	N	N_cases	N_controls	Imputed
# clean up
	del gwas_data

# Execute `basic_check` function - first we just make sure the data has the expected format, columns, and datatypes.
# full data
	gwas_data_cohort.basic_check(verbose=True)

	gwas_data_cohort.data

#if only_qc=="NO":
	gl.dump_pickle(
	gwas_data_cohort,
	os.path.join(
        OUTPUT_loc + "/" + f"{PHENOTYPE}.hg{REFERENCE}.gwaslab.pkl",
    ),
    overwrite=True,
	)

#plot allele frequency comparison plot against reference
	if make_plots == "YES":
		gwas_data_cohort.plot_daf(threshold=DAF, save=os.path.join(PLOTS_loc, f"EAF.{PHENOTYPE}.png"))

# select caveats in dataset
	temp = gwas_data_cohort.data["CAVEAT"].value_counts()

	temp.to_csv(
	os.path.join(
        OUTPUT_loc + "/" + PHENOTYPE + f".hg{REFERENCE}.counts_caveats.csv",
    )
	)
	del temp

# manhattan and qq plot
	if make_plots == "YES":
		gwas_data_cohort.plot_daf(threshold=DAF)
    # Manhattan and QQ plot
		gwas_data_cohort.plot_mqq(
        skip=2,
        cut=10,
        mode="m",
        sig_line=True,
        sig_level=5e-8,
        anno="GENENAME",
        anno_style="right",
        windowsizekb=500,
        arm_offset=2,
        repel_force=0.02,  # default 0.01
        use_rank=True,
        build=f"{REFERENCE}",
        stratified=True,
        drop_chr_start=True,
        title=f"{PHENOTYPE}",
        save=os.path.join(PLOTS_loc, f"manhattan.500kb.300dpi.{PHENOTYPE}.png"),
        saveargs={"dpi": 300},
        verbose=True,
    )
		gwas_data_cohort.plot_mqq(
        skip=2,
        cut=10,
        mode="qq",
        sig_line=True,
        sig_level=5e-8,
        arm_offset=2,
        repel_force=0.02,  # default 0.01
        use_rank=True,
        build="{REFERENCE}",
        stratified=True,
        drop_chr_start=True,
        title=f"{PHENOTYPE}",
        save=os.path.join(PLOTS_loc, f"qq.500kb.300dpi.{PHENOTYPE}.png"),
        saveargs={"dpi": 300},
        verbose=True,
    )
################ END of no QC#####
if only_qc == "YES":
    gwas_data_cohort = gl.load_pickle(
        os.path.join(GWAS_RES_loc, f"{PHENOTYPE}.hg{REFERENCE}.gwaslab.pkl"),
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
    # Join active filters
	expr = ' & '.join(filters)
	print("Applying filter with expression:")
	print(expr)
	# Apply filtering
	# Make sure numeric columns are actually numeric before filtering
	num_cols = ["EAF","DAF","BETA","SE","INFO","MAC","HWE_P","N","N_cases","N_controls","POS"]
	for c in num_cols:
		if c in gwas_data_cohort.data.columns:
			gwas_data_cohort.data[c] = pd.to_numeric(gwas_data_cohort.data[c], errors="coerce")
	gwas_data_cohort_qc = gwas_data_cohort.filter_value(expr=expr)
	temp_table = pa.Table.from_pandas(gwas_data_cohort_qc.data)
	pq.write_table(
	temp_table,
	os.path.join(OUTPUT_loc, f"{PHENOTYPE}.hg{REFERENCE}.gwaslab.qc.parquet",),
	compression="BROTLI",
	)
# Load the raw Parquet file
	df = pd.read_parquet(os.path.join(OUTPUT_loc, f"{PHENOTYPE}.hg{REFERENCE}.gwaslab.qc.parquet",))
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

# Rename core fields
	df = df.rename(columns={
    "CHR": "CHR",
    "POS": "BP",
     "EA": "EffectAllele",
     "NEA": "OtherAllele",
    "INFO": "Info",
    "BETA": "Beta"})



# Define all desired columns
	desired_columns = ["VariantID", "MarkerOriginal", "rsID", "CHR", "BP", "Strand",
    "EffectAllele", "OtherAllele", "MinorAllele", "MajorAllele",
    "EAF", "MAF", "MAC", "HWE_P", "Info",
    "Beta", "BetaMinor", "SE", "P",
    "N", "N_cases", "N_controls", "Imputed","DAF"]

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
	output_file = os.path.join(OUTPUT_loc, f"{PHENOTYPE}.hg{REFERENCE}.gwaslab.qc.tsv")
	df.to_csv(output_file, sep="\t", index=False)
# Compress it using gzip
	gzipped_file = output_file + ".gz"
	with open(output_file, 'rb') as f_in, gzip.open(gzipped_file, 'wb') as f_out:
		shutil.copyfileobj(f_in, f_out)         

	os.remove(output_file)

#     # Generate plots if required
	if make_plots == "YES":
		gwas_data_cohort_qc.plot_mqq(
        skip=2,
        cut=10,
        mode="m",
        sig_line=True,
        sig_level=5e-8,
        anno="GENENAME",
        anno_style="right",
        windowsizekb=500,
        arm_offset=2,
        repel_force=0.02,  # default 0.01
        use_rank=True,
        build=f"{REFERENCE}",
        stratified=True,
        drop_chr_start=True,
        title=f"{PHENOTYPE}",
        save=os.path.join(PLOTS_loc, f"manhattan.500kb.300dpi.{PHENOTYPE}.qc.png"),
        saveargs={"dpi": 300},
        verbose=True,
    )
		gwas_data_cohort_qc.plot_mqq(
        skip=2,
        cut=10,
        mode="qq",
        sig_line=True,
        sig_level=5e-8,
        arm_offset=2,
        repel_force=0.02,  # default 0.01
        use_rank=True,
        build="{REFERENCE}",
        stratified=True,
        drop_chr_start=True,
        title=f"{PHENOTYPE}",
        save=os.path.join(PLOTS_loc, f"qq.500kb.300dpi.{PHENOTYPE}.qc.png"),
        saveargs={"dpi": 300},
        verbose=True,
    )
	if select_leads=="YES":
		gwas_data_cohort_leads = gwas_data_cohort.get_lead(anno=True, windowsizekb=0, sig_level=5e-8, verbose=True, gls=True)
		gwas_data_cohort_leads.to_format(
    os.path.join(OUTPUT_loc + "/" + PHENOTYPE + f".hg{REFERENCE}.gwaslab.significant_snps"),
    fmt="ssf",
    build="{REFERENCE}",
	)

	if select_leads == "YES":
		gwas_data_cohort_leads_df = gwas_data_cohort.get_lead(anno=True, sig_level=5e-8, verbose=True)

    # Wrap the DataFrame in a new Sumstats object
		gwas_data_cohort_leads = gl.Sumstats(sumstats=gwas_data_cohort_leads_df)
		gwas_data_cohort_leads.to_format(
        os.path.join(OUTPUT_loc, f"{PHENOTYPE}.hg{REFERENCE}.gwaslab.leads"),
        fmt="ssf",
        build=f"{REFERENCE}",)
