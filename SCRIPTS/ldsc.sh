#!/usr/bin/env bash

# SLURM settings
#SBATCH --job-name=ldsc   # Job name
#SBATCH --mail-type=END,FAIL          # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=e.j.a.smulders-2@umcutrecht.nl     # Where to send mail
#SBATCH --nodes=1                     #run on one node	
#SBATCH --ntasks=1                    # Run on a single CPU
#SBATCH --mem=32G                    # Job memory request
#SBATCH --time=2:00:00               # Time limit hrs:min:sec
#SBATCH --output=ldsc.log   # Standard output and error log




#Path to where the software resides on the server.
SOFTWARE="/hpc/local/CentOS7/dhl_ec/software"


#Path to where PLINK resides on the server.
PLINK="${SOFTWARE}/plink_v1.9"

#Path to where GCTA resides on the server.

LDSC="${SOFTWARE}/ldsc/ldsc.py"

#Root location for emma

ESMULDERS="/hpc/dhl_ec/esmulders"

#toolkit loc
METAGWASTOOLKIT="${ESMULDERS}/MetaGWASToolKit"

SCRIPTS="${METAGWASTOOLKIT}/SCRIPTS"

#reference needed
REFERENCE="${METAGWASTOOLKIT}/RESOURCES/1000Gp3v5_EUR/1000Gp3v5.20130502.EUR.noDup"

#clumping output
OUTPUT="${METAGWASTOOLKIT}/CHARGE_cIMT_test/RESOURCES/ldsc_Gp3v5"

${LDSC} --bfile ${REFERENCE} --l2 --ld-wind-cm 1 --out ${OUTPUT}