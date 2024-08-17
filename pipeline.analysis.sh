#!/bin/bash

# SLURM settings
#SBATCH --job-name=genius_chd                  # Job name
#SBATCH --mail-type=FAIL             # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=e.j.a.smulders-2@umcutrecht.nl  # Where to send mail
#SBATCH --nodes=1                        # Run on one node
#SBATCH --ntasks=1                       # Run on a single CPU
#SBATCH --mem=128G                        # Job memory request
#SBATCH --gres=tmpspace:128G                                        														# the amount of temporary diskspace per node
#SBATCH --time=24:00:00                   # Time limit hrs:min:sec
#SBATCH --output=genius_chd.analysis.out   # Standard output and error log

##############################
## DOWNSTREAM GWAS ANALYSIS ##
##############################


####### Input data of phenotypes and traits needs to be in cojo formatfor both LDSC and GSMR, GWASCatalog format for PolyFun ######
####### check gwas2cojo.run.sh for file conversion ###########################



python3_exe="/hpc/local/Rocky8/dhl_ec/software/mambaforge3/envs/polyfun/bin/python3"

DATA="/hpc/dhl_ec/esmulders"
PROJECTNAME="PROJECTNAME"
SCRIPTS="${DATA}/SCRIPTS_own"

data_analysed="PHENOTYPE"

PHENOTYPE_FILE="${DATA}/${PROJECTNAME}.PHENOTYPES.txt"
TRAIT_FILE="${DATA}/${PROJECTNAME}.TRAITS.txt"

POPULATION="EUR"
###LDSC
# path to map with ld
REF="${DATA}/references"
REF_LD="${REF}/eur_w_ld_chr/"
# path to merge allele snplist
SNPLIST="${DATA}/ldsc/w_hm3.snplist"


#polyfun 
min_maf=0.005
max_num_causal=1
pip_cutoff=0.50
CHUNKSIZE=500000


#GSMR reference
GSMR_REF="/hpc/dhl_ec/esmulders/gsmr/gsmr_ref_data_eur.txt"

#r="rsid"
#n="n"
#a="effect_allele"
#b="other_allele"
#v="p_value"
#f="effect_allele_frequency"

RESOURCES=/hpc/local/Rocky8/dhl_ec/software/MetaGWASToolKit/RESOURCES
rsid="rsid"
n="n"
a1="a1"
a2="a2"
p="p"
eaf="eaf"

