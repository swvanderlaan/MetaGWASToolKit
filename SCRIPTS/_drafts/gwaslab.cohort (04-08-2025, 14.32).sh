#!/bin/bash
#SBATCH --job-name=${COHORT}_gwaslab
#SBATCH --cpus-per-task=2



source "${GWASLAB_ENV}" gwaslab_env

echo "Running gwaslab.cohort.py with the following parameters:"
echo "COHORT:         ${COHORT}"
echo "FILE:           ${FILE}"
echo "ORIGINALS:      ${ORIGINALS}"
echo "POPULATION:     ${POPULATION}"
echo "REFERENCE DIR:  ${REF}"
echo "PERFORM_QC:     ${PERFORM_QC}"
echo "OUTPUT FILE:    ${RAWDATACOHORT}"
echo "MAKE_FIGURES:   ${MAKE_FIGURES}"
echo "ONLY_QC:        ${ONLY_QC}"
echo "SELECT_LEADS:   ${SELECT_LEADS}"
echo "DAF:            ${DAF}"
echo "EAF:            ${EAF}"
echo "BETA:           ${BETA}"
echo "SE:             ${SE}"
echo "INFO:           ${INFO}"
echo "MAC:            ${MAC}"
echo "HWE:            ${HWE}"
echo "REFERENCE:            hg${REFERENCE}"

python3 ${SCRIPTS}/gwaslab.cohort.py \
    -g ${COHORT} \
    -d ${ORIGINALS} \
    -i ${FILE} \
    -p ${POPULATION} \
    -z ${REFERENCE} \
    -r ${REF} \
    --qc ${PERFORM_QC} \
    -o ${RAWDATACOHORT} \
    --figures ${MAKE_FIGURES} \
    --onlyqc ${ONLY_QC} \
    --leads ${SELECT_LEADS} \
    --daf ${DAF} \
    --eaf ${EAF} \
    --beta ${BETA} \
    --se ${SE} \
    --info ${INFO} \
    --mac ${MAC} \
    --hwe ${HWE} \
    
        
#VariantID	MarkerOriginal	rsID	CHR	BP	Strand	EffectAllele	OtherAllele	MinorAllele	MajorAllele	
#EAF	MAF	MAC	HWE_P	Info	Beta	BetaMinor	SE	P	N	N_cases	N_controls	Imputed
# 1:54490:G:A	chr1:54490:A_G	rs141149254	1	54490	+	A	G	A	G	
# 0.18085195	0.180851957142588	NA	1	0.43748	0.0294443449788275	0.0294443449788275	0.0432866273139689	0.496366408541577	3526	NA	NA	Imputed
