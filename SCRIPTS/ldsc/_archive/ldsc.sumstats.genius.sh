#!/bin/bash
#ldsc.sumstats.sh
###Download ldsc by GitHub instructions
###In environment.yml change pandas=0.20 to simply pandas
###set up environment in miniconda3 bin (not anaconda)

# activate ldsc conda environment
source /hpc/local/Rocky8/dhl_ec/software/mambaforge3/bin/activate ldsc
# set up paths
# path to ldsc scripts



# Default values
#DATA="/Volumes/MacExtern/UMC/Werk/GENIUS-CHD"
DATA=""
PHENOTYPE=""
TRAIT=""
SNPLIST=""
CHUNKSIZE=
r=""
N=""
a1=""
a2=""
p=""
frq=""


# Function to display usage information
usage() {
    echo "Usage: $0 [-p <phenotype>] [-i <input_file>] [Options]" 1>&2
    echo "Options:" 1>&2
    echo "  -p <phenotype>: Specify the phenotype." 1>&2
    echo "  -t <trait>: Specify the trait." 1>&2
    echo "  -d <data_map>: Specify the map for data" 1>&2
    echo "  -h <snptlist>: Specify the snplist file." 1>&2
    echo "  -i <input_file>: Specify the input file for sumstats conversion." 1>&2
    echo "  -r <snp_column>: Specify the column name for SNP IDs." 1>&2
    echo "  -n <N_column>: Specify the column name for sample size (N)." 1>&2
    echo "  -a <allele1_column>: Specify the column name for effect allele (a1)." 1>&2
    echo "  -b <allele2_column>: Specify the column name for other allele (a2)." 1>&2
    echo "  -v <pvalue_column>: Specify the column name for P-value." 1>&2
    echo "  -f <frequency_column>: Specify the column name for effect allele frequency." 1>&2
    exit 1
}


# Parsing command-line options
while getopts ":p:t:d:j:h:i:r:n:a:b:v:f:c:" opt; do
    case ${opt} in
        p) PHENOTYPE=$OPTARG ;;
        t) TRAIT=$OPTARG ;;
        d) DATA=$OPTARG ;;
        j) PROJECTNAME=$OPTARG ;;
        h) SNPLIST=$OPTARG ;;
        i) INPUT=$OPTARG ;;
        r) snp=$OPTARG ;;
        n) N=$OPTARG ;;
        a) a1=$OPTARG ;;
        b) a2=$OPTARG ;;
        v) p=$OPTARG ;;
        f) frq=$OPTARG ;;
        c) CHUNKSIZE=$OPTARG ;;
        :) echo "Option -$OPTARG requires an argument." >&2; exit 1 ;;
        \?) echo "Invalid option: -$OPTARG" >&2; exit 1 ;;
    esac
done


# Debugging: Print parsed options
LDSC="${DATA}/ldsc"
cd ${LDSC}



# Ensure either PHENOTYPE or TRAIT is provided
if [ -z "$PHENOTYPE" ] && [ -z "$TRAIT" ]; then
    echo "Error: Either phenotype or trait must be specified." >&2
    usage
fi


## path to phenotypes input file for sumstats conversion

# echo "PHENOTYPE: ${PHENOTYPE}"
# echo "TRAIT: ${TRAIT}"
# echo "DATA: ${DATA}"
# echo "INPUT: ${INPUT}"
# echo "snp: ${snp}"
# echo "N: ${N}"
# echo "a1: ${a1}"
# echo "a2: ${a2}"
# echo "p: ${p}"
# echo "frq: ${frq}"
# SUMSTATS_INPUT="${DATA}/input/${PHENOTYPE}.b37.gwaslab.ssf.tsv.gz"


# Determine output file based on PHENOTYPE or TRAIT
if [ -n "$PHENOTYPE" ]; then
    SUMSTATS_INPUT="${INPUT}"
elif [ -n "$TRAIT" ]; then
    SUMSTATS_INPUT="${INPUT}"
fi

# Determine output file based on PHENOTYPE or TRAIT
if [ -n "$PHENOTYPE" ]; then
	mkdir -p ${DATA}/${PROJECTNAME}/${PHENOTYPE}/ldsc/sumstats
    SUMSTATS_OUTPUT="${DATA}/${PROJECTNAME}/${PHENOTYPE}/ldsc/sumstats/${PHENOTYPE}"
elif [ -n "$TRAIT" ]; then
	mkdir -p ${DATA}/traits/sumstats
    SUMSTATS_OUTPUT="${DATA}/traits/sumstats/${TRAIT}"
fi

### sumstats conversion for later testing
./munge_sumstats.py \
--sumstats ${SUMSTATS_INPUT} \
--snp ${snp} \
--N-col ${N} \
--a1 ${a1} \
--a2 ${a2} \
--p ${p} \
--frq ${frq} \
--out ${SUMSTATS_OUTPUT} \
--merge-alleles ${SNPLIST} \
--chunksize ${CHUNKSIZE}

