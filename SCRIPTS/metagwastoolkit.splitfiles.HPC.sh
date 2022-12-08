#!/bin/bash
# This script is created to run the Parser, Harmonizer and Cleaner as an array job
# Written by Moezammin Baksi

# GET some functions from the prep file
function echobold { #'echobold' is the function name
    echo -e "${BOLD}${1}${NONE}" # this is whatever the function needs to execute, note ${1} is the text for echo
}

# Get variables from the config file and the export function
source "$1"
ORIGINALS=${DATA_UPLOAD_FREEZE}
METAOUTPUT=${OUTPUTDIRNAME}
RAWDATA=${PROJECTDIR}/${METAOUTPUT}/${SUBPROJECTDIRNAME}/RAW
LINEINTEXTFILE=$((SLURM_ARRAY_TASK_ID+1))
SPLITFILE=$(sed -n "$LINEINTEXTFILE{p;q}" ${RAWDATACOHORT}/splitfiles.txt)
METAGWASTOOLKIT=${METAGWASTOOLKITDIR}
SCRIPTS=${METAGWASTOOLKIT}/SCRIPTS
BASEFILE=$(basename ${FILE} .txt.gz)
REFERENCE=${REFERENCE}

## Adding headers -- this is ABSOLUTELY required for the 'gwas.parser.R'.
### determine basename of the splitfile
BASESPLITFILE=$(basename ${SPLITFILE} .pdat)
# echo ""
# echo "* Prepping split chunk: [ ${BASESPLITFILE} ]..."
# echo ""
# echo " - heading a temporary file." 
# zcat ${ORIGINALS}/${FILE} | head -1 > ${RAWDATACOHORT}/tmp_file.${SLURM_ARRAY_TASK_ID}
# echo " - adding the split data to the temporary file."
# cat ${SPLITFILE} >> ${RAWDATACOHORT}/tmp_file.${SLURM_ARRAY_TASK_ID}
# echo " - renaming the temporary file."
# mv -fv ${RAWDATACOHORT}/tmp_file.${SLURM_ARRAY_TASK_ID} ${SPLITFILE}
echobold "#========================================================================================================"
echobold "#== PARSING THE GWAS DATA"
echobold "#========================================================================================================"
echobold "#"
echo ""
echo "* Parsing data for cohort ${COHORT} [ file: ${BASESPLITFILE} ]."

### FOR DEBUGGING LOCALLY -- Mac OS X
### Rscript ${SCRIPTS}/gwas.parser.R -p ${PROJECTDIR} -d ${SPLITFILE} -o ${METAOUTPUT}/${SUBPROJECTDIRNAME}/RAW/${COHORT} 

## echo "Rscript ${SCRIPTS}/gwas.parser.R -p ${PROJECTDIR} -d ${SPLITFILE} -o ${METAOUTPUT}/${SUBPROJECTDIRNAME}/RAW/${COHORT} " > ${RAWDATACOHORT}/gwas.parser.${BASESPLITFILE}.sh
## qsub -S /bin/bash -N gwas.parser.${BASESPLITFILE} -hold_jid metagwastoolkit -o ${RAWDATACOHORT}/gwas.parser.${BASESPLITFILE}.log -e ${RAWDATACOHORT}/gwas.parser.${BASESPLITFILE}.errors -l h_rt=${QRUNTIMEPARSER} -l h_vmem=${QMEMPARSER} -M ${QMAIL} -m ${QMAILOPTIONS} -cwd ${RAWDATACOHORT}/gwas.parser.${BASESPLITFILE}.sh

# Call the parser script
# printf "#!/bin/bash\nRscript ${SCRIPTS}/gwas.parser.R -p ${PROJECTDIR} -d ${SPLITFILE} -o ${METAOUTPUT}/${SUBPROJECTDIRNAME}/RAW/${COHORT}" > ${RAWDATACOHORT}/gwas.parser.${BASESPLITFILE}.sh
# PARSER_ID=$(sbatch --parsable --job-name=gwas.parser.${BASESPLITFILE} --dependency=afterany:${INIT_ID} -o ${RAWDATACOHORT}/gwas.parser.${BASESPLITFILE}.log --error ${RAWDATACOHORT}/gwas.parser.${BASESPLITFILE}.errors --time=${QRUNTIMEPARSER} --mem=${QMEMPARSER} --mail-user=${QMAIL} --mail-type=${QMAILOPTIONS} ${RAWDATACOHORT}/gwas.parser.${BASESPLITFILE}.sh)

Rscript ${SCRIPTS}/gwas.parser.R -p ${PROJECTDIR} -d ${SPLITFILE} -o ${METAOUTPUT}/${SUBPROJECTDIRNAME}/RAW/${COHORT}
wait # Wait till the scripts are finished

echobold "#========================================================================================================"
echobold "#== HARMONIZING THE PARSED GWAS DATA"
echobold "#========================================================================================================"
echobold "#"
echo ""
echo "* Harmonising parsed [ ${BASESPLITFILE} ] file for cohort ${COHORT} with ${REFERENCE}..."

### FOR DEBUGGING LOCALLY -- Mac OS X
### module load python
### ${SCRIPTS}/gwas2ref.harmonizer.py -g ${SPLITFILE}.pdat -r ${VINFOFILE} -i ${VARIANTYPE} -o ${SPLITFILE}.ref.pdat

