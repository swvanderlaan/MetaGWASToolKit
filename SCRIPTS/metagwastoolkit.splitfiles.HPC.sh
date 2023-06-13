#!/bin/bash
# This script is created to run the Parser, Harmonizer and Cleaner as an array job
# Written by Moezammin Baksi

### Creating display functions
### Setting colouring
NONE='\033[00m'
OPAQUE='\033[2m'
FLASHING='\033[5m'
BOLD='\033[1m'
ITALIC='\033[3m'
UNDERLINE='\033[4m'
STRIKETHROUGH='\033[9m'

RED='\033[01;31m'
GREEN='\033[01;32m'
YELLOW='\033[01;33m'
PURPLE='\033[01;35m'
CYAN='\033[01;36m'
WHITE='\033[01;37m'

function echobold { #'echobold' is the function name
    echo -e "${BOLD}${1}${NONE}" # this is whatever the function needs to execute, note ${1} is the text for echo
}
function echoitalic { 
    echo -e "${ITALIC}${1}${NONE}" 
}
function echonooption { 
    echo -e "${OPAQUE}${RED}${1}${NONE}"
}
function echoerrorflash { 
    echo -e "${RED}${BOLD}${FLASHING}${1}${NONE}" 
}
function echoerror { 
    echo -e "${RED}${1}${NONE}"
}
# errors no option
function echoerrornooption { 
    echo -e "${YELLOW}${1}${NONE}"
}
function echoerrorflashnooption { 
    echo -e "${YELLOW}${BOLD}${FLASHING}${1}${NONE}"
}

script_copyright_message() {
	echo ""
	THISYEAR=$(date +'%Y')
	echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echo "+ The MIT License (MIT)                                                                                 +"
	echo "+ Copyright (c) 2015-${THISYEAR} Sander W. van der Laan                                                        +"
	echo "+                                                                                                       +"
	echo "+ Permission is hereby granted, free of charge, to any person obtaining a copy of this software and     +"
	echo "+ associated documentation files (the \"Software\"), to deal in the Software without restriction,         +"
	echo "+ including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, +"
	echo "+ and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, +"
	echo "+ subject to the following conditions:                                                                  +"
	echo "+                                                                                                       +"
	echo "+ The above copyright notice and this permission notice shall be included in all copies or substantial  +"
	echo "+ portions of the Software.                                                                             +"
	echo "+                                                                                                       +"
	echo "+ THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT     +"
	echo "+ NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND                +"
	echo "+ NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES  +"
	echo "+ OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN   +"
	echo "+ CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                            +"
	echo "+                                                                                                       +"
	echo "+ Reference: http://opensource.org.                                                                     +"
	echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
}

script_arguments_error() {
	echoerror "$1" # Additional message
	echoerror "- Argument #1 is path_to/filename of the configuration file."
	echoerror ""
	echoerror "An example command would be: metagwastoolkit.splitfiles.HPC.sh [arg1]"
	echoerror "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
 	echo ""
	script_copyright_message
	exit 1
}

echobold "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echobold "          MetaGWASToolKit: A TOOLKIT FOR THE META-ANALYSIS OF GENOME-WIDE ASSOCIATION STUDIES"
echobold "               --- ARRAY JOB TO REFORMAT, PARSE, HARMONIZE, CLEAN ORIGINAL GWAS DATA ---"
echobold ""
echobold "* Version:      v1.0.2" # Needs change
echobold ""
echobold "* Last update:  2023-01-01" # Needs change
echobold "* Based on:     MANTEL, as written by Sara Pulit, Jessica van Setten, and Paul de Bakker."
echobold "* Written by:   Sander W. van der Laan | s.w.vanderlaan@gmail.com."
echobold "                Moezammin Baksi"
echobold "* Testers:      Sander W. van der Laan; Emma J.A. Smulders; Moezammin Baksi."
echobold "* Description:  This script will use the splitted individual cohort-files and create array-jobs"
echobold "                to perform a meta-analysis of genome-wide association studies. "
echobold "                It will do the following:"
echobold "                - Automatically parse the various cohort files."
echobold "                - Harmonize GWAS datasets relative to a reference."
echobold "                - Perform QC on GWAS datasets using user-defined settings."
echobold "                - Produce plots (PDF and PNG) for quick inspection and publication."
echobold "                - Run a meta-analysis using Random, Fixed, and Z-score methods."
echobold "                - Correct results for the genomic inflation factor."
echobold "                - Clump results based on a p-value threshold for downstream (meta-)analyses."
echobold "                - Produce plots (PDF and PNG) of the final meta-analysis results for publication."
echobold "                - Produce LocusZoom style regional plots for genome-wide significant hits."
echobold "                - Produce a ReadMe file."
echobold ""
echobold "* REQUIRED: "
echobold "  - A high-performance computer cluster with a SLURM system"
echobold "  - R v3.2+, Python 2.7+, Perl."
echobold "  - Required Python 2.7+ modules: [pandas], [scipy], [numpy]."
echobold "  - Required Perl modules: [YAML], [Statistics::Distributions], [Getopt::Long]."
echobold "  - Note: it will also work on a Mac OS X system with R and Python installed."
### ADD-IN: function to check requirements...
### This might be a viable option! https://gist.github.com/JamieMason/4761049
echobold ""
echobold "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"


