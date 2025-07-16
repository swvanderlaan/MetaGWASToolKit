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

requiredNamed.add_argument("-g1", "--gwas1", help="The name of the first GWAS study.", type=str)
requiredNamed.add_argument("-g2", "--gwas2", help="The name of the second GWAS study.", type=str)
#requiredNamed.add_argument("-i1", "--input", help="The path and name of the first parsed input file.", type=str)
#requiredNamed.add_argument("-i2", "--input", help="The path and name of the second parsed input file.", type=str)
requiredNamed.add_argument("-d1", "--directory1", help="The path to the first results directory.", type=str)
requiredNamed.add_argument("-d2", "--directory2", help="The path to the second results directory.", type=str)
requiredNamed.add_argument("-p", "--population", help="Population analysed.", type=str)
requiredNamed.add_argument("-q", "--qc", help="Perform Quality Control or not?(YES or NO).", type=str)
requiredNamed.add_argument("-l", "--leads", help="select lead SNPs and safe in file?(YES or NO).", type=str)
args = parser.parse_args()

#reference_identifier = args.identifier
#### set some general defaults

#PHENOTYPE1 = "CHARGE_cIMT_FEMALES_EUR"
#
#PHENOTYPE2 = "CHARGE_cIMT_MALES_EUR"
PHENOTYPE1 = args.gwas1

PHENOTYPE2 = args.gwas2
#PHENOTYPE = "cox_DEAD_ALL"  # option
#SUBSTUDY_PHENO = f"META_{PHENOTYPE}"

POPULATION = args.population

#POPULATION = "EUR" # option

perform_qc = args.qc

select_leads= args.leads

# Reference data directory

# GWAS data directory

GWAS_RES_loc1 = args.directory1
GWAS_RES_loc2 = args.directory2
# Check if the GWASCatalog directory exists within GWAS_RES_loc
if not os.path.exists(os.path.join(GWAS_RES_loc1, "GWASCatalog")):
    # If it doesn't exist, create it
    os.makedirs(os.path.join(GWAS_RES_loc1, "GWASCatalog"))

# GWAS Catalog directory
GWASCatalog_loc1 = os.path.join(GWAS_RES_loc1, "GWASCatalog/")

# Check if the GWASCatalog directory exists within GWAS_RES_loc
if not os.path.exists(os.path.join(GWAS_RES_loc2, "GWASCatalog")):
    # If it doesn't exist, create it
    os.makedirs(os.path.join(GWAS_RES_loc2, "GWASCatalog"))

# GWAS Catalog directory
GWASCatalog_loc2 = os.path.join(GWAS_RES_loc2, "GWASCatalog/")

# # List the files in the GWASCatalog directory
# files = os.listdir(GWASCatalog_loc)
# print("Files in GWASCatalog directory:", files)

print(check_output(
    ["ls", os.path.join(GWASCatalog_loc1)]).decode("utf8"))
    
print(check_output(
    ["ls", os.path.join(GWASCatalog_loc2)]).decode("utf8"))


# general plotting directory

# Check if the directory exists
if not (os.path.join(GWAS_RES_loc1, "PLOTS")):
    # If it doesn't exist, create it
    os.makedirs(os.path.join(GWAS_RES_loc1, "PLOTS"))
PLOTS_loc1 = os.path.join(GWAS_RES_loc1, "PLOTS/")

# Check if the directory exists
if not (os.path.join(GWAS_RES_loc2, "PLOTS")):
    # If it doesn't exist, create it
    os.makedirs(os.path.join(GWAS_RES_loc2, "PLOTS"))
PLOTS_loc2 = os.path.join(GWAS_RES_loc2, "PLOTS/")

# for future reference to open the pickle file
gwas_data1_sumstats = gl.load_pickle(
    os.path.join(
        os.path.join(GWASCatalog_loc1 , f"{PHENOTYPE1}.b37.gwaslab.pkl"),
    )
)

gwas_data1_sumstats.data

# for future reference to open the pickle file
gwas_data2_sumstats = gl.load_pickle(
    os.path.join(
        os.path.join(GWASCatalog_loc2 , f"{PHENOTYPE2}.b37.gwaslab.pkl"),
    )
)

gwas_data2_sumstats.data

gwas_data1_sumstats_qc = gwas_data1_sumstats.filter_value(
    '(EAF>=0.01 & EAF<0.99 & DF>=1) & (DAF<0.12 & DAF>-0.12) & (CAVEAT=="None")'
)

gwas_data1_sumstats_qc.data

gwas_data2_sumstats_qc = gwas_data2_sumstats.filter_value(
    '(EAF>=0.01 & EAF<0.99 & DF>=1) & (DAF<0.12 & DAF>-0.12) & (CAVEAT=="None")'
)

gwas_data2_sumstats_qc.data

# manhattan and qq plot
gwas_data1_sumstats.plot_mqq(
     skip=2,
     cut=10,
    sig_line=True,
    sig_level=5e-8,
    anno="GENENAME",
    anno_style="right",
    windowsizekb=500,
    arm_offset=2,
    repel_force=0.02,  # default 0.01
    use_rank=False,
    build="19",
    # mode="m",
    stratified=True,
    drop_chr_start=True,
    # figargs={"figsize": (25, 15), "dpi": 300},
    #title="" + PHENOTYPE1 + "",
    save=os.path.join(PLOTS_loc1, "manhattan.500kb.300dpi." + PHENOTYPE1 + ".png"),
    saveargs={"dpi": 300},
    verbose=True,
)

