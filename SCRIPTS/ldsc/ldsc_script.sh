#!/bin/bash

###Download ldsc by GitHub instructions
###In environment.yml change pandas=0.20 to simply pandas
###set up environment in miniconda3 bin (not anaconda)

# activate ldsc conda environment
source /Users/esmulde2/miniconda3/bin/activate ldsc

# set up paths
# path to ldsc scripts
ROOT="/Users/esmulde2"
LDSC="${ROOT}/ldsc"
cd ${LDSC}
#data folder
DATA="/Volumes/MacExtern/UMC/Werk/GENIUS-CHD/ldsc"

# path to map with ld
EUR_LD="${LDSC}/eur_w_ld_chr/"
# path to merge allele snplist
SNPLIST="${LDSC}/w_hm3.snplist"

PHENOTYPE="META_cox_DEAD_ALL"



## path to GENIUS_CHD phenotypes input file for sumstats conversion
SUMSTATS_INPUT="${DATA}/input/${PHENOTYPE}.b37.gwaslab.ssf.tsv.gz"
## path to output file for sumstats conversion
SUMSTATS_OUTPUT="${DATA}/sumstats/${PHENOTYPE}"
## path to input file for heritability
H2_INPUT="${DATA}/sumstats/${PHENOTYPE}.sumstats.gz"
## path to output file for heritability
H2_OUTPUT="${DATA}/heritability/${PHENOTYPE}_h2"

##CAD
#SUMSTATS_INPUT="${DATA}/input/MILLIONHEARTS.b37.gwaslab.ssf.tsv.gz"
# path to output file for sumstats conversion
#SUMSTATS_OUTPUT="${DATA}/sumstats/MILLIONHEARTS"
# path to input file for heritability
CAD_INPUT="${DATA}/sumstats/MILLIONHEARTS.sumstats.gz"
# path to output file for heritability
PHENOTYPE_CAD="${DATA}/heritability/${PHENOTYPE}_MILLIONHEARTS"



## column names
snp="rsid" # SNP ID needs to be rs format
N="n" #sample size (N)
a1="effect_allele" #effect allele
a2="other_alle" # other allele
p="p_value" #P-value
frq="effect_allele_frequency" #EAF

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
--merge-alleles ${SNPLIST}

### h2 heritability
./ldsc.py \
--h2 ${H2_INPUT} \
--ref-ld-chr ${EUR_LD} \
--w-ld-chr ${EUR_LD} \
--out ${H2_OUTPUT}

##phenotype comparison with CAD
./ldsc.py \
--rg ${H2_INPUT},${CAD_INPUT} \
--ref-ld-chr ${EUR_LD} \
--w-ld-chr ${EUR_LD} \
--out ${PHENOTYPE_CAD}
