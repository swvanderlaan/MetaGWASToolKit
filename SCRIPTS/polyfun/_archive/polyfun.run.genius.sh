#!/bin/bash

# SLURM settings
##SBATCH --array=1-49                # create 23 jobs from this
#SBATCH --job-name=polyfun                  # Job name
#SBATCH --mail-type=FAIL             # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=e.j.a.smulders-2@umcutrecht.nl  # Where to send mail
#SBATCH --nodes=1                        # Run on one node
#SBATCH --ntasks=1                       # Run on a single CPU
#SBATCH --mem=128G                        # Job memory request
#SBATCH --time=24:00:00                   # Time limit hrs:min:sec
#SBATCH --output=polyfun.out   # Standard output and error log


# SuSIE
# https://github.com/omerwe/polyfun
# make conda env
# CHR - chromosome
# BP - base pair position (in hg19 coordinates)
# A1 - The effect allele (i.e., the sign of the effect size is with respect to A1)
# A2 - the second allele

# A PolyFun workflow

# change env location accordingly
source /hpc/local/Rocky8/dhl_ec/software/mambaforge3/bin/activate polyfun

#ROOT="/Users/esmulde2"


python3_exe="/hpc/local/Rocky8/dhl_ec/software/mambaforge3/envs/polyfun/bin/python3"

DATA=""
REF=""
#DATA="/Volumes/MacExtern/UMC/Werk/GENIUS-CHD"
# DATA="/Volumes/MacExtern/UMC/Werk/cIMT/polyfun"
#REF="/Volumes/MacExtern/UMC/Werk/references"
# Define PHENOTYPES and their respective max sample sizes
PHENOTYPE=""
SAMPLESIZE=
# SAMPLESIZE=(46018 45589)  # Corresponding sample sizes

# Default values for parameters
default_min_maf=0.005
default_max_num_causal=1
default_pip_cutoff=0.50
default_phenotype_file=""

# Function to display usage information
usage() {
    echo "Usage: $0 [Options]" 1>&2
    echo "Options:" 1>&2
    echo "  -p <phenotype>: Specify the PHENOTYPE file (default: $default_phenotype_file)." 1>&2
    echo "  -d <data_map>: Specify the map for data (default: $DATA)." 1>&2
    echo "  -m <min_maf>: Specify the minimum MAF (default: $default_min_maf)." 1>&2
    echo "  -x <max_num_causal>: Specify the maximum number of causal SNPs (default: $default_max_num_causal)." 1>&2
    echo "  -c <pip_cutoff>: Specify the PIP cutoff (default: $default_pip_cutoff)." 1>&2
    exit 1
}

# Parsing command-line options
while getopts ":p:s:d:j:l:m:x:c:" opt; do
    case ${opt} in
        p) PHENOTYPE=$OPTARG ;;
        s) SAMPLESIZE=$OPTARG ;;
        d) DATA=$OPTARG ;;
        j) PROJECTNAME=$OPTARG ;;
        l) REF=$OPTARG ;;
        m) min_maf=$OPTARG ;;
        x) max_num_causal=$OPTARG ;;
        c) pip_cutoff=$OPTARG ;;
        :) echo "Option -$OPTARG requires an argument." >&2; exit 1 ;;
        \?) echo "Invalid option: -$OPTARG" >&2; exit 1 ;;
    esac
done
#cd /hpc/dhl_ec/esmulders/polyfun
cd ${DATA}/polyfun

#echo "${DATA}/polyfun"
#echo "$SAMPLESIZE"

# Use default values if not set
min_maf=${min_maf:-$default_min_maf}
max_num_causal=${max_num_causal:-$default_max_num_causal}
pip_cutoff=${pip_cutoff:-$default_pip_cutoff}
PHENOTYPE_FILE=${PHENOTYPE_FILE:-$default_phenotype_file}

mkdir -p ${DATA}/${PROJECTNAME}/${PHENOTYPE}/polyfun
#mkdir -p ${DATA}/${PROJECTNAME}/${PHENOTYPE}/polyfun/input
mkdir -p ${DATA}/${PROJECTNAME}/${PHENOTYPE}/polyfun/data
mkdir -p ${DATA}/${PROJECTNAME}/${PHENOTYPE}/polyfun/finemapping
mkdir -p ${DATA}/${PROJECTNAME}/${PHENOTYPE}/polyfun/annotations


# if [ -n "$PHENOTYPE_FILE" ]; then
#     PHENOTYPES=()
#     SAMPLESIZES=()
#     while IFS=',' read -r phenotype sample_size; do
#         PHENOTYPES+=("$phenotype")
#         SAMPLESIZES+=("$sample_size")
#     done < "$PHENOTYPE_FILE"
#     if [ ${#PHENOTYPES[@]} -eq 0 ]; then
#         echo "Phenotype file is empty or not properly formatted."
#         exit 1
#     fi
# else
#     echo "Phenotype file (-p) is required."
#     exit 1
# fi

# for (( i=0; i<${#PHENOTYPES[@]}; i++ )); do
#     PHENOTYPE="${PHENOTYPES[i]}"
#     SAMPLESIZE="${SAMPLESIZES[i]}"
#     echo "Processing PHENOTYPE with PolyFun: $PHENOTYPE"



