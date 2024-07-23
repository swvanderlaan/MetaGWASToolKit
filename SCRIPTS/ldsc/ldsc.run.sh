#!/bin/bash

# SLURM settings
#SBATCH --job-name=ldsc                  # Job name
#SBATCH --mail-type=FAIL             # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=e.j.a.smulders-2@umcutrecht.nl  # Where to send mail
#SBATCH --nodes=1                        # Run on one node
#SBATCH --ntasks=1                       # Run on a single CPU
#SBATCH --mem=32G                        # Job memory request
#SBATCH --time=1:00:00                   # Time limit hrs:min:sec
#SBATCH --output=ldsc.out   # Standard output and error log

###Download ldsc by GitHub instructions
###In environment.yml change pandas=0.20 to simply pandas
###set up environment in miniconda3 bin (not anaconda)

# set up paths
# path to ldsc scripts
#ROOT="/Users/esmulde2"


#data folder
#DATA="/Volumes/MacExtern/UMC/Werk/GENIUS-CHD/ldsc"
#DATA="/Volumes/MacExtern/UMC/Werk/GENIUS-CHD"
DATA=""
PROJECTNAME=""
PHENOTYPE=""
TRAIT_FILE=""
#DATA="/Volumes/MacExtern/UMC/Werk/GENIUS-CHD"
# path to map with ld
REF_LD=""
REF=""
#REF_LD="/Volumes/MacExtern/UMC/Werk/references/eur_w_ld_chr/"
# path to merge allele snplist
SNPLIST="${LDSC}/w_hm3.snplist"
CHUNKSIZE=

path=""
r=""
n=""
a=""
b=""
p=""
f=""

#PHENOTYPES=("META_cox_DEAD_ALL" "META_logistic_DEAD_ALL")
#TRAITS=("AD" "Na" "K")
data_analysed=""
# Function to display usage information
usage() {
    echo "Usage: $0 [-p <phenotype>]  [Options]" 1>&2
    echo "Options:" 1>&2
    echo "  -p <phenotype>: Specify the phenotypes." 1>&2
    echo "  -t <trait>: Specify the traits." 1>&2
    echo "  -w <analysis>: Specify trait or phenotype analysis." 1>&2
    echo "  -d <data_map>: Specify the map for data" 1>&2
    echo "  -l <ref_ld>: Specify the map with ref_ld info." 1>&2
    echo "  -h <snplist>: Specify the snplist file." 1>&2
    exit 1
}
# Parsing command-line options
while getopts ":p:t:w:d:j:i:l:h:r:n:a:b:v:f:c:" opt; do
    case ${opt} in
        p) PHENOTYPE=$OPTARG ;;
        t) TRAIT_FILE=$OPTARG ;;
        w) data_analysed=$OPTARG ;;
        d) DATA=$OPTARG ;;
        j) PROJECTNAME=$OPTARG ;;
        i) path=$OPTARG ;;
        l) REF_LD=$OPTARG ;;
        h) SNPLIST=$OPTARG ;;
        r) r=$OPTARG ;;
        n) n=$OPTARG ;;
        a) a=$OPTARG ;;
        b) b=$OPTARG ;;
        v) v=$OPTARG ;;
        f) f=$OPTARG ;;
        c) CHUNKSIZE=$OPTARG ;;
        :) echo "Option -$OPTARG requires an argument." >&2; exit 1 ;;
        \?) echo "Invalid option: -$OPTARG" >&2; exit 1 ;;
    esac
done
LDSC="/hpc/dhl_ec/esmulders/ldsc"
#LDSC="${DATA}/ldsc"

#echo "${path}"

# Validate input for data_analysed
if [ "$data_analysed" != "PHENOTYPE" ] && [ "$data_analysed" != "TRAIT" ]; then
    echo "Invalid value for -w option. Please specify either 'PHENOTYPE' or 'TRAIT'."
    exit 1
fi

# Check if phenotype file is provided and read the contents
# if [ "$data_analysed" == "PHENOTYPE" ]; then
#     if [ -n "$PHENOTYPE_FILE" ]; then
#         PHENOTYPES=()
#         SAMPLESIZES=()
#         while IFS=',' read -r phenotype sample_size; do
#             PHENOTYPES+=("$phenotype")
#             SAMPLESIZES+=("$sample_size")
#         done < "$PHENOTYPE_FILE"
#         if [ ${#PHENOTYPES[@]} -eq 0 ]; then
#             echo "Phenotype file is empty or not properly formatted."
#             exit 1
#         fi
#     else
#         echo "Phenotype file (-p) is required."
#         exit 1
#     fi

