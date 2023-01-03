#!/usr/bin/env bash

# SLURM settings
#SBATCH --job-name=clump_metagwas   # Job name
#SBATCH --mail-type=END,FAIL          # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=e.j.a.smulders-2@umcutrecht.nl     # Where to send mail
#SBATCH --nodes=1                     #run on one node	
#SBATCH --ntasks=1                    # Run on a single CPU
#SBATCH --mem=128G                    # Job memory request
#SBATCH --time=2:00:00               # Time limit hrs:min:sec
#SBATCH --output=Plink_clump_meta.log   # Standard output and error log




#Path to where the software resides on the server.
SOFTWARE="/hpc/local/CentOS7/dhl_ec/software"


#Path to where PLINK resides on the server.
PLINK="${SOFTWARE}/plink_v1.9"

#Root location for emma

ESMULDERS="/hpc/dhl_ec/esmulders"

#toolkit loc
METAGWASTOOLKIT="${ESMULDERS}/MetaGWASToolKit"

SCRIPTS="${METAGWASTOOLKIT}/SCRIPTS"

#reference needed
REFERENCE="${METAGWASTOOLKIT}/RESOURCES/1000Gp3v5_EUR/1000Gp3v5.20130502.EUR.noDup.newIDs"

# gwas results
INPUT="${METAGWASTOOLKIT}/females_cojo_rs"

DUPLICATE="${METAGWASTOOLKIT}/CHARGE_cIMT_test/females/META/cojo.female.clumped.dupvar"

#clumping output
OUTPUT="${METAGWASTOOLKIT}/CHARGE_cIMT_test/females/META/cojo.female.clumped"

# update 1000G
# cat ${REFERENCE}.bim | awk '{ print $2, "chr"$1":"$4":"$5"_"$6}' > ${REFERENCE}.updateSNPid.txt
# ${PLINK} --bfile ${REFERENCE} --memory 385382 --update-name ${REFERENCE}.updateSNPid.txt --make-bed --out ${REFERENCE}.newIDs

# run clumping
${PLINK} --bfile ${REFERENCE} --memory 385382 --clump ${INPUT}  --exclude ${DUPLICATE} --clump-snp-field VARIANTID --clump-p1 5e-8 --clump-p2 0.05 --clump-r2 0.05 --clump-kb 1000 --clump-field P_FIXED --out ${OUTPUT} --clump-verbose --clump-annotate CHR,POS,MINOR,MAJOR,MAF,CODEDALLELE,OTHERALLELE,CAF,N_EFF,BETA_FIXED,SE_FIXED,BETA_LOWER_FIXED,BETA_UPPER_FIXED,Z_FIXED,COCHRANS_Q,DF,P_COCHRANS_Q,I_SQUARED,TAU_SQUARED,DIRECTIONS,GENES_250KB,NEAREST_GENE,NEAREST_GENE_ENSEMBLID,NEAREST_GENE_STRAND,VARIANT_FUNCTION,CAVEAT
			

#--list-duplicate-vars suppress-first