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
	echoerror "- Argument #2 is path_to/ the cleaned, parsed, harmonized GWAS data."
	echoerror "- Argument #3 is path_to/ main meta-analysis results directory."
	echoerror "- Argument #4 is path_to/ cohort meta-analysis results directory."
	echoerror "- Argument #5 is the name of the cohort."
	echoerror ""
	echoerror "An example command would be: meta.preparator.sh [arg1] [arg2] [arg3] [arg4] [arg5]"
	echoerror "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  	# The wrong arguments are passed, so we'll exit the script now!
 	echo ""
	script_copyright_message
	exit 1
}

echobold "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echobold "                                          META-PREPARATOR OF GWAS"
echobold ""
echobold "* Version:      v1.1.1"
echobold ""
echobold "* Last update:  2017-05-05"
echobold "* Written by:   Sander W. van der Laan | UMC Utrecht | s.w.vanderlaan-2@umcutrecht.nl."
echobold "* Description:  Collects all variants into one file."
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
if [[ $# -lt 5 ]]; then 
	echo ""
	echoerror "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echoerrorflash "               *** Oh, computer says no! Number of arguments found "$#". ***"
	echoerror "You must supply [5] arguments when running *** METAGWASPREPARATOR -- MetaGWASToolKit ***!"
	script_arguments_error
else
	echo ""
	echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echo "Processing arguments..."
	source ${1} # depends on arg1
	RAWDATACOHORT=${2} # depends on arg2
	METARESULTDIR=${3} # depends on arg3
	METAPREPDIRCOHORT=${4} # depends on arg4
	COHORT=${5} # depends on arg5
	CHUNKSIZE=${CHUNKSIZE} # depends on contents of arg1
	SCRIPTS=${METAGWASTOOLKITDIR}/SCRIPTS
	METATEMPRESULTDIR=${METARESULTDIR}/TEMP
	echo ""
	echo "All arguments are passed. These are the settings:"
	echo "Cleaned, parsed, and harmonized data..................: "${RAWDATACOHORT}
	echo "Main meta-analysis results directory..................: "${METARESULTDIR}
	echo "Cohort specific meta-analysis preparatory directory...: "${METAPREPDIRCOHORT}
	echo "Cohort to be prepared..............;..................: "${COHORT}
	echo "Temporary meta-analysis results directory.............: "${METATEMPRESULTDIR}
	
	echo ""
	echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echo "We will do some cleaning first..."
	
	### Remove remover-script results
	rm -v ${RAWDATACOHORT}/*remover.errors
	rm -v ${RAWDATACOHORT}/*remover.log
	rm -v ${RAWDATACOHORT}/*remover.sh
	
	echo ""	
	echo "We will collect all unique variants across all GWAS cohorts..."
	echo ""
	echo "* Reordering [ ${COHORT} ]..."
	echo " - merging cleaned data with uniquefied variant list..." 
	${SCRIPTS}/mergeTables.pl --file1 ${RAWDATACOHORT}/${COHORT}.cdat.gz --file2 ${METARESULTDIR}/meta.all.unique.variants.txt --index VariantID --format GZIP1 > ${METAPREPDIRCOHORT}/${COHORT}.reorder.cdat
	echo " - gzipping the shizzle..."
	gzip -fv ${METAPREPDIRCOHORT}/${COHORT}.reorder.cdat
	echo " - splitting cleaned, and re-ordered data into chunks of ${CHUNKSIZE} variants -- for parallelisation and speedgain..."
	zcat ${METAPREPDIRCOHORT}/${COHORT}.reorder.cdat.gz | tail -n +2 | split -a 3 -l ${CHUNKSIZE} - ${METATEMPRESULTDIR}/${COHORT}.reorder.split.
	
	### HEADER .cdat-file
	### VariantID	Marker	MarkerOriginal	CHR	BP	Strand	EffectAllele	OtherAllele	MinorAllele	MajorAllele	EAF	MAF	MAC	HWE_P	Info	Beta	BetaMinor	SE	P	N	N_cases	N_controls	Imputed	Reference
	### 1		    2       3               4   5   6       7               8           9           10          11  12  13  14      15	    16	    17          18  19  20  21      22          23      24

	for SPLITFILE in ${METATEMPRESULTDIR}/${COHORT}.reorder.split.*; do
		### determine basename of the splitfile
		BASESPLITFILE=$(basename ${SPLITFILE})
		echo ""
		echo "* Prepping split chunk [ ${BASESPLITFILE} ] while re-ordering columns..."
		echo ""
		### REQUIRED Columns: VariantID CHR BP BetaMino SE P MinorAllele MajorAllele MAF Info
		cat ${SPLITFILE} | awk ' { print $1, $4, $5, $17, $18, $19, $9, $10, $12, $15 } ' > ${METAPREPDIRCOHORT}/tmp_file
		echo " - renaming the temporary file."
		mv -fv ${METAPREPDIRCOHORT}/tmp_file ${METAPREPDIRCOHORT}/${BASESPLITFILE}
		rm -v ${SPLITFILE}
	done
	
### END of if-else statement for the number of command-line arguments passed ###
fi 

script_copyright_message