##########################################################################################
### SET THE SCENE FOR THE SCRIPT
##########################################################################################

### START of if-else statement for the number of command-line arguments passed ###
if [[ $# -lt 1 ]]; then 
	echo ""
	echoerror "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echoerrorflash "               *** Oh, oh, computer says no! Number of arguments found "$#". ***"
	echoerror "You must supply [1] arguments when running *** MetaGWASToolKit ***!"
	script_arguments_error
else
	echo "These are the "$#" arguments that passed:"
	echo "The configuration file.................: "$(basename ${1}) # argument 1
	
	### SETTING DIRECTORIES (from configuration file).
	# Loading the configuration file (please refer to the MetaGWASToolKit-Manual for specifications of this file). 
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

	echobold "#========================================================================================================"
	echobold "#== ADDING HEADERS"
	echobold "#========================================================================================================"
	echobold "#"
	### Adding headers -- this is ABSOLUTELY required for the 'gwas.parser.R'.
	### determine basename of the splitfile
	### SLURM version -- ARRAY JOB
	BASESPLITFILE=$(basename ${SPLITFILE} .pdat)

	echo ""
	echobold "#========================================================================================================"
	echobold "#== PARSING THE GWAS DATA"
	echobold "#========================================================================================================"
	echobold "#"
	echo ""
	echo "* Parsing data for cohort ${COHORT} [ file: ${BASESPLITFILE} ]."

	### FOR DEBUGGING LOCALLY -- Mac OS X
	### Call the GWAS Parsing
	### Rscript ${SCRIPTS}/gwas.parser.R -p ${PROJECTDIR} -d ${SPLITFILE} -o ${METAOUTPUT}/${SUBPROJECTDIRNAME}/RAW/${COHORT} 

	### OLD QSUB version
	### echo "Rscript ${SCRIPTS}/gwas.parser.R -p ${PROJECTDIR} -d ${SPLITFILE} -o ${METAOUTPUT}/${SUBPROJECTDIRNAME}/RAW/${COHORT} " > ${RAWDATACOHORT}/gwas.parser.${BASESPLITFILE}.sh
	### qsub -S /bin/bash -N gwas.parser.${BASESPLITFILE} -hold_jid metagwastoolkit -o ${RAWDATACOHORT}/gwas.parser.${BASESPLITFILE}.log -e ${RAWDATACOHORT}/gwas.parser.${BASESPLITFILE}.errors -l h_rt=${QRUNTIMEPARSER} -l h_vmem=${QMEMPARSER} -M ${QMAIL} -m ${QMAILOPTIONS} -cwd ${RAWDATACOHORT}/gwas.parser.${BASESPLITFILE}.sh

	### SLURM version -- ARRAY JOB
	### Call the parser script
	printf "#!/bin/bash\nRscript ${SCRIPTS}/gwas.parser.R -p ${PROJECTDIR} -d ${SPLITFILE} -o ${METAOUTPUT}/${SUBPROJECTDIRNAME}/RAW/${COHORT}" > ${RAWDATACOHORT}/gwas.parser.${BASESPLITFILE}.sh
	PARSER_ID=$(sbatch --parsable --job-name=gwas.parser.${BASESPLITFILE} --dependency=afterany:${INIT_ID} -o ${RAWDATACOHORT}/gwas.parser.${BASESPLITFILE}.log --error ${RAWDATACOHORT}/gwas.parser.${BASESPLITFILE}.errors --time=${QRUNTIMEPARSER} --mem=${QMEMPARSER} --mail-user=${QMAIL} --mail-type=${QMAILOPTIONS} ${RAWDATACOHORT}/gwas.parser.${BASESPLITFILE}.sh)
	wait # Wait till the scripts are finished; after that this script will be killed/stopped and the depending scripts will start
	
	echobold "#========================================================================================================"
	echobold "#== HARMONIZING THE PARSED GWAS DATA"
	echobold "#========================================================================================================"
	echobold "#"
	echo ""
	echo "* Harmonising parsed [ ${BASESPLITFILE} ] file for cohort ${COHORT} with ${REFERENCE}..."

	### FOR DEBUGGING LOCALLY -- SLURM/Mac OS X
	### Call the GWAS Harmonizer
	### module load python
	### python ${SCRIPTS}/gwas2ref.harmonizer.py -g ${SPLITFILE}.pdat -r ${VINFOFILE} -i ${VARIANTYPE} -o ${SPLITFILE}.ref.pdat

	### OLD QSUB version
	### echo "module load python" > ${RAWDATACOHORT}/gwas2ref.harmonizer.${BASESPLITFILE}.sh
	### echo "${SCRIPTS}/gwas2ref.harmonizer.py -g ${SPLITFILE}.pdat -r ${VINFOFILE} -i ${VARIANTYPE} -o ${SPLITFILE}.ref.pdat" >> ${RAWDATACOHORT}/gwas2ref.harmonizer.${BASESPLITFILE}.sh
	### qsub -S /bin/bash -N gwas2ref.harmonizer.${BASESPLITFILE} -hold_jid gwas.parser.${BASESPLITFILE} -o ${RAWDATACOHORT}/gwas2ref.harmonizer.${BASESPLITFILE}.log -e ${RAWDATACOHORT}/gwas2ref.harmonizer.${BASESPLITFILE}.errors -l h_rt=${QRUNTIMEHARMONIZE} -l h_vmem=${QMEMHARMONIZE} -M ${QMAIL} -m ${QMAILOPTIONS} -cwd ${RAWDATACOHORT}/gwas2ref.harmonizer.${BASESPLITFILE}.sh

	### SLURM version -- ARRAY JOB
	### Call the harmonizer
	printf "#!/bin/bash\nmodule load python/3.6.1\n" > ${RAWDATACOHORT}/gwas2ref.harmonizer.${BASESPLITFILE}.sh
	printf "${SCRIPTS}/gwas2ref.harmonizer.py -g ${SPLITFILE}.pdat -r ${VINFOFILE} -i ${VARIANTYPE} -o ${SPLITFILE}.ref.pdat" >> ${RAWDATACOHORT}/gwas2ref.harmonizer.${BASESPLITFILE}.sh
	HARMONIZER_ID=$(sbatch --parsable --job-name=gwas2ref.harmonizer.${BASESPLITFILE} --dependency=afterany:${PARSER_ID} -o ${RAWDATACOHORT}/gwas2ref.harmonizer.${BASESPLITFILE}.log --error ${RAWDATACOHORT}/gwas2ref.harmonizer.${BASESPLITFILE}.errors --time=${QRUNTIMEHARMONIZE} --mem=${QMEMHARMONIZE} --mail-user=${QMAIL} --mail-type=${QMAILOPTIONS} ${RAWDATACOHORT}/gwas2ref.harmonizer.${BASESPLITFILE}.sh)
	wait # Wait till the scripts are finished; after that this script will be killed/stopped and the depending scripts will start

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
	### Call the GWAS Cleaner
	### Rscript ${SCRIPTS}/gwas.cleaner.R -d ${SPLITFILE}.ref.pdat -f ${BASESPLITFILE} -o ${RAWDATACOHORT} -e ${BETA} -s ${SE} -m ${MAF} -c ${MAC} -i ${INFO} -w ${HWE}

	## echo "${SCRIPTS}/gwas.cleaner.R -d ${SPLITFILE}.ref.pdat -f ${BASESPLITFILE} -o ${RAWDATACOHORT} -e ${BETA} -s ${SE} -m ${MAF} -c ${MAC} -i ${INFO} -w ${HWE}" >> ${RAWDATACOHORT}/gwas.cleaner.${BASESPLITFILE}.sh
	## qsub -S /bin/bash -N gwas.cleaner.${BASEFILE} -hold_jid gwas2ref.harmonizer.${BASESPLITFILE} -o ${RAWDATACOHORT}/gwas.cleaner.${BASESPLITFILE}.log -e ${RAWDATACOHORT}/gwas.cleaner.${BASESPLITFILE}.errors -l h_rt=${QRUNTIMECLEANER} -l h_vmem=${QMEMCLEANER} -M ${QMAIL} -m ${QMAILOPTIONS} -cwd ${RAWDATACOHORT}/gwas.cleaner.${BASESPLITFILE}.sh

	### SLURM version -- ARRAY JOB
	### Call the cleaner
	### The --wait flag will cause this array to wait until each script is finished before moving to the next step
	printf "#!/bin/bash\n${SCRIPTS}/gwas.cleaner.R -d ${SPLITFILE}.ref.pdat -f ${BASESPLITFILE} -o ${RAWDATACOHORT} -e ${BETA} -s ${SE} -m ${MAF} -c ${MAC} -i ${INFO} -w ${HWE}" >> ${RAWDATACOHORT}/gwas.cleaner.${BASESPLITFILE}.sh
	CLEANER_ID=$(sbatch --parsable --wait --job-name=gwas.cleaner.${BASESPLITFILE} --dependency=afterany:${HARMONIZER_ID} -o  ${RAWDATACOHORT}/gwas.cleaner.${BASESPLITFILE}.log --error ${RAWDATACOHORT}/gwas.cleaner.${BASESPLITFILE}.errors --time=${QRUNTIMECLEANER} --mem=${QMEMCLEANER} --mail-user=${QMAIL} --mail-type=${QMAILOPTIONS} ${RAWDATACOHORT}/gwas.cleaner.${BASESPLITFILE}.sh)
	
	echo ""
	wait # Wait till the scripts are finished; after that this script will be killed/stopped and the depending scripts will start
	
	echo ""
	echo "All done for this array."
	
### END of if-else statement for the number of command-line arguments passed ###
fi 

script_copyright_message
