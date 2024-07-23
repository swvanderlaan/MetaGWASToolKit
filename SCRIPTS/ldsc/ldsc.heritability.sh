#!/bin/bash
#ldsc.heritability.sh
###Download ldsc by GitHub instructions
###In environment.yml change pandas=0.20 to simply pandas
###set up environment in miniconda3 bin (not anaconda)

# activate ldsc conda environment
source /hpc/local/Rocky8/dhl_ec/software/mambaforge3/bin/activate ldsc
# set up paths
# path to ldsc scripts
#ROOT="/Users/esmulde2"

#data folder
#DATA="/Volumes/MacExtern/UMC/Werk/GENIUS-CHD/ldsc"
DATA=""
#
## path to map with ld
#REF_LD="${LDSC}/eur_w_ld_chr/"
## path to merge allele snplist
#SNPLIST="${LDSC}/w_hm3.snplist"

# Default values
PHENOTYPE=""
TRAIT=""
REF_LD=""
#REF_LD="${LDSC}/eur_w_ld_chr/"

# Function to display usage information
usage() {
    echo "Usage: $0 [-p <phenotype>]  [Options]" 1>&2
    echo "Options:" 1>&2
    echo "  -p <phenotype>: Specify the phenotype." 1>&2
    echo "  -p <trait>: Specify the trait." 1>&2
    echo "  -d <data_map>: Specify the map for data" 1>&2
    echo "  -l <REF_LD>: Specify the map with REF_LD info." 1>&2
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

#LDSC="${DATA}/ldsc"
LDSC="/hpc/dhl_ec/esmulders/ldsc"
cd ${LDSC}

# Ensure either PHENOTYPE or TRAIT is provided
if [ -z "$PHENOTYPE" ] && [ -z "$TRAIT" ]; then
    echo "Error: Either phenotype or trait must be specified." >&2
    usage
fi

# Perform actions based on PHENOTYPE
if [ -n "$PHENOTYPE" ]; then
    echo "PHENOTYPE: ${PHENOTYPE}"
    #H2_INPUT="${DATA}/${PROJECTNAME}/${PHENOTYPE}/ldsc/sumstats/${PHENOTYPE}.sumstats.gz"
    H2_INPUT="${DATA}/ldsc/sumstats/${PHENOTYPE}.sumstats.gz"
    #mkdir -p "${DATA}/${PROJECTNAME}/${PHENOTYPE}/ldsc/heritability/"
    mkdir -p "${DATA}/ldsc/heritability/"
    #H2_OUTPUT="${DATA}/${PROJECTNAME}/${PHENOTYPE}/ldsc/heritability/${PHENOTYPE}_h2"
    H2_OUTPUT="${DATA}/ldsc/heritability/${PHENOTYPE}_h2"

    # Ensure input file exists
    if [ ! -f "$H2_INPUT" ]; then
        echo "Error: Input file ${H2_INPUT} not found." >&2
        exit 1
    fi

    ### h2 heritability
    ./ldsc.py \
        --h2 ${H2_INPUT} \
        --ref-ld-chr ${REF_LD} \
        --w-ld-chr ${REF_LD} \
        --out ${H2_OUTPUT}
fi

# Perform actions based on TRAIT
if [ -n "$TRAIT" ]; then
    echo "TRAIT: ${TRAIT}"
    H2_INPUT="${DATA}/ldsc/traits/sumstats/${TRAIT}.sumstats.gz"
    mkdir -p "${DATA}/traits/heritability"
    H2_OUTPUT="${DATA}/traits/heritability/${TRAIT}_h2"
    # Ensure input file exists
    if [ ! -f "$H2_INPUT" ]; then
        echo "Error: Input file ${H2_INPUT} not found." >&2
        exit 1
    fi

    ### h2 heritability
    ./ldsc.py \
        --h2 ${H2_INPUT} \
        --ref-ld-chr ${REF_LD} \
        --w-ld-chr ${REF_LD} \
        --out ${H2_OUTPUT}
fi
