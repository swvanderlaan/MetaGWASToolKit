#!/bin/bash

### Creating display functions
### Setting colouring
NONE='\033[00m'
BOLD='\033[1m'
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
function echoerrorflash { 
    echo -e "${RED}${BOLD}${FLASHING}${1}${NONE}" 
}
function echoerror { 
    echo -e "${RED}${1}${NONE}"
}
function echosucces { 
    echo -e "${YELLOW}${1}${NONE}"
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
	echoerror "- Argument #1 is path_to/ the configuration file."
	echoerror "- Argument #2 is path_to/ variants files list."
	echoerror "- Argument #3 is path_to/ main meta-analysis results directory."
	echoerror ""
	echoerror "An example command would be: meta.preparator.sh [arg1] [arg2] [arg3]"
	echoerror "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  	# The wrong arguments are passed, so we'll exit the script now!
 	echo ""
	script_copyright_message
	exit 1
}

echobold "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echobold "                     META-CONCATENATOR OF META-ANALYSIS OF GENOME-WIDE ASSOCIATION STUDIES"
echobold ""
echobold "* Version:      v1.0.5"
echobold ""
echobold "* Last update:  2017-05-21"
echobold "* Written by:   Sander W. van der Laan | UMC Utrecht | s.w.vanderlaan-2@umcutrecht.nl."
echobold "* Description:  Checks errors- and log-files for consistency, prior to concatenating all chunks with "
echobold "                meta-analyzed results into one file and gzips it."
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
	echoerror "You must supply [3] arguments when running *** META-CONCATENATOR OF GWAS -- MetaGWASToolKit ***!"
	script_arguments_error
