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
	echoerror "- Argument #2 is path_to/ parameter file."
	echoerror "- Argument #3 is path_to/ variantsfile."
	echoerror "- Argument #4 is the reference used."
	echoerror "- Argument #5 is path_to/ main meta-analysis results directory."
	echoerror "- Argument #6 is the extension of the input/output file used."
	echoerror ""
	echoerror "An example command would be: meta.analyzer.sh [arg1] [arg2] [arg3] [arg4] [arg5] [arg6]"
	echoerror "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  	# The wrong arguments are passed, so we'll exit the script now!
 	echo ""
	script_copyright_message
	exit 1
}

echobold "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echobold "                                          META-ANALYZER OF GWAS"
echobold ""
echobold "* Version:      v1.0.4"
echobold ""
echobold "* Last update:  2017-05-08"
echobold "* Written by:   Sander W. van der Laan | UMC Utrecht | s.w.vanderlaan-2@umcutrecht.nl."
echobold "* Description:  Meta-analyses GWAS datasets."
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
if [[ $# -lt 6 ]]; then 
	echo ""
	echoerror "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echoerrorflash "               *** Oh, computer says no! Number of arguments found "$#". ***"
	echoerror "You must supply [6] arguments when running *** META-ANALYZER OF GWAS -- MetaGWASToolKit ***!"
	script_arguments_error
else
	echo ""
	echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echo "Processing arguments..."
	source ${1} # depends on arg1
	GENESDISTANCE=${GENESDISTANCE} # depends on contents of arg1
	FREQFLIP=${FREQFLIP} # depends on contents of arg1
	FREQWARNING=${FREQWARNING} # depends on contents of arg1
	POPULATION=${POPULATION} # depends on contents of arg1
	METAMODEL=${METAMODEL} # depends on contents of arg1
	VERBOSE=${VERBOSE} # depends on contents of arg1
	DBSNPFILE=${DBSNPFILE} # depends on contents of arg1
	REFFREQFILE=${REFFREQFILE} # depends on contents of arg1
	GENESFILE=${GENESFILE} # depends on contents of arg1
	
	SCRIPTS=${METAGWASTOOLKITDIR}/SCRIPTS # depends on contents of arg1
	
	PARAMSFILE=${2} # depends on arg2 ### NOTE: FUTURE VERSION WILL MAKE THIS AUTOMATICALLY -- WILL BE REMOVED FROM CONF FILE
	VARIANTSFILE=${3} # depends on arg3
	
	REFERENCE=${4} # depends on arg4
	
	METARESULTDIR=${5} # depends on arg5
	
	EXTENSION=${6} # depends on arg5
	
	echo ""
	echo "All arguments are passed. These are the settings:"
	echo "Main meta-analysis results directory..................: "${METARESULTDIR}
	echo "The reference used....................................: "${REFERENCE}
	echo "The reference population..............................: "${POPULATION}
	echo "The dbSNP data........................................: "${DBSNPFILE}
	echo "The Reference frequency file..........................: "${REFFREQFILE}
	echo "The genes file........................................: "${GENESFILE}
	echo "The gene distance to variant .........................: "${GENESDISTANCE}
	echo "Meta-analysis model (default: fixed)..................: "${METAMODEL}
	echo "Frequency allele flipping (default: 0.30).............: "${FREQFLIP}
	echo "Frequency allele warning (default: 0.45)..............: "${FREQWARNING}
	echo "Verbose output (default: no)..........................: "${VERBOSE}
	echo "The parameter file....................................: "${PARAMSFILE}
	echo "The variant list file.................................: "${VARIANTSFILE}
	echo "Processing chunk......................................: "${EXTENSION}
	
	echo ""
	echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echo "We will collect all unique variants across all GWAS cohorts..."

	METACOMMAND="${SCRIPTS}/METAGWAS.pl --params ${PARAMSFILE} --variants ${VARIANTSFILE} --dbsnp ${DBSNPFILE} --freq ${REFFREQFILE} --genes ${GENESFILE} --dist ${GENESDISTANCE} --out ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.${EXTENSION}.out --ext ${EXTENSION} --ref ${REFERENCE} --pop ${POPULATION} --freq-flip ${FREQFLIP} --freq-warning ${FREQWARNING} --no-header" 
	
	if [[ ${METAMODEL} == "RANDOM" && ${VERBOSE} == "VERBOSE" ]]; then
		echo "Performing meta-analysis using Z-score and fixed-effects models; and in addition a random-effects model."
		echo "Results will be verbose -- all per-cohort data are added to the output."
		${METACOMMAND} --random --verbose
	
	elif [[ ${METAMODEL} == "RANDOM" && ${VERBOSE} == "DEFAULT" ]]; then
		echo "Performing meta-analysis using Z-score and fixed-effects models; and in addition a random-effects model."
		echo "Results will be summarized."
		${METACOMMAND} --random
	
	elif [[ ${METAMODEL} == "DEFAULT" && ${VERBOSE} == "VERBOSE" ]]; then
		echo "Performing meta-analysis using Z-score and fixed-effects models."
		echo "Results will be verbose -- all per-cohort data are added to the output."
		${METACOMMAND} --verbose
	
	else [[ ${METAMODEL} == "DEFAULT" && ${VERBOSE} == "DEFAULT" ]]
		echo "Performing meta-analysis using Z-score and fixed-effects models."
		echo "Results will be summarized."
		${METACOMMAND}
	
	fi
	echo ""
	echo "All done! Let's have a beer, buddy."

### END of if-else statement for the number of command-line arguments passed ###
fi 

script_copyright_message