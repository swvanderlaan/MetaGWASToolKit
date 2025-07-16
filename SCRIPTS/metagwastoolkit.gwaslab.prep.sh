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
	echoerror ""
	echoerror "An example command would be: run_metagwastoolkit.sh [arg1] [arg2]"
	echoerror "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
 	echo ""
	script_copyright_message
	exit 1
}

echobold "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echobold "          MetaGWASToolKit: A TOOLKIT FOR THE META-ANALYSIS OF GENOME-WIDE ASSOCIATION STUDIES"
echobold "                      --- REFORMAT, PARSE, HARMONIZE, CLEAN ORIGINAL GWAS DATA ---"
echobold ""
echobold "* Version:      v1.6.6"
echobold ""
echobold "* Last update:  2023-09-22"
echobold "* Based on:     MANTEL, as written by Sara Pulit, Jessica van Setten, and Paul de Bakker."
echobold "* Written by:   Sander W. van der Laan | s.w.vanderlaan@gmail.com."
echobold "                Sara Pulit; "
echobold "                Jessica van Setten; "
echobold "                Paul I.W. de Bakker."
echobold "* Testers:      Jessica van Setten; Emma J.A. Smulders; M. Baksi; Mike Puijk."
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
	GWASFILES="$2" # Depends on arg2 -- all the GWAS dataset information; e.g. metagwastoolkit.files.list
	REFERENCE=${REFERENCE} # from configuration file
	REFFREQFILE=${REFFREQFILE} # from configuration file
	POPULATION=${POPULATION} # from configuration file
	REF=${GWASLAB_REF}
	ONLY_QC=${ONLY_QC}
	SELECT_LEADS=${SELECT_LEADS}
	MAKE_FIGURES=${GWASLABPLOT}
	PERFORM_QC=${PERFORM_QC}
	
	##########################################################################################
	### CREATE THE OUTPUT DIRECTORIES
	echo ""
	echo "Checking for the existence of the output directory [ ${OUTPUTDIRNAME} ]."
	if [ ! -d ${PROJECTDIR}/${OUTPUTDIRNAME} ]; then
		echo "> Output directory doesn't exist - Mr. Bourne will create it for you."
		mkdir -v ${PROJECTDIR}/${OUTPUTDIRNAME}
	else
		echo "> Output directory already exists."
		ls -lh ${PROJECTDIR}/${OUTPUTDIRNAME}
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
	
	elif [[ ${REFERENCE} = "1Gp3" ]]; then
	
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

	elif [[ ${REFERENCE} = "1Gp3GONL5" ]]; then
	
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
		while IFS='' read -r GWASCOHORT || [[ -n "$GWASCOHORT" ]]; do # -n check is included in the loop condition, the loop will terminate when it encounters this empty line because -n checks if a string is not empty
			LINE=${GWASCOHORT}
			COHORT=$(echo "${LINE}" | awk '{ print $1 }')
			echo "     * ${COHORT}"
		done < ${GWASFILES}
	  	echo "Raw data directory.............................: "${METAOUTPUT}/${SUBPROJECTDIRNAME}/RAW
	  	echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	  	echo ""	
	
	elif [[ ${REFERENCE} = "HM2" || ${REFERENCE} = "GONL4" || ${REFERENCE} = "GONL5" ]]; then
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
	  	echoerror " - [1Gp3]         1000G (phase 3, release 5c, 20130502 version, b37, hg19)."
	  	echonooption " - [GoNL4]        Genome of the Netherlands, version 4."
	  	echonooption " - [GONL5]        Genome of the Netherlands, version 5."
	  	echoerror " - [1Gp3GONL5]    integrated 1000G phase 3, version 5 and GoNL5."
	  	echonooption "(Opaque: not an option yet)"
	  	echoerror "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
		### The wrong arguments are passed, so we'll exit the script now!
		echo ""
		script_copyright_message
		exit 1
	fi
	
	echobold "#########################################################################################################"
	echobold "### REFORMAT, PARSE, HARMONIZE, CLEAN, AND PLOT ORIGINAL GWAS DATA"
	echobold "#########################################################################################################"
	echobold "#"
	echo ""
	echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echo "Start the reformatting, parsing, harmonizing, and cleaning of each cohort and dataset. "
	echo ""

	### SLURM version
	### Create a file to put the SBATCH IDs for the raw and cleaned file plotting in.
	###This can be used as depenendancy down the road.
	
	
	### Create a file with reference allele frequencies which is neccesary for plotting later.
	### Creates slight bottleneck, this step could be changed to an sbatch command, while making the gwas.plotter.sh steps dependant on this.

	if [ ! -f ${SUBPROJECTDIR}/${REFERENCE}.AF.txt.gz ]; then
		echo "Create file with reference allele frequencies for plotting purposes..."
		zcat ${REFFREQFILE} | ${SCRIPTS}/parseTable.pl --col VariantID,AF > ${SUBPROJECTDIR}/${REFERENCE}.AF.txt
		gzip -fv ${SUBPROJECTDIR}/${REFERENCE}.AF.txt
	fi
	REFAFFILE="${SUBPROJECTDIR}/${REFERENCE}.AF.txt.gz"
		
	while IFS='' read -r GWASCOHORT || [[ -n "$GWASCOHORT" ]]; do # -n check is included in the loop condition, the loop will terminate when it encounters this empty line because -n checks if a string is not empty
		LINE=${GWASCOHORT}
		COHORT=$(echo "${LINE}" | awk '{ print $1 }')
		FILE=$(echo "${LINE}" | awk '{ print $2 }')
		
		BASEFILE=$(basename ${FILE} .txt.gz)
		
		if [ ! -d ${RAWDATA}/${COHORT} ]; then
	  		echo "Making subdirectory for ${COHORT}..."
	  		mkdir -v ${RAWDATA}/${COHORT}
		else
			echo "Directory for ${COHORT} already there."
		fi
		RAWDATACOHORT=${RAWDATA}/${COHORT}
		
		echobold "#========================================================================================================"
		echobold "#== REFORMAT, PARSE, HARMONIZE, CLEANING ORIGINAL GWAS DATA: [ ${COHORT} ]"
		echobold "#========================================================================================================"
		echobold "#"
		echo ""
		### Safely store the ID of the start job
		INIT_ID=$SLURM_JOB_ID
		if [ "$ONLY_QC" == "NO" ]; then
			Rscript ${SCRIPTS}/pipeline.parser.R -p ${ORIGINALS} -d ${FILE} -o ${COHORT}
		fi
		source /hpc/local/Rocky8/dhl_ec/software/mambaforge3/bin/activate gwaslab_env
		python3 ${SCRIPTS}/gwaslab_cohort.py -g ${COHORT} -d ${ORIGINALS} -i ${FILE} -p ${POPULATION} -r ${REF} --qc ${PERFORM_QC} -o ${RAWDATA}/${COHORT} --figures ${MAKE_FIGURES} --onlyqc ${ONLY_QC} --leads ${SELECT_LEADS}
		
	done < ${GWASFILES}

### END of if-else statement for the number of command-line arguments passed ###
fi 

script_copyright_message
