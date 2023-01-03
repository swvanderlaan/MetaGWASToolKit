#!/usr/bin/env bash
# SLURM settings
#SBATCH --job-name=reference_test    # Job name
#SBATCH --mail-type=END,FAIL          # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=e.j.a.smulders-2@umcutrecht.nl     # Where to send mail
#SBATCH --nodes=1                     #run on one node	
#SBATCH --ntasks=1                    # Run on a single CPU
#SBATCH --mem=10G                    # Job memory request
#SBATCH --time=10:00:00               # Time limit hrs:min:sec


# root location for Emma
ESMULDERS="/hpc/dhl_ec/esmulders"


# path to software
SOFTWARE="/hpc/local/CentOS7/dhl_ec/software"


# path to perl
#perl="${SOFTWARE}/perl"


# path to script
PARSER="${ESMULDERS}/MetaGWASToolKit/SCRIPTS/resource.VCFparser.pl"


# path to input file
VCF="${SOFTWARE}/MetaGWASToolKit/RESOURCES/ALL.wgs.phase3_shapeit2_mvncall_integrated_v5c.20130502.sites.vcf.gz"


# input for script parameters
REF="1Gp3"
POP="EUR"
OUTPUT="${ESMULDERS}/MetaGWASToolKit/RESOURCES/1000Gp3v5_20130502_mvncall_integrated_v5c"


# run script
perl ${PARSER} --file ${VCF}  --ref ${REF} --pop ${POP} --out ${OUTPUT}
