#!/usr/bin/env bash


# SLURM settings
#SBATCH --job-name=miami_plotter    # Job name
#SBATCH --mail-type=FAIL          # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=e.j.a.smulders-2@umcutrecht.nl     # Where to send mail
#SBATCH --nodes=1                     #run on one node	
#SBATCH --ntasks=1                    # Run on a single CPU
#SBATCH --mem-per-cpu=10G                    # Job memory request
#SBATCH --time=5:00:00               # Time limit hrs:min:sec
#SBATCH --output=miami_plotter.log   # Standard output and error log




/hpc/dhl_ec/esmulders/SCRIPTS_own/plotter.miami.R --projectdir /hpc/dhl_ec/esmulders/MetaGWASToolKit/CHARGE_cIMT_test --top /hpc/dhl_ec/esmulders/MetaGWASToolKit/CHARGE_cIMT_test/females/META/filtering/female_hudson.new.txt --bottom /hpc/dhl_ec/esmulders/MetaGWASToolKit/CHARGE_cIMT_test/males/META/filtering/male_hudson.new.txt --outputdir /hpc/dhl_ec/esmulders/MetaGWASToolKit/CHARGE_cIMT_test --toptitle "female gwas" --bottomtitle "male gwas" --imageformat PNG


####   * Please ensure both inputs have the same metadata columns.* (SNP, CHR, POS, pvalue)