#!/bin/bash
#SBATCH --job-name=${COHORT}_gwaslab
#SBATCH --cpus-per-task=2

echo "Processing cohort: ${COHORT}"
echo "File: ${FILE}"
echo "Raw data directory: ${RAWDATACOHORT}"

source /hpc/local/Rocky8/dhl_ec/software/mambaforge3/bin/activate gwaslab_env

python3 ${SCRIPTS}/gwaslab.cohort.py \
    -g ${COHORT} \
    -d ${ORIGINALS} \
    -i ${FILE} \
    -p ${POPULATION} \
    -r ${REF} \
    --qc ${PERFORM_QC} \
    -o ${RAWDATACOHORT} \
    --figures ${MAKE_FIGURES} \
    --onlyqc ${ONLY_QC} \
    --leads ${SELECT_LEADS}
    
    
#VariantID	MarkerOriginal	rsID	CHR	BP	Strand	EffectAllele	OtherAllele	MinorAllele	MajorAllele	
#EAF	MAF	MAC	HWE_P	Info	Beta	BetaMinor	SE	P	N	N_cases	N_controls	Imputed
# 1:54490:G:A	chr1:54490:A_G	rs141149254	1	54490	+	A	G	A	G	
# 0.18085195	0.180851957142588	NA	1	0.43748	0.0294443449788275	0.0294443449788275	0.0432866273139689	0.496366408541577	3526	NA	NA	Imputed