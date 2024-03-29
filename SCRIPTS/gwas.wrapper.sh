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
	echoerror "- Argument #1 is path_to/ the raw, parsed and harmonized GWAS data."
	echoerror "- Argument #2 is the cohort name."
	echoerror "- Argument #3 is 'basename' of the cohort data file."
	echoerror ""
	echoerror "An example command would be: gwas.wrapper.sh [arg1] [arg2] [arg3]"
	echoerror "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  	# The wrong arguments are passed, so we'll exit the script now!
 	echo ""
	script_copyright_message
	exit 1
}

echobold "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echobold "          GWASWRAPPER: WRAPPER FOR PARSED, HARMONIZED CLEANED GENOME-WIDE ASSOCIATION STUDIES"
echobold ""
echobold "* Version:      v1.2.1"
echobold ""
echobold "* Last update:  2023-06-23"
echobold "* Written by:   Sander W. van der Laan | s.w.vanderlaan@gmail.com."
echobold "* Edited by:    Moezammin Baksi; Mike Puijk."
echobold "* Description:  Produce concatenated parsed, harmonized, and cleaned GWAS data."
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
	echoerror "You must supply [3] arguments when running *** GWASWRAPPER -- MetaGWASToolKit ***!"
	script_arguments_error
else
	echo ""
	echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echo "Processing arguments..."
	PROJECTDIR=${1} # depends on arg1
	COHORTNAME=${2} # depends on arg2
	BASEFILENAME=${3} # depends on arg3

	echo ""
	echo "All arguments are passed. These are the settings:"
	echo "Project directory.......................: "${PROJECTDIR}
	echo "Cohort name.............................: "${COHORTNAME}
	echo "Cohort's raw file name..................: "${BASEFILENAME}.txt.gz
	echo "The basename of the cohort is...........: "${BASEFILENAME}
	
	echo ""
	echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echo "Wrapping up split files and checking parsing and harmonizing..."
	echo ""
	echo "* Making necessary 'readme' files..."
	echo "Cohort File Array ArrayErrorFile" > ${PROJECTDIR}/${COHORTNAME}.wrap.array.readme
	echo "Cohort File Harmonizing HarmonizingErrorFile" > ${PROJECTDIR}/${COHORTNAME}.wrap.harmonized.readme
	echo "Cohort File Cleaning CleaningErrorFile" > ${PROJECTDIR}/${COHORTNAME}.wrap.cleaned.readme
	
	
	### HEADER .rdat-file
	### VariantID	Marker	MarkerOriginal	CHR	BP	Strand	EffectAllele	OtherAllele	MinorAllele	MajorAllele	EAF	MAF	MAC	HWE_P	Info	Beta	BetaMinor	SE	P	N	N_cases	N_controls	Imputed	Reference
	### 1		    2       3               4   5   6       7               8           9           10          11  12  13  14      15	    16	    17          18  19  20  21      22          23      24
	
	### HEADER cdat-file
	### VariantID	Marker	MarkerOriginal	CHR	BP	Strand	EffectAllele	OtherAllele	MinorAllele	MajorAllele	EAF	MAF	MAC	HWE_P	Info	Beta	BetaMinor	SE	P	N	N_cases	N_controls	Imputed	Reference	VT
	### 1		    2       3               4   5   6       7               8           9           10          11  12  13  14      15	    16	    17          18  19  20  21      22          23      24			25
	
	echo ""	
	echo "* Making necessary 'summarized' files..."
	echo "VariantID	Marker	MarkerOriginal	CHR	BP	Strand	EffectAllele	OtherAllele	MinorAllele	MajorAllele	EAF	MAF	MAC	HWE_P	Info	Beta	BetaMinor	SE	P	N	N_cases	N_controls	Imputed	Reference" > ${PROJECTDIR}/${COHORTNAME}.rdat
	echo "VariantID	Marker	MarkerOriginal	CHR	BP	Strand	EffectAllele	OtherAllele	MinorAllele	MajorAllele	EAF	MAF	MAC	HWE_P	Info	Beta	BetaMinor	SE	P	N	N_cases	N_controls	Imputed	Reference	VT" > ${PROJECTDIR}/${COHORTNAME}.cdat
	
		
	### Setting the patterns to look for -- never change this
	ARRAYPATTERN="All done for this array"
	HARMONIZEDPATTERN="All done parsing and harmonizing. Let's have a non-alcoholic beverage, buddy!"
	CLEANEDPATTERN="All done cleaning"
	
	echo ""
	echo "We will look for the following pattern in the ..."
	echo "...array log file............: [ ${ARRAYPATTERN} ]"
	echo "...harmonized log file.......: [ ${HARMONIZEDPATTERN} ]"
	echo "...cleaned log file..........: [ ${CLEANEDPATTERN} ]"

	### ARRAY
	echo ""
	echo "* Check array and split of GWAS datasets."
	for ERRORFILE in ${PROJECTDIR}/gwas.parser_harm_cleaner.*.log; do
		BASENAMEERRORFILE=$(basename ${ERRORFILE})
		BASEERRORFILE=$(basename ${ERRORFILE} .log)
		prefix_array='gwas.parser_harm_cleaner.array.' # removing the 'gwas.parser_harm_cleaner.'-part from the ERRORFILE
		BASEARRAYFILE_N=$(echo "${BASEERRORFILE}" | sed -e "s/^$prefix_array//")
		
		LINEINTEXTFILE=$((BASEARRAYFILE_N+1))
		SPLITFILE=$(sed -n "$LINEINTEXTFILE{p;q}" ${PROJECTDIR}/splitfiles.txt)
		BASESPLITFILE=$(basename ${SPLITFILE})

		echo ""
		echo "* checking split chunk: [ ${BASEARRAYFILE_N} ] for pattern \"${ARRAYPATTERN}\"..."
	
		echo "Error file...........................:" ${BASENAMEERRORFILE}
		if [[ ! -z $(grep "${ARRAYPATTERN}" "${ERRORFILE}") ]]; then 
			ARRAYMESSAGE=$(echosucces "successfully executed array")
			ARRAYMESSAGEREADME=$(echo "success")
			echo "Array report.........................: ${ARRAYMESSAGE}"
			echo "${COHORTNAME} ${BASESPLITFILE} ${ARRAYMESSAGEREADME} ${BASENAMEERRORFILE}" >> ${PROJECTDIR}/${COHORTNAME}.wrap.array.readme
			echo "- removing files [ ${PROJECTDIR}/${prefix_array}${BASEPARSEDFILE}[.errors/log] ]..."
			rm -v ${PROJECTDIR}/${prefix_array}${BASEARRAYFILE_N}.errors
			rm -v ${PROJECTDIR}/${prefix_array}${BASEARRAYFILE_N}.log
		else
			echoerrorflash "*** Error *** The pattern \"${ARRAYPATTERN}\" was NOT found in [ ${BASENAMEERRORFILE} ]..."
			echoerror "Reported in the [ ${BASENAMEERRORFILE} ]:      "
			echoerror "####################################################################################"
			cat ${BASEERRORFILE}.errors
			echoerror "####################################################################################"
			ARRAYMESSAGE=$(echosucces "array execution failure")
			ARRAYMESSAGEREADME=$(echo "failure")
			echo "Array report.........................: ${ARRAYMESSAGE}"
			echo "${COHORTNAME} ${BASESPLITFILE} ${ARRAYMESSAGEREADME} ${BASENAMEERRORFILE}" >> ${PROJECTDIR}/${COHORTNAME}.wrap.array.readme
		fi
		echo ""
	done
	

	### PARSER & HARMONIZER
	echo ""
	echo "* Check parsing and harmonization of GWAS datasets."
	for ERRORFILE in ${PROJECTDIR}/gwas.parser.harmonizer.${BASEFILENAME}.*.log; do
		### determine basename of the ERRORFILE
		BASENAMEERRORFILE=$(basename ${ERRORFILE})
		BASEERRORFILE=$(basename ${ERRORFILE} .log)
		prefix_harmonized='gwas.parser.harmonizer.' # removing the 'gwas.parser.harmonizer.'-part from the ERRORFILE
		BASEHARMONIZEDFILE=$(echo "${BASEERRORFILE}" | sed -e "s/^$prefix_harmonized//")
		echo ""
		echo "* checking split chunk: [ ${BASEHARMONIZEDFILE} ] for pattern \"${HARMONIZEDPATTERN}\"..."

		echo "Error file...........................:" ${BASENAMEERRORFILE}
		if [[ ! -z $(grep "${HARMONIZEDPATTERN}" "${ERRORFILE}") ]]; then 
  
			HARMONIZEDMESSAGE=$(echosucces "successfully parsed and harmonized")
			HARMONIZEDMESSAGEREADME=$(echo "success")
			echo "Harmonizing report...................: ${HARMONIZEDMESSAGE}"
			echo "- concatenating data to [ ${PROJECTDIR}/${COHORTNAME}.rdat ]..."
			echo "${COHORTNAME} ${BASEFILENAME}.txt.gz ${HARMONIZEDMESSAGEREADME} ${BASENAMEERRORFILE}" >> ${PROJECTDIR}/${COHORTNAME}.wrap.harmonized.readme
			cat ${PROJECTDIR}/${BASEHARMONIZEDFILE}.rdat | tail -n +2  | awk -F '\t' '{ print $0 }' >> ${PROJECTDIR}/${COHORTNAME}.rdat
			echo "- removing files [ ${PROJECTDIR}/${BASEHARMONIZEDFILE}[.rdat/.rdat.report/.errors/.log] ]..."
			rm -v ${PROJECTDIR}/${BASEHARMONIZEDFILE}.rdat
			rm -v ${PROJECTDIR}/${BASEHARMONIZEDFILE}.rdat.report
			rm -v ${PROJECTDIR}/${prefix_harmonized}${BASEHARMONIZEDFILE}.errors
			rm -v ${PROJECTDIR}/${prefix_harmonized}${BASEHARMONIZEDFILE}.log
			rm -v ${PROJECTDIR}/${prefix_harmonized}${BASEHARMONIZEDFILE}.sh
		else
			echoerrorflash "*** Error *** The pattern \"${HARMONIZEDPATTERN}\" was NOT found in [ ${BASENAMEERRORFILE} ]..."
			echoerror "Reported in the [ ${BASENAMEERRORFILE} ]:      "

			echoerror "####################################################################################"
			cat ${ERRORFILE}
			echoerror "####################################################################################"
			HARMONIZEDMESSAGE=$(echosucces "harmonization failure")
			HARMONIZEDMESSAGEREADME=$(echo "failure")
			echo "Harmonizing report...................: ${HARMONIZEDMESSAGE}"
			echo "${COHORTNAME} ${BASEFILENAME}.txt.gz ${HARMONIZEDMESSAGEREADME} ${BASENAMEERRORFILE}" >> ${PROJECTDIR}/${COHORTNAME}.wrap.harmonized.readme
		fi

		echo ""
	done

	### CLEANER
	echo ""
	echo "* Check cleaning of harmonized GWAS datasets."
	for ERRORFILE in ${PROJECTDIR}/gwas.cleaner.${BASEFILENAME}.*.log; do
		### determine basename of the ERRORFILE
		BASENAMEERRORFILE=$(basename ${ERRORFILE})
		BASEERRORFILE=$(basename ${ERRORFILE} .log)
		prefix_cleaned='gwas.cleaner.' # removing the 'gwas2ref.harmonizer.'-part from the ERRORFILE
		BASECLEANEDFILE=$(echo "${BASEERRORFILE}" | sed -e "s/^$prefix_cleaned//")
		echo ""
		echo "* checking split chunk: [ ${BASECLEANEDFILE} ] for pattern \"${CLEANEDPATTERN}\"..."

		echo "Error file...........................:" ${BASENAMEERRORFILE}
		if [[ ! -z $(grep "${CLEANEDPATTERN}" "${ERRORFILE}") ]]; then 
			CLEANEDMESSAGE=$(echosucces "successfully cleaned")
			CLEANEDMESSAGEREADME=$(echo "success")
			echo "Cleaning report......................: ${CLEANEDMESSAGE}"
			echo "- concatenating data to [ ${PROJECTDIR}/${COHORTNAME}.rdat ]..."
			echo "${COHORTNAME} ${BASEFILENAME}.txt.gz ${CLEANEDMESSAGEREADME} ${BASENAMEERRORFILE}" >> ${PROJECTDIR}/${COHORTNAME}.wrap.cleaned.readme
			cat ${PROJECTDIR}/${BASECLEANEDFILE}.cdat | tail -n +2  | awk -F '\t' '{ print $0 }' >> ${PROJECTDIR}/${COHORTNAME}.cdat
			echo "- removing files [ ${PROJECTDIR}/${BASECLEANEDFILE}[.cdat/.errors/.log] ]..."
			rm -v ${PROJECTDIR}/${BASECLEANEDFILE}.cdat
			rm -v ${PROJECTDIR}/${prefix_cleaned}${BASECLEANEDFILE}.errors
			rm -v ${PROJECTDIR}/${prefix_cleaned}${BASECLEANEDFILE}.log
			rm -v ${PROJECTDIR}/${prefix_cleaned}${BASECLEANEDFILE}.sh
		else
			echoerrorflash "*** Error *** The pattern \"${CLEANEDPATTERN}\" was NOT found in [ ${BASENAMEERRORFILE} ]..."

			echoerror "Reported in the [ ${BASENAMEERRORFILE} ]:      "
			echoerror "####################################################################################"
			cat ${ERRORFILE}
			echoerror "####################################################################################"
			CLEANEDMESSAGE=$(echosucces "cleaning failure")
			CLEANEDMESSAGEREADME=$(echo "failure")
			echo "Cleaning report......................: ${CLEANEDMESSAGE}"
			echo "${COHORTNAME} ${BASEFILENAME}.txt.gz ${CLEANEDMESSAGEREADME} ${BASENAMEERRORFILE}" >> ${PROJECTDIR}/${COHORTNAME}.wrap.cleaned.readme
		fi

		echo ""
	done
	
	### GZIPPING
	echo ""
	echo "Gzipping da [ ${COHORTNAME}.rdat ] shizzle..."
	gzip -fv ${PROJECTDIR}/${COHORTNAME}.rdat
	
	echo ""
	echo "Gzipping da [ ${COHORTNAME}.cdat ] shizzle..."
	gzip -fv ${PROJECTDIR}/${COHORTNAME}.cdat

	
### END of if-else statement for the number of command-line arguments passed ###
fi 

script_copyright_message