## echo "module load python" > ${RAWDATACOHORT}/gwas2ref.harmonizer.${BASESPLITFILE}.sh
## echo "${SCRIPTS}/gwas2ref.harmonizer.py -g ${SPLITFILE}.pdat -r ${VINFOFILE} -i ${VARIANTYPE} -o ${SPLITFILE}.ref.pdat" >> ${RAWDATACOHORT}/gwas2ref.harmonizer.${BASESPLITFILE}.sh
## qsub -S /bin/bash -N gwas2ref.harmonizer.${BASESPLITFILE} -hold_jid gwas.parser.${BASESPLITFILE} -o ${RAWDATACOHORT}/gwas2ref.harmonizer.${BASESPLITFILE}.log -e ${RAWDATACOHORT}/gwas2ref.harmonizer.${BASESPLITFILE}.errors -l h_rt=${QRUNTIMEHARMONIZE} -l h_vmem=${QMEMHARMONIZE} -M ${QMAIL} -m ${QMAILOPTIONS} -cwd ${RAWDATACOHORT}/gwas2ref.harmonizer.${BASESPLITFILE}.sh

# Call the harmonizer
# printf "#!/bin/bash\nmodule load python\n" > ${RAWDATACOHORT}/gwas2ref.harmonizer.${BASESPLITFILE}.sh
# printf "${SCRIPTS}/gwas2ref.harmonizer.py -g ${SPLITFILE}.pdat -r ${VINFOFILE} -i ${VARIANTYPE} -o ${SPLITFILE}.ref.pdat" >> ${RAWDATACOHORT}/gwas2ref.harmonizer.${BASESPLITFILE}.sh
# HARMONIZER_ID=$(sbatch --parsable --job-name=gwas2ref.harmonizer.${BASESPLITFILE} --dependency=afterany:${PARSER_ID} -o ${RAWDATACOHORT}/gwas2ref.harmonizer.${BASESPLITFILE}.log --error ${RAWDATACOHORT}/gwas2ref.harmonizer.${BASESPLITFILE}.errors --time=${QRUNTIMEHARMONIZE} --mem=${QMEMHARMONIZE} --mail-user=${QMAIL} --mail-type=${QMAILOPTIONS} ${RAWDATACOHORT}/gwas2ref.harmonizer.${BASESPLITFILE}.sh)

# Call the harmonizer
module load python
${SCRIPTS}/gwas2ref.harmonizer.py -g ${SPLITFILE}.pdat -r ${VINFOFILE} -i ${VARIANTYPE} -o ${SPLITFILE}.ref.pdat
wait # Wait till the scripts are finished

echobold "#========================================================================================================"
echobold "#== CLEANING UP THE REFORMATTED GWAS DATA"
echobold "#========================================================================================================"
echobold "#"
echo ""
echo "* Cleaning harmonized data for [ ${BASESPLITFILE} ] file for cohort ${COHORT} with ${REFERENCE}"
echo "  using the following pre-specified settings:"
echo "  - MAF  = ${MAF}"
echo "  - MAC  = ${MAC}"
echo "  - HWE  = ${HWE}"
echo "  - INFO = ${INFO}"
echo "  - BETA = ${BETA}"
echo "  - SE   = ${SE}"

### FOR DEBUGGING LOCALLY -- Mac OS X
### ${SCRIPTS}/gwas.cleaner.R -d ${SPLITFILE}.ref.pdat -f ${BASESPLITFILE} -o ${RAWDATACOHORT} -e ${BETA} -s ${SE} -m ${MAF} -c ${MAC} -i ${INFO} -w ${HWE}

## echo "${SCRIPTS}/gwas.cleaner.R -d ${SPLITFILE}.ref.pdat -f ${BASESPLITFILE} -o ${RAWDATACOHORT} -e ${BETA} -s ${SE} -m ${MAF} -c ${MAC} -i ${INFO} -w ${HWE}" >> ${RAWDATACOHORT}/gwas.cleaner.${BASESPLITFILE}.sh
## qsub -S /bin/bash -N gwas.cleaner.${BASEFILE} -hold_jid gwas2ref.harmonizer.${BASESPLITFILE} -o ${RAWDATACOHORT}/gwas.cleaner.${BASESPLITFILE}.log -e ${RAWDATACOHORT}/gwas.cleaner.${BASESPLITFILE}.errors -l h_rt=${QRUNTIMECLEANER} -l h_vmem=${QMEMCLEANER} -M ${QMAIL} -m ${QMAILOPTIONS} -cwd ${RAWDATACOHORT}/gwas.cleaner.${BASESPLITFILE}.sh

# Call the cleaner
# printf "#!/bin/bash\n${SCRIPTS}/gwas.cleaner.R -d ${SPLITFILE}.ref.pdat -f ${BASESPLITFILE} -o ${RAWDATACOHORT} -e ${BETA} -s ${SE} -m ${MAF} -c ${MAC} -i ${INFO} -w ${HWE}" >> ${RAWDATACOHORT}/gwas.cleaner.${BASESPLITFILE}.sh
# CLEANER_ID=$(sbatch --parsable --job-name=gwas.cleaner.${BASEFILE} --dependency=afterany:${HARMONIZER_ID} -o  ${RAWDATACOHORT}/gwas.cleaner.${BASESPLITFILE}.log --error ${RAWDATACOHORT}/gwas.cleaner.${BASESPLITFILE}.errors --time=${QRUNTIMECLEANER} --mem=${QMEMCLEANER} --mail-user=${QMAIL} --mail-type=${QMAILOPTIONS} ${RAWDATACOHORT}/gwas.cleaner.${BASESPLITFILE}.sh)
# echo "${CLEANER_ID}" >> ${RAWDATACOHORT}/cleaner_ids.txt

# Call the cleaner
Rscript ${SCRIPTS}/gwas.cleaner.R -d ${SPLITFILE}.ref.pdat -f ${BASESPLITFILE} -o ${RAWDATACOHORT} -e ${BETA} -s ${SE} -m ${MAF} -c ${MAC} -i ${INFO} -w ${HWE}
wait  # Wait till the scripts are finished