else
	echo ""
	echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echo "Processing arguments..."
	source ${1} # depends on arg1
	VARIANTSFILES=${2} # depends on arg2
	METARESULTDIR=${3} # depends on arg3
	SCRIPTS=${METAGWASTOOLKITDIR}/SCRIPTS
	METATEMPRESULTDIR=${METARESULTDIR}/TEMP
	echo ""
	echo "All arguments are passed. These are the settings:"
	echo "Main meta-analysis results directory..................: "${METARESULTDIR}
	echo "The list of files to concatenate......................: "${VARIANTSFILES}
	echo "The 'head' of the meta-analyzed data..................: "${COHORT}
	echo "Temporary meta-analysis results directory.............: "${METATEMPRESULTDIR}
	
	echo ""
	echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echo "Checking consistency of meta-analysis results."
	
	echo "* Making necessary 'readme' files..."
	echo "Chunk Skipped Flipped Success" > ${METARESULTDIR}/meta.analysis.readme
	echo "Chunk PvalCorrected Success" > ${METARESULTDIR}/meta.p_corrector.readme

	### Setting the patterns to look for -- never change this
	METASKIPPEDPATTERN="skipping"
	METAFLIPPEDPATTERN="Flipping"
	METASUCCESSPATTERN="This meta-analysis of GWAS was successfully finished"
	
	PCORRERRORPATTERN="File is empty"
	PCORRSUCCESSPATTERN="All done correcting p-values in the dataset."
	
	while IFS='' read -r VARIANTFILE || [[ -n "$VARIANTFILE" ]]; do  
	
		EXTENSION="${VARIANTFILE##*.}"
		VARIANTFILEBASE=${METATEMPRESULTDIR}/${VARIANTFILE%.*}
		METAERRORFILE=${METARESULTDIR}/meta.analyzer.${EXTENSION}.errors
		METALOGFILE=${METARESULTDIR}/meta.analyzer.${EXTENSION}.log
 		PCORRERRORFILE=${METARESULTDIR}/meta.p_corrector.${EXTENSION}.errors
 		PCORRLOGFILE=${METARESULTDIR}/meta.p_corrector.${EXTENSION}.log
		
		### determine basename of the ERRORFILE
		BASENAMEERRORFILE=$(basename ${METAERRORFILE})
		BASENAMELOGFILE=$(basename ${METALOGFILE})
		echo ""
		echo "* checking split chunk: [ ${EXTENSION} ] for pattern \"${METASUCCESSPATTERN}\"..."
		echo "Error file...........................:" $(basename ${BASENAMEERRORFILE})
		echo "Log file.............................:" $(basename ${BASENAMELOGFILE})
		if [[ ! -z $(grep "${METASUCCESSPATTERN}" "${METALOGFILE}") ]] ; then 
			SUCCESSMESSAGE=$(echosucces "successfully meta-analyzed")
			SUCCESSMESSAGEREADME=$(echo "success")
			NSKIPPED=$(grep "${METASKIPPEDPATTERN}" "${METAERRORFILE}" | wc -l)
			NFLIPPED=$(grep "${METAFLIPPEDPATTERN}" "${METAERRORFILE}" | wc -l)
			echo "Meta-analysis report...................................: ${SUCCESSMESSAGE}"
			echo "Number of variants skipped in meta-analysis "
			echo "(not in reference, allele frequency issues, etc.)......: ${NSKIPPED}"
			echo "Number of variants flipped skipped in meta-analysis....: ${NFLIPPED}"
			echo "${EXTENSION} ${NSKIPPED} ${NFLIPPED} ${SUCCESSMESSAGEREADME}" >> ${METARESULTDIR}/meta.analysis.readme
			
			### p-value corrections
			if [[ ! -z $(grep "${PCORRSUCCESSPATTERN}" "${PCORRLOGFILE}") ]] ; then 
				SUCCESSMESSAGE=$(echosucces "p-values successfully corrected")
				SUCCESSMESSAGEREADME=$(echo "success")
				echo "Meta-analysis report...................................: ${SUCCESSMESSAGE}"
				echo "${EXTENSION} yes ${SUCCESSMESSAGEREADME}" >> ${METARESULTDIR}/meta.p_corrector.readme
				
			else
				echoerrorflash "*** Warning *** There were no p-values corrected..."
				echoerror "Reported in the [ ${PCORRERRORFILE} ]:      "
				echoerror "####################################################################################"
				head ${PCORRERRORFILE}
				tail ${PCORRERRORFILE}
				echoerror "####################################################################################"
				FAILUREMESSAGE=$(echosucces "no p-values corrected")
				FAILUREMESSAGEREADME=$(echo "no_pval_correction")
				echo "Meta-analysis report...................................: ${FAILUREMESSAGE}"
				echo "${EXTENSION} no ${FAILUREMESSAGEREADME}" >> ${METARESULTDIR}/meta.p_corrector.readme
		
			fi
			
			echo "- removing files [ ${METARESULTDIR}/meta.analyzer.${EXTENSION}[.sh/.errors/.log] ]..."
			rm -v ${METARESULTDIR}/meta.analyzer.${EXTENSION}.sh
			rm -v ${METARESULTDIR}/meta.analyzer.${EXTENSION}.errors
			rm -v ${METARESULTDIR}/meta.analyzer.${EXTENSION}.log
			rm -v ${METARESULTDIR}/meta.p_corrector.${EXTENSION}.sh
			rm -v ${METARESULTDIR}/meta.p_corrector.${EXTENSION}.errors
			rm -v ${METARESULTDIR}/meta.p_corrector.${EXTENSION}.log

		else
			echoerrorflash "*** Error *** The pattern \"${METASUCCESSPATTERN}\" was NOT found in [ ${METALOGFILE} ]..."
			echoerror "Reported in the [ ${METAERRORFILE} ]:      "
			echoerror "####################################################################################"
			head ${METAERRORFILE}
			tail ${METAERRORFILE}
			echoerror "####################################################################################"
			FAILUREMESSAGE=$(echosucces "meta-analysis failure")
			FAILUREMESSAGEREADME=$(echo "failure")
			NSKIPPED=$(grep "${METASKIPPEDPATTERN}" "${METAERRORFILE}" | wc -l)
			NFLIPPED=$(grep "${METAFLIPPEDPATTERN}" "${METAERRORFILE}" | wc -l)
			echo "Meta-analysis report...................................: ${FAILUREMESSAGE}"
			echo "${EXTENSION} ${NSKIPPED} ${NFLIPPED} ${FAILUREMESSAGEREADME}" >> ${METARESULTDIR}/meta.analysis.readme
		fi

	done < ${VARIANTSFILES}

	if [[ ! -z $(grep "success" ${METARESULTDIR}/meta.analysis.readme) ]]; then 
	
		echo ""
		echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
		echo "There were no errors in the meta-analysis. We will create the concatenated data file."
		
		cat ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.aaa.corrected_p.out | head -1 > ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.txt
	
		echo "* Processing each meta-analyzed chunk ..."
		while IFS='' read -r VARIANTFILE || [[ -n "$VARIANTFILE" ]]; do  
		
			EXTENSION="${VARIANTFILE##*.}"
		 	VARIANTFILEBASE=${METATEMPRESULTDIR}/${VARIANTFILE%.*}
	 		echo "  - wrapping results for chunk [ ${EXTENSION} ] ..."
			cat ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.${EXTENSION}.corrected_p.out | tail -n +2 >> ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.txt
			echo "  - removing results for chunk [ ${EXTENSION} ] (note: we do not need this anymore)..."
			echo "    > original ..."
			rm -v ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.${EXTENSION}.out
			echo "    > p-value corrected ..."
 			rm -v ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.${EXTENSION}.corrected_p.out
 			echo "    > other intermediate files ..."
 			rm -v ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.${EXTENSION}.fixed_headed.out
			rm -v ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.${EXTENSION}.needs_p_fixing.out
		done < ${VARIANTSFILES}
		
		echo ""
		echo "* Gzipping the shizzle..."
		gzip -vf ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.txt
	
	else
		echoerrorflash "*** Error *** The meta-analysis of one of the chunks failed..."
		echoerror "Reported in the [ meta.analysis.readme ]:      "
		echoerror "####################################################################################"
		cat ${METARESULTDIR}/meta.analysis.readme
		echoerror "####################################################################################"
		echo ""
		echoerror "We will not concatenate the meta-analysis results."
	fi
	
### END of if-else statement for the number of command-line arguments passed ###
fi 

script_copyright_message