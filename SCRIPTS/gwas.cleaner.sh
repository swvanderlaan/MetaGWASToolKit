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
<<<<<<< HEAD
	echoerror "- Argument #1 is path_to/file to the source file."
	echoerror "- Argument #2 is path_to/ the raw, parsed and harmonized GWAS data."
	echoerror "- Argument #3 is the cohort name."
	echoerror "- Argument #4 is 'basename' of the cohort data file."
	echoerror "- Argument #5 is the variant type used in the GWAS data."
	echoerror ""
	echoerror "An example command would be: gwas.wrapper.sh [arg1] [arg2] [arg3] [arg4] [arg5]"
=======
	echoerror "- Argument #1 is path_to/ the raw, parsed and harmonized GWAS data."
	echoerror "- Argument #2 is the cohort name."
	echoerror "- Argument #3 is 'basename' of the cohort data file."
	echoerror "- Argument #4 is the variant type used in the GWAS data."
	echoerror "- Argument #5 is the effect size filter (beta)."
	echoerror "- Argument #6 is the standard error (of the beta) filter (se)."
	echoerror "- Argument #7 is the minor allele frequency filter (maf)."
	echoerror "- Argument #8 is the minor allele count filter (mac)."
	echoerror "- Argument #9 is the imputation quality (info-metric) filter (info)."
	echoerror "- Argument #10 is the Hardy-Weinberg equilibrium p-value filter (hwe)."
	echoerror "An example command would be: gwas.wrapper.sh [arg1] [arg2] [arg3] [arg4] [arg5] [arg6] [arg7] [arg8] [arg9] [arg10] "
>>>>>>> origin/master
	echoerror "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  	# The wrong arguments are passed, so we'll exit the script now!
 	echo ""
	script_copyright_message
	exit 1
}

echobold "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echobold "                     GWASCLEANER: CLEANER OF GENOME-WIDE ASSOCIATION STUDIES"
echobold ""
echobold "* Version:      v1.0.0"
echobold ""
<<<<<<< HEAD
echobold "* Last update:  2016-12-11"
=======
echobold "* Last update:  2016-12-07"
echobold "* Based on:     MANTEL, as written by Sara Pulit, Jessica van Setten, and Paul de Bakker."
>>>>>>> origin/master
echobold "* Written by:   Sander W. van der Laan | UMC Utrecht | s.w.vanderlaan-2@umcutrecht.nl."
echobold "                Sara Pulit | UMC Utrecht | s.l.pulit@umcutrecht.nl; "
echobold "                Jessica van Setten | UMC Utrecht | j.vansetten@umcutrecht.nl; "
echobold "                Paul I.W. de Bakker | UMC Utrecht | p.i.w.debakker-2@umcutrecht.nl."
echobold "* Testers:      Jessica van Setten | UMC Utrecht | j.vansetten@umcutrecht.nl."
echobold "* Description:  Clean parsed, harmonized GWAS datasets based on pre-defined settings."
echobold ""
echobold "* REQUIRED: "
echobold "  - A high-performance computer cluster with a qsub system"
<<<<<<< HEAD
echobold "  - R v3.2+, Python 2.7+, Perl."
echobold "  - Required Python 2.7+ modules: [pandas], [scipy], [numpy]."
echobold "  - Required Perl modules: [YAML], [Statistics::Distributions], [Getopt::Long]."
echobold "  - Note: it will also work on a Mac OS X system with R and Python installed."
### ADD-IN: function to check requirements...
### This might be a viable option! https://gist.github.com/JamieMason/4761049
echobold ""
echobold "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
=======
echobold "  - R v3.2+, Python 2.7+"
echobold "  - Note: it will also work on a Mac OS X system with R and Python installed."
### ADD-IN: function to check requirements...
echo ""
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
>>>>>>> origin/master

##########################################################################################
### SET THE SCENE FOR THE SCRIPT
##########################################################################################

