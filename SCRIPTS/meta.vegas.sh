#!/bin/bash
# This script is created to run VEGAS as an array job
# Written by Moezammin Baksi

# eXCECUTE VEGAS BASED ON SLURM ARRAY ID
if [[ ${SLURM_ARRAY_TASK_ID} -le 22 ]]; then 
    CHR=$((SLURM_ARRAY_TASK_ID+1))
    echo "Processing chromosome ${CHR}..."
    printf "#!/bin/bash\nzcat ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.summary.txt.gz | ${SCRIPTS}/parseTable.pl --col VARIANTID,CHR,P_FIXED | awk ' \$2==${CHR} ' | awk '{ print \$1, \$3 }' | tail -n +2 > ${VEGASDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.chr${CHR}.forVEGAS.txt \n" > ${VEGASDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.chr${CHR}.runVEGAS.sh
    echo "cd ${VEGASDIR} " >> ${VEGASDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.chr${CHR}.runVEGAS.sh
    echo "$VEGAS2 -G -snpandp meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.chr${CHR}.forVEGAS.txt -custom ${VEGAS2POP}.chr${CHR} -glist ${VEGAS2GENELIST} -upper ${VEGAS2UPPER} -lower ${VEGAS2LOWER} -chr ${CHR} -out meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.chr${CHR}.fromVEGAS " >> ${VEGASDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.chr${CHR}.runVEGAS.sh
    # qsub -S /bin/bash -N VEGAS2.${PROJECTNAME}.chr${CHR} -hold_jid METASUM -o ${VEGASDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.chr${CHR}.runVEGAS.log -e ${VEGASDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.chr${CHR}.runVEGAS.errors -l h_vmem=${QMEMVEGAS} -l h_rt=${QRUNTIMEVEGAS} -wd ${VEGASDIR} ${VEGASDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.chr${CHR}.runVEGAS.sh
    VEGAS2_ID=$(sbatch --parsable --job-name=VEGAS2.${PROJECTNAME}.chr${CHR} ${METASUM_IDS_D} -o ${VEGASDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.chr${CHR}.runVEGAS.log --error ${VEGASDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.chr${CHR}.runVEGAS.errors --time=${QRUNTIMEVEGAS} --mem=${QMEMVEGAS} --mail-user=${QMAIL} --mail-type=${QMAILOPTIONS} --chdir ${VEGASDIR} ${VEGASDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.chr${CHR}.runVEGAS.sh)
elif [[ ${SLURM_ARRAY_TASK_ID} -eq 23 ]]; then
    CHR=$((SLURM_ARRAY_TASK_ID+1))
    echo "Processing chromosome X..."
    printf "#!/bin/bash\nzcat ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.summary.txt.gz | ${SCRIPTS}/parseTable.pl --col VARIANTID,CHR,P_FIXED | awk ' \$2==\"X\" ' | awk '{ print \$1, \$3 }' | tail -n +2 > ${VEGASDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.chr${CHR}.forVEGAS.txt \n" > ${VEGASDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.chr${CHR}.runVEGAS.sh
    echo "cd ${VEGASDIR} " >> ${VEGASDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.chr${CHR}.runVEGAS.sh
    echo "$VEGAS2 -G -snpandp meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.chr${CHR}.forVEGAS.txt -custom ${VEGAS2POP}.chr${CHR} -glist ${VEGAS2GENELIST} -upper ${VEGAS2UPPER} -lower ${VEGAS2LOWER} -chr ${CHR} -out meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.chr${CHR}.fromVEGAS " >> ${VEGASDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.chr${CHR}.runVEGAS.sh
    # qsub -S /bin/bash -N VEGAS2.${PROJECTNAME}.chr${CHR} -hold_jid METASUM -o ${VEGASDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.chr${CHR}.runVEGAS.log -e ${VEGASDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.chr${CHR}.runVEGAS.errors -l h_vmem=${QMEMVEGAS} -l h_rt=${QRUNTIMEVEGAS} -wd ${VEGASDIR} ${VEGASDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.chr${CHR}.runVEGAS.sh
    VEGAS2_ID=$(sbatch --parsable --job-name=VEGAS2.${PROJECTNAME}.chr${CHR} ${METASUM_IDS_D} -o ${VEGASDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.chr${CHR}.runVEGAS.log --error ${VEGASDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.chr${CHR}.runVEGAS.errors --time=${QRUNTIMEVEGAS} --mem=${QMEMVEGAS} --mail-user=${QMAIL} --mail-type=${QMAILOPTIONS} --chdir ${VEGASDIR} ${VEGASDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.chr${CHR}.runVEGAS.sh)
else
    echo "*** ERROR *** Something is rotten in the City of Gotham; most likely a typo. Double back, please."	
fi

