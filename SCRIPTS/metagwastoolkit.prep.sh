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
echobold "* Version:      v1.6.4"
echobold ""
echobold "* Last update:  2023-05-25"
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

	### loading required modules
	### Loading the GWAS-Anaconda3.8 environment
	### You need to also have the conda init lines in your .bash_profile/.bashrc file
	echo "..... > loading required anaconda environment containing the GWAS analyses data..."
	eval "$(conda shell.bash hook)"
	conda activate gwas
	
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
		while IFS='' read -r GWASCOHORT || [[ -n "$GWASCOHORT" ]]; do
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
	
	if [ ! -f ${SUBPROJECTDIR}/plotter_ids.txt ]; then
		echo "Create file to save SLURM-IDs of plotter-step in..."
		touch ${SUBPROJECTDIR}/plotter_ids.txt
		
	else
		echo "The file to save SLURM-IDs of plotter-step in already exists. Removing it to create a new one."
		THISDATESTAMP=$(date +'+%Y%m%d_%H%M%S')
		ls -lh ${SUBPROJECTDIR}/plotter_ids.txt
		mv -v ${SUBPROJECTDIR}/plotter_ids.txt ${SUBPROJECTDIR}/plotter_ids.${THISDATESTAMP}.txt
		touch ${SUBPROJECTDIR}/plotter_ids.txt
	fi

	### Create a file with reference allele frequencies which is neccesary for plotting later.
	### Creates slight bottleneck, this step could be changed to an sbatch command, while making the gwas.plotter.sh steps dependant on this.

	if [ ! -f ${SUBPROJECTDIR}/${REFERENCE}.AF.txt.gz ]; then
		echo "Create file with reference allele frequencies for plotting purposes..."
		zcat ${REFFREQFILE} | $SCRIPTS/parseTable.pl --col VariantID,AF > ${SUBPROJECTDIR}/${REFERENCE}.AF.txt
		gzip -fv ${SUBPROJECTDIR}/${REFERENCE}.AF.txt
	fi
	REFAFFILE="${SUBPROJECTDIR}/${REFERENCE}.AF.txt.gz"
		
	while IFS='' read -r GWASCOHORT || [[ -n "$GWASCOHORT" ]]; do
		LINE=${GWASCOHORT}
		COHORT=$(echo "${LINE}" | awk '{ print $1 }')
		FILE=$(echo "${LINE}" | awk '{ print $2 }')
		VARIANTYPE=$(echo "${LINE}" | awk '{ print $3 }')
		
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
		echo "* Chopping up GWAS summary statistics into chunks of ${CHUNKSIZE} variants."
		echo "  This is done to enable parallelisation and gain speed/time in an array-job."
		
		### Safely store the ID of the start job
		INIT_ID=$SLURM_JOB_ID

		### Split up the file in increments of 1000K -- note: the period at the end of '${BASEFILE}' is a separator character
		zcat ${ORIGINALS}/${FILE} | tail -n +2 | split -a 3 -l ${CHUNKSIZE} - ${RAWDATACOHORT}/${BASEFILE}.
				
		### Adding headers -- this is ABSOLUTELY required for the 'gwas.parser.R'.
		for SPLITFILE in ${RAWDATACOHORT}/${BASEFILE}.*; do
			### Create a textfile so you can use this as input in the arrrayjob
			printf "${SPLITFILE}\n" >> ${RAWDATACOHORT}/splitfiles.txt

			### determine basename of the splitfile
			BASESPLITFILE=$(basename ${SPLITFILE} .pdat)
			echo ""
			echo "* Prepping split chunk: [ ${BASESPLITFILE} ]..."
			echo ""
			echo " - heading a temporary file." 
			zcat ${ORIGINALS}/${FILE} | head -1 > ${RAWDATACOHORT}/tmp_file
			echo " - adding the split data to the temporary file."
			cat ${SPLITFILE} >> ${RAWDATACOHORT}/tmp_file
			echo " - renaming the temporary file."
			mv -fv ${RAWDATACOHORT}/tmp_file ${SPLITFILE}
		done 

		### Call an array job for all the different splitfiles
		NFILES=$(wc -l ${RAWDATACOHORT}/splitfiles.txt | awk '{ print $1 }') # Count the number of lines in the textfile
		NFILES=$((NFILES-1)) # Decrement by one so the last emtpy line is not counted
		splitfiles_parser_harm_cleaner_ID=$(sbatch --parsable --job-name=splitfiles_parser_harm_cleaner --dependency=afterany:${INIT_ID} --array=0-${NFILES} --export=RAWDATACOHORT=${RAWDATACOHORT},COHORT=${COHORT},FILE=${FILE},VARIANTYPE=${VARIANTYPE},INIT_ID=${INIT_ID} -o ${RAWDATACOHORT}/gwas.parser_harm_cleaner.array.%a.log --time=${QRUNTIMERUNNER} --error ${RAWDATACOHORT}/gwas.parser_harm_cleaner.array.%a.errors ${SCRIPTS}/metagwastoolkit.splitfiles.HPC.sh ${CONFIGURATIONFILE})
		
		echobold "#========================================================================================================"
		echobold "#== WRAPPING THE REFORMATTED GWAS DATA: [ ${COHORT} ]"
		echobold "#========================================================================================================"
		echobold "#"
		echo ""
		echo "* Wrapping up parsed and harmonized data for cohort ${COHORT}..."

		### FOR DEBUGGING LOCALLY -- Mac OS X
		### ${SCRIPTS}/gwas.wrapper.sh ${RAWDATACOHORT} ${COHORT} ${BASEFILE} ${VARIANTYPE}

		### Get all the CLEANER ID's to set dependancy, by looping over all lines in the file
		### IS THIS NEEDED?
		### if [ -f ${SUBPROJECTDIRNAME}/cleaner_ids.txt ]; then
		### 	CLEANER_IDS="" # Init a variable
		### 	while read line; do    
		### 		CLEANER_IDS="${CLEANER_IDS},${line}" # Add every ID with a comma
		### 	done < ${RAWDATACOHORT}/cleaner_ids.txt
		### 	CLEANER_IDS="${CLEANER_IDS:1}" # Remove the first character (',')
		### 	CLEANER_IDS_D="--dependency=afterany:${CLEANER_IDS}" # Create a variable which can be used as dependancy
		### else 
		### 	echo "Dependancy file does not exist, assuming the PLOTTER jobs finished."
		### 	CLEANER_IDS_D="" # Empty variable so there is no dependancy
		### fi

		### FOR DEBUGGING 
		### CLEANER_ID=$(head -1 ${RAWCOHORTDATA}/cleaner_ids.txt)
		### echo "$CLEANER_ID"
		### CLEANER_IDS=""
		### echo ${RAWDATACOHORT}/cleaner_ids.txt >> "${CLEANER_IDS}" 
		### read CLEANER_IDS < ${RAWDATACOHORT}/cleaner_ids.txt

		### OLD QSUB version
		### qsub -S /bin/bash -N gwas.wrapper.${BASEFILE} -hold_jid gwas.cleaner.${BASEFILE} -o ${RAWDATACOHORT}/gwas.wrapper.${BASEFILE}.log -e ${RAWDATACOHORT}/gwas.wrapper.${BASEFILE}.errors -l h_rt=${QRUNTIMEWRAPPER} -l h_vmem=${QMEMWRAPPER} -M ${QMAIL} -m ${QMAILOPTIONS} -cwd ${RAWDATACOHORT}/gwas.wrapper.${BASEFILE}.sh

		### SLURM version
 		printf "#!/bin/bash\n${SCRIPTS}/gwas.wrapper.sh ${RAWDATACOHORT} ${COHORT} ${BASEFILE} ${VARIANTYPE}" > ${RAWDATACOHORT}/gwas.wrapper.${BASEFILE}.sh
		WRAPPER_ID=$(sbatch --parsable --job-name=gwas.wrapper.${BASEFILE} --dependency=afterany:${splitfiles_parser_harm_cleaner_ID} -o ${RAWDATACOHORT}/gwas.wrapper.${BASEFILE}.log --error ${RAWDATACOHORT}/gwas.wrapper.${BASEFILE}.errors --time=${QRUNTIMEWRAPPER} --mem=${QMEMWRAPPER} --mail-user=${QMAIL} --mail-type=${QMAILOPTIONS} ${RAWDATACOHORT}/gwas.wrapper.${BASEFILE}.sh)

		echobold "#========================================================================================================"
		echobold "#== PLOTTING THE REFORMATTED & WRAPPED GWAS DATA: [ ${COHORT} ]"
		echobold "#========================================================================================================"
		echobold "#"

		#### Add in functions based on Winkler et al. (frequency plot among others) for 
		#### both types of data, i.e. raw and cleaned.
		echo ""
		echo "* Plotting harmonized data for cohort [ ${COHORT} ]..."
		DATAFORMAT="RAW"
		IMAGEFORMAT=${IMAGEFORMATQC}

		### FOR DEBUGGING LOCALLY -- Mac OS X
		### ${SCRIPTS}/gwas.plotter.sh ${CONFIGURATIONFILE} ${RAWDATACOHORT} ${COHORT} ${DATAFORMAT} ${IMAGEFORMAT} ${QRUNTIMEPLOTTER} ${QMEMPLOTTER} ${REFAFFILE}
 		
 		### OLD QSUB version
 		### qsub -S /bin/bash -N gwas.plotter -hold_jid gwas.wrapper.${BASEFILE} -o ${RAWDATACOHORT}/gwas.plotter.${BASEFILE}.raw.log -e ${RAWDATACOHORT}/gwas.plotter.${BASEFILE}.raw.errors -l h_rt=${QRUNTIMEPLOTTER} -l h_vmem=${QMEMPLOTTER} -M ${QMAIL} -m ${QMAILOPTIONS} -cwd ${RAWDATACOHORT}/gwas.plotter.${BASEFILE}.raw.sh

		### SLURM version
 		printf "#!/bin/bash\n${SCRIPTS}/gwas.plotter.sh ${CONFIGURATIONFILE} ${RAWDATACOHORT} ${COHORT} ${DATAFORMAT} ${IMAGEFORMAT} ${QRUNTIMEPLOTTER} ${QMEMPLOTTER} ${TITLEPLOT} ${REFAFFILE}" > ${RAWDATACOHORT}/gwas.plotter.${BASEFILE}.raw.sh
		PLOTTER_ID=$(sbatch --parsable --job-name=gwas.plotter --dependency=afterany:${WRAPPER_ID} -o ${RAWDATACOHORT}/gwas.plotter.${BASEFILE}.raw.log --error ${RAWDATACOHORT}/gwas.plotter.${BASEFILE}.raw.errors --time=${QRUNTIMEPLOTTER} --mem=${QMEMPLOTTER} --mail-user=${QMAIL} --mail-type=${QMAILOPTIONS} ${RAWDATACOHORT}/gwas.plotter.${BASEFILE}.raw.sh)
		
		echobold "#========================================================================================================"
		echobold "#== PLOTTING THE CLEANED GWAS DATA: [ ${COHORT} ]"
		echobold "#========================================================================================================"
		echobold "#"
		echo ""
		echo "* Plotting the cleaned and harmonized data for cohort [ ${COHORT} ]..."
		DATAFORMAT="QC"
		IMAGEFORMAT=${IMAGEFORMATQC}
		
		### FOR DEBUGGING LOCALLY -- Mac OS X
		### ${SCRIPTS}/gwas.plotter.sh ${CONFIGURATIONFILE} ${RAWDATACOHORT} ${COHORT} ${DATAFORMAT} ${IMAGEFORMAT} ${QRUNTIMEPLOTTER} ${QMEMPLOTTER} ${REFAFFILE}
 		
 		### OLD QSUB version
 		### qsub -S /bin/bash -N gwas.plotter -hold_jid gwas.wrapper.${BASEFILE} -o ${RAWDATACOHORT}/gwas.plotter.${BASEFILE}.qc.log -e ${RAWDATACOHORT}/gwas.plotter.${BASEFILE}.qc.errors -l h_rt=${QRUNTIMEPLOTTER} -l h_vmem=${QMEMPLOTTER} -M ${QMAIL} -m ${QMAILOPTIONS} -cwd ${RAWDATACOHORT}/gwas.plotter.${BASEFILE}.qc.sh

		### SLURM version
		printf "#!/bin/bash\n${SCRIPTS}/gwas.plotter.sh ${CONFIGURATIONFILE} ${RAWDATACOHORT} ${COHORT} ${DATAFORMAT} ${IMAGEFORMAT} ${QRUNTIMEPLOTTER} ${QMEMPLOTTER} ${TITLEPLOT} ${REFAFFILE}" > ${RAWDATACOHORT}/gwas.plotter.${BASEFILE}.qc.sh
		PLOTTER_ID_CLEAN=$(sbatch --parsable --job-name=gwas.plotter.qc --dependency=afterany:${WRAPPER_ID} -o ${RAWDATACOHORT}/gwas.plotter.${BASEFILE}.qc.log --error ${RAWDATACOHORT}/gwas.plotter.${BASEFILE}.qc.errors --time=${QRUNTIMEPLOTTER} --mem=${QMEMPLOTTER} --mail-user=${QMAIL} --mail-type=${QMAILOPTIONS} ${RAWDATACOHORT}/gwas.plotter.${BASEFILE}.qc.sh)
				
		### SLURM version
		### Create a file to put the SBATCH IDs for the raw and cleaned file plotting in.
		### This can be used as depenendency down the road.
		echo "${PLOTTER_ID}" >>  ${SUBPROJECTDIR}/plotter_ids.txt
		echo "${PLOTTER_ID_CLEAN}" >>  ${SUBPROJECTDIR}/plotter_ids.txt
		
	done < ${GWASFILES}

### END of if-else statement for the number of command-line arguments passed ###
fi 

script_copyright_message