# manhattan and qq plot
gwas_data1_sumstats_qc.plot_mqq(
    skip=2,
    cut=10,
    sig_line=True,
    sig_level=5e-8,
    anno="GENENAME",
    anno_style="right",
    windowsizekb=500,
    arm_offset=2,
    repel_force=0.02,  # default 0.01
    use_rank=False,
    build="19",
    # mode="m",
    stratified=True,
    drop_chr_start=True,
    # figargs={"figsize": (25, 15), "dpi": 300},
   #title="" + PHENOTYPE1 +"_QC" + "",
    save=os.path.join(
        PLOTS_loc1, "manhattan.500kb.300dpi." + PHENOTYPE1 + ".qc.png"),
    saveargs={"dpi": 300},
    verbose=True,
)


# manhattan and qq plot
gwas_data2_sumstats.plot_mqq(
    skip=2,
    cut=10,
    sig_line=True,
    sig_level=5e-8,
    anno="GENENAME",
    anno_style="right",
    windowsizekb=500,
    arm_offset=2,
    repel_force=0.02,  # default 0.01
    use_rank=False,
    build="19",
    # mode="m",
    stratified=True,
    drop_chr_start=True,
    # figargs={"figsize": (25, 15), "dpi": 300},
   #title="" + PHENOTYPE2 + "",
    save=os.path.join(PLOTS_loc2, "manhattan.500kb.300dpi." + PHENOTYPE2 + ".png"),
    saveargs={"dpi": 300},
    verbose=True,
)

# manhattan and qq plot
gwas_data2_sumstats_qc.plot_mqq(
    skip=2,
    cut=10,
    sig_line=True,
    sig_level=5e-8,
    anno="GENENAME",
    anno_style="right",
    windowsizekb=500,
    arm_offset=2,
    repel_force=0.02,  # default 0.01
    use_rank=False,
    build="19",
    # mode="m",
    stratified=True,
    drop_chr_start=True,
    # figargs={"figsize": (25, 15), "dpi": 300},
    #title="" + PHENOTYPE2 +"_QC" + "",
    save=os.path.join(PLOTS_loc2, "manhattan.500kb.300dpi." + PHENOTYPE2 + ".qc.png"),
    saveargs={"dpi": 300},
    verbose=True,
)

gwas_data1_sumstats.get_lead(anno=True, sig_level=5e-8, verbose=True)

gwas_data2_sumstats.get_lead(anno=True, sig_level=5e-8, verbose=True)

gwas1_vs_gwas2_sumstats = gl.plot_miami(
    path1=gwas_data1_sumstats,
    path2=gwas_data2_sumstats,
    sig_line=True,
    sig_level=5e-8,
    titles=[PHENOTYPE1, PHENOTYPE2],
    titles_pad=[0.15, 0.15],
    anno="GENENAME",
    # anno_set=[(10, 2122415), (12, 115969517)],
    # highlight=[(10, 2122415), (12, 115969517)],
    # highlight_windowkb=500,
    save=os.path.join(PLOTS_loc1, "miami.500kb.300dpi." + PHENOTYPE1 + "_vs_" + PHENOTYPE2 + ".png"),
    #  saveargs={"dpi": 300}
)


gwas1_vs_gwas2_sumstats_qc = gl.plot_miami(
    path1=gwas_data1_sumstats_qc,
    path2=gwas_data2_sumstats_qc,
    titles=[PHENOTYPE1, PHENOTYPE2],
    titles_pad=[0.15, 0.15],
    anno="GENENAME",
    # anno_set=[(10, 2122415), (12, 115969517)],
    # highlight=[(10, 2122415), (12, 115969517)],
    # highlight_windowkb=500,
    save=os.path.join(PLOTS_loc1, "miami.500kb.300dpi." + PHENOTYPE1 + "_vs_" + PHENOTYPE2 + ".qc.png"),
    #  saveargs={"dpi": 300}
)


gwas1_vs_gwas2_sumstats_qc_effect = gl.compare_effect(
    gwas_data1_sumstats_qc,
    gwas_data2_sumstats_qc,
    mode="beta",
    #label=[SEX1, SEX2],
    #label=[PHENOTYPE, "Females", "Males"],
    label=[PHENOTYPE1, PHENOTYPE2,"Both","None"],
    sig_level=5e-8,
    legend_title=r"$ P < 5 x 10^{-8}$ in:",
    legend_title2=r"Heterogeneity test:",
    legend_pos="upper left",
    #  legend_args=None,
    xylabel_prefix="Per-allele effect size in ",
    is_reg=True,
    is_45_helper_line=True,
    # anno=True,
    # anno_min=0,
    # anno_min1=0,
    # anno_min2=0,
    # anno_diff=0,
    # is_q=False,
    q_level=0.05,
    is_q_mc="fdr",  # or use "bon"
    # anno_het=False,
    # r_se=False,
    #  fdr=False,
    #  legend_mode="full",
     save=os.path.join(PLOTS_loc1, "effect_size." + PHENOTYPE1 + "_vs_" + PHENOTYPE2 + ".qc.png"),
    # saveargs=None,
    verbose=False,
)
