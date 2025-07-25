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
from scipy import stats
import numpy as np
import cmcrameri as ccm
from cmcrameri import cm
import matplotlib
import matplotlib.pyplot as plt
import seaborn as sns
import liftover
from liftover import get_lifter

parser = argparse.ArgumentParser(description="Parser commands.")
# parser.add_argument("-i", "--identifier", help="The VariantID identifier to use (" + ", ".join(["VariantID"] + alt_ids) + ").", type=str)
# parser.add_argument("-s", "--subsample", help="Number of rows to use for subsampling, when determining the optimal VariantID (default = 100,000)", type=int)

requiredNamed = parser.add_argument_group('required named arguments')

requiredNamed.add_argument("-g", "--gwas", help="The name of the GWAS study.", type=str)
requiredNamed.add_argument("-i", "--input", help="The path and name of the parsed input file.", type=str)
requiredNamed.add_argument("-d", "--directory", help="The path to the results directory.", type=str)
requiredNamed.add_argument("-r", "--reference", help="The path to the references directory.", type=str)
requiredNamed.add_argument("-p", "--population", help="Population analysed.", type=str)
requiredNamed.add_argument("-f", "--figures", help="Make plots or not?(YES or NO).", type=str)
requiredNamed.add_argument("-q", "--qc", help="Perform Quality Control or not?(YES or NO).", type=str)
requiredNamed.add_argument("-n", "--onlyqc", help="Perform ONLY Quality Control or not? pickle file has to exist! (YES or NO).", type=str)
requiredNamed.add_argument("-l", "--leads", help="select lead SNPs and safe in file?(YES or NO).", type=str)
requiredNamed.add_argument("-e", "--df", help="degrees of freedom (DF), for filtering.", type=int)
#requiredNamed.add_argument("-o", "--output", help="File name for the output file to store the results.", type=str)
args = parser.parse_args()

#reference_identifier = args.identifier
#### set some general defaults

PHENOTYPE = args.gwas
#PHENOTYPE = "cox_DEAD_ALL"  # option
SUBSTUDY_PHENO = f"META_{PHENOTYPE}"

POPULATION = args.population

perform_qc = args.qc
DF = args.df
select_leads= args.leads
only_qc= args.onlyqc
# Reference data directory
REF_loc = args.reference
gl.options.set_option("data_directory",f"{REF_loc}")

#REF_loc = "/hpc/dhl_ec/esmulders/references"
print("Checking contents of the reference directory:")
print(check_output(["ls", os.path.join(REF_loc)]).decode("utf8"))

#DAF = args.daf

# GWAS data directory

GWAS_RES_loc = args.directory
# print("Checking contents of the GWAS results directory:")
# print(check_output(["ls", os.path.join(GWAS_RES_loc)]).decode("utf8"))
# GWAS_RES_loc = "/hpc/dhl_ec/svanderlaan/projects/consortia/CHARGE_cIMT_Sex/CHARGE_cIMT_EUR/cimt_eur/META/"
# print("Checking contents of the GWAS results directory:")
# print(check_output(["ls", os.path.join(GWAS_RES_loc)]).decode("utf8"))

# GWAS_DATASETS_loc = "/hpc/dhl_ec/esmulders/GENIUS_CHD/gwaslab/"
# print("Checking contents of the GWAS Datasets directory:")
# print(check_output(["ls", os.path.join(GWAS_DATASETS_loc)]).decode("utf8"))

# Check if the GWASCatalog directory exists within GWAS_RES_loc
if not os.path.exists(os.path.join(GWAS_RES_loc, "GWASCatalog")):
    # If it doesn't exist, create it
    os.makedirs(os.path.join(GWAS_RES_loc, "GWASCatalog"))

# GWAS Catalog directory
GWASCatalog_loc = os.path.join(GWAS_RES_loc, "GWASCatalog/")

# # List the files in the GWASCatalog directory
# files = os.listdir(GWASCatalog_loc)
# print("Files in GWASCatalog directory:", files)

print(check_output(
    ["ls", os.path.join(GWASCatalog_loc)]).decode("utf8"))

# general plotting directory

make_plots=args.figures
# Check if the directory exists
if not (os.path.join(GWAS_RES_loc, "PLOTS")):
    # If it doesn't exist, create it
    os.makedirs(os.path.join(GWAS_RES_loc, "PLOTS"))
