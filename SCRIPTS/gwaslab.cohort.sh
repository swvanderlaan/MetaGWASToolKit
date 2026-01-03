#!/bin/bash
#SBATCH --job-name=${COHORT}_gwaslab
#SBATCH --cpus-per-task=2
#SBATCH --time=24:00:00                                             														# the amount of time the job will take: -t [min] OR -t [days-hh:mm:ss]
#SBATCH --mem=128G                                                    														# the amount of memory you think the script will consume, found on: https://wiki.bioinformatics.umcutrecht.nl/bin/view/HPC/SlurmScheduler
#SBATCH --gres=tmpspace:128G                                        														# the amount of temporary diskspace per node



source "${GWASLAB_ENV}" gwaslab_env

echo "Running gwaslab.cohort.py with the following parameters:"
echo "COHORT:         ${COHORT}"
echo "FILE:           ${FILE}"
echo "ORIGINALS:      ${ORIGINALS}"
echo "RAWDATACOHORT:  ${RAWDATACOHORT}"
echo "POPULATION:     ${POPULATION}"
echo "REFERENCE DIR:  ${REF}"
echo "PERFORM_QC:     ${PERFORM_QC}"
echo "LIFTOVER:       ${LIFTOVER}"
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
echo "REFERENCE:      hg${REFERENCE}"


python3 ${SCRIPTS}/gwaslab.cohort2.py \
    -g ${COHORT} \
    -d ${RAWDATACOHORT} \
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
    --liftover ${LIFTOVER}
    
rm -f ${RAWDATACOHORT}/array_jobid.txt
#VariantID	MarkerOriginal	rsID	CHR	BP	Strand	EffectAllele	OtherAllele	MinorAllele	MajorAllele	
#EAF	MAF	MAC	HWE_P	Info	Beta	BetaMinor	SE	P	N	N_cases	N_controls	Imputed
# 1:54490:G:A	chr1:54490:A_G	rs141149254	1	54490	+	A	G	A	G	
# 0.18085195	0.180851957142588	NA	1	0.43748	0.0294443449788275	0.0294443449788275	0.0432866273139689	0.496366408541577	3526	NA	NA	Imputed
