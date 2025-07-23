#!/bin/bash
#SBATCH --job-name=${COHORT}_parser
#SBATCH --cpus-per-task=1
#SBATCH --time=1:00:00


# # Set and prepare writable temp directory
# export TMPDIR=${RAWDATACOHORT}/tmp
# mkdir -p "$TMPDIR"

echo "Running pipeline.parser.R for ${COHORT}"

# Call your R script directly
#Rscript --vanilla ${SCRIPTS}/pipeline.parser.R -p ${ORIGINALS} -d ${FILE} -o ${COHORT}
Rscript ${SCRIPTS}/pipeline.parser.R -p ${ORIGINALS} -d ${FILE} -o ${COHORT}

#Marker	MarkerOriginal	CHR	BP	Strand	EffectAllele	OtherAllele	MinorAllele	MajorAllele	
#EAF	MAF	MAC	HWE_P	Info	Beta	BetaMinor	SE	P	N	N_cases	N_controls	Imputed	CAVEAT	DF
