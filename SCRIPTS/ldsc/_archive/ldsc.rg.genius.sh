#!/bin/bash

###Download ldsc by GitHub instructions
###In environment.yml change pandas=0.20 to simply pandas
###set up environment in miniconda3 bin (not anaconda)

# activate ldsc conda environment
source /hpc/local/Rocky8/dhl_ec/software/mambaforge3/bin/activate ldsc

# set up paths
# path to ldsc scripts
#ROOT="/Users/esmulde2"

#data folder
DATA=""
#DATA="/Volumes/MacExtern/UMC/Werk/GENIUS-CHD"

# Default values
PHENOTYPE=""
TRAIT=""
REF_LD=""

# Function to display usage information
usage() {
    echo "Usage: $0 [-p <phenotype>] [-t <trait>] [-i <input_file>] [Options]" 1>&2
    echo "Options:" 1>&2
    echo "  -p <phenotype>: Specify the phenotype." 1>&2
    echo "  -t <trait>: Specify the trait." 1>&2
    echo "  -d <data_map>: Specify the map for data" 1>&2
    echo "  -l <ref_ld>: Specify the map with eur_ld info." 1>&2
    exit 1
}
# Parsing command-line options
while getopts ":p:t:d:j:l:" opt; do
    case ${opt} in
        p) PHENOTYPE=$OPTARG ;;
        t) TRAIT=$OPTARG ;;
        d) DATA=$OPTARG ;;
        j) PROJECTNAME=$OPTARG ;;
        l) REF_LD=$OPTARG ;;
        :) echo "Option -$OPTARG requires an argument." >&2; exit 1 ;;
        \?) echo "Invalid option: -$OPTARG" >&2; exit 1 ;;
    esac
done

#echo "$DATA"
#echo "$REF_LD"
LDSC="${DATA}/ldsc"
cd ${LDSC}
# Check if either phenotype or trait is provided
if [[ -z "${PHENOTYPE}" || -z "${TRAIT}" ]]; then
    echo "Error: Please specify a phenotype and a trait." 1>&2
    exit 1
fi




## path to GENIUS_CHD phenotypes input file
PHENO_INPUT="${DATA}/${PROJECTNAME}/${PHENOTYPE}/ldsc/sumstats/${PHENOTYPE}.sumstats.gz"

# mkdir -p "${DATA}/ldsc/heritability/${PHENOTYPE}"

# path to input file for heritability
TRAIT_INPUT="${DATA}/traits/sumstats/${TRAIT}.sumstats.gz"

# path to output file for heritability
PHENOTYPE_TRAIT="${DATA}/${PROJECTNAME}/${PHENOTYPE}/ldsc/heritability/${PHENOTYPE}_${TRAIT}"

##phenotype comparison with trait
./ldsc.py \
--rg ${PHENO_INPUT},${TRAIT_INPUT} \
--ref-ld-chr ${REF_LD} \
--w-ld-chr ${REF_LD} \
--out ${PHENOTYPE_TRAIT}
