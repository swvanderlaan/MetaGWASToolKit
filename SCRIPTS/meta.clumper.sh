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
echo "                                             META-CLUMPER"
echo "                              CLUMPING OF META-ANALYSIS OF GWAS RESULTS"
echo ""
echo " Version    : v1.2.1"
echo ""
echo " Last update: 2019-12-10"
echo " Written by : Sander W. van der Laan | s.w.vanderlaan@gmail.com."
echo ""
echo " Testers    : - Jessica van Setten"
echo ""
echo " Description: Clumping of a meta-analysis of genome-wide association studies results."
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
	source "$1" # Depends on arg1.
	
	### Directories & Software
	RESOURCES=${METAGWASTOOLKITDIR}/RESOURCES # depends on contents of arg1
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
			REFERENCE_1kGp3v5=${RESOURCES}/1000Gp3v5_EUR # 1000Gp3v5.20130502.EURs
		elif [[ ${REFERENCE} = "GoNL5" ]]; then
			echo "Apologies: currently it is not possible to clump based on GoNL5."
		elif [[ ${REFERENCE} = "GoNL4" ]]; then
			echo "Apologies: currently it is not possible to clump based on GoNL4"
		elif [[ ${REFERENCE} = "1Gp3GONL5" ]]; then
			REFERENCE_1kGp3v5GoNL5=${RESOURCES}/1000Gp3v5_GoNL5 # 1000Gp3v5.20130502.EURs		
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
	echo "Preparing clumping of genome-wide analysis results using the P-values."

	### HEADER summary file
	### VARIANTID CHR POS MINOR MAJOR MAF CODEDALLELE OTHERALLELE CAF N_EFF Z_SQRTN P_SQRTN BETA_FIXED SE_FIXED Z_FIXED P_FIXED BETA_LOWER_FIXED BETA_UPPER_FIXED BETA_GC SE_GC Z_GC P_GC BETA_RANDOM SE_RANDOM Z_RANDOM P_RANDOM BETA_LOWER_RANDOM BETA_UPPER_RANDOM COCHRANS_Q DF P_COCHRANS_Q I_SQUARED TAU_SQUARED DIRECTIONS GENES_250KB NEAREST_GENE NEAREST_GENE_ENSEMBLID NEAREST_GENE_STRAND VARIANT_FUNCTION CAVEAT
	### 1		  2   3   4     5     6   7           8           9   10    11      12      13         14       15      16      17               18               19      20    21   22   23          24        25       26       27                28                29         30 31           32        33          34         35          36           37                     38                  39               40 
	# --exlude ${METARESULTDIR}/duplist.txt
	# what is the basename of the file?
	# meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.summary.txt.gz
	RESULTS=${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.summary.txt.gz
	FILENAME=$(basename ${RESULTS} .txt.gz)
	echo "The basename is: [ ${FILENAME} ]."
	echo ""
	echo "Clumping..."
	if [[ ${REFERENCE} = "HM2" ]]; then
		echo "Apologies: currently it is not possible to clump based on ${REFERENCE}."
	elif [[ ${REFERENCE} = "1Gp1" ]]; then
		echo "The reference is ${REFERENCE}."
		### REFERENCE_1kGp1v3 # 1000Gp1v3.20101123.EUR
		### ls -lh ${REFERENCE_1kGp1v3}/1000Gp1v3.20101123.EUR*
		${PLINK} --bfile ${REFERENCE_1kGp1v3}/1000Gp1v3.20101123.EUR --clump ${METARESULTDIR}/${FILENAME}.txt.gz --clump-snp-field ${CLUMP_SNP_FIELD} --clump-p1 ${CLUMP_P1} --clump-p2 ${CLUMP_P2} --clump-r2 ${CLUMP_R2} --clump-kb ${CLUMP_KB} --clump-field ${CLUMP_FIELD} --out ${METARESULTDIR}/${FILENAME}.${CLUMP_R2}.clumped --clump-verbose --clump-annotate CHR,POS,MINOR,MAJOR,MAF,CODEDALLELE,OTHERALLELE,CAF,N_EFF,BETA_FIXED,SE_FIXED,BETA_LOWER_FIXED,BETA_UPPER_FIXED,Z_FIXED,COCHRANS_Q,DF,P_COCHRANS_Q,I_SQUARED,TAU_SQUARED,DIRECTIONS,GENES_250KB,NEAREST_GENE,NEAREST_GENE_ENSEMBLID,NEAREST_GENE_STRAND,VARIANT_FUNCTION,CAVEAT 
	elif [[ ${REFERENCE} = "1Gp3" ]]; then
		echo "The reference is ${REFERENCE}."
		### REFERENCE_1kGp3v5 # 1000Gp3v5.20130502.EUR
		### ls -lh ${REFERENCE_1kGp3v5}/1000Gp3v5.20130502.EUR*
		${PLINK} --bfile ${REFERENCE_1kGp3v5}/1000Gp3v5.20130502.EUR.noDup.newIDs --memory 28000000  --clump ${METARESULTDIR}/${FILENAME}.txt.gz --clump-snp-field ${CLUMP_SNP_FIELD} --clump-p1 ${CLUMP_P1} --clump-p2 ${CLUMP_P2} --clump-r2 ${CLUMP_R2} --clump-kb ${CLUMP_KB} --clump-field ${CLUMP_FIELD} --out ${METARESULTDIR}/${FILENAME}.${CLUMP_R2}.clumped --clump-verbose --clump-annotate CHR,POS,MINOR,MAJOR,MAF,CODEDALLELE,OTHERALLELE,CAF,N_EFF,BETA_FIXED,SE_FIXED,BETA_LOWER_FIXED,BETA_UPPER_FIXED,Z_FIXED,COCHRANS_Q,DF,P_COCHRANS_Q,I_SQUARED,TAU_SQUARED,DIRECTIONS,GENES_250KB,NEAREST_GENE,NEAREST_GENE_ENSEMBLID,NEAREST_GENE_STRAND,VARIANT_FUNCTION,CAVEAT
	elif [[ ${REFERENCE} = "1Gp3GONL5" ]]; then
		echo "The reference is ${REFERENCE}."
		### REFERENCE_1kGp3v5GoNL5 # 1000Gp3v5.20130502.EUR
		### ls -lh ${REFERENCE_1kGp3v5GoNL5}/1000Gp3v5.20130502.EUR*
		${PLINK} --bfile ${REFERENCE_1kGp3v5GoNL5}/1000Gp3v5_GoNL5 --memory 168960 --clump ${METARESULTDIR}/${FILENAME}.txt.gz --clump-snp-field ${CLUMP_SNP_FIELD} --clump-p1 ${CLUMP_P1} --clump-p2 ${CLUMP_P2} --clump-r2 ${CLUMP_R2} --clump-kb ${CLUMP_KB} --clump-field ${CLUMP_FIELD} --out ${METARESULTDIR}/${FILENAME}.${CLUMP_R2}.clumped --clump-verbose --clump-annotate CHR,POS,MINOR,MAJOR,MAF,CODEDALLELE,OTHERALLELE,CAF,N_EFF,BETA_FIXED,SE_FIXED,BETA_LOWER_FIXED,BETA_UPPER_FIXED,Z_FIXED,COCHRANS_Q,DF,P_COCHRANS_Q,I_SQUARED,TAU_SQUARED,DIRECTIONS,GENES_250KB,NEAREST_GENE,NEAREST_GENE_ENSEMBLID,NEAREST_GENE_STRAND,VARIANT_FUNCTION,CAVEAT 
	elif [[ ${REFERENCE} = "GoNL4" ]]; then
		echo "Apologies: currently it is not possible to clump based on ${REFERENCE}."
	elif [[ ${REFERENCE} = "GoNL5" ]]; then
		echo "Apologies: currently it is not possible to clump based on ${REFERENCE}."
	else
		### If arguments are not met than the 
		echo "Oh, computer says no! Number of arguments found "$#"."
		script_arguments_error_reference echo "      *** ERROR *** ERROR --- $(basename "${0}") --- ERROR *** ERROR ***"
		echo ""
		script_copyright_message
	fi
		#--exclude ${METARESULTDIR}/meta.dupvar
	echo "Done clumping the results for [ ${FILENAME} ]..."
	echo ""
	
	echo "After clumping, pull out the index variants..."
	grep "INDEX" ${METARESULTDIR}/${FILENAME}.${CLUMP_R2}.clumped.clumped | awk ' { print $2 } ' > ${METARESULTDIR}/${FILENAME}.${CLUMP_R2}.indexvariants.txt
	echo "Number of index variants..." 
	cat ${METARESULTDIR}/${FILENAME}.${CLUMP_R2}.indexvariants.txt | wc -l
	
	echo ""
	echo "Copying to a working file..."
	cp -v ${METARESULTDIR}/${FILENAME}.${CLUMP_R2}.indexvariants.txt ${METARESULTDIR}/${FILENAME}.clumped_hits.txt.foo
	echo ""
	
	echo "Counting the total of number of index variants to look at:"
	cat ${METARESULTDIR}/${FILENAME}.clumped_hits.txt.foo | wc -l
	echo "Sorting the total number of unique index variants"
	cat ${METARESULTDIR}/${FILENAME}.clumped_hits.txt.foo | sort -u > ${METARESULTDIR}/${FILENAME}.clumped_hits.txt
	rm -v ${METARESULTDIR}/${FILENAME}.clumped_hits.txt.foo
	echo ""
	
	echo "Making a list of TOP-variants based on p <= ${CLUMP_P1}."
	zcat ${METARESULTDIR}/${FILENAME}.txt.gz | awk '$1=="VARIANTID" || $16 <= '${CLUMP_P1}'' > ${METARESULTDIR}/${FILENAME}.TOP_based_on_p${CLUMP_P1}.txt
	echo ""
	
### END of if-else statement for the number of command-line arguments passed ###
fi

script_copyright_message
