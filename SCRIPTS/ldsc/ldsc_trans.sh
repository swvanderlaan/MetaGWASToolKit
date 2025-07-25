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

LDSC="/hpc/dhl_ec/esmulders/MetaGWASToolKit/SCRIPTS/ldsc"
source /hpc/local/Rocky8/dhl_ec/software/mambaforge3/bin/activate ldsc

python ${LDSC}/ldsc.py \
    --rg /hpc/dhl_ec/svanderlaan/projects/consortia/CHARGE_cIMT_Sex/SECOND_ROUND/CHARGE_cIMT_MALES_EUR/males_eur/META/ldsc/sumstats/CHARGE_cIMT_MALES_EUR.sumstats.gz,/hpc/dhl_ec/svanderlaan/projects/consortia/CHARGE_cIMT_Sex/SECOND_ROUND/CHARGE_cIMT_MALES_AFR/males_afr/META/ldsc/sumstats/CHARGE_cIMT_MALES_AFR.sumstats.gz,/hpc/dhl_ec/svanderlaan/projects/consortia/CHARGE_cIMT_Sex/SECOND_ROUND/CHARGE_cIMT_MALES_AMR/males_amr/META/ldsc/sumstats/CHARGE_cIMT_MALES_AMR.sumstats.gz \
    --ref-ld-chr /hpc/dhl_ec/esmulders/MetaGWASToolKit/RESOURCES/EUR_w_ld_chr/,/hpc/dhl_ec/esmulders/MetaGWASToolKit/RESOURCES/AFR_w_ld_chr/,/hpc/dhl_ec/esmulders/MetaGWASToolKit/RESOURCES/AMR_w_ld_chr/ \
    --w-ld-chr /hpc/dhl_ec/esmulders/MetaGWASToolKit/RESOURCES/EUR_w_ld_chr/,/hpc/dhl_ec/esmulders/MetaGWASToolKit/RESOURCES/AFR_w_ld_chr/,/hpc/dhl_ec/esmulders/MetaGWASToolKit/RESOURCES/AMR_w_ld_chr/ \
    --out EUR_AFR_AMR_rg