### START of if-else statement for the number of command-line arguments passed ###
if [[ $# -lt 5 ]]; then 
	echo ""
	echoerror "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echoerrorflash "               *** Oh, computer says no! Number of arguments found "$#". ***"
	echoerror "You must supply [5] arguments when running *** GWASCLEANER -- MetaGWASToolKit ***!"
	script_arguments_error
else
	echo ""
	echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echo "Processing arguments..."
	source ${1}
	
	# Where MetaGWASToolKit resides
	METAGWASTOOLKIT=${METAGWASTOOLKITDIR} # from configuration file
	SCRIPTS=${METAGWASTOOLKIT}/SCRIPTS

	PROJECTDIR=${2} # depends on arg1
	COHORTNAME=${3} # depends on arg2
	BASEFILENAME=${4} # depends on arg3
	VARIANTTYPE=${5} # depends on arg4

	MAF=${MAF} # depends on arg7
	MAC=${MAC} # depends on arg8
	HWE=${HWE} # depends on arg10
	INFO=${INFO} # depends on arg9
	BETA=${BETA} # depends on arg5
	SE=${SE} # depends on arg6

	echo ""
	echo "All arguments are passed. These are the settings:"
	echo "MetaGWASToolKit program.................: "${METAGWASTOOLKIT}
  	echo "MetaGWASToolKit scripts.................: "${SCRIPTS}
	echo "Project directory.......................: "${PROJECTDIR}
	echo "Cohort name.............................: "${COHORTNAME}
	echo "Cohort's raw file name..................: "${BASEFILENAME}.txt.gz
	echo "The basename of the cohort is...........: "${BASEFILENAME}
	echo "Variant type in cohort's data...........: "${VARIANTTYPE}
	echo ""
	echo "Cleaning settings:"
	echo " - BETA -- effect size ±................: "${BETA}
	echo " - SE -- standard error ±...............: "${SE}
	echo " - MAF -- minor allele frequency........: "${MAF}
	echo " - MAC -- minor allele count............: "${MAC}
	echo " - INFO -- imputation quality score.....: "${INFO}
	echo " - HWE p-value..........................: "${HWE}
	echo ""
<<<<<<< HEAD
	echo " Data to be cleaned.....................: "${COHORTNAME}.[rdat/pdat]
	
	echo ""
	echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echo "Cleaning parsed and harmonized GWAS datasets."
	
	### HEADER .pdat-file
	### Marker CHR BP Strand EffectAllele OtherAllele EAF MAF MAC HWE_P Info Beta SE P  N  N_cases N_controls Imputed
	### 1	   2   3  4      5            6           7   8   9   10    11   12   13 14 15 16      17         18
	
	### HEADER .rdat-file
	### VariantID Marker CHR BP Strand EffectAllele OtherAllele EAF MAF MAC HWE_P Info Beta SE P 	N 	N_cases N_controls Imputed CHR_ref BP_ref REF ALT AlleleA AlleleB VT AF EURAF AFRAF AMRAF ASNAF EASAF SASAF Reference
	### 1		  2      3   4  5      6            7           8   9   10  11    12   13   14 15	16	17      18         19      20      21     22  23  24      25      26 27 28    29    30    31    32    33    34
	
	### REPORTING
	echo ""
	echo "Reporting some general statistics."
	echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" > ${PROJECTDIR}/${COHORTNAME}.cleaner.readme
	echo "                              			 DATA CLEANING REPORT" >> ${PROJECTDIR}/${COHORTNAME}.cleaner.readme
	echo "                              		 before meta-analysis of GWAS" >> ${PROJECTDIR}/${COHORTNAME}.cleaner.readme
	echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" >> ${PROJECTDIR}/${COHORTNAME}.cleaner.readme
	echo "" >> ${PROJECTDIR}/${COHORTNAME}.cleaner.readme
	echo "Started on......................................................................: $(date)" >> ${PROJECTDIR}/${COHORTNAME}.cleaner.readme
	echo "Model directory.................................................................: ${PROJECTDIR}" >> ${PROJECTDIR}/${COHORTNAME}.cleaner.readme
	echo "Cohort base filename............................................................: ${COHORTNAME}" >> ${PROJECTDIR}/${COHORTNAME}.cleaner.readme
	echo "" >> ${PROJECTDIR}/${COHORTNAME}.cleaner.readme
	echo "Cleaning parameters set. " >> ${PROJECTDIR}/${COHORTNAME}.cleaner.readme
	echo " - BETA -- effect size ±........................................................: ${BETA}" >> ${PROJECTDIR}/${COHORTNAME}.cleaner.readme
	echo " - SE -- standard error ±.......................................................: ${SE}" >> ${PROJECTDIR}/${COHORTNAME}.cleaner.readme
	echo " - MAF -- minor allele frequency................................................: ${MAF}" >> ${PROJECTDIR}/${COHORTNAME}.cleaner.readme
	echo " - MAC -- minor allele count....................................................: ${MAC}" >> ${PROJECTDIR}/${COHORTNAME}.cleaner.readme
	echo " - INFO -- imputation quality score.............................................: ${INFO}" >> ${PROJECTDIR}/${COHORTNAME}.cleaner.readme
	echo " - HWE p-value..................................................................: ${HWE}" >> ${PROJECTDIR}/${COHORTNAME}.cleaner.readme
	echo "" >> ${PROJECTDIR}/${COHORTNAME}.cleaner.readme
	echo "General statistics." >> ${PROJECTDIR}/${COHORTNAME}.cleaner.readme
	
	cat ${PROJECTDIR}/${COHORTNAME}.rdat | tail -n +2 | awk '{ print $1 }' > ${PROJECTDIR}/${COHORTNAME}.markers.dat
	perl ${SCRIPTS}/uniquefy.pl ${PROJECTDIR}/${COHORTNAME}.markers.dat > ${PROJECTDIR}/${COHORTNAME}.uniquemarkers.dat
	
	UNIQUE_NUMBER_VARIANTS=$(tail -n +2 ${PROJECTDIR}/${COHORTNAME}.uniquemarkers.dat | wc -l | awk '{printf ("%'\''d\n", $0)}')
	
	N_COLUMNS=$(cat ${PROJECTDIR}/${COHORTNAME}.rdat | tail -n +2 | awk '{ print NF }' | sort -n | uniq | awk '{printf ("%'\''d\n", $0)}')
	AVG_NUMBER_VARIANTS=$(cat ${PROJECTDIR}/${COHORTNAME}.rdat | tail -n +2 | awk '{ if($16 != "NA" ) { SUM_N += $16; TOT_N++ } } END { if(TOT_N > 0) print SUM_N / TOT_N; } ' | awk '{printf ("%'\''d\n", $0)}')
	TOT_NUMBER_VARIANTS=$(cat ${PROJECTDIR}/${COHORTNAME}.rdat | tail -n +2 | wc -l | awk '{printf ("%'\''d\n", $0)}')
	NOTREF_NUMBER_VARIANTS=$(cat ${PROJECTDIR}/${COHORTNAME}.rdat | tail -n +2 | awk '( $34 == "no" )' | wc -l | awk '{printf ("%'\''d\n", $0)}')
	REF_NUMBER_VARIANTS=$(cat ${PROJECTDIR}/${COHORTNAME}.rdat | tail -n +2 | awk -F '\t' '( $34 == "yes" )' | wc -l | awk '{printf ("%'\''d\n", $0)}')
	
	BETA_OOR=$(cat ${PROJECTDIR}/${COHORTNAME}.rdat | tail -n +2 | awk '( $13 > '$BETA' || $13 < -'$BETA' )' | wc -l | awk '{printf ("%'\''d\n", $0)}')
	BETA_INVALID=$(cat ${PROJECTDIR}/${COHORTNAME}.rdat | tail -n +2 | awk '( $13 == "NA" )' | wc -l | awk '{printf ("%'\''d\n", $0)}')
	SE_OOR=$(cat ${PROJECTDIR}/${COHORTNAME}.rdat | tail -n +2 | awk '( $14 > '$SE' || $14 < -'$SE' )' | wc -l | awk '{printf ("%'\''d\n", $0)}')
	SE_INVALID=$(cat ${PROJECTDIR}/${COHORTNAME}.rdat | tail -n +2 | awk '( $14 == "NA" )' | wc -l | awk '{printf ("%'\''d\n", $0)}')
	P_OOR=$(cat ${PROJECTDIR}/${COHORTNAME}.rdat | tail -n +2 | awk '( $15 < 0 || $15 > 1)' | wc -l | awk '{printf ("%'\''d\n", $0)}')
	P_INVALID=$(cat ${PROJECTDIR}/${COHORTNAME}.rdat | tail -n +2 | awk '( $15 == "NA" )' | wc -l | awk '{printf ("%'\''d\n", $0)}')
	
	MONOMORPHIC=$(cat ${PROJECTDIR}/${COHORTNAME}.rdat | tail -n +2 | awk '( $9 == "0" || $9 == "1" )' | wc -l | awk '{printf ("%'\''d\n", $0)}')
	MAF_OOR=$(cat ${PROJECTDIR}/${COHORTNAME}.rdat | tail -n +2 | awk '( $9 < '$MAF' || $9 > (1-'$MAF') )' | wc -l | awk '{printf ("%'\''d\n", $0)}')
	MAC_INVALID=$(cat ${PROJECTDIR}/${COHORTNAME}.rdat | tail -n +2 | awk '( $10 < '$MAC' )' | wc -l | awk '{printf ("%'\''d\n", $0)}')
	INFO_INVALID=$(cat ${PROJECTDIR}/${COHORTNAME}.rdat | tail -n +2 | awk '{if($12 != "NA") ( $12 > 1.1 || $12 < '$INFO' )}' | wc -l | awk '{printf ("%'\''d\n", $0)}')
	
	### On screen output
	echo "Sanity check: number of columns (we expect 34)..................................: ${N_COLUMNS}" 
	echo "Average sample size (N) per variant.............................................: ${AVG_NUMBER_VARIANTS}" 
	echo "Total number of variants........................................................: ${TOT_NUMBER_VARIANTS}" 
	echo "Number of unique variants.......................................................: ${UNIQUE_NUMBER_VARIANTS}" 
	echo "Number of variants *not* in the reference.......................................: ${NOTREF_NUMBER_VARIANTS}" 
	echo "Number of variants in the reference.............................................: ${REF_NUMBER_VARIANTS}" 
	echo "Number of variants with out of range effect sizes (-${BETA} > beta > ${BETA}).............: ${BETA_OOR}" 
	echo "Number of variants with invalid effect sizes....................................: ${BETA_INVALID}" 
	echo "Number of variants with out of range standard errors (-${SE} > se > ${SE})............: ${SE_OOR}" 
	echo "Number of variants with invalid standard errors.................................: ${SE_INVALID}" 
	echo "Number of variants with out of range p-values (p < 0, p > 1)....................: ${P_OOR}"
	echo "Number of variants with invalid p-values........................................: ${P_INVALID}" 
	echo "Number of monomorphic variants..................................................: ${MONOMORPHIC}" 
	echo "Number of variants *not* meeting the MAF filter.................................: ${MAF_OOR}" 
	echo "Number of variants *not* meeting the MAC filter.................................: ${MAC_INVALID}" 
	echo "Number of variants *not* meeting the INFO-metric filter.........................: ${INFO_INVALID}" 
	
	### REPORTING
	echo "Sanity check: number of columns (we expect 34)..................................: ${N_COLUMNS}" >> ${PROJECTDIR}/${COHORTNAME}.cleaner.readme
	echo "Average sample size (N) per variant.............................................: ${AVG_NUMBER_VARIANTS}" >> ${PROJECTDIR}/${COHORTNAME}.cleaner.readme
	echo "Total number of variants........................................................: ${TOT_NUMBER_VARIANTS}" >> ${PROJECTDIR}/${COHORTNAME}.cleaner.readme
	echo "Number of unique variants.......................................................: ${UNIQUE_NUMBER_VARIANTS}" >> ${PROJECTDIR}/${COHORTNAME}.cleaner.readme
	echo "Number of variants *not* in the reference.......................................: ${NOTREF_NUMBER_VARIANTS}" >> ${PROJECTDIR}/${COHORTNAME}.cleaner.readme
	echo "Number of variants in the reference.............................................: ${REF_NUMBER_VARIANTS}" >> ${PROJECTDIR}/${COHORTNAME}.cleaner.readme
	echo "Number of variants with out of range effect sizes (-${BETA} > beta > ${BETA}).............: ${BETA_OOR}" >> ${PROJECTDIR}/${COHORTNAME}.cleaner.readme
	echo "Number of variants with invalid effect sizes....................................: ${BETA_INVALID}" >> ${PROJECTDIR}/${COHORTNAME}.cleaner.readme
	echo "Number of variants with out of range standard errors (-${SE} > se > ${SE})............: ${SE_OOR}" >> ${PROJECTDIR}/${COHORTNAME}.cleaner.readme
	echo "Number of variants with invalid standard errors.................................: ${SE_INVALID}" >> ${PROJECTDIR}/${COHORTNAME}.cleaner.readme
	echo "Number of variants with out of range p-values (p < 0, p > 1)....................: ${P_OOR}" >> ${PROJECTDIR}/${COHORTNAME}.cleaner.readme
	echo "Number of variants with invalid p-values........................................: ${P_INVALID}" >> ${PROJECTDIR}/${COHORTNAME}.cleaner.readme
	echo "Number of monomorphic variants..................................................: ${MONOMORPHIC}" >> ${PROJECTDIR}/${COHORTNAME}.cleaner.readme
	echo "Number of variants *not* meeting the MAF filter.................................: ${MAF_OOR}" >> ${PROJECTDIR}/${COHORTNAME}.cleaner.readme
	echo "Number of variants *not* meeting the MAC filter.................................: ${MAC_INVALID}" >> ${PROJECTDIR}/${COHORTNAME}.cleaner.readme
	echo "Number of variants *not* meeting the INFO-metric filter.........................: ${INFO_INVALID}" >> ${PROJECTDIR}/${COHORTNAME}.cleaner.readme
	echo "" >> ${PROJECTDIR}/${COHORTNAME}.cleaner.readme
	
	echo ""
	echo "Applying filters..."
	cat ${PROJECTDIR}/${COHORTNAME}.rdat | tail -n +2 | awk '( ($13 < '$BETA' && $13 > -'$BETA' && $13 != "NA") && ($14 < '$SE' && $14 > -'$SE' && $14 != "NA") && ($15 > 0 && $15 < 1 && $15 != "NA") && ($9 != 0 && $9 != 1 && $9 > '$MAF' && $9 < (1-'$MAF')) && ($10 > '$MAC') && ($12 < 1.1 && $12 > '$INFO' || $12 == "NA" ) )' > ${PROJECTDIR}/${COHORTNAME}.cdat.temp
	### VariantID Marker CHR BP Strand EffectAllele OtherAllele EAF MAF MAC HWE_P Info Beta SE P 	N 	N_cases N_controls Imputed CHR_ref BP_ref REF ALT AlleleA AlleleB VT AF EURAF AFRAF AMRAF ASNAF EASAF SASAF Reference
	### 1		  2      3   4  5      6            7           8   9   10  11    12   13   14 15	16	17      18         19      20      21     22  23  24      25      26 27 28    29    30    31    32    33    34
	echo "Making cleaned dataset..."
	echo "VariantID Marker CHR BP Strand EffectAllele OtherAllele EAF MAF MAC HWE_P Info Beta SE P N N_cases N_controls Imputed REF ALT VT AF EURAF AFRAF AMRAF ASNAF EASAF SASAF Reference" > ${PROJECTDIR}/${COHORTNAME}.cdat
	cat ${PROJECTDIR}/${COHORTNAME}.cdat.temp | awk '{ print 1, $2, $20, $21, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $24, $25, $26, $27, $28, $29, $30, $31, $32, $33, $34 }' >> ${PROJECTDIR}/${COHORTNAME}.cdat
	echo ""
	echo "GWAS dataset is parsed, harmonized, and cleaned."
	QC_NUMBER_VARIANTS=$(cat ${PROJECTDIR}/${COHORTNAME}.cdat | tail -n +2 | wc -l | awk '{printf ("%'\''d\n", $0)}')
	
	### On screen output
	echo "Number of variants after cleaning...............................................: ${QC_NUMBER_VARIANTS}"
	### REPORTING
	echo "Number of variants after cleaning...............................................: ${QC_NUMBER_VARIANTS}" >> ${PROJECTDIR}/${COHORTNAME}.cleaner.readme
	echo "" >> ${PROJECTDIR}/${COHORTNAME}.cleaner.readme
	
	echo ""
	echo "Gzipping (intermediate) and removing temporary files..."
	#gzip -v ${PROJECTDIR}/${COHORTNAME}.markers.dat
	#gzip -v ${PROJECTDIR}/${COHORTNAME}.uniquemarkers.dat
	#gzip -v ${PROJECTDIR}/${COHORTNAME}.pdat
	#gzip -v ${PROJECTDIR}/${COHORTNAME}.rdat
	#gzip -v ${PROJECTDIR}/${COHORTNAME}.cdat
	
	echo "" >> ${PROJECTDIR}/${COHORTNAME}.cleaner.readme
	echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" >> ${PROJECTDIR}/${COHORTNAME}.cleaner.readme
	echo "                              		 * END OF DATA CLEANING REPORT *" >> ${PROJECTDIR}/${COHORTNAME}.cleaner.readme
	echo " [ finished on: $(date) ]" >> ${PROJECTDIR}/${COHORTNAME}.cleaner.readme
	echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" >> ${PROJECTDIR}/${COHORTNAME}.cleaner.readme
	echo ""
	
	### END of if-else statement for the number of command-line arguments passed ###
=======
	echo " Data to be cleaned.....................: "${COHORTNAME}.rdat
	
echo ""
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "Cleaning parsed and harmonized GWAS datasets."

### HEADER .pdat-file
### Marker CHR BP Strand EffectAllele OtherAllele EAF MAF MAC HWE_P Info Beta SE P  N  N_cases N_controls Imputed
### 1	   2   3  4      5            6           7   8   9   10    11   12   13 14 15 16      17         18

### HEADER .rdat-file
### VariantID Marker CHR BP Strand EffectAllele OtherAllele EAF MAF MAC HWE_P Info Beta SE P 	N 	N_cases N_controls Imputed CHR_ref BP_ref REF ALT AlleleA AlleleB VT AF EURAF AFRAF AMRAF ASNAF EASAF SASAF Reference
### 1		  2      3   4  5      6            7           8   9   10  11    12   13   14 15	16	17      18         19      20      21     22  23  24      25      26 27 28    29    30    31    32    33    34

### REPORTING
echo ""
echo "Reporting some general statistics."
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" > ${PROJECTDIR}/${COHORTNAME}.cleaner.readme
echo "                              			 DATA CLEANING REPORT" >> ${PROJECTDIR}/${COHORTNAME}.cleaner.readme
echo "                              		 before meta-analysis of GWAS" >> ${PROJECTDIR}/${COHORTNAME}.cleaner.readme
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" >> ${PROJECTDIR}/${COHORTNAME}.cleaner.readme
echo "" >> ${PROJECTDIR}/${COHORTNAME}.cleaner.readme
echo "Started on......................................................................:  $(date)" >> ${PROJECTDIR}/${COHORTNAME}.cleaner.readme
echo "Model directory.................................................................:  ${PROJECTDIR}" >> ${PROJECTDIR}/${COHORTNAME}.cleaner.readme
echo "Cohort base filename............................................................:  ${COHORTNAME}" >> ${PROJECTDIR}/${COHORTNAME}.cleaner.readme
echo ""
echo "Cleaning parameters set. " >> ${PROJECTDIR}/${COHORTNAME}.cleaner.readme
echo " - BETA -- effect size ±........................................................:  ${BETA}" >> ${PROJECTDIR}/${COHORTNAME}.cleaner.readme
echo " - SE -- standard error ±.......................................................:  ${SE}" >> ${PROJECTDIR}/${COHORTNAME}.cleaner.readme
echo " - MAF -- minor allele frequency................................................:  ${MAF}" >> ${PROJECTDIR}/${COHORTNAME}.cleaner.readme
echo " - MAC -- minor allele count....................................................:  ${MAC}" >> ${PROJECTDIR}/${COHORTNAME}.cleaner.readme
echo " - INFO -- imputation quality score.............................................:  ${INFO}" >> ${PROJECTDIR}/${COHORTNAME}.cleaner.readme
echo " - HWE p-value..................................................................:  ${HWE}" >> ${PROJECTDIR}/${COHORTNAME}.cleaner.readme
echo "" >> ${PROJECTDIR}/${COHORTNAME}.cleaner.readme
echo "General statistics." >> ${PROJECTDIR}/${COHORTNAME}.cleaner.readme

cat ${PROJECTDIR}/${COHORTNAME}.rdat | tail -n +2 | awk ' { print $1 } ' > ${PROJECTDIR}/${COHORTNAME}.markers.dat
perl ${SCRIPTS}/uniquefy.pl ${PROJECTDIR}/${COHORTNAME}.markers.dat > ${PROJECTDIR}/${COHORTNAME}.uniquemarkers.dat

UNIQUE_NUMBER_VARIANTS=$(tail -n +2 ${PROJECTDIR}/${COHORTNAME}.uniquemarkers.dat | wc -l | awk '{printf ("%'\''d\n", $0)}')

AVG_NUMBER_VARIANTS=$(cat ${PROJECTDIR}/${COHORTNAME}.rdat | tail -n +2 | awk '{ sum += $16; n++ } END { if (n > 0) print sum / n; }' | awk '{printf ("%'\''d\n", $0)}')
TOT_NUMBER_VARIANTS=$(cat ${PROJECTDIR}/${COHORTNAME}.rdat | tail -n +2 | wc -l | awk '{printf ("%'\''d\n", $0)}')
NOTREF_NUMBER_VARIANTS=$(cat ${PROJECTDIR}/${COHORTNAME}.rdat | tail -n +2 | awk '( $34 == "no" )' | wc -l | awk '{printf ("%'\''d\n", $0)}')
REF_NUMBER_VARIANTS=$(cat ${PROJECTDIR}/${COHORTNAME}.rdat | tail -n +2 | awk '( $34 == "yes" )' | wc -l | awk '{printf ("%'\''d\n", $0)}')

BETA_OOR=$(cat ${PROJECTDIR}/${COHORTNAME}.rdat | tail -n +2 | awk '( $13 > '$BETA' || $13 < -'$BETA' )' | wc -l | awk '{printf ("%'\''d\n", $0)}')
BETA_INVALID=$(cat ${PROJECTDIR}/${COHORTNAME}.rdat | tail -n +2 | awk '( $13 == "NA" )' | wc -l | awk '{printf ("%'\''d\n", $0)}')
SE_OOR=$(cat ${PROJECTDIR}/${COHORTNAME}.rdat | tail -n +2 | awk '( $14 > '$SE' || $14 < -'$SE' )' | wc -l | awk '{printf ("%'\''d\n", $0)}')
SE_INVALID=$(cat ${PROJECTDIR}/${COHORTNAME}.rdat | tail -n +2 | awk '( $14 == "NA" )' | wc -l | awk '{printf ("%'\''d\n", $0)}')
P_OOR=$(cat ${PROJECTDIR}/${COHORTNAME}.rdat | tail -n +2 | awk '( $15 < 0 || $15 > 1 )' | wc -l | awk '{printf ("%'\''d\n", $0)}')
P_INVALID=$(cat ${PROJECTDIR}/${COHORTNAME}.rdat | tail -n +2 | awk '( $15 == "NA" )' | wc -l | awk '{printf ("%'\''d\n", $0)}')

MONOMORPHIC=$(cat ${PROJECTDIR}/${COHORTNAME}.rdat | tail -n +2 | awk '( $9 == "0" || $9 == "1" )' | wc -l | awk '{printf ("%'\''d\n", $0)}')
MAF_OOR=$(cat ${PROJECTDIR}/${COHORTNAME}.rdat | tail -n +2 | awk '( $9 < '$MAF' || $9 > (1-'$MAF') )' | wc -l | awk '{printf ("%'\''d\n", $0)}')
MAC_INVALID=$(cat ${PROJECTDIR}/${COHORTNAME}.rdat | tail -n +2 | awk '( $10 < '$MAC' )' | wc -l | awk '{printf ("%'\''d\n", $0)}')
INFO_INVALID=$(cat ${PROJECTDIR}/${COHORTNAME}.rdat | tail -n +2 | awk '( $12 > 1.1 || $12 < '$INFO' )' | wc -l | awk '{printf ("%'\''d\n", $0)}')

echo "Average sample size (N) per variant.............................................: ${AVG_NUMBER_VARIANTS}" 
echo "Total number of variants........................................................: ${TOT_NUMBER_VARIANTS}" 
echo "Number of unique variants.......................................................: ${UNIQUE_NUMBER_VARIANTS}" 
echo "Number of variants *not* in the reference.......................................: ${NOTREF_NUMBER_VARIANTS}" 
echo "Number of variants in the reference.............................................: ${REF_NUMBER_VARIANTS}" 
echo "Number of variants with out of range effect sizes (-${BETA} > beta > ${BETA}).............: ${BETA_OOR}" 
echo "Number of variants with invalid effect sizes....................................: ${BETA_INVALID}" 
echo "Number of variants with out of range standard errors (-${SE} > se > ${SE})............: ${SE_OOR}" 
echo "Number of variants with invalid standard errors.................................: ${SE_INVALID}" 
echo "Number of variants with out of range p-values (p < 0, p > 1)....................: ${P_OOR}" 
echo "Number of variants with invalid p-values........................................: ${P_INVALID}" 
echo "Number of monomorphic variants..................................................: ${MONOMORPHIC}" 
echo "Number of variants not meeting the MAF filter...................................: ${MAF_OOR}" 
echo "Number of variants not meeting the MAC filter...................................: ${MAC_INVALID}" 
echo "Number of variants not meeting the INFO-metric filter...........................: ${INFO_INVALID}" 

### REPORTING
echo "Average sample size (N) per variant.............................................: ${AVG_NUMBER_VARIANTS}" >> ${PROJECTDIR}/${COHORTNAME}.cleaner.readme
echo "Total number of variants........................................................: ${TOT_NUMBER_VARIANTS}" >> ${PROJECTDIR}/${COHORTNAME}.cleaner.readme
echo "Number of unique variants.......................................................: ${UNIQUE_NUMBER_VARIANTS}" >> ${PROJECTDIR}/${COHORTNAME}.cleaner.readme
echo "Number of variants *not* in the reference.......................................: ${NOTREF_NUMBER_VARIANTS}" >> ${PROJECTDIR}/${COHORTNAME}.cleaner.readme
echo "Number of variants in the reference.............................................: ${REF_NUMBER_VARIANTS}" >> ${PROJECTDIR}/${COHORTNAME}.cleaner.readme
echo "Number of variants with out of range effect sizes (-${BETA} > beta > ${BETA}).............: ${BETA_OOR}" >> ${PROJECTDIR}/${COHORTNAME}.cleaner.readme
echo "Number of variants with invalid effect sizes....................................: ${BETA_INVALID}" >> ${PROJECTDIR}/${COHORTNAME}.cleaner.readme
echo "Number of variants with out of range standard errors (-${SE} > se > ${SE})............: ${SE_OOR}" >> ${PROJECTDIR}/${COHORTNAME}.cleaner.readme
echo "Number of variants with invalid standard errors.................................: ${SE_INVALID}" >> ${PROJECTDIR}/${COHORTNAME}.cleaner.readme
echo "Number of variants with out of range p-values (p < 0, p > 1)....................: ${P_OOR}" >> ${PROJECTDIR}/${COHORTNAME}.cleaner.readme
echo "Number of variants with invalid p-values........................................: ${P_INVALID}" >> ${PROJECTDIR}/${COHORTNAME}.cleaner.readme
echo "Number of monomorphic variants..................................................: ${MONOMORPHIC}" >> ${PROJECTDIR}/${COHORTNAME}.cleaner.readme
echo "Number of variants not meeting the MAF filter...................................: ${MAF_OOR}" >> ${PROJECTDIR}/${COHORTNAME}.cleaner.readme
echo "Number of variants not meeting the MAC filter...................................: ${MAC_INVALID}" >> ${PROJECTDIR}/${COHORTNAME}.cleaner.readme
echo "Number of variants not meeting the INFO-metric filter...........................: ${INFO_INVALID}" >> ${PROJECTDIR}/${COHORTNAME}.cleaner.readme
echo "" >> ${PROJECTDIR}/${COHORTNAME}.cleaner.readme

echo ""
echo "Applying filters..."
echo "VariantID Marker CHR BP BETA SE P EffectAllele OtherAllele EAF INFO MAF MAC N STRAND VT" > ${PROJECTDIR}/${COHORTNAME}.cdat
cat ${PROJECTDIR}/${COHORTNAME}.rdat | tail -n +2 | awk ' ( NF == 34 && $13 < $BETA && $13 > -$BETA && $13 != "NA" && $14 < $SE && $14 > -$SE && $14 != "NA" && $15 > 0 && $15 < 1 && $15 != "NA" && $9 != 0 && $9 != 1 && $9 > $MAF && $9 < (1-$MAF) && $10 > $MAC && $12 < 1.1 && $12 > $INFO )' >> ${PROJECTDIR}/${COHORTNAME}.cdat.temp

cat ${PROJECTDIR}/${COHORTNAME}.cdat.temp | head

#cat ${PROJECTDIR}/${COHORTNAME}.cdat.temp | awk '{ }' >> ${PROJECTDIR}/${COHORTNAME}.cdat

echo "GWAS dataset is parsed, harmonized, and cleaned."
# QC_NUMBER_VARIANTS=$(tail -n +2 ${PROJECTDIR}/${COHORTNAME}.cdat | wc -l | awk '{printf ("%'\''d\n", $0)}')
# 
# ### REPORTING
# echo "Number of variants after cleaning...............................................: ${QC_NUMBER_VARIANTS}" >> ${PROJECTDIR}/${COHORTNAME}.cleaner.readme
echo "" >> ${PROJECTDIR}/${COHORTNAME}.cleaner.readme

echo "Gzipping (intermediate) and removing temporary files..."
#gzip -v ${PROJECTDIR}/${COHORTNAME}.markers.dat
#gzip -v ${PROJECTDIR}/${COHORTNAME}.uniquemarkers.dat
#gzip -v ${PROJECTDIR}/${COHORTNAME}.pdat
#gzip -v ${PROJECTDIR}/${COHORTNAME}.rdat
#gzip -v ${PROJECTDIR}/${COHORTNAME}.cdat

echo "" >> ${PROJECTDIR}/${COHORTNAME}.cleaner.readme
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" >> ${PROJECTDIR}/${COHORTNAME}.cleaner.readme
echo "                              		 * END OF DATA CLEANING REPORT *" >> ${PROJECTDIR}/${COHORTNAME}.cleaner.readme
echo " [ finished on: $(date) ]" >> ${PROJECTDIR}/${COHORTNAME}.cleaner.readme
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" >> ${PROJECTDIR}/${COHORTNAME}.cleaner.readme
echo ""

### END of if-else statement for the number of command-line arguments passed ###
>>>>>>> origin/master
fi 

script_copyright_message