# data preparation
if [ "$data_analysed" == "PHENOTYPE" ]; then
    if [ -n "$PHENOTYPE_FILE" ]; then
    	sed -i 's/\r$//' "$PHENOTYPE_FILE"
        PHENOTYPES=()
        SAMPLESIZES=()
        PATHS=()
        while IFS=' ' read -r phenotype sample_size path; do
            PHENOTYPES+=("$phenotype")
            SAMPLESIZES+=("$sample_size")
            PATHS+=("$path")
        done < "$PHENOTYPE_FILE"
        
        if [ ${#PHENOTYPES[@]} -eq 0 ]; then
            echo "Phenotype file is empty or not properly formatted."
            exit 1
        fi
    else
        echo "Phenotype file (-p) is required."
        exit 1
    fi

    for (( i=0; i<${#PHENOTYPES[@]}; i++ )); do
        PHENOTYPE="${PHENOTYPES[i]}"
        SAMPLE_SIZE="${SAMPLESIZES[i]}"
        INPUT="${PATHS[i]}"
        
        mkdir -p "${DATA}/${PROJECTNAME}/${PHENOTYPE}"
         mkdir -p "${DATA}/${PROJECTNAME}/${PHENOTYPE}/input"
        echo "Phenotype: ${PHENOTYPE}"
        echo "Sample Size: ${SAMPLE_SIZE}"
        echo "Input file: ${INPUT}"
        zcat "${DATA}/${PROJECTNAME}/${PHENOTYPE}/${INPUT}" | head

        # Parsing
         Rscript ${SCRIPTS}/pipeline.parser.R -p ${DATA}/${PROJECTNAME}/${PHENOTYPE} -d ${INPUT} -o input
         #GWASLAB
         source /hpc/local/Rocky8/dhl_ec/software/mambaforge3/bin/activate gwaslab_env
          python3 ${SCRIPTS}/pipeline.gwaslab.py -g ${PHENOTYPE} -d ${DATA}/${PROJECTNAME}/${PHENOTYPE} -i ${INPUT} -p ${POPULATION} -r ${REF}
	#COJO
	zcat "${DATA}/${PROJECTNAME}/${PHENOTYPE}/GWASCatalog/${PHENOTYPE}.b37.gwaslab.qc.ssf.tsv.gz" | head   
  mkdir -p ${DATA}/${PROJECTNAME}/${PHENOTYPE}
 	mkdir -p ${DATA}/${PROJECTNAME}/${PHENOTYPE}/input
 	mkdir -p ${DATA}/${PROJECTNAME}/${PHENOTYPE}/gsmr
 	mkdir -p ${DATA}/${PROJECTNAME}/${PHENOTYPE}/polyfun
 	mkdir -p ${DATA}/${PROJECTNAME}/${PHENOTYPE}/ldsc
    	${python3_exe} /hpc/local/Rocky8/dhl_ec/software/gwas2cojo/gwas2cojo.py \
    	--gen:build hg19 \
    	--gen ${RESOURCES}/1kGp3v5b.ref.allfreq.noCN_noINS_noSS_noESV_noMultiAllelic.sumstats.txt.gz \
    	--gwas ${DATA}/${PROJECTNAME}/${PHENOTYPE}/GWASCatalog/${PHENOTYPE}.b37.gwaslab.qc.ssf.tsv.gz \
    	--gen:ident ID --gen:chr CHROM --gen:bp POS --gen:other REF --gen:effect ALT --gen:eaf EUR_AF \
    	--gwas:chr chromosome --gwas:bp base_pair_location --gwas:other other_allele --gwas:effect effect_allele \
    	--gwas:beta beta --gwas:se standard_error --gwas:p p_value \
    	--gwas:freq effect_allele_frequency --gwas:n n --gwas:build hg19 \
    	--out ${DATA}/${PROJECTNAME}/${PHENOTYPE}/input/${PHENOTYPE}.cojo
    	${python3_exe} /hpc/local/Rocky8/dhl_ec/software/gwas2cojo/gwas2cojo-verify.py ${DATA}/${PROJECTNAME}/${PHENOTYPE}/input/${PHENOTYPE}.cojo
    	gzip -vf ${DATA}/${PROJECTNAME}/${PHENOTYPE}/input/${PHENOTYPE}.cojo
    done   
fi

if [ "$data_analysed" == "PHENOTYPE" ]; then
    if [ -n "$PHENOTYPE_FILE" ]; then
        PHENOTYPES=()
        PATHS=()
        while IFS=' ' read -r phenotype sample_size; do
            PHENOTYPES+=("$phenotype")
            SAMPLESIZES+=("$sample_size")
        done < "$PHENOTYPE_FILE"
        if [ ${#PHENOTYPES[@]} -eq 0 ]; then
            echo "Phenotype file is empty or not properly formatted."
            exit 1
        fi
    else
        echo "Phenotype file (-p) is required."
        exit 1
    fi
 	for (( i=0; i<${#PHENOTYPES[@]}; i++ )); do
 	PHENOTYPE="${PHENOTYPES[i]}"
 	PHENOPATH="${PATHS[i]}"
 	echo "${PHENOTYPE}"
 	echo "${PHENOPATH}"
 	mkdir -p ${DATA}/${PROJECTNAME}/${PHENOTYPE}
 	mkdir -p ${DATA}/${PROJECTNAME}/${PHENOTYPE}/input
 	mkdir -p ${DATA}/${PROJECTNAME}/${PHENOTYPE}/gsmr
 	mkdir -p ${DATA}/${PROJECTNAME}/${PHENOTYPE}/polyfun
 	mkdir -p ${DATA}/${PROJECTNAME}/${PHENOTYPE}/ldsc
    	${python3_exe} /hpc/local/Rocky8/dhl_ec/software/gwas2cojo/gwas2cojo.py \
    	--gen:build hg19 \
    	--gen ${RESOURCES}/1kGp3v5b.ref.allfreq.noCN_noINS_noSS_noESV_noMultiAllelic.sumstats.txt.gz \
    	--gwas ${DATA}/${PROJECTNAME}/${PHENOTYPE}/parsed/${INPUT} \
    	--gen:ident ID --gen:chr CHROM --gen:bp POS --gen:other REF --gen:effect ALT --gen:eaf EUR_AF \
    	--gwas:chr chromosome --gwas:bp base_pair_location --gwas:other other_allele --gwas:effect effect_allele \
    	--gwas:beta beta --gwas:se standard_error --gwas:p p_value \
    	--gwas:freq effect_allele_frequency --gwas:n n --gwas:build hg19 \
    	--out ${DATA}/${PROJECTNAME}/${PHENOTYPE}/input/${PHENOTYPE}.cojo
    	${python3_exe} /hpc/local/Rocky8/dhl_ec/software/gwas2cojo/gwas2cojo-verify.py ${DATA}/${PROJECTNAME}/${PHENOTYPE}/input/${PHENOTYPE}.cojo
    	gzip -vf ${DATA}/${PROJECTNAME}/${PHENOTYPE}/input/${PHENOTYPE}.cojo 
	done   
fi

    
#LDSC
if [ "$data_analysed" == "PHENOTYPE" ]; then
    if [ -n "$PHENOTYPE_FILE" ]; then
        PHENOTYPES=()
        #PATHS=()
        while IFS=' ' read -r phenotype sample_size; do
            PHENOTYPES+=("$phenotype")
            SAMPLESIZES+=("$sample_size")
            PATHS+=("$path")
        done < "$PHENOTYPE_FILE"
        if [ ${#PHENOTYPES[@]} -eq 0 ]; then
            echo "Phenotype file is empty or not properly formatted."
            exit 1
        fi
    else
        echo "Phenotype file (-p) is required."
        exit 1
    fi
 	for (( i=0; i<${#PHENOTYPES[@]}; i++ )); do
    	PHENOTYPE="${PHENOTYPES[i]}"
    	#PHENOPATH="${PATHS[i]}"
    	#echo "${PHENOTYPE}" 
		sbatch ${DATA}/ldsc/ldsc.run.sh -w "${data_analysed}" -d "${DATA}" -j "${PROJECTNAME}" -p "${PHENOTYPE}" -t "${TRAIT_FILE}" -l "${REF}/eur_w_ld_chr/" -h "${SNPLIST}" -r ${rsid} -n ${n} -a ${a1} -b ${a2} -v ${p} -f ${eaf} -c ${CHUNKSIZE}
	done   
fi

Check if trait file is provided and read the contents if data_analysed is TRAIT
if [ "$data_analysed" == "TRAIT" ] && [ -n "$TRAIT_FILE" ]; then
    TRAITS=()
    PATHS=()
    while IFS= read -r line || [ -n "$line" ]; do
        # Use read to parse line into trait and path
        read -r trait path <<< "$line"
        TRAITS+=("$trait")
        PATHS+=("$path")
    done < "$TRAIT_FILE"
    
    if [ ${#TRAITS[@]} -eq 0 ]; then
        echo "Trait file is empty or not properly formatted."
        exit 1
    fi
    
    for (( i=0; i<${#TRAITS[@]}; i++ )); do
        TRAIT="${TRAITS[i]}"
        TRAITPATH="${PATHS[i]}"
        echo "Analyzing trait : ${TRAIT}"
        sbatch ${DATA}/ldsc/ldsc.run.sh -w "${data_analysed}" -d "${DATA}" -j "${PROJECTNAME}" -p "${PHENOTYPE_FILE}" -t "${TRAIT}" -i "${TRAITPATH}" -l "${REF}/eur_w_ld_chr/" -h "${SNPLIST}" -r ${rsid} -n ${n} -a ${a1} -b ${a2} -v ${p} -f ${eaf} -c ${CHUNKSIZE}
    done
fi

#PolyFun
if [ "$data_analysed" == "PHENOTYPE" ]; then
    if [ -n "$PHENOTYPE_FILE" ]; then
        PHENOTYPES=()
        SAMPLESIZES=()
        while IFS=' ' read -r phenotype sample_size; do
            PHENOTYPES+=("$phenotype")
            SAMPLESIZES+=("$sample_size")
        done < "$PHENOTYPE_FILE"
        if [ ${#PHENOTYPES[@]} -eq 0 ]; then
            echo "Phenotype file is empty or not properly formatted."
            exit 1
        fi
    else
        echo "Phenotype file (-p) is required."
        exit 1
    fi
 	for (( i=0; i<${#PHENOTYPES[@]}; i++ )); do
    	PHENOTYPE="${PHENOTYPES[i]}"
    	SAMPLESIZE="${SAMPLESIZES[i]}"
		sbatch ${DATA}/polyfun/polyfun.run.sh -p "${PHENOTYPE}" -s "${SAMPLESIZE}" -d "${DATA}" -j "${PROJECTNAME}" -l "${REF}" -m "${min_maf}" -x "${max_num_causal}" -c "${pip_cutoff}"
	done   
fi

#GSMR
if [ "$data_analysed" == "PHENOTYPE" ]; then
	if [ -n "$PHENOTYPE_FILE" ]; then
    	PHENOTYPES=()
    	while IFS=' ' read -r phenotype sample_size; do
        	PHENOTYPES+=("$phenotype")
    	done < "$PHENOTYPE_FILE"
    	
    	if [ ${#PHENOTYPES[@]} -eq 0 ]; then
        	echo "Phenotype file is empty or not properly formatted."
        	exit 1
    	fi
	else
    	echo "Phenotype file (-p) is required."
    	exit 1
	fi

	for (( i=0; i<${#PHENOTYPES[@]}; i++ )); do
    	PHENOTYPE="${PHENOTYPES[i]}"
    	echo "${PHENOTYPE}" 
		sbatch ${DATA}/gsmr/gsmr.analysis.sh -t "${TRAIT_FILE}" -d "${DATA}" -j "${PROJECTNAME}" -p "${PHENOTYPE}" -r "${GSMR_REF}"
	done
fi