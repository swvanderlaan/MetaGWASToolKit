#!/bin/bash

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
	echoerror "- Argument #2 is path_to/filename of the list of GWAS files with names."
	echoerror "- Argument #3 is reference to use [1Gp1] for the QC and analysis."
	echoerror ""
	echoerror "An example command would be: run_metagwastoolkit.sh [arg1] [arg2] [arg3]"
	echoerror "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
 	echo ""
	script_copyright_message
	exit 1
}

echobold "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echobold "          MetaGWASToolKit: A TOOLKIT FOR THE META-ANALYSIS OF GENOME-WIDE ASSOCIATION STUDIES"
echobold ""
echobold "* Version:      v1.5.3"
echobold ""
echobold "* Last update:  2017-05-30"
echobold "* Based on:     MANTEL, as written by Sara Pulit, Jessica van Setten, and Paul de Bakker."
echobold "* Written by:   Sander W. van der Laan | s.w.vanderlaan@gmail.com."
echobold "                Sara Pulit; "
echobold "                Jessica van Setten; "
echobold "                Paul I.W. de Bakker."
echobold "* Testers:      Jessica van Setten."
echobold "* Description:  Perform a meta-analysis of genome-wide association studies. It will do the following:"
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
echobold "  - A high-performance computer cluster with a qsub system"
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
if [[ $# -lt 2 ]]; then 
	echo ""
	echoerror "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echoerrorflash "               *** Oh, oh, computer says no! Number of arguments found "$#". ***"
	echoerror "You must supply [2] arguments when running *** MetaGWASToolKit ***!"
	script_arguments_error
else
	echo "These are the "$#" arguments that passed:"
	echo "The configuration file.................: "$(basename ${1}) # argument 1
	echo "The list of GWAS files.................: "$(basename ${2}) # argument 2
	
	### SETTING DIRECTORIES (from configuration file).
	# Loading the configuration file (please refer to the MetaGWASToolKit-Manual for specifications of this file). 
	source "$1" # Depends on arg1.
	
	CONFIGURATIONFILE="$1" # Depends on arg1 -- but also on where it resides!!!
	SOFTWARE=${SOFTWARE} # from configuration file
	
	# Where MetaGWASToolKit resides
	METAGWASTOOLKIT=${METAGWASTOOLKITDIR} # from configuration file
	SCRIPTS=${METAGWASTOOLKIT}/SCRIPTS
	RESOURCES=${METAGWASTOOLKIT}/RESOURCES
	
	# Project information
	ORIGINALS=${DATA_UPLOAD_FREEZE} # from configuration file
	PROJECTDIR=${PROJECTDIR} # from configuration file
	SUBPROJECTDIRNAME=${SUBPROJECTDIRNAME} # from configuration file
	OUTPUTDIRNAME=${OUTPUTDIRNAME} # from configuration file
	GWASFILES="$2" # Depends on arg2 -- all the GWAS dataset information
	REFERENCE=${REFERENCE} # from configuration file
	POPULATION=${POPULATION} # from configuration file
	
	# Data preparation settings for parallelization
	CHUNKSIZE=${CHUNKSIZE}
	# Cleaning settings
	MAF=${MAF} # from configuration file
	MAC=${MAC} # from configuration file
	HWE=${HWE} # from configuration file
	INFO=${INFO} # from configuration file
	BETA=${BETA} # from configuration file
	SE=${SE} # from configuration file
	
	# Plotting settings
	RANDOMSAMPLE=${RANDOMSAMPLE}
	
	# Settings for QSUB-system
	# - run times
	QRUNTIME=${QRUNTIME} # from configuration file
	QRUNTIMEPARSER=${QRUNTIMEPARSER} # from configuration file
	QRUNTIMEHARMONIZE=${QRUNTIMEHARMONIZE} # from configuration file
	QRUNTIMEWRAPPER=${QRUNTIMEWRAPPER} # from configuration file
	QRUNTIMECLEANER=${QRUNTIMECLEANER} # from configuration file
	QRUNTIMEPLOTTER=${QRUNTIMEPLOTTER} # from configuration file
	QRUNTIMEMETAPREP=${QRUNTIMEMETAPREP} # from configuration file
	QRUNTIMEANALYZER=${QRUNTIMEANALYZER} # from configuration file
	
	# - run memory
	QMEM=${QMEM} # from configuration file
	QMEMPARSER=${QMEMPARSER} # from configuration file
	QMEMHARMONIZE=${QMEMHARMONIZE} # from configuration file
	QMEMWRAPPER=${QMEMWRAPPER} # from configuration file
	QMEMCLEANER=${QMEMCLEANER} # from configuration file
	QMEMPLOTTER=${QMEMPLOTTER} # from configuration file
	QMEMMETAPREP=${QMEMMETAPREP} # from configuration file
	QMEMANALYZER=${QMEMANALYZER} # from configuration file
	
	#- mailing
	QMAIL=${QMAIL} # from configuration file
	QMAILOPTIONS=${QMAILOPTIONS} # from configuration file
	
	### SETTING THE AVAILABLE REFERENCES -- could also go to the source file
	VINFOFILE=${VINFOFILE} # from configuration file
	
	##########################################################################################
	### CREATE THE OUTPUT DIRECTORIES
	echo ""
	echo "Checking for the existence of the output directory [ ${OUTPUTDIRNAME} ]."
	if [ ! -d ${PROJECTDIR}/${OUTPUTDIRNAME} ]; then
		echo "> Output directory doesn't exist - Mr. Bourne will create it for you."
		mkdir -v ${PROJECTDIR}/${OUTPUTDIRNAME}
	else
		echo "> Output directory already exists."
	fi
	METAOUTPUT=${OUTPUTDIRNAME}
	
	echo ""
	echo "Checking for the existence of the subproject directory [ ${METAOUTPUT}/${SUBPROJECTDIRNAME} ]."
	if [ ! -d ${PROJECTDIR}/${METAOUTPUT}/${SUBPROJECTDIRNAME} ]; then
		echo "> Subproject directory doesn't exist - Mr. Bourne will create it for you."
		mkdir -v ${PROJECTDIR}/${METAOUTPUT}/${SUBPROJECTDIRNAME}
	else
		echo "> Subproject directory already exists."
	fi
	SUBPROJECTDIR=${PROJECTDIR}/${METAOUTPUT}/${SUBPROJECTDIRNAME}

	echo ""	
	echo "Checking for the existence of the raw data directory [ ${METAOUTPUT}/${SUBPROJECTDIRNAME}/RAW ]."
	if [ ! -d ${PROJECTDIR}/${METAOUTPUT}/${SUBPROJECTDIRNAME}/RAW ]; then
		echo "> Raw data directory doesn't exist - Mr. Bourne will create it for you."
		mkdir -v ${PROJECTDIR}/${METAOUTPUT}/${SUBPROJECTDIRNAME}/RAW
	else
		echo "> Raw data directory already exists."
	fi
	# Setting directory for raw data.
	RAWDATA=${PROJECTDIR}/${METAOUTPUT}/${SUBPROJECTDIRNAME}/RAW

	echo ""		
	echo "Checking for the existence of the meta-analysis results directory [ ${METAOUTPUT}/${SUBPROJECTDIRNAME}/META ]."
	if [ ! -d ${PROJECTDIR}/${METAOUTPUT}/${SUBPROJECTDIRNAME}/META ]; then
		echo "> Meta-analysis results directory doesn't exist - Mr. Bourne will create it for you."
		mkdir -v ${PROJECTDIR}/${METAOUTPUT}/${SUBPROJECTDIRNAME}/META
	else
		echo "> Meta-analysis results directory already exists."
	fi
	# Setting directory for meta-analysis data.
	METARESULTDIR=${PROJECTDIR}/${METAOUTPUT}/${SUBPROJECTDIRNAME}/META
	
	echo "Checking for the existence of the meta-analysis temporary results directory [ ${METAOUTPUT}/${SUBPROJECTDIRNAME}/META/TEMP ]."
	if [ ! -d ${PROJECTDIR}/${METAOUTPUT}/${SUBPROJECTDIRNAME}/META/TEMP ]; then
		echo "> Meta-analysis results temporary directory doesn't exist - Mr. Bourne will create it for you."
		mkdir -v ${PROJECTDIR}/${METAOUTPUT}/${SUBPROJECTDIRNAME}/META/TEMP
	else
		echo "> Meta-analysis results temporary directory already exists."
	fi
	# Setting directory for meta-analysis temporary data.
	METATEMPRESULTDIR=${PROJECTDIR}/${METAOUTPUT}/${SUBPROJECTDIRNAME}/META/TEMP
	
	##########################################################################################
	### SETTING UP THE OUTPUT AND RAWDATA DIRECTORIES
	echo ""
	### Making raw data directories, unless they already exist. Depends on arg2.
	if [[ ${REFERENCE} = "1Gp1" ]]; then

	  	echo ""
	  	echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	  	echo ""
	  	echo "The scene is properly set, and directories are created! 🖖"
	  	echo "MetaGWASToolKit program........................: "${METAGWASTOOLKIT}
	  	echo "MetaGWASToolKit scripts........................: "${SCRIPTS}
	  	echo "MetaGWASToolKit resources......................: "${RESOURCES}
	  	echo "Reference used.................................: "${REFERENCE}
	  	echo "Main directory.................................: "${PROJECTDIR}
	  	echo "Main analysis output directory.................: "${METAOUTPUT}
	  	echo "Subproject's analysis output directory.........: "${METAOUTPUT}/${SUBPROJECTDIRNAME}
	  	echo "Original data directory........................: "${ORIGINALS}
	  	echo "We are processing these cohort(s)..............:"
		while IFS='' read -r GWASCOHORT || [[ -n "$GWASCOHORT" ]]; do
			LINE=${GWASCOHORT}
			COHORT=$(echo "${LINE}" | awk '{ print $1 }')
			echo "     * ${COHORT}"
		done < ${GWASFILES}
	  	echo "Raw data directory.............................: "${METAOUTPUT}/${SUBPROJECTDIRNAME}/RAW
	  	echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	  	echo ""
	
	elif [[ ${REFERENCE} = "HM2" || ${REFERENCE} = "GONL4" || ${REFERENCE} = "GONL5" || ${REFERENCE} = "1Gp3" || ${REFERENCE} = "1Gp3GONL5" ]]; then
		echoerrornooption "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	  	echoerrornooption ""
	  	echoerrorflashnooption "               *** Oh, computer says no! This option is not available yet. ***"
	  	echoerrornooption "Unfortunately using ${REFERENCE} as a reference is not possible yet. Currently only 1Gp1 is available."
	  	echoerrornooption "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
		### The wrong arguments are passed, so we'll exit the script now!
		echo ""
		script_copyright_message
		exit 1
	
	else
	  	echoerror "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	  	echoerror ""
	  	echoerrorflash "                  *** Oh, computer says no! Argument not recognised. ***"
	  	echoerror "You have the following options as reference for the quality control"
	  	echoerror "and meta-analysis:"
	  	echonooption " - [HM2]          HapMap2 (r27, b36, hg18)."
	  	echoerror " - [1Gp1]         1000G (phase 1, release 3, 20101123 version, updated on 20110521 "
	  	echoerror "                  and revised on Feb/Mar 2012, b37, hg19)."
	  	echonooption " - [1Gp3]         1000G (phase 3, release 5, 20130502 version, b37, hg19)."
	  	echonooption " - [GoNL4]        Genome of the Netherlands, version 4."
	  	echonooption " - [GONL5]        Genome of the Netherlands, version 5."
	  	echonooption " - [1Gp3GONL5]    integrated 1000G phase 3, version 5 and GoNL5."
	  	echonooption "(Opaque: not an option yet)"
	  	echoerror "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
		### The wrong arguments are passed, so we'll exit the script now!
		echo ""
		script_copyright_message
		exit 1
	fi
# 	
# 	echobold "#########################################################################################################"
# 	echobold "### REFORMAT, PARSE, HARMONIZE, CLEAN, AND PLOT ORIGINAL GWAS DATA"
# 	echobold "#########################################################################################################"
# 	echobold "#"
# 	echo ""
# 	echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
# 	echo "Start the reformatting, parsing, harmonizing, and cleaning of each cohort and dataset. "
# 	echo ""
# 	
# 	while IFS='' read -r GWASCOHORT || [[ -n "$GWASCOHORT" ]]; do
# 			
# 		LINE=${GWASCOHORT}
# 		COHORT=$(echo "${LINE}" | awk '{ print $1 }')
# 		FILE=$(echo "${LINE}" | awk '{ print $2 }')
# 		VARIANTYPE=$(echo "${LINE}" | awk '{ print $3 }')
# 		
# 		BASEFILE=$(basename ${FILE} .txt.gz)
# 		
# 		if [ ! -d ${RAWDATA}/${COHORT} ]; then
# 	  		echo "Making subdirectory for ${COHORT}..."
# 	  		mkdir -v ${RAWDATA}/${COHORT}
# 		else
# 			echo "Directory for ${COHORT} already there."
# 		fi
# 		RAWDATACOHORT=${RAWDATA}/${COHORT}
# 		
# 		echobold "#========================================================================================================"
# 		echobold "#== REFORMAT, PARSE, HARMONIZE, CLEANING ORIGINAL GWAS DATA"
# 		echobold "#========================================================================================================"
# 		echobold "#"
# 		echo ""
# 		echo "* Chopping up GWAS summary statistics into chunks of ${CHUNKSIZE} variants -- for parallelisation and speedgain..."
# 		
# 		### Split up the file in increments of 1000K -- note: the period at the end of '${BASEFILE}' is a separator character
# 		zcat ${ORIGINALS}/${FILE} | tail -n +2 | split -a 3 -l ${CHUNKSIZE} - ${RAWDATACOHORT}/${BASEFILE}.
# 		
# 		## Adding headers -- this is ABSOLUTELY required for the 'gwas.parser.R'.
# 		for SPLITFILE in ${RAWDATACOHORT}/${BASEFILE}.*; do
# 			### determine basename of the splitfile
# 			BASESPLITFILE=$(basename ${SPLITFILE} .pdat)
# 			echo ""
# 			echo "* Prepping split chunk: [ ${BASESPLITFILE} ]..."
# 			echo ""
# 			echo " - heading a temporary file." 
# 			zcat ${ORIGINALS}/${FILE} | head -1 > ${RAWDATACOHORT}/tmp_file
# 			echo " - adding the split data to the temporary file."
# 			cat ${SPLITFILE} >> ${RAWDATACOHORT}/tmp_file
# 			echo " - renaming the temporary file."
# 			mv -fv ${RAWDATACOHORT}/tmp_file ${SPLITFILE}
# 			
# 			echobold "#========================================================================================================"
# 			echobold "#== PARSING THE GWAS DATA"
# 			echobold "#========================================================================================================"
# 			echobold "#"
# 			echo ""
# 			echo "* Parsing data for cohort ${COHORT} [ file: ${BASESPLITFILE} ]."
# 			### FOR DEBUGGING LOCALLY -- Mac OS X
# 			### Rscript ${SCRIPTS}/gwas.parser.R -p ${PROJECTDIR} -d ${SPLITFILE} -o ${METAOUTPUT}/${SUBPROJECTDIRNAME}/RAW/${COHORT} 
# 			echo "Rscript ${SCRIPTS}/gwas.parser.R -p ${PROJECTDIR} -d ${SPLITFILE} -o ${METAOUTPUT}/${SUBPROJECTDIRNAME}/RAW/${COHORT} " > ${RAWDATACOHORT}/gwas.parser.${BASESPLITFILE}.sh
# 			qsub -S /bin/bash -N gwas.parser.${BASESPLITFILE} -hold_jid run_metagwastoolkit -o ${RAWDATACOHORT}/gwas.parser.${BASESPLITFILE}.log -e ${RAWDATACOHORT}/gwas.parser.${BASESPLITFILE}.errors -l h_rt=${QRUNTIMEPARSER} -l h_vmem=${QMEMPARSER} -M ${QMAIL} -m ${QMAILOPTIONS} -cwd ${RAWDATACOHORT}/gwas.parser.${BASESPLITFILE}.sh
# 			
# 			echobold "#========================================================================================================"
# 			echobold "#== HARMONIZING THE PARSED GWAS DATA"
# 			echobold "#========================================================================================================"
# 			echobold "#"
# 			echo ""
# 			echo "* Harmonising parsed [ ${BASESPLITFILE} ] file for cohort ${COHORT} with ${REFERENCE}..."
# 			### FOR DEBUGGING LOCALLY -- Mac OS X
# 			### module load python
# 			### ${SCRIPTS}/gwas2ref.harmonizer.py -g ${SPLITFILE}.pdat -r ${VINFOFILE} -i ${VARIANTYPE} -o ${SPLITFILE}.ref.pdat
# 			echo "module load python" > ${RAWDATACOHORT}/gwas2ref.harmonizer.${BASESPLITFILE}.sh
# 			echo "${SCRIPTS}/gwas2ref.harmonizer.py -g ${SPLITFILE}.pdat -r ${VINFOFILE} -i ${VARIANTYPE} -o ${SPLITFILE}.ref.pdat" >> ${RAWDATACOHORT}/gwas2ref.harmonizer.${BASESPLITFILE}.sh
# 			qsub -S /bin/bash -N gwas2ref.harmonizer.${BASEFILE} -hold_jid gwas.parser.${BASESPLITFILE} -o ${RAWDATACOHORT}/gwas2ref.harmonizer.${BASESPLITFILE}.log -e ${RAWDATACOHORT}/gwas2ref.harmonizer.${BASESPLITFILE}.errors -l h_rt=${QRUNTIMEHARMONIZE} -l h_vmem=${QMEMHARMONIZE} -M ${QMAIL} -m ${QMAILOPTIONS} -cwd ${RAWDATACOHORT}/gwas2ref.harmonizer.${BASESPLITFILE}.sh
# 		
# 			echobold "#========================================================================================================"
# 			echobold "#== CLEANING UP THE REFORMATTED GWAS DATA"
# 			echobold "#========================================================================================================"
# 			echobold "#"
# 			echo ""
# 			echo "* Cleaning harmonized data for [ ${BASESPLITFILE} ] file for cohort ${COHORT} with ${REFERENCE}"
# 			echo "  using the following pre-specified settings:"
# 			echo "  - MAF  = ${MAF}"
# 			echo "  - MAC  = ${MAC}"
# 			echo "  - HWE  = ${HWE}"
# 			echo "  - INFO = ${INFO}"
# 			echo "  - BETA = ${BETA}"
# 			echo "  - SE   = ${SE}"
# 			### FOR DEBUGGING LOCALLY -- Mac OS X
# 			### ${SCRIPTS}/gwas.cleaner.R -d ${SPLITFILE}.ref.pdat -f ${BASESPLITFILE} -o ${RAWDATACOHORT} -e ${BETA} -s ${SE} -m ${MAF} -c ${MAC} -i ${INFO} -w ${HWE}
# 			echo "${SCRIPTS}/gwas.cleaner.R -d ${SPLITFILE}.ref.pdat -f ${BASESPLITFILE} -o ${RAWDATACOHORT} -e ${BETA} -s ${SE} -m ${MAF} -c ${MAC} -i ${INFO} -w ${HWE}" >> ${RAWDATACOHORT}/gwas.cleaner.${BASESPLITFILE}.sh
# 			qsub -S /bin/bash -N gwas.cleaner.${BASEFILE} -hold_jid gwas2ref.harmonizer.${BASEFILE} -o ${RAWDATACOHORT}/gwas.cleaner.${BASESPLITFILE}.log -e ${RAWDATACOHORT}/gwas.cleaner.${BASESPLITFILE}.errors -l h_rt=${QRUNTIMECLEANER} -l h_vmem=${QMEMCLEANER} -M ${QMAIL} -m ${QMAILOPTIONS} -cwd ${RAWDATACOHORT}/gwas.cleaner.${BASESPLITFILE}.sh
# 
# 		done
# 
# 		echobold "#========================================================================================================"
# 		echobold "#== WRAPPING THE REFORMATTED GWAS DATA"
# 		echobold "#========================================================================================================"
# 		echobold "#"
# 
# 		echo ""
# 		echo "* Wrapping up parsed and harmonized data for cohort ${COHORT}..."
# 		### FOR DEBUGGING LOCALLY -- Mac OS X
# 		### ${SCRIPTS}/gwas.wrapper.sh ${RAWDATACOHORT} ${COHORT} ${BASEFILE} ${VARIANTYPE}
# 		echo "${SCRIPTS}/gwas.wrapper.sh ${RAWDATACOHORT} ${COHORT} ${BASEFILE} ${VARIANTYPE}" >> ${RAWDATACOHORT}/gwas.wrapper.${BASEFILE}.sh
# 		qsub -S /bin/bash -N gwas.wrapper -hold_jid gwas.cleaner.${BASEFILE} -o ${RAWDATACOHORT}/gwas.wrapper.${BASEFILE}.log -e ${RAWDATACOHORT}/gwas.wrapper.${BASEFILE}.errors -l h_rt=${QRUNTIMEWRAPPER} -l h_vmem=${QMEMWRAPPER} -M ${QMAIL} -m ${QMAILOPTIONS} -cwd ${RAWDATACOHORT}/gwas.wrapper.${BASEFILE}.sh
# 		
# 		echobold "#========================================================================================================"
# 		echobold "#== PLOTTING THE REFORMATTED & WRAPPED GWAS DATA"
# 		echobold "#========================================================================================================"
# 		echobold "#"
# 		#### Add in functions based on Winkler et al. (frequency plot among others) for 
# 		#### both types of data, i.e. raw and cleaned.
# 		echo ""
# 		echo "* Plotting harmonized data for cohort [ ${COHORT} ]..."
# 		DATAFORMAT="RAW"
# 		IMAGEFORMAT="PNG"
# 		### FOR DEBUGGING LOCALLY -- Mac OS X
# 		### ${SCRIPTS}/gwas.plotter.sh ${CONFIGURATIONFILE} ${RAWDATACOHORT} ${COHORT} ${DATAFORMAT} ${IMAGEFORMAT} ${QRUNTIMEPLOTTER} ${QMEMPLOTTER}
#  		echo "${SCRIPTS}/gwas.plotter.sh ${CONFIGURATIONFILE} ${RAWDATACOHORT} ${COHORT} ${DATAFORMAT} ${IMAGEFORMAT} ${QRUNTIMEPLOTTER} ${QMEMPLOTTER}" >> ${RAWDATACOHORT}/gwas.plotter.${BASEFILE}.raw.sh
#  		qsub -S /bin/bash -N gwas.plotter.${BASEFILE}.raw -hold_jid gwas.wrapper -o ${RAWDATACOHORT}/gwas.plotter.${BASEFILE}.raw.log -e ${RAWDATACOHORT}/gwas.plotter.${BASEFILE}.raw.errors -l h_rt=${QRUNTIMEPLOTTER} -l h_vmem=${QMEMPLOTTER} -M ${QMAIL} -m ${QMAILOPTIONS} -cwd ${RAWDATACOHORT}/gwas.plotter.${BASEFILE}.raw.sh
# 
# 		echobold "#========================================================================================================"
# 		echobold "#== PLOTTING THE CLEANED GWAS DATA"
# 		echobold "#========================================================================================================"
# 		echobold "#"
# 
# 		echo ""
# 		echo "* Plotting the cleaned and harmonized data for cohort [ ${COHORT} ]..."
# 		DATAFORMAT="QC"
# 		IMAGEFORMAT="PNG"
# 		### FOR DEBUGGING LOCALLY -- Mac OS X
# 		### ${SCRIPTS}/gwas.plotter.sh ${CONFIGURATIONFILE} ${RAWDATACOHORT} ${COHORT} ${DATAFORMAT} ${IMAGEFORMAT} ${QRUNTIMEPLOTTER} ${QMEMPLOTTER}	
#  		echo "${SCRIPTS}/gwas.plotter.sh ${CONFIGURATIONFILE} ${RAWDATACOHORT} ${COHORT} ${DATAFORMAT} ${IMAGEFORMAT} ${QRUNTIMEPLOTTER} ${QMEMPLOTTER}" >> ${RAWDATACOHORT}/gwas.plotter.${BASEFILE}.qc.sh
#  		qsub -S /bin/bash -N gwas.plotter.${BASEFILE}.qc -hold_jid gwas.wrapper -o ${RAWDATACOHORT}/gwas.plotter.${BASEFILE}.qc.log -e ${RAWDATACOHORT}/gwas.plotter.${BASEFILE}.qc.errors -l h_rt=${QRUNTIMEPLOTTER} -l h_vmem=${QMEMPLOTTER} -M ${QMAIL} -m ${QMAILOPTIONS} -cwd ${RAWDATACOHORT}/gwas.plotter.${BASEFILE}.qc.sh
# 
# 	done < ${GWASFILES}
# 
# 					### !!! THIS PART STILL REQUIRES MANUAL START !!! ###
# 					          ### can we make it automatic? ###
# 
# 	echobold "#########################################################################################################"
# 	echobold "### META-ANALYSIS"
# 	echobold "#########################################################################################################"
# 	echobold "#" 	 
# 	echo ""
# 	echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
# 	echo "Starting the meta-analysis. "
# 	echo ""
# 	
# 	echobold "#========================================================================================================"
# 	echobold "#== CHECK INDIVIDUAL COHORTS PRE-META-ANALYSIS -- WILL BE ADDED TO FUTURE VERSION"
# 	echobold "#========================================================================================================"
# 	echobold "#"
# 	echonooption "#### Add in functions that goes over each cohort and:" 
# 	echonooption "#### - checks whether it should be included,"
# 	echonooption "#### - changes the list of cohorts that should go forward into the meta-analysis,"
# 	echonooption "#### - creates param-files automatically."
# 	
# 	echobold "#========================================================================================================"
# 	echobold "#== COLLECT ALL UNIQUE VARIANTS ACROSS ALL GWAS COHORTS"
# 	echobold "#========================================================================================================"
# 	echobold "#"
# 	
# 	echo ""
# 	echo "We will collect all unique variants across all GWAS cohorts."
# 	### FOR DEBUGGING LOCALLY -- Mac OS X
# 	### ${SCRIPTS}/gwas.variantcollector.sh ${CONFIGURATIONFILE} ${RAWDATA} ${METARESULTDIR}	
# 	echo "${SCRIPTS}/gwas.variantcollector.sh ${CONFIGURATIONFILE} ${RAWDATA} ${METARESULTDIR}" > ${METARESULTDIR}/gwas.variantcollector.sh
#  	qsub -S /bin/bash -N gwas.variantcollector -hold_jid gwas.wrapper -o ${METARESULTDIR}/gwas.variantcollector.log -e ${METARESULTDIR}/gwas.variantcollector.errors -l h_rt=${QRUNTIME} -l h_vmem=${QMEM} -M ${QMAIL} -m ${QMAILOPTIONS} -cwd ${METARESULTDIR}/gwas.variantcollector.sh
# 
# 	echobold "#========================================================================================================"
# 	echobold "#== ALIGN COHORTS AND SPLIT IN PREPARATION OF META-ANALYSIS"
# 	echobold "#========================================================================================================"
# 	echobold "#"
# 	
# 	echo ""
# 	echo "We will prepare each cleaned cohort for meta-analysis."
# 	while IFS='' read -r GWASCOHORT || [[ -n "$GWASCOHORT" ]]; do
# 			
# 		LINE=${GWASCOHORT}
# 		COHORT=$(echo "${LINE}" | awk '{ print $1 }')
# 		FILE=$(echo "${LINE}" | awk '{ print $2 }')
# 		VARIANTYPE=$(echo "${LINE}" | awk '{ print $3 }')
# 		
# 		BASEFILE=$(basename ${FILE} .txt.gz)
# 		
# 		echo ""
# 		if [ ! -d ${METARESULTDIR}/${COHORT} ]; then
# 	  		echo "Making subdirectory for ${COHORT}..."
# 	  		mkdir -v ${METARESULTDIR}/${COHORT}
# 		else
# 			echo "Directory for ${COHORT} already there."
# 		fi
# 		
# 		# Set the rawdata for the cohort
# 		RAWDATACOHORT=${RAWDATA}/${COHORT}
# 		
# 		# Set the meta-analysis preparation-stage directory for the cohort
# 		METAPREPDIRCOHORT=${METARESULTDIR}/${COHORT}
# 
# 		echo ""
# 		echo "* Reordering [ ${COHORT} ]..."
# 		### FOR DEBUGGING LOCALLY -- Mac OS X
# 		### ${SCRIPTS}/meta.preparator.sh ${CONFIGURATIONFILE} ${RAWDATACOHORT} ${METARESULTDIR} ${METAPREPDIRCOHORT} ${COHORT}
# 		echo "${SCRIPTS}/meta.preparator.sh ${CONFIGURATIONFILE} ${RAWDATACOHORT} ${METARESULTDIR} ${METAPREPDIRCOHORT} ${COHORT}" > ${METARESULTDIR}/${COHORT}/${COHORT}.meta.preparator.sh
#  		qsub -S /bin/bash -N meta.preparator -hold_jid gwas.variantcollector -o ${METARESULTDIR}/${COHORT}/${COHORT}.meta.preparator.log -e ${METARESULTDIR}/${COHORT}/${COHORT}.meta.preparator.errors -l h_rt=${QRUNTIMEMETAPREP} -l h_vmem=${QMEMMETAPREP} -M ${QMAIL} -m ${QMAILOPTIONS} -cwd ${METARESULTDIR}/${COHORT}/${COHORT}.meta.preparator.sh
# 	
# 	done < ${GWASFILES}
#  
# 					### !!! THIS PART STILL REQUIRES MANUAL START !!! ###
# 					          ### can we make it automatic? ###
# 
# 	echobold "#========================================================================================================"
# 	echobold "#== PERFORM META-ANALYSIS & CORRECT P-VALUES PER CHUNK IN PARALLEL"
# 	echobold "#========================================================================================================"
# 	echobold "#"
# 	
# 	### FUTURE VERSIONS WILL HAVE A SCRIPT TO AUTOMATICALLY MAKE THIS...
# 	### * paramCreator.pl will get the necessary information directly from the data:
# 	### - lambda
# 	### - sample size
# 	### - ratio
# 	### - basename of the to-be-meta-analyzed files
# 	### - beta-correction factor
# 	PARAMSFILE="${PARAMSFILE}" 
# 
# 	### List of all split and reordered unique variants in this
# 	VARIANTSFILES=${METATEMPRESULTDIR}/meta.all.unique.variants.reorder.split.list
# 	
# 	echo ""
# 	echo "We will perform the meta-analysis per chunk of ${CHUNKSIZE} variants."
# 	
# 	while IFS='' read -r VARIANTFILE || [[ -n "$VARIANTFILE" ]]; do
# 	
# 		EXTENSION="${VARIANTFILE##*.}"
#  		VARIANTFILEBASE="${VARIANTFILE%.*}"
#  		echo "* processing chunk [ ${EXTENSION} ] ..."
# 		echo ""
# 		echo "  - submit meta-analysis job..."
# 		### FOR DEBUGGING LOCALLY -- Mac OS X
# 		### ${SCRIPTS}/meta.analyzer.sh ${CONFIGURATIONFILE} ${PARAMSFILE} ${VARIANTFILEBASE} ${REFERENCE} ${METARESULTDIR} ${EXTENSION}
# 		echo "${SCRIPTS}/meta.analyzer.sh ${CONFIGURATIONFILE} ${PARAMSFILE} ${VARIANTFILEBASE} ${REFERENCE} ${METARESULTDIR} ${EXTENSION}" > ${METARESULTDIR}/meta.analyzer.${EXTENSION}.sh
#  		qsub -S /bin/bash -N meta.analyzer -hold_jid meta.preparator -o ${METARESULTDIR}/meta.analyzer.${EXTENSION}.log -e ${METARESULTDIR}/meta.analyzer.${EXTENSION}.errors -l h_rt=${QRUNTIMEANALYZER} -l h_vmem=${QMEMANALYZER} -M ${QMAIL} -m ${QMAILOPTIONS} -cwd ${METARESULTDIR}/meta.analyzer.${EXTENSION}.sh
# 	
# 		echo ""
# 		echo "  - submit p-value correction job..."
# 		### P-VALUE CORRECTION
# 		# Some p-values are computed as 0 (because the Statistics module in Perl freaks out 
# 		# for chi-square above a certain threshold). Here we can recompute these p-values 
# 		# in R.
# 		#
# 		# FUTURE VERSION: updated script which uses Rscript instead of 'R CMD BATCH -CL'
# 		### HEADER OUTPUT
# 		### -- verbose --
# 		### VARIANTID CHR POS REF ALT REFFREQ EFFECTALLELE_COHORT1 OTHERALLELE_COHORT1 ALLELES_FLIPPED_COHORT1 SIGN_FLIPPED_COHORT1 EAF_COHORT1 BETA_COHORT1 SE_COHORT1 P_COHORT1 Info_COHORT1 NEFF_COHORT1 [...OTHER COHORTS HERE..] EFFECTALLELE OTHERALLELE EAF N_EFF Z_SQRTN P_SQRTN BETA_FIXED SE_FIXED Z_FIXED P_FIXED BETA_LOWER_FIXED BETA_UPPER_FIXED BETA_RANDOM  SE_RANDOM  Z_RANDOM  P_RANDOM  BETA_LOWER_RANDOM BETA_UPPER_RANDOM COCHRANS_Q DF P_COCHRANS_Q I_SQUARED TAU_SQUARED DIRECTIONS GENES_250KB NEAREST_GENE NEAREST_GENE_ENSEMBLID NEAREST_GENE_STRAND VARIANT_FUNCTION CAVEAT
# 		
# 		echo "cat ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.${EXTENSION}.out | ${SCRIPTS}/parseTable.pl --col VARIANTID,P_SQRTN,P_FIXED,P_RANDOM | awk '\$2 == 0 || \$3 == 0 || \$4 == 0 { print \$1, \$2, \$3, \$4 }' > ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.${EXTENSION}.needs_p_fixing.out" > ${METARESULTDIR}/meta.p_corrector.${EXTENSION}.sh
# 		echo "Rscript ${SCRIPTS}/meta.pval_corrector.R --inputfile ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.${EXTENSION}.needs_p_fixing.out --outputfile ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.${EXTENSION}.fixed.out" >> ${METARESULTDIR}/meta.p_corrector.${EXTENSION}.sh
# 		echo "echo \"VARIANTID P_SQRTN P_FIXED P_RANDOM\" > ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.${EXTENSION}.fixed_headed.out" >> ${METARESULTDIR}/meta.p_corrector.${EXTENSION}.sh
# 		echo "tail -n +2 ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.${EXTENSION}.fixed.out >> ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.${EXTENSION}.fixed_headed.out" >> ${METARESULTDIR}/meta.p_corrector.${EXTENSION}.sh
# 		echo "${SCRIPTS}/mergeTables.pl --file1 ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.${EXTENSION}.fixed_headed.out --file2 ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.${EXTENSION}.out --index VARIANTID --format NORM --replace > ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.${EXTENSION}.corrected_p.out" >> ${METARESULTDIR}/meta.p_corrector.${EXTENSION}.sh
#  		qsub -S /bin/bash -N meta.p_corrector -hold_jid meta.analyzer -o ${METARESULTDIR}/meta.p_corrector.${EXTENSION}.log -e ${METARESULTDIR}/meta.p_corrector.${EXTENSION}.errors -l h_rt=${QRUNTIMEANALYZER} -l h_vmem=${QMEMANALYZER} -M ${QMAIL} -m ${QMAILOPTIONS} -cwd ${METARESULTDIR}/meta.p_corrector.${EXTENSION}.sh
# 	
# 	done < ${VARIANTSFILES}
# 	
# 	echobold "#========================================================================================================"
# 	echobold "#== WRAPPING THE META-ANALYSIS RESULTS"
# 	echobold "#========================================================================================================"
# 	echobold "#"
# 
# 	echo "Concatenating meta-analysis of GWAS results."
# 	VARIANTSFILES=${METATEMPRESULTDIR}/meta.all.unique.variants.reorder.split.list
# 	### For DEBUGGING
# 	### ${SCRIPTS}/meta.concatenator.sh ${CONFIGURATIONFILE} ${VARIANTSFILES} ${METARESULTDIR}
# 	echo "${SCRIPTS}/meta.concatenator.sh ${CONFIGURATIONFILE} ${VARIANTSFILES} ${METARESULTDIR} " > ${METARESULTDIR}/meta.concatenator.${PROJECTNAME}.${REFERENCE}.${POPULATION}.sh
#  	qsub -S /bin/bash -N meta.concatenator -hold_jid meta.p_corrector -o ${METARESULTDIR}/meta.concatenator.${PROJECTNAME}.${REFERENCE}.${POPULATION}.log -e ${METARESULTDIR}/meta.concatenator.${PROJECTNAME}.${REFERENCE}.${POPULATION}.errors -l h_rt=${QRUNTIME} -l h_vmem=${QMEM} -M ${QMAIL} -m ${QMAILOPTIONS} -cwd ${METARESULTDIR}/meta.concatenator.${PROJECTNAME}.${REFERENCE}.${POPULATION}.sh
#   	
# 	echobold "#========================================================================================================"
# 	echobold "#== PLOTTING THE CORRECTED META-ANALYSIS RESULTS"
# 	echobold "#========================================================================================================"
# 	echobold "#"
# 
# 	#### Perhaps a separate plotter script for this?
# 	echo "Plotting the corrected meta-analysis results..."
# 	IMAGEFORMAT="PNG"
# 	
# 	echo "* Producing Manhattan-plots..." # CHR, BP, P-value (P_SQRTN P_FIXED P_RANDOM)
# 	echo "zcat ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.txt.gz | ${SCRIPTS}/parseTable.pl --col CHR,POS,P_SQRTN | tail -n +2 > ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.MANHATTAN.P_SQRTN.txt" > ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.MANHATTAN.sh
# 	echo "zcat ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.txt.gz | ${SCRIPTS}/parseTable.pl --col CHR,POS,P_FIXED | tail -n +2 > ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.MANHATTAN.P_FIXED.txt" >> ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.MANHATTAN.sh
# 	echo "zcat ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.txt.gz | ${SCRIPTS}/parseTable.pl --col CHR,POS,P_RANDOM | tail -n +2 > ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.MANHATTAN.P_RANDOM.txt" >> ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.MANHATTAN.sh
# 	echo "${SCRIPTS}/plotter.manhattan.R --projectdir ${METARESULTDIR} --resultfile ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.MANHATTAN.P_SQRTN.txt --outputdir ${METARESULTDIR} --colorstyle FULL --imageformat ${IMAGEFORMAT} --title ${PROJECTNAME}.${SUBPROJECTDIRNAME}.P_SQRTN" >> ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.MANHATTAN.sh
# 	echo "${SCRIPTS}/plotter.manhattan.R --projectdir ${METARESULTDIR} --resultfile ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.MANHATTAN.P_FIXED.txt --outputdir ${METARESULTDIR} --colorstyle FULL --imageformat ${IMAGEFORMAT} --title ${PROJECTNAME}.${SUBPROJECTDIRNAME}.P_FIXED" >> ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.MANHATTAN.sh
# 	echo "${SCRIPTS}/plotter.manhattan.R --projectdir ${METARESULTDIR} --resultfile ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.MANHATTAN.P_RANDOM.txt --outputdir ${METARESULTDIR} --colorstyle FULL --imageformat ${IMAGEFORMAT} --title ${PROJECTNAME}.${SUBPROJECTDIRNAME}.P_RANDOM" >> ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.MANHATTAN.sh
# 	echo "gzip -v ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.MANHATTAN*.txt" >> ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.MANHATTAN.sh
# 	qsub -S /bin/bash -N META.MANHATTAN.${PROJECTNAME} -hold_jid meta.concatenator -o ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.MANHATTAN.log -e ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.MANHATTAN.errors -l h_vmem=${QMEMPLOTTER} -l h_rt=${QRUNTIMEPLOTTER} -wd ${METARESULTDIR} ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.MANHATTAN.sh
# 
# 	echo "* Producing normal QQ-plots..."
# 	echo "  - p-value based on square root of N" # P_SQRTN
# 	echo "zcat ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.txt.gz | ${SCRIPTS}/parseTable.pl --col P_SQRTN | tail -n +2 > ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_sqrtn.txt" > ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_sqrtn.sh
# 	echo "zcat ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.txt.gz | ${SCRIPTS}/parseTable.pl --col P_SQRTN,CAF | tail -n +2 > ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_sqrtn_by_CAF.txt" >> ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_sqrtn.sh
# 	echo "${SCRIPTS}/plotter.qq.R --projectdir ${METARESULTDIR} --resultfile ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_sqrtn.txt --outputdir ${METARESULTDIR} --stattype ${STATTYPE} --imageformat ${IMAGEFORMAT}" >> ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_sqrtn.sh
# 	echo "${SCRIPTS}/plotter.qq_by_caf.R --projectdir ${METARESULTDIR} --resultfile ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_sqrtn_by_CAF.txt --outputdir ${METARESULTDIR} --stattype ${STATTYPE} --imageformat ${IMAGEFORMAT}" >> ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_sqrtn.sh
# 	echo "gzip -v ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_sqrtn*.txt" >> ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_sqrtn.sh
# 	qsub -S /bin/bash -N META.QQ_SQRTN.${PROJECTNAME} -hold_jid meta.concatenator -o ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_sqrtn.log -e ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_sqrtn.errors -l h_vmem=${QMEMPLOTTER} -l h_rt=${QRUNTIMEPLOTTER} -wd ${METARESULTDIR} ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_sqrtn.sh
# 	
# 	echo "  - based on fixed-effects p-value..." # P_FIXED
# 	echo "zcat ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.txt.gz | ${SCRIPTS}/parseTable.pl --col P_FIXED | tail -n +2 > ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_fixed.txt" > ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_fixed.sh
# 	echo "zcat ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.txt.gz | ${SCRIPTS}/parseTable.pl --col P_FIXED,CAF | tail -n +2 > ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_fixed_by_CAF.txt" >> ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_fixed.sh
# 	echo "${SCRIPTS}/plotter.qq.R --projectdir ${METARESULTDIR} --resultfile ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_fixed.txt --outputdir ${METARESULTDIR} --stattype ${STATTYPE} --imageformat ${IMAGEFORMAT}" >> ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_fixed.sh
# 	echo "${SCRIPTS}/plotter.qq_by_caf.R --projectdir ${METARESULTDIR} --resultfile ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_fixed_by_CAF.txt --outputdir ${METARESULTDIR} --stattype ${STATTYPE} --imageformat ${IMAGEFORMAT}" >> ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_fixed.sh
# 	echo "gzip -v ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_fixed*.txt" >> ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_fixed.sh
# 	qsub -S /bin/bash -N META.QQ_FIXED.${PROJECTNAME} -hold_jid meta.concatenator -o ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_fixed.log -e ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_fixed.errors -l h_vmem=${QMEMPLOTTER} -l h_rt=${QRUNTIMEPLOTTER} -wd ${METARESULTDIR} ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_fixed.sh
# 
# 	echo "  - based on random-effects p-value..." # P_RANDOM
# 	echo "zcat ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.txt.gz | ${SCRIPTS}/parseTable.pl --col P_RANDOM | tail -n +2 > ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_random.txt" > ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_random.sh
# 	echo "zcat ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.txt.gz | ${SCRIPTS}/parseTable.pl --col P_RANDOM,CAF | tail -n +2 > ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_random_by_CAF.txt" >> ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_random.sh
# 	echo "${SCRIPTS}/plotter.qq.R --projectdir ${METARESULTDIR} --resultfile ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_random.txt --outputdir ${METARESULTDIR} --stattype ${STATTYPE} --imageformat ${IMAGEFORMAT}" >> ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_random.sh
# 	echo "${SCRIPTS}/plotter.qq_by_caf.R --projectdir ${METARESULTDIR} --resultfile ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_random_by_CAF.txt --outputdir ${METARESULTDIR} --stattype ${STATTYPE} --imageformat ${IMAGEFORMAT}" >> ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_random.sh
# 	echo "gzip -v ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_random*.txt" >> ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_random.sh
# 	qsub -S /bin/bash -N META.QQ_RANDOM.${PROJECTNAME} -hold_jid meta.concatenator -o ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_random.log -e ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_random.errors -l h_vmem=${QMEMPLOTTER} -l h_rt=${QRUNTIMEPLOTTER} -wd ${METARESULTDIR} ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_random.sh
#  
# 	###############################
# 	### THIS PART NEEDS FIXING ####
# 	echo "  - to make histograms of N_EFF and DF+1"
# 	### adjust number of bins in histogram with number of contributing studies 
# 	### (i.e. -CL -inputfile -number.of.studies -output.file)
# 	### FUTURE VERSION: updated script which uses Rscript instead of 'R CMD BATCH -CL'; including automatic determination of number of studies
# 	echo "NSTUDIES=$(cat ${METARESULTDIR}/meta.cohorts.cleaned.txt | wc -l)" > ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.n_eff.sh
# 	echo "zcat ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.txt.gz | ${SCRIPTS}/parseTable.pl --col N_EFF,DF | tail -n +2 | grep -v NA > ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.n_eff.txt" >> ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.n_eff.sh
# 	echo "R CMD BATCH -CL -${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.n_eff.txt -\$NSTUDIES -PNG -${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.n_eff ${SCRIPTS}/plotter.n_eff_k_studies.R" >> ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.n_eff.sh
# 	qsub -S /bin/bash -N META.N_EFF.${PROJECTNAME} -hold_jid meta.concatenator -o ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.n_eff.log -e ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.n_eff.errors -l h_vmem=${QMEMPLOTTER} -l h_rt=${QRUNTIMEPLOTTER} -wd ${METARESULTDIR} ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.n_eff.sh
# 	
# 	### Add in functions based on Winkler et al. (SE-Lambda-Plot, frequency plot among others)
# 	echo "  - to make SE-N-lambda plot"
# 	### FUTURE VERSION: updated script which uses Rscript instead of 'R CMD BATCH -CL';
# 	### 
# 	echo "perl ${SCRIPTS}/se-n-lambda.pl ${PROJECTDIR}/metagwastoolkit.${SUBPROJECTDIRNAME}.studyfile ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.se_n_lambda.txt 1Gp1" > ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.se_n_lambda.sh
# 	echo "R CMD BATCH --args -CL -${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.se_n_lambda.txt -PNG -${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.se_n_lambda.PNG ${SCRIPTS}/plotter.se_n_lambda.R" >> ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.se_n_lambda.sh
# 	qsub -S /bin/bash -N META.SE_N_LAMBDA.${PROJECTNAME} -hold_jid meta.concatenator -o ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.se_n_lambda.log -e ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.se_n_lambda.errors -l h_vmem=${QMEMPLOTTER} -l h_rt=${QRUNTIMEPLOTTER} -wd ${METARESULTDIR} ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.se_n_lambda.sh
# 	## THIS PART NEEDS FIXING ####
# 	###############################
# 	
# 	echobold "#========================================================================================================"
# 	echobold "#== GENOMIC CONTROL *AFTER* META-ANALYSIS USING LAMBDA CORRECTION"
# 	echobold "#========================================================================================================"
# 	echobold "#"
# 	
# 	echo "zcat ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.txt.gz | ${SCRIPTS}/parseTable.pl --col VARIANTID,BETA_FIXED,SE_FIXED > ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.beta_se.txt" > ${METARESULTDIR}/meta.genomic_control.sh
# 	echo "Rscript ${SCRIPTS}/meta.pval_gc_corrector.R --inputfile ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.beta_se.txt --outputfile ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.beta_se.lambda_corrected.txt " >> ${METARESULTDIR}/meta.genomic_control.sh
# 	echo "${SCRIPTS}/mergeTables.pl --file1 ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.beta_se.lambda_corrected.txt --file2 ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.txt.gz --index VARIANTID --format GZIP2 > ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.GC.txt " >> ${METARESULTDIR}/meta.genomic_control.sh
# 	echo "gzip -fv ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.GC.txt " >> ${METARESULTDIR}/meta.genomic_control.sh
# 	echo "rm -v ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.beta_se.lambda_corrected.txt ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.beta_se.txt " >> ${METARESULTDIR}/meta.genomic_control.sh
# 	qsub -S /bin/bash -N meta.genomic_control -hold_jid meta.concatenator -o ${METARESULTDIR}/meta.genomic_control.log -e ${METARESULTDIR}/meta.genomic_control.errors -l h_rt=${QRUNTIMECLEANER} -l h_vmem=${QMEMCLEANER} -M ${QMAIL} -m ${QMAILOPTIONS} -wd ${METARESULTDIR} ${METARESULTDIR}/meta.genomic_control.sh
# 	IMAGEFORMAT="PNG"
# 	### make pretty Manhattan plots
# 	echo "* Producing Manhattan-plot after genomic-control..." # CHR, BP, P-value (P_GC)
# 	echo "zcat ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.GC.txt.gz | ${SCRIPTS}/parseTable.pl --col CHR,POS,P_GC | tail -n +2 > ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.MANHATTAN.P_GC.txt" > ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.MANHATTAN.P_GC.sh
# 	echo "${SCRIPTS}/plotter.manhattan.R --projectdir ${METARESULTDIR} --resultfile ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.MANHATTAN.P_GC.txt --outputdir ${METARESULTDIR} --colorstyle FULL --imageformat ${IMAGEFORMAT} --title ${PROJECTNAME}.${SUBPROJECTDIRNAME}.P_GC" >> ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.MANHATTAN.P_GC.sh
# 	echo "gzip -v ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.MANHATTAN.P_GC.txt" >> ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.MANHATTAN.P_GC.sh
# 	qsub -S /bin/bash -N META.GC.MANHATTAN.${PROJECTNAME} -hold_jid meta.genomic_control -o ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.MANHATTAN.P_GC.log -e ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.MANHATTAN.P_GC.errors -l h_vmem=${QMEMPLOTTER} -l h_rt=${QRUNTIMEPLOTTER} -wd ${METARESULTDIR} ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.MANHATTAN.P_GC.sh
# 
# 	echo "* Producing QQ-plots after genomic control" # P_GC
# 	echo "zcat ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.GC.txt.gz | ${SCRIPTS}/parseTable.pl --col P_GC | tail -n +2 > ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_gc.txt" > ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_gc.sh
# 	echo "zcat ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.GC.txt.gz | ${SCRIPTS}/parseTable.pl --col P_GC,CAF | tail -n +2 > ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_gc_by_CAF.txt" >> ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_gc.sh
# 	echo "${SCRIPTS}/plotter.qq.R --projectdir ${METARESULTDIR} --resultfile ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_gc.txt --outputdir ${METARESULTDIR} --stattype ${STATTYPE} --imageformat ${IMAGEFORMAT}" >> ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_gc.sh
# 	echo "${SCRIPTS}/plotter.qq_by_caf.R --projectdir ${METARESULTDIR} --resultfile ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_gc_by_CAF.txt --outputdir ${METARESULTDIR} --stattype ${STATTYPE} --imageformat ${IMAGEFORMAT}" >> ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_gc.sh
# 	echo "gzip -v ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_gc*.txt" >> ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_gc.sh
# 	qsub -S /bin/bash -N META.GC.QQ.${PROJECTNAME} -hold_jid meta.genomic_control -o ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_gc.log -e ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_gc.errors -l h_vmem=${QMEMPLOTTER} -l h_rt=${QRUNTIMEPLOTTER} -wd ${METARESULTDIR} ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_gc.sh
# 	
# 	echobold "#========================================================================================================"
# 	echobold "#== META-ANALYSIS SUMMARIZER"
# 	echobold "#========================================================================================================"
# 	echobold "#"
# 	echo "Creating meta-analysis summary file..." 
# 	echo "zcat ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.GC.txt.gz | ${SCRIPTS}/parseTable.pl --col VARIANTID,CHR,POS,MINOR,MAJOR,MAF,CODEDALLELE,OTHERALLELE,CAF,N_EFF,Z_SQRTN,P_SQRTN,BETA_FIXED,SE_FIXED,Z_FIXED,P_FIXED,BETA_LOWER_FIXED,BETA_UPPER_FIXED,BETA_GC,SE_GC,Z_GC,P_GC,BETA_RANDOM,SE_RANDOM,Z_RANDOM,P_RANDOM,BETA_LOWER_RANDOM,BETA_UPPER_RANDOM,COCHRANS_Q,DF,P_COCHRANS_Q,I_SQUARED,TAU_SQUARED,DIRECTIONS,GENES_250KB,NEAREST_GENE,NEAREST_GENE_ENSEMBLID,NEAREST_GENE_STRAND,VARIANT_FUNCTION,CAVEAT > ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.summary.txt " > ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.metasum.sh
# 	echo "gzip -fv ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.summary.txt " >> ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.metasum.sh
# 	qsub -S /bin/bash -N METASUM -hold_jid meta.genomic_control -o ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.metasum.log -e ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.metasum.errors -l h_vmem=${QMEMANALYZER} -l h_rt=${QRUNTIMEANALYZER} -wd ${METARESULTDIR} ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.metasum.sh
# 	
# 	echobold "#========================================================================================================"
# 	echobold "#== CLUMPING & REGIONAL ASSOCIATION PLOTTING OF META-ANALYSIS RESULTS -- BETA"
# 	echobold "#========================================================================================================"
# 	echobold "#"
# 	echo "Clumping meta-analysis summary file..." 
# 	echo "${SCRIPTS}/meta.clumper.sh ${CONFIGURATIONFILE} ${METARESULTDIR} " >> ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.metaclumper.sh
# 	qsub -S /bin/bash -N METACLUMP -hold_jid METASUM -o ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.metaclumper.log -e ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.metaclumper.errors -l h_vmem=${QMEMCLUMPER} -l h_rt=${QRUNTIMECLUMPER} -wd ${METARESULTDIR} ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.metaclumper.sh
# 
	echo "Parsing clumped results..." 
	INDEXVARIANTS="${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.summary.0.2.indexvariants.txt"
	if [[ -s ${INDEXVARIANTS} ]] ; then
		echo "There are indexed variants after clumping in [ "$(basename ${INDEXVARIANTS})" ]."
		VARIANTLIST="${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.summary.0.2.indexvariants.txt" 
		while read VARIANTS; do 
			for VARIANT in ${VARIANTS}; do
				echo "* ${VARIANT}"
			done
		done < ${VARIANTLIST}
		echo ""
		while IFS='' read -r VARIANTS || [[ -n "$VARIANTS" ]]; do
					
			LINE=${VARIANTS}
			VARIANT=$(echo "${LINE}" | awk '{ print $1 }')
			echo "* Extracting clumped data for ${VARIANT}..."
			${SCRIPTS}/parseClumps.pl --file ${METARESULTDIR}/meta.results.FABP4.1Gp1.EUR.summary.0.2.clumped.clumped --variant ${VARIANT} > ${METARESULTDIR}/meta.results.FABP4.1Gp1.EUR.summary.0.2.${VARIANT}.txt
			
		done < ${VARIANTLIST}
		
	else
		echo "There are no clumped variants. We will not produce regional associations plots."
	fi


# 	echo "Plotting clumped hits - note: will not plot if there are no clumped hits..."
# 	LDMAP="--pop EUR --build hg19 --source 1000G_March2012"
# 	LOCUSZOOM_SETTINGS="ldColors=\"#595A5C,#4C81BF,#1396D8,#C5D220,#F59D10,red,#9A3480\" showRecomb=TRUE drawMarkerNames=FALSE refsnpTextSize=1.0 showRug=FALSE showAnnot=TRUE showRefsnpAnnot=TRUE showGenes=TRUE clean=TRUE bigDiamond=TRUE refsnpLineWidth=2 axisSize=1.25 axisTextSize=1.25 refsnpLineWidth=1.25 geneFontSize=1.25"
# 	echo "MarkerName P-value" > ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.locuszoom
# 	zcat ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.summary.txt.gz | ${SCRIPTS}/parseTable.pl --col VARIANTID,P_FIXED | tail -n +2 >> ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.locuszoom
# 
# 	INDEXVARIANTS="${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.summary.0.2.indexvariants.txt"
# 	if [[ -s ${INDEXVARIANTS} ]] ; then
# 		echo "There are indexed variants after clumping in [ "$(basename ${INDEXVARIANTS})" ]."
# 		VARIANTLIST="${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.summary.0.2.indexvariants.txt" 
# 		while read VARIANTS; do 
# 			for VARIANT in ${VARIANTS}; do
# 				echo "* ${VARIANT}"
# 			done
# 		done < ${VARIANTLIST}
# 		
# 		### Determine the range
# 		LZRANGE=${LZRANGE}
# 		echo ""
# 		N_VARIANTS=$(cat ${VARIANTLIST} | wc -l)
# 		echo "Number of variants to plot...: ${N_VARIANTS} variants"
# 		echo "Investigating range..........: ${LZRANGE}kb around each of these variants."
# 		
# 		echo ""
# 		echo "* Creating output directory for regional association plots..."
# 		if [ ! -d ${METARESULTDIR}/locuszoom ]; then
# 	  		echo " - making subdirectory ..."
# 	  		mkdir -v ${METARESULTDIR}/locuszoom
# 		else
# 			echo " - subdirectory already there ..."
# 		fi
# 		
# 		### Set the rawdata for the cohort
# 		VARIANTOUTPUTDIR=${METARESULTDIR}/locuszoom
# 
# 		echo ""
# 		while IFS='' read -r VARIANTS || [[ -n "$VARIANTS" ]]; do
# 					
# 			LINE=${VARIANTS}
# 			VARIANT=$(echo "${LINE}" | awk '{ print $1 }')
# 			echo "Starting plotting ${VARIANT} ± ${LZRANGE}kb..."
# 			
# 			echo "* Actual plotting of ${VARIANT}..."
# 			cd ${VARIANTOUTPUTDIR}
# 			${LZv13} --metal ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.locuszoom --markercol MarkerName --delim space --refsnp ${VARIANT} --flank ${LZRANGE}kb ${LDMAP} theme=publication title="${VARIANT} for project: ${PROJECTNAME}" --prefix=${PROJECTNAME}.${REFERENCE}.${POPULATION}.${VARIANT} ${LOCUSZOOM_SETTINGS}
# 			
# 		done < ${VARIANTLIST}
# 		
# 	else
# 		echo "There are no clumped variants. We will not produce regional associations plots."
# 	fi
# 	qsub -S /bin/bash -N Regional.Plotting -hold_jid METACLUMP -o ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.LZ.log -e ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.LZ.errors -l h_vmem=${QMEMANALYZER} -l h_rt=${QRUNTIMEANALYZER} -wd ${METARESULTDIR} ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.LZ.sh

# 	echobold "#========================================================================================================"
# 	echobold "#== FOREST PLOTTER OF META-ANALYSIS RESULTS -- NOT IMPLEMENTED YET"
# 	echobold "#========================================================================================================"
# 	echobold "#"
# 	### CREATE
#   ### Perform R-based meta-analysis to plot; likely the results will slightly differ because of Perl <> R
#	### Plan:
#	### - Extract top hits from clumper
#	### - Extract these variants from each input cohort-meta-file ([cohort].reorder.cdat.gz)
#	### - Make file out of this (beta, se, p, n, name, variantid, hwe, info)
#	### - Input for meta-analysis R script
#	### - R: meta-analysis
#	### - R: forest plot
#	### - R: include heterogeneity
# 
# 	echobold "#========================================================================================================"
# 	echobold "#== ANNOTATING META-ANALYSIS RESULTS "
# 	echobold "#========================================================================================================"
# 	echobold "#"
# 	echo "Many online tools are available, for your convenience, we will create input files for a/several popular one(s)."
# 
# 	echo ""
# 	echo "* Creating input file for FUMAGWAS -- http://fuma.ctglab.nl/snp2gene"
# 	### We will collect the following information for the summarized data.
# 	### Column name -- FUMA column name
# 	### VARIANTID 		-- SNP | snpid | markername | rsID: rsID
# 	### CHR 			-- CHR | chromosome | chrom: chromosome
# 	### POS 			-- BP | pos | position: genomic position (hg19)
# 	### CODEDALLELE 	-- A1 | alt | effect_allele | allele1 | alleleB: affected allele
# 	### OTHERALLELE 	-- A2 | ref | non_effect_allele | allele2 | alleleA: another allele
# 	### P_FIXED 		-- P | pvalue | p-value | p_value | frequentist_add_pvalue | pval: P-value (Mandatory)
# 	### BETA_FIXED 		-- Beta | be: Beta
# 	### SE_FIXED 		-- SE: Standard error
# 	### N_EFF 			-- N: sample size
# 	echo "echo \"SNP CHR BP A1 A2 P Beta SE N\" > ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.forFUMA.txt " > ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.FUMA.sh
# 	echo "zcat ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.summary.txt.gz | ${SCRIPTS}/parseTable.pl --col VARIANTID,CHR,POS,CODEDALLELE,OTHERALLELE,P_FIXED,BETA_FIXED,SE_FIXED,N_EFF | tail -n +2 >> ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.forFUMA.txt " >> ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.FUMA.sh
# 	echo "gzip -vf ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.forFUMA.txt " >> ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.FUMA.sh
# 	qsub -S /bin/bash -N Annot.FUMA -hold_jid METASUM -o ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.FUMA.log -e ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.FUMA.errors -l h_vmem=${QMEMANALYZER} -l h_rt=${QRUNTIMEANALYZER} -wd ${METARESULTDIR} ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.FUMA.sh
# 
#	### THIS DOES NOT SEEM TO WORK -- WEBSITE IS MEGA-SLOW !!!
# 	### echo ""
# 	### echo "* Creating input file for LocusTrack -- https://gump.qimr.edu.au/general/gabrieC/LocusTrack/index.html"
# 	### echo "zcat ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.summary.txt.gz | ${SCRIPTS}/parseTable.pl --col VARIANTID,CHR,POS,P_FIXED > ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.forLocusTrack.txt " > ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.LocusTrack.sh
# 	### echo "gzip -vf ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.forLocusTrack.txt " >> ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.LocusTrack.sh
# 	### qsub -S /bin/bash -N Annot.LocusTrack -hold_jid METASUM -o ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.LocusTrack.log -e ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.LocusTrack.errors -l h_vmem=${QMEMANALYZER} -l h_rt=${QRUNTIMEANALYZER} -wd ${METARESULTDIR} ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.LocusTrack.sh
#	### THIS DOES NOT SEEM TO WORK -- WEBSITE IS MEGA-SLOW !!!
# 
#	### THINK ABOUT THIS ### 
#	### Should I annotate everything? Or just the clumps? Latter seems logical.
# 	### echo ""
# 	### echo "* Creating input file for ANNOVAR -- http://annovar.openbioinformatics.org/en/latest/"
# 	### echo "zcat ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.summary.txt.gz | ${SCRIPTS}/parseTable.pl --col VARIANTID,CHR,POS,P_FIXED > ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.forLocusTrack.txt " > ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.LocusTrack.sh
# 	### echo "gzip -vf ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.forLocusTrack.txt " >> ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.LocusTrack.sh
# 	### qsub -S /bin/bash -N Annot.LocusTrack -hold_jid METASUM -o ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.LocusTrack.log -e ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.LocusTrack.errors -l h_vmem=${QMEMANALYZER} -l h_rt=${QRUNTIMEANALYZER} -wd ${METARESULTDIR} ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.LocusTrack.sh
#	### THINK ABOUT THIS ###
# 
# 	echobold "#========================================================================================================"
# 	echobold "#== GENE-BASED ANALYSIS OF META-ANALYSIS RESULTS USING VEGAS2"
# 	echobold "#========================================================================================================"
# 	echobold "#"
# 	# REQUIRED: VEGAS/VEGAS2 settings.
# 	echo "Creating VEGAS input files..." 
# 	mkdir -v ${METARESULTDIR}/vegas
# 	VEGASDIR=${METARESULTDIR}/vegas
# 	chmod -Rv a+rwx ${VEGASDIR}
# 	echo " - per chromosome..."	
#  	for CHR in $(seq 1 23); do
# 		if [[ $CHR -le 22 ]]; then 
# 			echo "Processing chromosome ${CHR}..."
# 			echo "zcat ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.summary.txt.gz | ${SCRIPTS}/parseTable.pl --col VARIANTID,CHR,P_FIXED | awk ' \$2==${CHR} ' | awk '{ print \$1, \$3 }' | tail -n +2 > ${VEGASDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.chr${CHR}.forVEGAS.txt " > ${VEGASDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.chr${CHR}.runVEGAS.sh
# 	  		echo "$VEGAS2 -G -snpandp ${VEGASDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.chr${CHR}.forVEGAS.txt -custom ${VEGAS2POP} -glist ${VEGAS2GENELIST} -upper ${VEGAS2UPPER} -lower ${VEGAS2LOWER} -chr ${CHR} -out ${VEGASDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.chr${CHR}.fromVEGAS " > ${VEGASDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.chr${CHR}.runVEGAS.sh
# 	  		qsub -S /bin/bash -N VEGAS2.${PROJECTNAME}.chr${CHR} -hold_jid METASUM -o ${VEGASDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.chr${CHR}.runVEGAS.log -e ${VEGASDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.chr${CHR}.runVEGAS.errors -l h_vmem=${QMEMVEGAS} -l h_rt=${QRUNTIMEVEGAS} -wd ${VEGASDIR} ${VEGASDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.chr${CHR}.runVEGAS.sh
# 		elif [[ $CHR -eq 23 ]]; then  
# 			echo "Processing chromosome X..."
# 			echo "zcat ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.summary.txt.gz | ${SCRIPTS}/parseTable.pl --col VARIANTID,CHR,P_FIXED | awk ' \$2==\"X\" ' | awk '{ print \$1, \$3 }' | tail -n +2 > ${VEGASDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.chr${CHR}.forVEGAS.txt " > ${VEGASDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.chr${CHR}.runVEGAS.sh
# 	  		echo "$VEGAS2 -G -snpandp ${VEGASDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.chr${CHR}.forVEGAS.txt -custom ${VEGAS2POP} -glist ${VEGAS2GENELIST} -upper ${VEGAS2UPPER} -lower ${VEGAS2LOWER} -chr ${CHR} -out ${VEGASDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.chr${CHR}.fromVEGAS " > ${VEGASDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.chr${CHR}.runVEGAS.sh
# 	  		qsub -S /bin/bash -N VEGAS2.${PROJECTNAME}.chr${CHR} -hold_jid METASUM -o ${VEGASDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.chr${CHR}.runVEGAS.log -e ${VEGASDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.chr${CHR}.runVEGAS.errors -l h_vmem=${QMEMVEGAS} -l h_rt=${QRUNTIMEVEGAS} -wd ${VEGASDIR} ${VEGASDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.chr${CHR}.runVEGAS.sh
# 		else
# 			echo "*** ERROR *** Something is rotten in the City of Gotham; most likely a typo. Double back, please."	
# 			exit 1
# 		fi
# 
# 	done
# 
# 	echobold "#========================================================================================================"
# 	echobold "#== GENE-BASED ANALYSIS OF META-ANALYSIS RESULTS USING MAGMA"
# 	echobold "#========================================================================================================"
# 	echobold "#"
# 	### REQUIRED: MAGMA settings.
# 	### Head for MAGMA input
# 	### SNP CHR BP P NOBS 
# 	echo "Creating MAGMA input files..." 
# 	mkdir -v ${METARESULTDIR}/magma
# 	MAGMARESULTDIR=${METARESULTDIR}/magma
# 	chmod -Rv a+rwx ${MAGMARESULTDIR}
# 	echo " - whole-genome..."
#  	echo "echo \"SNP CHR BP P NOBS\" > ${MAGMARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.forMAGMA.txt " > ${MAGMARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.runMAGMA.sh
#  	echo "zcat ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.summary.txt.gz | ${SCRIPTS}/parseTable.pl --col VARIANTID,CHR,POS,P_FIXED,N_EFF | tail -n +2 | awk '{ print \$1, \$2, \$3, \$4, int(\$5) }' >> ${MAGMARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.forMAGMA.txt " >> ${MAGMARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.runMAGMA.sh
# 	echo "${MAGMA} --annotate --snp-loc ${MAGMARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.forMAGMA.txt --gene-loc ${MAGMAGENES} --out ${MAGMARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.fromMAGMA.annotated " >> ${MAGMARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.runMAGMA.sh
# 	echo "${MAGMA} --bfile ${MAGMAPOP} synonyms=${MAGMADBSNP} synonym-dup=drop-dup --pval ${MAGMARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.forMAGMA.txt ncol=NOBS --gene-annot ${MAGMARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.fromMAGMA.annotated.genes.annot --out ${MAGMARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.fromMAGMA.genesannotated " >> ${MAGMARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.runMAGMA.sh
#  	echo "${MAGMA} --gene-results ${MAGMARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.fromMAGMA.genesannotated.genes.raw --set-annot ${MAGMAGENESETS} --out ${MAGMARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.fromMAGMA.gsea " >> ${MAGMARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.runMAGMA.sh
#  	qsub -S /bin/bash -N MAGMA.${PROJECTNAME} -hold_jid METASUM -o ${MAGMARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.runMAGMA.log -e ${MAGMARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.runMAGMA.errors -l h_vmem=${QMEMMAGMA} -l h_rt=${QRUNTIMEMAGMA} -wd ${MAGMARESULTDIR} ${MAGMARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.runMAGMA.sh
#  
# 	echobold "#========================================================================================================"
# 	echobold "#== LD SCORE REGRESSION -- currently only the *input* files for LD-Hub are created --"
# 	echobold "#========================================================================================================"
# 	echobold "#"
# 	echo "We will make use of LD-Hub (http://ldsc.broadinstitute.org) to calculate genetic correlation with other traits."
# 	echo ""
# 	echo "Generating LD-Hub input file."
# 	mkdir -v ${METARESULTDIR}/ldscore
# 	LDSCOREDIR=${METARESULTDIR}/ldscore
# 	echo "echo \"snpid A1 A2 Zscore N P-value\" > ${LDSCOREDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.forLDscore.temp " > ${LDSCOREDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.forLDscore.sh
# 	echo "zcat ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.summary.txt.gz | ${SCRIPTS}/parseTable.pl --col VARIANTID,CODEDALLELE,OTHERALLELE,Z_FIXED,N_EFF,P_FIXED | tail -n +2 >> ${LDSCOREDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.forLDscore.temp " >> ${LDSCOREDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.forLDscore.sh
# 	echo "${SCRIPTS}/mergeTables.pl --file1 ${LDSCOREDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.forLDscore.temp --file2 ${RESOURCES}/w_hm3.noMHC.snplist.txt.gz --index snpid --format GZIP2 | awk '{ print \$1, \$4, \$5, \$6, \$7, \$8 }' > ${LDSCOREDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.forLDscore.txt " >> ${LDSCOREDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.forLDscore.sh
# 	### LD-Hub expects a ZIPPED file!!!
# 	echo "cd ${LDSCOREDIR}" >> ${LDSCOREDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.forLDscore.sh
# 	echo "zip -v meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.forLDscore.txt.zip meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.forLDscore.txt" >> ${LDSCOREDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.forLDscore.sh
#  	echo "rm -v ${LDSCOREDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.forLDscore.temp" >> ${LDSCOREDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.forLDscore.sh
# 	qsub -S /bin/bash -N LDSCORE.${PROJECTNAME} -hold_jid METASUM -o ${LDSCOREDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.forLDscore.log -e ${LDSCOREDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.forLDscore.errors -l h_vmem=${QMEMLDSCORE} -l h_rt=${QRUNTIMELDSCORE} -wd ${LDSCOREDIR} ${LDSCOREDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.forLDscore.sh
# 
# 	echobold "#========================================================================================================"
# 	echobold "#== MR BASE -- currently only the *input* files for MR-Base are created --"
# 	echobold "#========================================================================================================"
# 	echobold "#"
# 	### add in p-value selection in configuration
# 	### add in units of exposure
# 	echo "We will make use of MR-Base (http://www.mrbase.org/) to infer causality to other traits."
# 	echo ""
# 	echo "Generating MR-Base input file, based on p-value <= ${MRBASEPVAL}."
# 	mkdir -v ${METARESULTDIR}/mrbase
# 	MRBASEDIR=${METARESULTDIR}/mrbase
# 	echo "echo \"SNP beta se pval effect_allele other_allele eaf samplesize Phenotype\" > ${MRBASEDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.forMRBase.txt " > ${MRBASEDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.forMRBase.sh
# 	echo "zcat ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.summary.txt.gz | ${SCRIPTS}/parseTable.pl --col VARIANTID,BETA_FIXED,SE_FIXED,P_FIXED,CODEDALLELE,OTHERALLELE,CAF,N_EFF > ${MRBASEDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.forMRBase.temp " >> ${MRBASEDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.forMRBase.sh
# 	echo "cat ${MRBASEDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.forMRBase.temp | tail -n +2 | awk '\$4 <= ${MRBASEPVAL}' | awk '{ print \$0, \"${PROJECTNAME}\" }' >> ${MRBASEDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.forMRBase.txt " >> ${MRBASEDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.forMRBase.sh
# 	echo "rm -v ${MRBASEDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.forMRBase.temp " >> ${MRBASEDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.forMRBase.sh
#  	qsub -S /bin/bash -N MRBASE.${PROJECTNAME} -hold_jid METASUM -o ${MRBASEDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.forMRBase.log -e ${MRBASEDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.forMRBase.errors -l h_vmem=${QMEMMRBASE} -l h_rt=${QRUNTIMEMRBASE} -wd ${MRBASEDIR} ${MRBASEDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.forMRBase.sh

	### END of if-else statement for the number of command-line arguments passed ###
fi 

script_copyright_message