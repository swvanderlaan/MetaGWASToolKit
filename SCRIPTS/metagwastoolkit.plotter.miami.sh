#!/usr/bin/env bash


# SLURM settings
#SBATCH --job-name=miami.plotter    # Job name
#SBATCH --mail-type=FAIL          # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=     # Where to send mail
#SBATCH --nodes=1                     #run on one node	
#SBATCH --ntasks=1                    # Run on a single CPU
#SBATCH --mem-per-cpu=10G                    # Job memory request
#SBATCH --time=2:00:00               # Time limit hrs:min:sec
#SBATCH --output=metagwastoolkit.miami.plotter.log   # Standard output and error log


SOFTWARE="/hpc/local/CentOS7/dhl_ec/software"
METAGWASTOOLKIT="${SOFTWARE}/MetaGWASToolKit"
SCRIPTS="${METAGWASTOOLKIT}/SCRIPTS"

PROJECT=""
OUTPUT=""

female=""
make=""

zcat ${PROJECT}/${female}.summary.txt.gz | ${SCRIPTS}/parseTable.pl --col VARIANTID,CHR,POS,P_FIXED > ${PROJECT}/${female}.miami.txt
zcat ${PROJECT}/${male}.summary.txt.gz | ${SCRIPTS}/parseTable.pl --col VARIANTID,CHR,POS,P_FIXED > ${PROJECT}/${male}.miami.txt


${SCRIPTS}/metagwastoolkit.plotter.miami.R --projectdir ${PROJECT} --top ${PROJECT}/${female}.miami.txt --bottom ${PROJECT}/${male}.miami.txtt --outputdir ${OUTPUT} --toptitle "Female Title" --bottomtitle "Male Title" --imageformat PNG 


####   *** Please ensure both inputs have the same metadata columns (SNP, CHR, POS, pvalue) *** 

###   *** Only PNG is (currently) supported ***