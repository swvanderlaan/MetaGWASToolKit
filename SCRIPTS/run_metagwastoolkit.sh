#!/bin/bash

### Creating display functions
### Setting colouring
NONE='\033[00m'
BOLD='\033[1m'
OPAQUE='\033[2m'
FLASHING='\033[5m'
UNDERLINE='\033[4m'

RED='\033[01;31m'
GREEN='\033[01;32m'
YELLOW='\033[01;33m'
PURPLE='\033[01;35m'
CYAN='\033[01;36m'
WHITE='\033[01;37m'

function echobold { #'echobold' is the function name
    echo -e "${BOLD}${1}${NONE}" # this is whatever the function needs to execute, note ${1} is the text for echo
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
	echoerror "- Argument #3 is reference to use [1Gp1/1Gp3] for the QC and analysis."
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
echobold "* Version:      v1.4.0"
echobold ""
echobold "* Last update:  2016-12-07"
echobold "* Based on:     MANTEL, as written by Sara Pulit, Jessica van Setten, and Paul de Bakker."
echobold "* Written by:   Sander W. van der Laan | UMC Utrecht | s.w.vanderlaan-2@umcutrecht.nl."
echobold "                Sara Pulit | UMC Utrecht | s.l.pulit@umcutrecht.nl; "
echobold "                Jessica van Setten | UMC Utrecht | j.vansetten@umcutrecht.nl; "
echobold "                Paul I.W. de Bakker | UMC Utrecht | p.i.w.debakker-2@umcutrecht.nl."
echobold "* Testers:      Jessica van Setten | UMC Utrecht | j.vansetten@umcutrecht.nl."
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
if [[ $# -lt 3 ]]; then 
	echo ""
	echoerror "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echoerrorflash "               *** Oh, computer says no! Number of arguments found "$#". ***"
	echoerror "You must supply [3] arguments when running *** MetaGWASToolKit ***!"
	script_arguments_error
else
	echo "These are the "$#" arguments that passed:"
	echo "The configuration file.................: "$(basename ${1}) # argument 1
	echo "The list of GWAS files.................: "$(basename ${2}) # argument 2
	echo "The reference for QC and analysis is...: "${3} # argument 3
	
	### SETTING DIRECTORIES (from configuration file).
	# Loading the configuration file (please refer to the MetaGWASToolKit-Manual for specifications of this file). 
	source ${1} # Depends on arg1.
	
	CONFIGURATIONFILE=${1} # Depends on arg1 -- but also on where it resides!!!
	SOFTWARE=${SOFTWARE} # from configuration file
	
	# Where MetaGWASToolKit resides
	METAGWASTOOLKIT=${METAGWASTOOLKITDIR} # from configuration file
	SCRIPTS=${METAGWASTOOLKIT}/SCRIPTS
	RESOURCES=${METAGWASTOOLKIT}/RESOURCES
	
	# Project information
	ORIGINALS=${DATA_UPLOAD_FREEZE} # from configuration file
	PROJECTDIR=${PROJECTDIR} # from configuration file
	GWASFILES=${2} # Depends on arg2 -- all the GWAS dataset information
	REFERENCE=${3} # Depends on arg3 -- the reference to use
	
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
	
	# - run memory
	QMEM=${QMEM} # from configuration file
	QMEMPARSER=${QMEMPARSER} # from configuration file
	QMEMHARMONIZE=${QMEMHARMONIZE} # from configuration file
	QMEMWRAPPER=${QMEMWRAPPER} # from configuration file
	QMEMCLEANER=${QMEMCLEANER} # from configuration file
	QMEMPLOTTER=${QMEMPLOTTER} # from configuration file
	
	#- mailing
	QMAIL=${QMAIL} # from configuration file
	QMAILOPTIONS=${QMAILOPTIONS} # from configuration file
	
	### SETTING THE AVAILABLE REFERENCES -- could also go to the source file
	HM2=${RESOURCES}/HM2_r2v22_b36.INFO.txt.gz # not available yet > version 2
	G1000P1=${RESOURCES}/1000Gp1v3_20101123_integrated_ALL_snv_indels_sv.INFO.txt.gz
	G1000P3=${RESOURCES}/1000Gp3v5_20130502_integrated_ALL_snv_indels_sv.INFO.txt.gz
	GONL4=${RESOURCES}/GoNL4.INFO.txt.gz # not available yet > version 2
	GONL5=${RESOURCES}/GoNL5.INFO.txt.gz # not available yet > version 2.5
	G1000P3GONL5=${RESOURCES}/1000Gp3v5_GoNL5.INFO.txt.gz # not available yet > version 2.5
	
	##########################################################################################
	### CREATE THE OUTPUT DIRECTORY
	echo ""
	METAOUTPUT=${OUTPUTDIR}
	
	echo "Checking for the existence of the output directory [ ${METAOUTPUT} ]."
	if [ ! -d ${PROJECTDIR}/${METAOUTPUT} ]; then
		echo "> Output directory doesn't exist - Mr. Bourne will create it for you."
		mkdir -v ${PROJECTDIR}/${METAOUTPUT}
	else
		echo "> Output directory already exists."
	fi
	
	##########################################################################################
	### SETTING UP THE OUTPUT AND RAWDATA DIRECTORIES
	echo ""
	### Making raw data directories, unless they already exist. Depends on arg2.
	if [[ ${REFERENCE} = "1Gp1" || ${REFERENCE} = "1Gp3" ]]; then
		
		echo "Checking for the existence of the raw data directory [ ${METAOUTPUT}/RAW ]."
		if [ ! -d ${PROJECTDIR}/${METAOUTPUT}/RAW ]; then
	  		echo "> Raw data directory doesn't exist - Mr. Bourne will create it for you."
	  		mkdir -v ${PROJECTDIR}/${METAOUTPUT}/RAW
	  	else
	  		echo "> Raw data directory already exists."
	  	fi
	  	
	  	# Setting directory for raw data.
		RAWDATA=${PROJECTDIR}/${METAOUTPUT}/RAW
	  		
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
	  		echo "Original data directory........................: "${ORIGINALS}
	  		echo "We are processing these cohort(s)..............:"
			while IFS='' read -r GWASCOHORT || [[ -n "$GWASCOHORT" ]]; do
				LINE=${GWASCOHORT}
				COHORT=$(echo "${LINE}" | awk '{ print $1 }')
				echo "     * ${COHORT}"
			done < ${GWASFILES}
	  		echo "Raw data directory.............................: "${RAWDATA}
	  		echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	  		echo ""
	
	elif [[ ${REFERENCE} = "HM2" || ${REFERENCE} = "GONL4"  || ${REFERENCE} = "GONL5"  || ${REFERENCE} = "1Gp3GONL5" ]]; then
			echoerrornooption "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	  		echoerrornooption ""
	  		echoerrorflashnooption "               *** Oh, computer says no! This option is not available yet. ***"
	  		echoerrornooption "Unfortunately using ${REFERENCE} as a reference is not possible yet. Currently only 1Gp1 and 1Gp3 are "
	  		echoerrornooption "available."
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
	  		echoerror " - [1Gp3]         1000G (phase 3, release 5, 20130502 version, b37, hg19)."
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
	
	##########################################################################################
	### REFORMAT, PARSE, HARMONIZE, CLEAN, AND PLOT ORIGINAL GWAS DATA
	##########################################################################################
	#
	echo ""
	echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echo "Start the reformatting, parsing, harmonizing, and cleaning of each cohort and dataset. "
	echo ""
	
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
		
		##########################################################################################
		### REFORMAT, PARSE, AND HARMONIZE ORIGINAL GWAS DATA
		##########################################################################################
		#
		echo ""
		echo "* Chopping up GWAS summary statistics into chunks of 100K variants -- for parallelisation and speedgain..."
		
		### Split up the file in increments of 1000K -- note: the period at the end of '${BASEFILE}' is a separator character
		zcat ${ORIGINALS}/${FILE} | tail -n +2 | split -l 100000 - ${RAWDATACOHORT}/${BASEFILE}.
		
		### Adding headers -- this is ABSOLUTELY required for the 'gwas.parser.R'.
		for SPLITFILE in ${RAWDATACOHORT}/${BASEFILE}.*; do
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
			
			echo ""
			echo "* Parsing data for cohort ${COHORT} [ file: ${BASESPLITFILE} ]."
			### FOR DEBUGGING LOCALLY -- Mac OS X
			### Rscript ${SCRIPTS}/gwas.parser.R -p ${PROJECTDIR} -d ${SPLITFILE} -o ${METAOUTPUT}/RAW/${COHORT} 
			echo "Rscript ${SCRIPTS}/gwas.parser.R -p ${PROJECTDIR} -d ${SPLITFILE} -o ${METAOUTPUT}/RAW/${COHORT} " > ${RAWDATACOHORT}/gwas.parser.${BASESPLITFILE}.sh
			qsub -S /bin/bash -N gwas.parser.${BASESPLITFILE} -hold_jid run_metagwastoolkit -o ${RAWDATACOHORT}/gwas.parser.${BASESPLITFILE}.log -e ${RAWDATACOHORT}/gwas.parser.${BASESPLITFILE}.errors -l h_rt=${QRUNTIMEPARSER} -l h_vmem=${QMEMPARSER} -M ${QMAIL} -m ${QMAILOPTIONS} -cwd ${RAWDATACOHORT}/gwas.parser.${BASESPLITFILE}.sh
			
			echo ""
			echo "* Harmonising parsed [ ${BASESPLITFILE} ] file for cohort ${COHORT} with ${REFERENCE}..."
			### FOR DEBUGGING LOCALLY -- Mac OS X
			### module load python
			### ${SCRIPTS}/gwas2ref.harmonizer.py -g ${SPLITFILE}.pdat -r ${G1000P1} -i ${VARIANTYPE} -o ${SPLITFILE}.ref.pdat
			echo "module load python" > ${RAWDATACOHORT}/gwas2ref.harmonizer.${BASESPLITFILE}.sh
			echo "${SCRIPTS}/gwas2ref.harmonizer.py -g ${SPLITFILE}.pdat -r ${G1000P1} -i ${VARIANTYPE} -o ${SPLITFILE}.ref.pdat" >> ${RAWDATACOHORT}/gwas2ref.harmonizer.${BASESPLITFILE}.sh
			qsub -S /bin/bash -N gwas2ref.harmonizer.${BASEFILE} -hold_jid gwas.parser.${BASESPLITFILE} -o ${RAWDATACOHORT}/gwas2ref.harmonizer.${BASESPLITFILE}.log -e ${RAWDATACOHORT}/gwas2ref.harmonizer.${BASESPLITFILE}.errors -l h_rt=${QRUNTIMEHARMONIZE} -l h_vmem=${QMEMHARMONIZE} -M ${QMAIL} -m ${QMAILOPTIONS} -cwd ${RAWDATACOHORT}/gwas2ref.harmonizer.${BASESPLITFILE}.sh
		
		done

		##########################################################################################
		### WRAPPING THE REFORMATTED GWAS DATA
		##########################################################################################
		#

		echo ""
		echo "* Wrapping up parsed and harmonized data for cohort ${COHORT}..."
		### FOR DEBUGGING LOCALLY -- Mac OS X
		### ${SCRIPTS}/gwas.wrapper.sh ${RAWDATACOHORT} ${COHORT} ${BASEFILE} ${VARIANTYPE}
		echo "${SCRIPTS}/gwas.wrapper.sh ${RAWDATACOHORT} ${COHORT} ${BASEFILE} ${VARIANTYPE}" >> ${RAWDATACOHORT}/gwas.wrapper.${BASEFILE}.sh
		qsub -S /bin/bash -N gwas.wrapper.${BASEFILE} -hold_jid gwas2ref.harmonizer.${BASEFILE} -o ${RAWDATACOHORT}/gwas.wrapper.${BASEFILE}.log -e ${RAWDATACOHORT}/gwas.wrapper.${BASEFILE}.errors -l h_rt=${QRUNTIMEWRAPPER} -l h_vmem=${QMEMWRAPPER} -M ${QMAIL} -m ${QMAILOPTIONS} -cwd ${RAWDATACOHORT}/gwas.wrapper.${BASEFILE}.sh
		
		##########################################################################################
		### CLEANING UP THE REFORMATTED & WRAPPED GWAS DATA
		##########################################################################################
		#
		
		### MAKE A CLEANER SCRIPT TO REMOVE ALL THE INTERMEDIATE SPLITTED FILES
		# arguments: inputdir, outputdir, cohort, MAF, MAC, HWE, INFO, BETA, SE
		# - source configuration file with cleaner settings
	
		echo ""
		echo "* Cleaning harmonized data for cohort ${COHORT} using the specified settings..."
		### FOR DEBUGGING LOCALLY -- Mac OS X
		### ${SCRIPTS}/gwas.cleaner.sh ${CONFIGURATIONFILE} ${RAWDATACOHORT} ${COHORT} ${BASEFILE} ${VARIANTYPE}	
		echo "${SCRIPTS}/gwas.cleaner.sh ${CONFIGURATIONFILE} ${RAWDATACOHORT} ${COHORT} ${BASEFILE} ${VARIANTYPE}" >> ${RAWDATACOHORT}/gwas.cleaner.${BASEFILE}.sh
		qsub -S /bin/bash -N gwas.cleaner.${BASEFILE} -hold_jid gwas.wrapper.${BASEFILE} -o ${RAWDATACOHORT}/gwas.cleaner.${BASEFILE}.log -e ${RAWDATACOHORT}/gwas.cleaner.${BASEFILE}.errors -l h_rt=${QRUNTIMECLEANER} -l h_vmem=${QMEMCLEANER} -M ${QMAIL} -m ${QMAILOPTIONS} -cwd ${RAWDATACOHORT}/gwas.cleaner.${BASEFILE}.sh

	
		##########################################################################################
		### PLOTTING THE REFORMATTED & WRAPPED GWAS DATA
		##########################################################################################
		#

		echo ""
		echo "* Plotting harmonized data for cohort [ ${COHORT} ]..."
		DATAFORMAT="RAW"
		IMAGEFORMAT="PNG"
		### FOR DEBUGGING LOCALLY -- Mac OS X
		### ${SCRIPTS}/gwas.plotter.sh ${CONFIGURATIONFILE} ${RAWDATACOHORT} ${COHORT} ${DATAFORMAT} ${IMAGEFORMAT} ${QRUNTIMEPLOTTER} ${QMEMPLOTTER}
 		echo "${SCRIPTS}/gwas.plotter.sh ${CONFIGURATIONFILE} ${RAWDATACOHORT} ${COHORT} ${DATAFORMAT} ${IMAGEFORMAT} ${QRUNTIMEPLOTTER} ${QMEMPLOTTER}" >> ${RAWDATACOHORT}/gwas.plotter.${BASEFILE}.raw.sh
 		qsub -S /bin/bash -N gwas.plotter.${BASEFILE}.raw -hold_jid gwas.wrapper.${BASEFILE} -o ${RAWDATACOHORT}/gwas.plotter.${BASEFILE}.raw.log -e ${RAWDATACOHORT}/gwas.plotter.${BASEFILE}.raw.errors -l h_rt=${QRUNTIMEPLOTTER} -l h_vmem=${QMEMPLOTTER} -M ${QMAIL} -m ${QMAILOPTIONS} -cwd ${RAWDATACOHORT}/gwas.plotter.${BASEFILE}.raw.sh

		##########################################################################################
		### PLOTTING THE CLEANED GWAS DATA
		##########################################################################################
		#

		echo ""
		echo "* Plotting the cleaned and harmonized data for cohort [ ${COHORT} ]..."
		DATAFORMAT="QC"
		IMAGEFORMAT="PNG"
		### FOR DEBUGGING LOCALLY -- Mac OS X
		### ${SCRIPTS}/gwas.plotter.sh ${CONFIGURATIONFILE} ${RAWDATACOHORT} ${COHORT} ${DATAFORMAT} ${IMAGEFORMAT} ${QRUNTIMEPLOTTER} ${QMEMPLOTTER}	
 		echo "${SCRIPTS}/gwas.plotter.sh ${CONFIGURATIONFILE} ${RAWDATACOHORT} ${COHORT} ${DATAFORMAT} ${IMAGEFORMAT} ${QRUNTIMEPLOTTER} ${QMEMPLOTTER}" >> ${RAWDATACOHORT}/gwas.plotter.${BASEFILE}.qc.sh
 		qsub -S /bin/bash -N gwas.plotter.${BASEFILE}.qc -hold_jid gwas.cleaner.${BASEFILE} -o ${RAWDATACOHORT}/gwas.plotter.${BASEFILE}.qc.log -e ${RAWDATACOHORT}/gwas.plotter.${BASEFILE}.qc.errors -l h_rt=${QRUNTIMEPLOTTER} -l h_vmem=${QMEMPLOTTER} -M ${QMAIL} -m ${QMAILOPTIONS} -cwd ${RAWDATACOHORT}/gwas.plotter.${BASEFILE}.qc.sh

	
	done < ${GWASFILES}
	
	
	##############################################################################
	#### META-ANALYSIS
	##############################################################################
	#
	#### Collect all unique variants across all GWAS cohorts
	#echo ""
	#echo "We will collect all unique variants across all GWAS cohorts included."
	#for i in `seq 1 3`; do # you can change the number of models to collect data from by changing `seq 1 3`.
	#	echo "Making output directories."
	#	if [ ! -d $METAOUTPUT/MODEL$i/OUTPUT ]; then
	#		mkdir -v $METAOUTPUT/MODEL$i/OUTPUT
	#	else
	#		echo "Directory for model$i already there."
	#	fi
	#	tail -n +2 $METAOUTPUT/MODEL$i/*.cdat | awk ' { print $1 } ' >> $METAOUTPUT/MODEL$i/OUTPUT/foo
	#	$SCRIPTS/uniquefy.pl $METAOUTPUT/MODEL$i/OUTPUT/foo > $METAOUTPUT/MODEL$i/OUTPUT/bar
	#	echo "SNP" > $METAOUTPUT/MODEL$i/OUTPUT/all_variants.txt
	#	cat $METAOUTPUT/MODEL$i/OUTPUT/bar >> $METAOUTPUT/MODEL$i/OUTPUT/all_variants.txt
	#	#rm -v $METAOUTPUT/MODEL$i/OUTPUT/foo $METAOUTPUT/MODEL$i/OUTPUT/bar; 
	#	# chop up the SNP list into chunks of 100K SNPs -- for parallelisation [we will later use this file as input for mantel.pl '--snps']
	#	tail -n +2 $METAOUTPUT/MODEL$i/OUTPUT/all_variants.txt | split -d -a 3 -l 125000 - $METAOUTPUT/MODEL$i/OUTPUT/all_variants.txt.
	#done
	#
	#### Reorder all 
	#echo ""
	#echo "Preparing files for meta-analysis by re-ordering GWAS cohort data files by generic variant list."
	#for i in `seq 1 3`; do
	#	for j in $( ls $METAOUTPUT/MODEL$i/*.cdat ); do
	#		rawcohortpathname=$j
	#		rawcohortname=${rawcohortpathname%.*} # removes the extension
	#		cohortname=${rawcohortname##*/} #removes everything before the /
	#		echo $cohortname
	#		$SCRIPTS/merge_tables.pl --file1 $j --file2 $METAOUTPUT/MODEL$i/OUTPUT/all_variants.txt --index SNP > $METAOUTPUT/MODEL$i/OUTPUT/$cohortname.rcdat
	#		# chop up each GWAS result into chunks of 100K SNPs -- for parallelisation
	#		tail -n +2 $METAOUTPUT/MODEL$i/OUTPUT/$cohortname.rcdat | split -d -a 3 -l 125000 - $METAOUTPUT/MODEL$i/OUTPUT/$cohortname.rcdat.
	#		
	#		# we probably need to get the headers back on everyone of those .rcdat.* files?
	#		# how to do this in bash???
	#		#for k in ( $METAOUTPUT/MODEL$i/OUTPUT/$cohortname.rcdat.* )
	#		#	RAWEXT=$k
	#		#	EXT=${RAWEXT%.*} # removes the extension
	#		#	head -1 $METAOUTPUT/MODEL$i/$cohortname.rcdat | awk ' { printf("SNP"); for (l=2;l<=NF;l++) { printf(" %s", $l); } printf("\n"); } ' > $k:r:r.tmp.$EXT
	#		#	echo "SNP CHR POS BETA SE P CA A2 CAF RATIO MAF MAC N STRAND" > $k:r:r.tmp.$EXT
	#		#	cat $k >> $k:r:r.tmp.$EXT; 
	#		#done
	#
	#	done
	#done
	#
	#### collect all dbSNP129 SNPs
	##cat $OUT/*.129.txt | awk ' { print $1 } ' | grep -v SNP > $OUT/foo
	##$SCRIPTS/uniquefy.pl $OUT/foo > $OUT/all_129_snps.txt
	##rm $OUT/foo
	#
	##foreach i ( $OUT/cohort1.129.txt $OUT/cohort2.129.txt $OUT/cohort3.129.txt )
	#
	#	#echo $i
	#
	#	### prepare files for meta-analysis by re-ordering all study-specific files by the generic SNP list
	#	#$SCRIPTS/merge_tables.pl --file1 $i --file2 $OUT/all_129_snps.txt --index Build129 > $i:r.all.txt
	#	#tail -n +2 $i:r.all.txt | split -d -a 3 -l 125000 - $i:r.all.txt.
	#
	#	#foreach j ( $i:r.all.txt.* )
	#		#set ext=$j:e
	#		#head -1 $i:r.all.txt | awk ' { printf("SNP"); for (i=2;i<=NF;i++) { printf(" %s", $i); } printf("\n"); } ' > $j:r:r.tmp.$ext
	#		#echo "SNP CHR POS BETA SE PVAL CA A2 CAF RATIO" > $j:r:r.tmp.$ext
	#		#cat $j >> $j:r:r.tmp.$ext
	#	#end
	##end
	#
	#
	#### chop up the SNP list into chunks of 100K SNPs -- for parallelization
	##tail -n +2 $OUT/all_129_snps.txt | split -d -a 3 -l 125000 - $OUT/all_129_snps.txt.
	
	
	###############################################################################
	###
	### PERFORM META-ANALYSIS IN PARALLEL
	###
	###############################################################################
	
	#set OUT_FILES=$OUT/MANTEL_example
	#set PARAMS=$EXAMPLE/MANTEL_example.params
	#set HAPMAP_DIR=$RESOURCES/HAPMAP/
	
	#echo "SNP CHR POS A1 A2 HAPMAP_A1_FREQ CODED_ALLELE NONCODED_ALLELE CODED_ALLELE_FREQ N_EFF Z_SQRTN P_SQRTN BETA_FIXED SE_FIXED Z_FIXED P_FIXED BETA_LOWER_FIXED BETA_UPPER_FIXED BETA_RANDOM SE_RANDOM Z_RANDOM P_RANDOM BETA_LOWER_RANDOM BETA_UPPER_RANDOM COCHRANS_Q DF P_COCHRANS_Q I_SQUARED TAU_SQUARED DIRECTIONS GENES_1000KB NEAREST_GENE FUNCTION CAVEAT" > $OUT_FILES.all.txt
	
	#foreach iter ( 000 )
	
	#rm $OUT_FILES.$iter.std???
	
	#bsub -q hour -o $OUT_FILES.$iter.stdout -e $OUT_FILES.$iter.stderr $SCRIPTS/METAGWAS.pl --params $PARAMS --snps $OUT/all_129_snps.txt --dbsnp $RESOURCES/dbsnp129_hg18.txt --freq $HAPMAP_DIR/hapmap_ceu_r27_nr.b36_fwd.129.freq.frq --genes $RESOURCES/refseq_genes.short.txt --dist 1000 --out $OUT_FILES.$iter.out --ext $iter --no-header --random-effects
	
	#tail -n +2 $OUT_FILES.$iter.out >> $OUT_FILES.all.txt
	
	#end
	
	###############################################################################
	
	#set OUT=$OUT/MANTEL_example
	
	###
	### Some p-values are computed as 0 (because the Statistics module in Perl freaks out for chi-square above a certain threshold)
	### Here we can recompute these p-values in R (if not applying genomic control post-meta -- see below).
	### Note that in this example, there are no p-values that need to be recomputed.
	###
	
	#cat $OUT.all.txt | awk ' $12 == 0 || $16 == 0 || $22 == 0 { print $1,$11,$15,$21 } ' > $OUT.all.needs_fixing.txt
	#R CMD BATCH -CL -$OUT.all.needs_fixing.txt -$OUT.all.fixed.txt $SCRIPTS/meta.R
	#echo "SNP P_SQRTN P_FIXED P_RANDOM" > $OUT.all.fixed.txt.2
	#tail -n +2 $OUT.all.fixed.txt >> $OUT.all.fixed.txt.2
	#$SCRIPTS/merge_tables.pl --file1 $OUT.all.fixed.txt.2 --file2 $OUT.all.txt --index SNP --replace > $OUT.all.corrected.txt
	#mv $OUT.all.corrected.txt $OUT.all.txt
	
	### make QQ plot based on Z_FIXED
	#cat $OUT.all.txt | $SCRIPTS/parse_table.pl --col Z_FIXED --no-header | grep -v NA > $OUT.all.zfixed.txt
	#R CMD BATCH -CL -$OUT.all.zfixed.txt -Z -$OUT.zfixed.qqplot.pdf $SCRIPTS/qqplot.R
	
	#cat $OUT.all.txt | $SCRIPTS/parse_table.pl --col Z_SQRTN --no-header | grep -v NA > $OUT.all.zsqrtn.txt
	#R CMD BATCH -CL -$OUT.all.zsqrtn.txt -Z -$OUT.zsqrtn.qqplot.pdf $SCRIPTS/qqplot.R
	
	#cat $OUT.all.txt | $SCRIPTS/parse_table.pl --col Z_RANDOM --no-header | grep -v NA > $OUT.all.zrandom.txt
	#R CMD BATCH -CL -$OUT.all.zrandom.txt -Z -$OUT.zrandom.qqplot.pdf $SCRIPTS/qqplot.R
	
	### to make histograms of N_EFF and DF+1
	### adjust number of bins in histogram with number of contributing studies (i.e. -CL -inputfile -number.of.studies -output.file)
	#cat $OUT.all.txt | $SCRIPTS/parse_table.pl --col N_EFF,DF --no-header | grep -v NA > $OUT.all.n_eff_df.txt
	#R CMD BATCH -CL -$OUT.all.n_eff_df.txt -5 -$OUT $SCRIPTS/histograms.R
	
	### make pretty Manhattan plots
	#cat $OUT.all.txt | $SCRIPTS/parse_table.pl --col CHR,POS,P_FIXED | grep -v NA > $OUT.all.manhattan.txt
	#awk ' { if($1=="X") print 23, $2, $3; else if($1=="Y") print 24, $1, $2; else print $0 } ' $OUT.all.manhattan.txt > foo
	#mv foo $OUT.all.manhattan.txt
	#R CMD BATCH -CL -$OUT.all.manhattan.txt -$OUT.all.manhattan.pdf $SCRIPTS/manhattan_plot.R
	
	###############################################################################
	###
	### lambda correct - to apply genomic control *after* the meta-analysis
	###
	###############################################################################
	
	#cat $OUT.all.txt | $SCRIPTS/parse_table.pl --col SNP,BETA_FIXED,SE_FIXED > $OUT.all.beta_se.txt
	
	###
	### you have to specify the lambda value as the third commandline argument (after -CL -input_file)
	### the lambda is output on the QQ plots (see above)
	###
	
	#R CMD BATCH -CL -$OUT.all.beta_se.txt -1.002 -$OUT.all.beta_se.lambda_corrected.txt $SCRIPTS/lambda_correct.R
	#sed -i 's/foo.SNP P SE Z/SNP P_GC SE_GC Z_GC/g' $OUT.all.beta_se.lambda_corrected.txt
	#$SCRIPTS/merge_tables.pl --file1 $OUT.all.beta_se.lambda_corrected.txt --file2 $OUT.all.txt --index SNP > $OUT.lambda_corrected.txt
	
	### make pretty Manhattan plots
	#cat $OUT.lambda_corrected.txt | $SCRIPTS/parse_table.pl --col CHR,POS,P_GC | grep -v NA > $OUT.all.manhattan.GC.txt
	#awk ' { if($1=="X") print 23, $2, $3; else if($1=="Y") print 24, $1, $2; else print $0 } ' $OUT.all.manhattan.GC.txt > foo
	#mv foo $OUT.all.manhattan.GC.txt
	#R CMD BATCH -CL -$OUT.all.manhattan.GC.txt -$OUT.all.manhattan.GC.pdf $SCRIPTS/manhattan_plot.R
	
	###
	### THE END - see run_clumps.csh for downstream analyses (e.g. finding independent hits) and creating regional assocation plots
	###
	
	### END OF BETA ###
	
	### END of if-else statement for the number of command-line arguments passed ###
fi 

script_copyright_message