#     # Also read the trait file for genetic correlation analysis
#     if [ -n "$TRAIT_FILE" ]; then
#         TRAITS=()
#         while read -r line; do
#             trait=$(echo $line | awk '{print $1}')
#             TRAITS+=("$trait")
#         done < "$TRAIT_FILE"
#         if [ ${#TRAITS[@]} -eq 0 ]; then
#             echo "Trait file is empty or not properly formatted."
#             exit 1
#         fi
#     else
#         echo "Trait file (-t) is required for genetic correlation analysis."
#         exit 1
#     fi
# fi


# # Check if trait file is provided and read the contents if data_analysed is TRAIT
# if [ "$data_analysed" == "TRAIT" ] && [ -n "$TRAIT_FILE" ]; then
#     TRAITS=()
#     while read -r line; do
#         trait=$(echo $line | awk '{print $1}')
#         TRAITS+=("$trait")
#     done < "$TRAIT_FILE"
#     if [ ${#TRAITS[@]} -eq 0 ]; then
#         echo "Trait file is empty or not properly formatted."
#         exit 1
#     fi
# fi



# Check if phenotype file is provided and read the contents
if [ "$data_analysed" == "PHENOTYPE" ]; then
    if [ -z "$PHENOTYPE" ]; then
        echo "Phenotype (-p) is required for phenotype analysis."
        exit 1
    fi
    mkdir -p ${DATA}/ldsc
    mkdir -p ${DATA}/ldsc/sumstats
    mkdir -p ${DATA}/ldsc/heritability
    # Also read the trait file for genetic correlation analysis
    if [ -n "$TRAIT_FILE" ]; then
        TRAITS=()
        while read -r line; do
            trait=$(echo $line | awk '{print $1}')
            TRAITS+=("$trait")
        done < "$TRAIT_FILE"
        if [ ${#TRAITS[@]} -eq 0 ]; then
            echo "Trait file is empty or not properly formatted."
            exit 1
        fi
    else
        echo "Trait file (-t) is required for genetic correlation analysis."
        exit 1
    fi

    echo "Analyzing PHENOTYPE: ${PHENOTYPE}"
    echo "Making sumstats file..."
    bash ${LDSC}/ldsc.sumstats.sh -d ${DATA} -h ${SNPLIST} -p ${PHENOTYPE} -i ${DATA}/input/${PHENOTYPE}.cojo.gz -r ${r} -n ${n} -a ${a} -b ${b} -v ${v} -f ${f} -c ${CHUNKSIZE}
    echo "Running heritability analysis..."
     bash ${LDSC}/ldsc.heritability.sh -d ${DATA} -j "${PROJECTNAME}" -l ${REF_LD} -p ${PHENOTYPE}
    for TRAIT in "${TRAITS[@]}"; do
        echo "Comparing ${PHENOTYPE} with ${TRAIT} ..."
        bash ${LDSC}/ldsc.rg.sh -d ${DATA} -j "${PROJECTNAME}" -l ${REF_LD} -p ${PHENOTYPE} -t ${TRAIT}
    done
fi

if [ "$data_analysed" == "TRAIT" ]; then
    if [ -z "$TRAIT_FILE" ]; then
        echo "Trait file (-t) is required for trait analysis."
        exit 1
    fi
    mkdir -p ${DATA}/traits
    mkdir -p ${DATA}/traits/sumstats
    mkdir -p ${DATA}/traits/heritability
    echo "Analyzing TRAIT: ${TRAIT_FILE}"
    echo "Making sumstats file..."
    bash ${LDSC}/ldsc.sumstats.sh -d ${DATA} -j "${PROJECTNAME}" -h ${SNPLIST} -t ${TRAIT_FILE} -i ${path} -r ${r} -n ${n} -a ${a} -b ${b} -v ${v} -f ${f} -c ${CHUNKSIZE}
    echo "Running heritability analysis..."
    bash ${LDSC}/ldsc.heritability.sh -d ${DATA} -j "${PROJECTNAME}" -l ${REF_LD} -t ${TRAIT_FILE}
fi