#!/usr/bin/env bash

# SLURM settings
#SBATCH --job-name=gcta_interaction   # Job name
#SBATCH --mail-type=END,FAIL          # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=e.j.a.smulders-2@umcutrecht.nl     # Where to send mail
#SBATCH --nodes=1                     #run on one node	
#SBATCH --ntasks=1                    # Run on a single CPU
#SBATCH --mem=128G                    # Job memory request
#SBATCH --time=2:00:00               # Time limit hrs:min:sec
#SBATCH --output=gcta_interaction.log   # Standard output and error log




#Path to where the software resides on the server.
SOFTWARE="/hpc/local/CentOS7/dhl_ec/software"


#Path to where PLINK resides on the server.
PLINK="${SOFTWARE}/plink_v1.9"

#Path to where GCTA resides on the server.

GCTA="${SOFTWARE}/gcta_1.94.1"

#Root location for emma

ESMULDERS="/hpc/dhl_ec/esmulders"

#toolkit loc
METAGWASTOOLKIT="${ESMULDERS}/MetaGWASToolKit"

SCRIPTS="${METAGWASTOOLKIT}/SCRIPTS"

#reference needed
REFERENCE="${METAGWASTOOLKIT}/RESOURCES/1000Gp3v5_EUR/1000Gp3v5.20130502.EUR.noDup"

LD="${METAGWASTOOLKIT}/RESOURCES/eur_w_ld_chr"

# gwas results
INPUT="${METAGWASTOOLKIT}/CHARGE_cIMT_test/mtcojo_summary_data.list"

#clumping output
OUTPUT="${METAGWASTOOLKIT}/CHARGE_cIMT_test/interaction_rs"

#run gcta
${GCTA} --bfile ${REFERENCE} --mtcojo-file ${INPUT} --ref-ld-chr ${LD} --w-ld-chr ${LD} --out ${OUTPUT}

#--ref-ld-chr eur_w_ld_chr/ --w-ld-chr eur_w_ld_chr/