PLOTS_loc = os.path.join(GWAS_RES_loc, "PLOTS/")

# regional association plots directory
REG_PLOTS_loc = PLOTS_loc + "/Regional_Association_Plots"

# Check if the directory exists
if not os.path.exists(REG_PLOTS_loc):
    # If it doesn't exist, create it
    os.makedirs(REG_PLOTS_loc)

if only_qc=="YES":
	gwas_data_sumstats = gl.load_pickle(
    os.path.join(
        os.path.join(GWASCatalog_loc, f"{PHENOTYPE}.b37.gwaslab.pkl"),
    )
)
	gwas_data_sumstats.data

### Load data
if only_qc=="NO":
	temp = pl.read_csv(
    source=os.path.join(
        GWAS_RES_loc
        + "/meta.results." + PHENOTYPE + ".1Gp3." + POPULATION + ".summary.txt.gz",
    ),
    has_header=True,
    separator=" ",
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


	if make_plots == "YES":
    # CAF plot
		plt.figure()
		sns.histplot(
        data=gwas_data,
        x="CAF",
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
        data=gwas_data,
        x="BETA_FIXED",
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


	gwas_data[["POS"]] = gwas_data[["POS"]].astype("Int64")

# create new SNPID column based on chromosome, position, and alleles
# down the road we need an SNPID column to merge with the reference data and which does not contain 'ID' because this is not correctly interpreted by GWASLab
	gwas_data["SNPID"] = (
    gwas_data["CHR"].astype(str)
    + ":"
    + gwas_data["POS"].astype(str)
    + ":"
    + gwas_data["OTHERALLELE"].astype(str)
    + ":"
    + gwas_data["CODEDALLELE"].astype(str)
)

	gwas_data.rename(columns={"SNP": "VariantID"}, inplace=True)

# Create CAVEAT column
	gwas_data['CAVEAT'].fillna('None', inplace=True)



### GWASLAB - create variable
# Specify the columns:
	gwas_data_sumstats = gl.Sumstats(
    gwas_data,
    snpid="VARIANTID",
    # rsid="RSID", # not available
    chrom="CHR",
    pos="POS",
    ea="CODEDALLELE",
    nea="OTHERALLELE",
    eaf="CAF",
    beta="BETA_FIXED",
    se="SE_FIXED",
    p="P_FIXED",
    # direction="Direction",  # only for meta-GWAS
    n="N_EFF",
    # info="Info", # not available
    other=[
        "DF",
        "DIRECTIONS",
        "P_COCHRANS_Q",
        "I_SQUARED",
        "CAVEAT",
    ],
    build="19",
    verbose=True,
)
# clean up
	del gwas_data


# Execute `basic_check` function - first we just make sure the data has the expected format, columns, and datatypes.
# full data
	gwas_data_sumstats.basic_check(verbose=True)

# Remove duplicates
	gwas_data_sumstats.remove_dup(
    mode="md",  # remove multi-allelic and duplicate variants
    remove=False,  # remove NAs
    keep_col="P",
    keep_ascend=True,
    # keep the first variant, with the lowest p-value (sorted by that column)
    keep="first",
)


# .check_ref(): Check if NEA is aligned with the reference sequence. After checking, the tracking status code will be changed accordingly.

# full dataset
	gwas_data_sumstats.check_ref(
    ref_seq=REF_loc + "hg19.fa",
    #   chr_dict=gl.get_number_to_NC(build="19")
)

# we make sure to flip the alleles based on the status code
	gwas_data_sumstats.flip_allele_stats()
# infer strand for palindromic SNPs/align indistinguishable indels
	gwas_data_sumstats.infer_strand(
    ref_infer= REF_loc + f"{POPULATION}.ALL.split_norm_af.1kgp3v5.hg19.vcf.gz",
    ref_alt_freq="AF",
    n_cores=8
)
	gwas_data_sumstats.flip_allele_stats()


# # Assign rsID by matching SNPID with CHR:POS:REF:ALT in the reference
# 	gwas_data_sumstats.assign_rsid(
#     n_cores=8,
#     # this works for common variants
#     ref_rsid_tsv=REF_loc + "1kg_dbsnp151_hg19_auto.txt.gz",
#     # ref_rsid_vcf=gl.get_path("dbsnp_v156_hg19"),
#     chr_dict=gl.get_number_to_NC(
#         build="19"
#     ),  # this is needed as in the VCF file, the chromosome is in NC format
# )
	gwas_data_sumstats.assign_rsid(
    n_cores=8,
    # ref_rsid_tsv = gl.get_path("1kg_dbsnp151_hg19_auto"),
    ref_rsid_vcf= REF_loc + "GCF_000001405.25.gz",  # this works when SNPID is in the format chr:pos
    chr_dict=gl.get_number_to_NC(
        build="19"
    ),  # this is needed as in the VCF file, the chromosome is in NC format
)

# Check if SNPIDs are correct
	gwas_data_sumstats.fix_id(
    fixid=True,
    forcefixid=True,
    overwrite=True,
)

	gwas_data_sumstats.check_af(
    ref_infer=REF_loc + f"{POPULATION}.ALL.split_norm_af.1kgp3v5.hg19.vcf.gz",
    ref_alt_freq="AF",
    n_cores=8,
)
#plot allele frequency comparison plot against reference
if make_plots == "YES":
	gwas_data_sumstats.plot_daf(threshold=0.12, save=os.path.join(PLOTS_loc, f"EAF.{PHENOTYPE}.png"))


# select caveats in dataset
	temp = gwas_data_sumstats.data["CAVEAT"].value_counts()

	temp.to_csv(
    os.path.join(
        GWASCatalog_loc + PHENOTYPE + ".b37.counts_caveats.csv",
    )
)
	del temp

	gl.dump_pickle(
    gwas_data_sumstats,
    os.path.join(
        GWASCatalog_loc + PHENOTYPE + ".b37.gwaslab.pkl",
    ),
    overwrite=True,
)

	gwas_data_sumstats.log.show()

	gwas_data_sumstats.log.save(
    os.path.join(
        GWASCatalog_loc + PHENOTYPE + ".b37.gwaslab.log",
    )
)

	gwas_data_sumstats.to_format(
    os.path.join(GWASCatalog_loc + PHENOTYPE + ".b37.gwaslab"),
    fmt="ssf",
    build="19",
)


# manhattan and qq plot
	if make_plots == "YES":
		gwas_data_sumstats.plot_daf(threshold=0.12)
    # Manhattan and QQ plot
	gwas_data_sumstats.plot_mqq(
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
	    gwas_data_sumstats_qc = gwas_data_sumstats.filter_value(
        '(EAF>=0.01 & EAF<0.99 & DF>={DF}) & (DAF<0.12 & DAF>-0.12) & (CAVEAT=="None")'
        )
	    gl.dump_pickle(
        gwas_data_sumstats_qc,
        os.path.join(GWASCatalog_loc, f"{PHENOTYPE}.b37.gwaslab.qc.pkl"),
        overwrite=True,
    )

	    gwas_data_sumstats_qc.log.show()

	    gwas_data_sumstats_qc.log.save(
        os.path.join(GWASCatalog_loc, f"{PHENOTYPE}.b37.gwaslab.qc.log")
    )

	    gwas_data_sumstats_qc.to_format(
        os.path.join(GWASCatalog_loc, f"{PHENOTYPE}.b37.gwaslab.qc"),
        fmt="ssf",
        build="19",
    )

    # Generate plots if required
	    if make_plots == "YES":
		        gwas_data_sumstats_qc.plot_mqq(
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
		gwas_data_sumstats_leads = gwas_data_sumstats.get_lead(anno=True, windowsizekb=0, sig_level=5e-8, verbose=True, gls=True)
		gwas_data_sumstats_leads.to_format(
    os.path.join(GWASCatalog_loc + PHENOTYPE + ".b37.gwaslab.significant_snps"),
    fmt="ssf",
    build="19",
)

	if select_leads=="YES":
		gwas_data_sumstats_leads = gwas_data_sumstats.get_lead(anno=True, sig_level=5e-8, verbose=True)
		gwas_data_sumstats_leads.to_format(
    os.path.join(GWASCatalog_loc + PHENOTYPE + ".b37.gwaslab.leads"),
    fmt="ssf",
    build="19",
)