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
function importantnote { 
    echo -e "${CYAN}${1}${NONE}"
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
	echo "$1" # ERROR MESSAGE
	echo ""
	echo "- Argument #1 is path_to the configuration file."
	echo "- Argument #2 is path_to the output/result directory."
	echo ""
	echo "An example command would be: meta.clumper.sh [arg1: path_to_output_dir] [arg2: phenotype] "
	echo ""
  	echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  	# The wrong arguments are passed, so we'll exit the script now!
	date
  	exit 1

}

script_arguments_error_reference() {
	echo "$1" # ERROR MESSAGE
	echo ""
	echo " You must supply the correct argument:"
	echo " * [HM2]          -- for use of HapMap 2 release 22, b36 as reference | LEGACY."
	echo " * [1Gp1]         -- for use of 1000G (phase 1, version 3) as reference."
	echo " * [1Gp3]         -- for use of 1000G (phase 3, version 5) as reference | CURRENTLY UNAVAILABLE"
	echo " * [GoNL4]        -- for use of GoNL4 as reference | CURRENTLY UNAVAILABLE"
	echo " * [GoNL5]        -- for use of GoNL5 as reference | CURRENTLY UNAVAILABLE"
	echo " * [1Gp3GONL5] -- for use of 1000G (phase 3, version 5, \"Final release\") plus GoNL5 as reference."
	echo ""
	echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	# The wrong arguments are passed, so we'll exit the script now!
  	date
  	exit 1
}

echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "                                           META-CLUMP PARSER"
echo "                               PARSER OF CLUMPED META-ANALYSIS RESULTS"
echo ""
echo " Version    : v1.1.1"
echo ""
echo " Last update: 2018-08-09"
echo " Written by : Sander W. van der Laan | s.w.vanderlaan@gmail.com."
echo ""
echo " Testers    : - Jessica van Setten"
echo ""
echo " Description: Parsing clumped a meta-analysis of genome-wide association studies results."
echo ""
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

### START of if-else statement for the number of command-line arguments passed ###
if [[ $# -lt 2 ]]; then 
	echo "Oh, computer says no! Number of arguments found "$#"."
	script_arguments_error "You must supply at least [2] arguments when clumping with *** META-CLUMPER ***!"
	echo ""
	script_copyright_message
else
	echo ""
	echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echo "Processing arguments..."

	### SETTING DIRECTORIES (from configuration file).
	# Loading the configuration file (please refer to the MetaGWASToolKit-Manual for specifications of this file). 
	source "$1" # Depends on arg1.
	
	CONFIGURATIONFILE="$1" # Depends on arg1 -- but also on where it resides!!!
	SOFTWARE=${SOFTWARE} # from configuration file
	
	# Where MetaGWASToolKit resides
	METAGWASTOOLKIT=${METAGWASTOOLKITDIR} # from configuration file
	SCRIPTS=${METAGWASTOOLKIT}/SCRIPTS
	RESOURCES=${METAGWASTOOLKIT}/RESOURCES
	
	PLINK=${PLINK} # depends on contents of arg1
	LOCUSZOOM=${LOCUSZOOM} # depends on contents of arg1
	METARESULTDIR="$2" # depends on arg2
	REFERENCE=${REFERENCE} # depends on contents of arg1
	POPULATION=${POPULATION} # depends on contents of arg1
	PROJECTNAME=${PROJECTNAME} # depends on contents of arg1
	
	### Determine which reference and thereby input data to use, arg1 [1kGp3v5GoNL5/1kGp1v3/GoNL4] 
		if [[ ${REFERENCE} = "HM2" ]]; then
			REFERENCE_HM2=${RESOURCES}/HAPMAP 
		elif [[ ${REFERENCE} = "1Gp1" ]]; then
			REFERENCE_1kGp1v3=${RESOURCES}/1000Gp1v3_EUR # 1000Gp1v3.20101123.EUR
		elif [[ ${REFERENCE} = "1Gp3" ]]; then
			echo "Apologies: currently it is not possible to clump based on 1000G phase 3."
		elif [[ ${REFERENCE} = "GoNL5" ]]; then
			echo "Apologies: currently it is not possible to clump based on GoNL5."
		elif [[ ${REFERENCE} = "GoNL4" ]]; then
			echo "Apologies: currently it is not possible to clump based on GoNL4"
		elif [[ ${REFERENCE} = "1Gp3GONL5" ]]; then
			REFERENCE_1kGp3v5GoNL5=${RESOURCES}/1000Gp3v5_EUR # 1000Gp3v5.20130502.EURs		
		else
		### If arguments are not met than the 
			echo "Oh, computer says no! Number of arguments found "$#"."
			script_arguments_error_reference echo "      *** ERROR *** ERROR --- $(basename "${0}") --- ERROR *** ERROR ***"
			echo ""
			script_copyright_message
		fi
		
	echo ""
	echo "The results & output directory is.......................................: ${METARESULTDIR}"
	echo "The project name is.....................................................: ${PROJECTNAME}"
	echo "We will use the following reference.....................................: ${REFERENCE}"
	echo "We will use the following population (of the reference).................: ${POPULATION}"
	echo "Maximum (largest) p-value to clump......................................: ${CLUMP_P2}"
	echo "Minimum (smallest) p-value to clump.....................................: ${CLUMP_P1}"
	echo "R^2 to use for clumping.................................................: ${CLUMP_R2}"
	echo "The KB range used for clumping..........................................: ${CLUMP_KB}"
	echo "Indicate the name of the clumping field to use (default: p-value, P)....: ${CLUMP_FIELD}"
	echo "Indicate the name of column with the variantID..........................: ${CLUMP_SNP_FIELD}"
	echo ""
	
	echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echo "Parsing clumped meta-analysis results."

	INDEXVARIANTS="${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.summary.${CLUMP_R2}.indexvariants.txt"
	if [[ -s ${INDEXVARIANTS} ]] ; then
		echo "There are indexed variants after clumping in [ "$(basename ${INDEXVARIANTS})" ]."
		VARIANTLIST="${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.summary.${CLUMP_R2}.indexvariants.txt" 
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
			${SCRIPTS}/parseClumps.pl --file ${METARESULTDIR}/meta.results.FABP4.1Gp1.EUR.summary.${CLUMP_R2}.clumped.clumped --variant ${VARIANT} > ${METARESULTDIR}/meta.results.FABP4.1Gp1.EUR.summary.${CLUMP_R2}.${VARIANT}.txt
			
		done < ${VARIANTLIST}
		
	else
		echo ""
		importantnote "There are no clumped variants, so nothing to parse too."
	fi


### END of if-else statement for the number of command-line arguments passed ###
fi

script_copyright_message