# # #    # File formatting
echo "CHR BP A1 A2 BETA SE MAF P RSID N" > ${DATA}/${PROJECTNAME}/${PHENOTYPE}/input/${PHENOTYPE}.qc.polyfun.txt
gzip -dc ${DATA}/${PROJECTNAME}/gwaslab/${PHENOTYPE}.b37.qc.gwaslab.ssf.tsv.gz | awk '{ print $1, $2, $3, $4, $5, $6, $7, $8, $9, $11}' | tail -n +2 >> ${DATA}/${PROJECTNAME}/${PHENOTYPE}/input/${PHENOTYPE}.qc.polyfun.txt
gzip -vf ${DATA}/${PROJECTNAME}/${PHENOTYPE}/input/${PHENOTYPE}.qc.polyfun.txt
# 
#     # 1. lead snps make parquet
$python3_exe ${DATA}/polyfun/munge_polyfun_sumstats.py --sumstats ${DATA}/${PROJECTNAME}/${PHENOTYPE}/input/${PHENOTYPE}.qc.polyfun.txt.gz --out ${DATA}/${PROJECTNAME}/${PHENOTYPE}/polyfun/data/${PHENOTYPE}.lead_snps.parquet --min-info 0 --min-maf ${min_maf}
# # 
# #     # 2. extract snpvar
$python3_exe ${DATA}/polyfun/extract_snpvar.py --sumstats ${DATA}/${PROJECTNAME}/${PHENOTYPE}/polyfun/data/${PHENOTYPE}.lead_snps.parquet --out ${DATA}/${PROJECTNAME}/${PHENOTYPE}/polyfun/data/${PHENOTYPE}.snps_with_var.gz --allow-missing
# # # 
# #     # 3. finemapper jobs
$python3_exe ${DATA}/polyfun/create_finemapper_jobs.py \
 --sumstats ${DATA}/${PROJECTNAME}/${PHENOTYPE}/polyfun/data/${PHENOTYPE}.snps_with_var.gz \
 --n ${SAMPLESIZE} \
 --method susie \
 --pvalue-cutoff 5e-8 \
 --max-num-causal ${max_num_causal} \
 --memory 128 \
 --verbose \
 --out-prefix ${DATA}/${PROJECTNAME}/${PHENOTYPE}/polyfun/finemapping/${PHENOTYPE} \
 --jobs-file ${DATA}/${PROJECTNAME}/${PHENOTYPE}/polyfun/finemapping/${PHENOTYPE}.polyfun_all_jobs.sh \
 --allow-missing
# # # 
#     # 4. Run finemapping if jobs file is not empty
if [ -s ${DATA}/${PROJECTNAME}/${PHENOTYPE}/polyfun/finemapping/${PHENOTYPE}.polyfun_all_jobs.sh ]; then
	bash ${DATA}/${PROJECTNAME}/${PHENOTYPE}/polyfun/finemapping/${PHENOTYPE}.polyfun_all_jobs.sh
else
	echo "No finemapping jobs to run. Skipping finemapping step."
fi
# # 
# #     # 5. Aggregate results if there are files in the finemap folder
finemap_folder=${DATA}/${PROJECTNAME}/${PHENOTYPE}/polyfun/finemapping
if [ -d "$finemap_folder" ] && [ "$(ls -A $finemap_folder)" ]; then
	$python3_exe ${DATA}/polyfun/aggregate_finemapper_results.py \
	 --out-prefix ${DATA}/${PROJECTNAME}/${PHENOTYPE}/polyfun/finemapping/${PHENOTYPE} \
	 --sumstats ${DATA}/${PROJECTNAME}/${PHENOTYPE}/polyfun/data/${PHENOTYPE}.snps_with_var.gz \
	 --out ${DATA}/${PROJECTNAME}/${PHENOTYPE}/polyfun/data/${PHENOTYPE}.polyfun_agg.txt.gz \
	 --allow-missing-jobs
else
	echo "No files found in the finemap folder. Skipping aggregation."
fi
# 
# #     # 6. Extract annotations for each significant locus
finemap_folder=${DATA}/polyfun/output/${PHENOTYPE}/finemap
if [ -d "$finemap_folder" ] && [ "$(ls -A $finemap_folder)" ]; then
	for file in ${DATA}/${PROJECTNAME}/${PHENOTYPE}/polyfun/finemapping/*.gz; do
		if [[ $file =~ ${PHENOTYPE}.chr([0-9]+).([0-9]+)_([0-9]+).gz ]]; then
			chr=${BASH_REMATCH[1]}
			start=${BASH_REMATCH[2]}
			end=${BASH_REMATCH[3]}
			annot_file=${REF}/baselineLF2.2.UKB/baselineLF2.2.UKB.${chr}.annot.parquet
			output_file=${DATA}/${PROJECTNAME}/${PHENOTYPE}/polyfun/annotations/top_annot.${chr}.${start}_${end}.txt.gz
			$python3_exe ${DATA}/polyfun/extract_annotations.py \
			 --pips $file \
			 --annot $annot_file \
			 --pip-cutoff ${pip_cutoff} \
			--out $output_file
			else
				echo "Skipping file: $file (does not match pattern or no PIP > 0.5)."
			fi
	done
else
	echo "No files found in the finemap folder. Skipping extracting annotations."
	fi

#done
