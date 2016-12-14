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
	echoerror "- Argument #1 is path_to/file to the source file."
	echoerror "- Argument #2 is path_to/ the raw, parsed and harmonized GWAS data."
	echoerror "- Argument #3 is the cohort name."
	echoerror "- Argument #4 is the 'dataformat' of the GWAS data [QC/RAW/META]."
	echoerror "- Argument #5 is 'imageformat' you require for the plots of the GWAS data."
	echoerror "- Argument #6 is taken from the source-file and should be the qsub-runtime for plots."
	echoerror "- Argument #7 is taken from the source-file and should be the qsub-memory for plots."
	echoerror "- Argument #8 is 'random sample' taken from the GWAS data required for the P-Z plot."
	echoerror ""
	echoerror "An example command would be: gwas.plotter.sh [arg1] [arg2] [arg3] [arg4] [arg5] [arg6] [arg7] [arg8]"
	echoerror "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  	# The wrong arguments are passed, so we'll exit the script now!
 	echo ""
	script_copyright_message
	exit 1
}

echobold "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echobold "                     GWASPLOTTER: VISUALIZE GENOME-WIDE ASSOCIATION STUDIES"
echobold ""
echobold "* Version:      v1.0.0"
echobold ""
echobold "* Last update:  2016-12-14"
echobold "* Written by:   Sander W. van der Laan - UMC Utrecht - s.w.vanderlaan-2@umcutrecht.nl."
echobold "                Sara Pulit - UMC Utrecht - s.l.pulit@umcutrecht.nl; "
echobold "                Jessica van Setten - UMC Utrecht - j.vansetten@umcutrecht.nl; "
echobold "                Paul I.W. de Bakker - UMC Utrecht - p.i.w.debakker-2@umcutrecht.nl."
echobold "* Testers:      Jessica van Setten - UMC Utrecht - j.vansetten@umcutrecht.nl."
echobold "* Description:  Produce plots (PDF and PNG) for quick inspection and publication."
echobold ""
echobold "* REQUIRED: "
echobold "  - A high-performance computer cluster with a qsub system"
echobold "  - R v3.2+, Python 2.7+, Perl."
echobold "  - Required Python 2.7+ modules: {pandas}, {scipy}, {numpy}."
echobold "  - Required Perl modules: {YAML}, {Statistics::Distributions}, {Getopt::Long}."
echobold "  - Note: it will also work on a Mac OS X system with R and Python installed."
### ADD-IN: function to check requirements...
### This might be a viable option! https://gist.github.com/JamieMason/4761049
echobold ""
echobold "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"


##########################################################################################
### SET THE SCENE FOR THE SCRIPT
##########################################################################################

### START of if-else statement for the number of command-line arguments passed ###
if [[ $# -lt 7 ]]; then 
	echo ""
	echoerror "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echoerrorflash "               *** Oh, computer says no! Number of arguments found "$#". ***"
	echoerror "You must supply [7] arguments when running *** GWASPLOTTER -- MetaGWASToolKit ***!"
	script_arguments_error
else
	echo ""
	echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echo "Processing arguments..."
	source ${1} # depends on arg1
	
	# Where MetaGWASToolKit resides
	METAGWASTOOLKIT=${METAGWASTOOLKITDIR} # from configuration file
	SCRIPTS=${METAGWASTOOLKIT}/SCRIPTS
	
	PROJECTDIR=${2} # depends on arg2
	COHORTNAME=${3} # depends on arg3
	DATAFORMAT=${4} # depends on arg4
	IMAGEFORMAT=${5} # depends on arg5
	QRUNTIMEPLOTTER=${6} # depends on arg6
	QMEMPLOTTER=${7} # depends on arg7
	QRUNTIME="00:05:00" # to remove the intermediate data
	QMEM="4Gb" # to remove the intermediate data
	RANDOMSAMPLE=${RANDOMSAMPLE} # depends on arg1, setting in the source file
	STATTYPE=${STATTYPE} # depends on arg1, setting in the source file

	echo ""
	echo "All arguments are passed. These are the settings:"
	echo "MetaGWASToolKit program.......: "${METAGWASTOOLKIT}
  	echo "MetaGWASToolKit scripts.......: "${SCRIPTS}
	echo "Project directory.............: "${PROJECTDIR}
	echo "Cohort name...................: "${COHORTNAME}
	echo "Data style....................: "${DATAFORMAT}
	echo "Plotting format...............: "${IMAGEFORMAT}
	
	echo ""
	echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echo "Plotting original, cleaned, or meta-analyzed harmonized GWAS data."
	echo ""
	### PREPARING FILES -- ARGUMENT DEPENDENT
	echo "* Setting proper extension..."
	if [[ ${DATAFORMAT} == "QC" ]]; then
		echo "...for 'cleaned harmonized' data..."
		DATAEXT="cdat.gz"
		DATAPLOTID="QC"
		VT="26" # column that holds the variant type information, should be 'SNP' or 'INDEL'
	elif [[ ${DATAFORMAT} == "RAW" ]]; then
		echo "...for 'original harmonized' data..."
		DATAEXT="rdat.gz"
		DATAPLOTID="RAW"
		VT="26" # column that holds the variant type information, should be 'SNP' or 'INDEL'
	elif [[ ${DATAFORMAT} == "META" ]]; then
		echo "...for 'meta-analyzed, cleaned, and harmonized' data..."
		DATAEXT="mdat"
		DATAPLOTID="META"
		VT="22" # column that holds the variant type information, should be 'SNP' or 'INDEL'
	else
		echo ""
		echoerror "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
		echoerrorflash "                 *** Oh, computer says no! DATAFORMAT [${DATAFORMAT}] does not exist! ***"
		echoerror ""
		echoerror "You must supply [7] arguments when running *** GWASPLOTTER -- MetaGWASToolKit ***!"
		echoerror "Specifically: you should set the [DATAFORMAT] of your (meta-)GWAS data to [QC/RAW/META]."
		echoerror "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  		# The wrong arguments are passed, so we'll exit the script now!
		echo ""
		script_copyright_message
		exit 1
	fi
	
	### HEADER .pdat-file
	### Marker CHR BP Strand EffectAllele OtherAllele EAF MAF MAC HWE_P Info Beta SE P  N  N_cases N_controls Imputed
	### 1	   2   3  4      5            6           7   8   9   10    11   12   13 14 15 16      17         18
	
	### HEADER .rdat-file
	### VariantID Marker CHR BP Strand EffectAllele OtherAllele EAF MAF MAC HWE_P Info Beta SE P 	N 	N_cases N_controls Imputed CHR_ref BP_ref REF ALT AlleleA AlleleB VT AF EURAF AFRAF AMRAF ASNAF EASAF SASAF Reference
	### 1		  2      3   4  5      6            7           8   9   10  11    12   13   14 15	16	17      18         19      20      21     22  23  24      25      26 27 28    29    30    31    32    33    34
	
	### HEADER .cdat-file
	### VariantID Marker CHR BP Strand EffectAllele OtherAllele EAF MAF MAC HWE_P Info Beta SE P    N   N_cases N_controls Imputed CHR_ref BP_ref REF ALT AlleleA AlleleB VT AF EURAF AFRAF AMRAF ASNAF EASAF SASAF Reference
	### 1		  2      3   4  5      6            7           8   9   10  11    12   13   14 15	16	17      18         19      20      21     22  23  24      25      26 27 28    29    30    31    32    33    34
	
	echo ""
	### PREPARING FILES -- ARGUMENT DEPENDENT
	if [[ ${DATAFORMAT} == "QC" || ${DATAFORMAT} == "RAW" ]]; then # OPTION: RAW, or QC
		echosucces "Plotting original harmonized data."
		echo "* Making necessary intermediate 'plotting'-files."
		echo ""
		echo "- producing Manhattan-plots..." # CHR, BP, P-value
		zcat ${PROJECTDIR}/${COHORTNAME}.${DATAEXT} | awk '{ print $3, $4, $15 }' | tail -n +2 > ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.txt
		echo "${SCRIPTS}/manhattan.R --projectdir ${PROJECTDIR} --resultfile ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.txt --outputdir ${PROJECTDIR} --colorstyle FULL --imageformat ${IMAGEFORMAT} --title ${COHORTNAME}" > ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.FULL.sh
		qsub -S /bin/bash -N ${COHORTNAME}.${DATAPLOTID}.MANHATTAN -o ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.FULL.log -e ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.FULL.errors -l h_vmem=${QMEMPLOTTER} -l h_rt=${QRUNTIMEPLOTTER} -wd ${PROJECTDIR} ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.FULL.sh
		echo "${SCRIPTS}/manhattan.R --projectdir ${PROJECTDIR} --resultfile ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.txt --outputdir ${PROJECTDIR} --colorstyle QC --imageformat ${IMAGEFORMAT} --title ${COHORTNAME}" > ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.QC.sh
		qsub -S /bin/bash -N ${COHORTNAME}.${DATAPLOTID}.MANHATTAN -o ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.QC.log -e ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.QC.errors -l h_vmem=${QMEMPLOTTER} -l h_rt=${QRUNTIMEPLOTTER} -wd ${PROJECTDIR} ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.QC.sh
		echo "${SCRIPTS}/manhattan.R --projectdir ${PROJECTDIR} --resultfile ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.txt --outputdir ${PROJECTDIR} --colorstyle TWOCOLOR --imageformat ${IMAGEFORMAT} --title ${COHORTNAME}" > ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.TWOCOLOR.sh
		qsub -S /bin/bash -N ${COHORTNAME}.${DATAPLOTID}.MANHATTAN -o ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.TWOCOLOR.log -e ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.TWOCOLOR.errors -l h_vmem=${QMEMPLOTTER} -l h_rt=${QRUNTIMEPLOTTER} -wd ${PROJECTDIR} ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.TWOCOLOR.sh
		echo "rm -v ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.txt" > ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.remover.sh		
		#qsub -S /bin/bash -N ${COHORTNAME}.${DATAPLOTID}.MANHATTAN.remover -hold_jid ${COHORTNAME}.${DATAPLOTID}.MANHATTAN -o ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.remover.log -e ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.remover.errors -l h_vmem=${QMEM} -l h_rt=${QRUNTIME} -wd ${PROJECTDIR} ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.remover.sh

		echo "- producing normal QQ-plots..." # P-value
		zcat ${PROJECTDIR}/${COHORTNAME}.${DATAEXT} | awk '{ print $15 }' | tail -n +2 > ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ.txt
		echo "${SCRIPTS}/qqplot.R --projectdir ${PROJECTDIR} --resultfile ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ.txt --outputdir ${PROJECTDIR} --stattype ${STATTYPE} --imageformat ${IMAGEFORMAT}" > ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ.sh
		qsub -S /bin/bash -N ${COHORTNAME}.${DATAPLOTID}.QQ -o ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ.log -e ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ.errors -l h_vmem=${QMEMPLOTTER} -l h_rt=${QRUNTIMEPLOTTER} -wd ${PROJECTDIR} ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ.sh
		echo "rm -v ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ.txt" > ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ.remover.sh		
		#qsub -S /bin/bash -N ${COHORTNAME}.${DATAPLOTID}.QQ.remover -hold_jid ${COHORTNAME}.${DATAPLOTID}.QQ -o ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ.remover.log -e ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ.remover.errors -l h_vmem=${QMEM} -l h_rt=${QRUNTIME} -wd ${PROJECTDIR} ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ.remover.sh

		echo "- producing QQ-plots stratified by imputation quality..." # P-value, INFO
		zcat ${PROJECTDIR}/${COHORTNAME}.${DATAEXT} | awk '{ print $15, $12 }' | tail -n +2 > ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_INFO.txt
		echo "${SCRIPTS}/qqplot_by_info.R --projectdir ${PROJECTDIR} --resultfile ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_INFO.txt --outputdir ${PROJECTDIR} --stattype ${STATTYPE} --imageformat ${IMAGEFORMAT}" > ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_INFO.sh
		qsub -S /bin/bash -N ${COHORTNAME}.${DATAPLOTID}.QQ_by_INFO -o ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_INFO.log -e ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_INFO.errors -l h_vmem=${QMEMPLOTTER} -l h_rt=${QRUNTIMEPLOTTER} -wd ${PROJECTDIR} ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_INFO.sh
		echo "rm -v ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_INFO.txt" > ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_INFO.remover.sh		
		#qsub -S /bin/bash -N ${COHORTNAME}.${DATAPLOTID}.QQ_by_INFO.remover -hold_jid ${COHORTNAME}.${DATAPLOTID}.QQ_by_INFO -o ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_INFO.remover.log -e ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_INFO.remover.errors -l h_vmem=${QMEM} -l h_rt=${QRUNTIME} -wd ${PROJECTDIR} ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_INFO.remover.sh

		echo "- producing QQ-plots stratified by minor allele frequency..." # P-value, MAF
		zcat ${PROJECTDIR}/${COHORTNAME}.${DATAEXT} | awk '{ print $15, $9 }' | tail -n +2 > ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_CAF.txt
		echo "${SCRIPTS}/qqplot_by_caf.R --projectdir ${PROJECTDIR} --resultfile ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_CAF.txt --outputdir ${PROJECTDIR} --stattype ${STATTYPE} --imageformat ${IMAGEFORMAT}" > ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_CAF.sh
		qsub -S /bin/bash -N ${COHORTNAME}.${DATAPLOTID}.QQ_by_CAF -o ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_CAF.log -e ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_CAF.errors -l h_vmem=${QMEMPLOTTER} -l h_rt=${QRUNTIMEPLOTTER} -wd ${PROJECTDIR} ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_CAF.sh
		echo "rm -v ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_CAF.txt" > ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_CAF.remover.sh		
		#qsub -S /bin/bash -N ${COHORTNAME}.${DATAPLOTID}.QQ_by_CAF.remover -hold_jid ${COHORTNAME}.${DATAPLOTID}.QQ_by_CAF -o ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_CAF.remover.log -e ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_CAF.remover.errors -l h_vmem=${QMEM} -l h_rt=${QRUNTIME} -wd ${PROJECTDIR} ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_CAF.remover.sh
	
		echo "- producing QQ-plots stratified by variant type..." # P-value, VT
		zcat ${PROJECTDIR}/${COHORTNAME}.${DATAEXT} | awk '{ print $15, $'$VT' }' | tail -n +2 > ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_TYPE.txt
		echo "${SCRIPTS}/qqplot_by_type.R --projectdir ${PROJECTDIR} --resultfile ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_TYPE.txt --outputdir ${PROJECTDIR} --stattype ${STATTYPE} --imageformat ${IMAGEFORMAT}" > ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_TYPE.sh
		qsub -S /bin/bash -N ${COHORTNAME}.${DATAPLOTID}.QQ_by_TYPE -o ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_TYPE.log -e ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_TYPE.errors -l h_vmem=${QMEMPLOTTER} -l h_rt=${QRUNTIMEPLOTTER} -wd ${PROJECTDIR} ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_TYPE.sh
		echo "rm -v ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_TYPE.txt" > ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_TYPE.remover.sh		
		#qsub -S /bin/bash -N ${COHORTNAME}.${DATAPLOTID}.QQ_by_TYPE.remover -hold_jid ${COHORTNAME}.${DATAPLOTID}.QQ_by_TYPE -o ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_TYPE.remover.log -e ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_TYPE.remover.errors -l h_vmem=${QMEM} -l h_rt=${QRUNTIME} -wd ${PROJECTDIR} ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_TYPE.remover.sh
	
		echo "- producing histograms of the beta (effect size)..." # BETA
		zcat ${PROJECTDIR}/${COHORTNAME}.${DATAEXT} | awk '{ print $13 }' | tail -n +2 > ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.HISTOGRAM_BETA.txt
		echo "${SCRIPTS}/effectsize_plotter.R --projectdir ${PROJECTDIR} --resultfile ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.HISTOGRAM_BETA.txt --outputdir ${PROJECTDIR} --imageformat ${IMAGEFORMAT}" > ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.HISTOGRAM_BETA.sh
		qsub -S /bin/bash -N ${COHORTNAME}.${DATAPLOTID}.HISTOGRAM_BETA -o ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.HISTOGRAM_BETA.log -e ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.HISTOGRAM_BETA.errors -l h_vmem=${QMEMPLOTTER} -l h_rt=${QRUNTIMEPLOTTER} -wd ${PROJECTDIR} ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.HISTOGRAM_BETA.sh
		echo "rm -v ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.HISTOGRAM_BETA.txt" > ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.HISTOGRAM_BETA.remover.sh		
		#qsub -S /bin/bash -N ${COHORTNAME}.${DATAPLOTID}.HISTOGRAM_BETA.remover -hold_jid ${COHORTNAME}.${DATAPLOTID}.HISTOGRAM_BETA -o ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.HISTOGRAM_BETA.remover.log -e ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.HISTOGRAM_BETA.remover.errors -l h_vmem=${QMEM} -l h_rt=${QRUNTIME} -wd ${PROJECTDIR} ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.HISTOGRAM_BETA.remover.sh

		echo "- producing a correlation plot of the observed p-value and the p-value based on beta and standard error..." # BETA, SE, P-value
		zcat ${PROJECTDIR}/${COHORTNAME}.${DATAEXT} | awk '{ print $13, $14, $15 }' | tail -n +2 > ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.P_Z.txt
		echo "${SCRIPTS}/p_z_plotter.R --projectdir ${PROJECTDIR} --resultfile ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.P_Z.txt --outputdir ${PROJECTDIR} --randomsample ${RANDOMSAMPLE} --imageformat ${IMAGEFORMAT}" > ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.P_Z.sh
		qsub -S /bin/bash -N ${COHORTNAME}.${DATAPLOTID}.P_Z -o ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.P_Z.log -e ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.P_Z.errors -l h_vmem=${QMEMPLOTTER} -l h_rt=${QRUNTIMEPLOTTER} -wd ${PROJECTDIR} ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.P_Z.sh
		echo "rm -v ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.P_Z.txt" > ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.P_Z.remover.sh		
		#qsub -S /bin/bash -N ${COHORTNAME}.${DATAPLOTID}.P_Z.remover -hold_jid ${COHORTNAME}.${DATAPLOTID}.P_Z -o ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.P_Z.remover.log -e ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.P_Z.remover.errors -l h_vmem=${QMEM} -l h_rt=${QRUNTIME} -wd ${PROJECTDIR} ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.P_Z.remover.sh

		echo "- producing histograms of the imputation quality..." # INFO
		zcat ${PROJECTDIR}/${COHORTNAME}.${DATAEXT} | awk '{ print $12 }' | tail -n +2 > ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.INFO.txt
		echo "${SCRIPTS}/info_score_plotter.R --projectdir ${PROJECTDIR} --resultfile ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.INFO.txt --outputdir ${PROJECTDIR} --imageformat ${IMAGEFORMAT}" > ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.INFO.sh
		qsub -S /bin/bash -N ${COHORTNAME}.${DATAPLOTID}.INFO -o ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.INFO.log -e ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.INFO.errors -l h_vmem=${QMEMPLOTTER} -l h_rt=${QRUNTIMEPLOTTER} -wd ${PROJECTDIR} ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.INFO.sh
		echo "rm -v ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.INFO.txt" > ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.INFO.remover.sh		
		#qsub -S /bin/bash -N ${COHORTNAME}.${DATAPLOTID}.INFO.remover -hold_jid ${COHORTNAME}.${DATAPLOTID}.INFO -o ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.INFO.remover.log -e ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.INFO.remover.errors -l h_vmem=${QMEM} -l h_rt=${QRUNTIME} -wd ${PROJECTDIR} ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.INFO.remover.sh
	

	elif [[ ${DATAFORMAT} == "META" ]]; then # OPTION: META
		echosucces "Plotting meta-analysis results."
		echo ""

	else 
		echo ""
		echoerror "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
		echoerrorflash "                 *** Oh, computer says no! DATAFORMAT [${DATAFORMAT}] does not exist! ***"
		echoerror ""
		echoerror "You must supply [7] arguments when running *** GWASPLOTTER -- MetaGWASToolKit ***!"
		echoerror "Specifically: you should set the [DATAFORMAT] of your (meta-)GWAS data to [QC/RAW/META]."
		echoerror "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  		# The wrong arguments are passed, so we'll exit the script now!
		echo ""
		script_copyright_message
		exit 1

	fi
	
### END of if-else statement for the number of command-line arguments passed ###
fi 

script_copyright_message


#echo ""
#echo "================================================================================"
#echo "*** FREQUENCY PLOTTING ***"
#### scripts_allele_freq_plots
### Allele_frequencies.1000G_p1_v3.out
### Allele_frequencies.1000G_p3_v5.out
### allele_frequency_plot_by_ethnicity.Rscript
### dbSNP_146.b37.p13.chr_pos.out
### plotting_allele_frequencies_based_on_ethnicity_1000G_p1.sh
### plotting_allele_frequencies_based_on_ethnicity_1000G_p3.sh

### How to use the script ##
### sh plotting_allele_frequencies_based_on_ethnicity_1000G_p1.sh \
### -s <Allele frequency support file> \
### -i <input file> \
### -r <Rscript file for plotting allele frequencies based on ethnicity> \
### -e <Ethnicity> \    ## Available Options= EUR, AFR, EAS, AMR
### -o <output file prefix>

### sh plotting_allele_frequencies_based_on_ethnicity_1000G_p1.sh \
### -s Allele_frequencies.1000G_p1_v3.out \
### -r allele_frequency_plot_by_ethnicity.Rscript \
### -e EUR \
### -i chr22.CHARGE_EUR.input \
### -o test_chr22_CHARGE_Eur_p1

#	-r ${PROJECTDIR}/scripts_allele_freq_plots/allele_frequency_plot_by_ethnicity.Rscript \

#echo ""
#echo "* Preparing the input files..."
#for FILE in $(ls ${QCEDDATA}/*.gz ); do
#	### PREPARING FILES
#	FILENAME=$(basename ${FILE} .gz)
#	echo "*** Processing file ${FILENAME} ***"
#	echo ""
#	echo "- found file: ${FILE}"
#	echo "- creating files for plotting..." 
#	echo "zcat ${FILE} | awk 'BEGIN {FS==OFS=\"\t\"}; {if (NR==1) { print "'$1'", "'$8'", "'$9'", "'$10'" }}; {if (NR>1 && "'$18'" == 1 && "'$19'" > 0.01 && "'$14'" > 0.50 && "'$13'" != \"NA\") { print "'$1'", "'$8'", "'$9'", "'$10'" }};' > ${PLOTTED}/${FILENAME}.FREQ.txt" > ${PLOTTED}/${FILENAME}.FREQ.sh
#	qsub -S /bin/bash -N ${FILENAME}.FREQ -o ${PLOTTED}/${FILENAME}.FREQ.log -e ${PLOTTED}/${FILENAME}.FREQ.errors -l h_vmem=${QMEM} -l h_rt=${QTIME} -wd ${PROJECTDIR} ${PLOTTED}/${FILENAME}.FREQ.sh
#done

#echo "* Plotting EUROPEAN ancestral populations..."
#for FILE in $(echo `ls ${PLOTTED}/*.EUR.*.FREQ.txt`); do # weirdly this doesn't work when submitting a job...
#	### PREPARING FILES
#	FILENAME=$(basename ${FILE} .txt)
#	echo "*** Processing file ${FILENAME} ***"
#	echo ""
#	echo "- found file: ${FILE}"
#	echo "- plotting frequencies for EUROPEANS..."
#
#	echo "sh ${PROJECTDIR}/scripts_allele_freq_plots/plotting_allele_frequencies_based_on_ethnicity_1000G_p1.sh \
#	-s ${PROJECTDIR}/scripts_allele_freq_plots/Allele_frequencies.1000G_p1_v3.out \
#	-i ${FILE} \
#	-e EUR \
#	-o ${PLOTTED}/${FILENAME} " > ${PLOTTED}/${FILENAME}.AF_PLOTPREP.sh
#	qsub -S /bin/bash -N ${FILENAME}.AF_PLOTPREP -hold_jid ${FILENAME}.FREQ -o ${PLOTTED}/${FILENAME}.AF_PLOTPREP.log -e ${PLOTTED}/${FILENAME}.AF_PLOTPREP.errors -l h_vmem=${QMEM} -l h_rt=${QTIME} -wd ${PROJECTDIR} ${PLOTTED}/${FILENAME}.AF_PLOTPREP.sh
#
#	echo "${SOFTWARE}/MANTEL/SCRIPTS/allele_frequency_plotter.R -p ${PLOTTED} -r ${PLOTTED}/${FILENAME}.AF_PLOT.txt.gz -o ${PLOTTED} -e EUR -f PNG " > ${PLOTTED}/${FILENAME}.AF_PLOT.sh
#	qsub -S /bin/bash -N ${FILENAME}.AF_PLOT -hold_jid ${FILENAME}.AF_PLOTPREP -o ${PLOTTED}/${FILENAME}.AF_PLOT.log -e ${PLOTTED}/${FILENAME}.AF_PLOT.errors -l h_vmem=${QMEM} -l h_rt=${QTIME} -wd ${PROJECTDIR} ${PLOTTED}/${FILENAME}.AF_PLOT.sh
#
#done

#echo ""
#echo "* Plotting AFRICAN ancestral populations..."
#for FILE in $(echo `ls ${PLOTTED}/COMPASS*.AFR.*.FREQ.txt`); do
#	### PREPARING FILES
#	FILENAME=$(basename ${FILE} .txt)
#	echo "*** Processing file ${FILENAME} ***"
#	echo ""
#	echo "- found file: ${FILE}"
#	echo "- plotting frequencies for AFRICANS..."
#
#	echo "sh ${PROJECTDIR}/scripts_allele_freq_plots/plotting_allele_frequencies_based_on_ethnicity_1000G_p1.sh \
#	-s ${PROJECTDIR}/scripts_allele_freq_plots/Allele_frequencies.1000G_p1_v3.out \
#	-i ${FILE} \
#	-e AFR \
#	-o ${PLOTTED}/${FILENAME} " > ${PLOTTED}/${FILENAME}.AF_PLOTPREP.sh
#	qsub -S /bin/bash -N ${FILENAME}.AF_PLOTPREP -hold_jid ${FILENAME}.FREQ -o ${PLOTTED}/${FILENAME}.AF_PLOTPREP.log -e ${PLOTTED}/${FILENAME}.AF_PLOTPREP.errors -l h_vmem=${QMEM} -l h_rt=${QTIME} -wd ${PROJECTDIR} ${PLOTTED}/${FILENAME}.AF_PLOTPREP.sh
#	
#	echo "${SOFTWARE}/MANTEL/SCRIPTS/allele_frequency_plotter.R -p ${PLOTTED} -r ${PLOTTED}/${FILENAME}.AF_PLOT.txt.gz -o ${PLOTTED} -e AFR -f PNG " > ${PLOTTED}/${FILENAME}.AF_PLOT.sh
#	qsub -S /bin/bash -N ${FILENAME}.AF_PLOT -hold_jid ${FILENAME}.AF_PLOTPREP -o ${PLOTTED}/${FILENAME}.AF_PLOT.log -e ${PLOTTED}/${FILENAME}.AF_PLOT.errors -l h_vmem=${QMEM} -l h_rt=${QTIME} -wd ${PROJECTDIR} ${PLOTTED}/${FILENAME}.AF_PLOT.sh
#
#done

#echo ""
#echo "* Plotting SOUTH-/EAST-ASIAN ancestral populations..."
#for FILE in $(echo `ls ${PLOTTED}/*.SAS.*.FREQ.txt`); do
#	### PREPARING FILES
#	FILENAME=$(basename ${FILE} .txt)
#	echo "*** Processing file ${FILENAME} ***"
#	echo ""
#	echo "- found file: ${FILE}"
#	echo "- plotting frequencies for ASIANS..."
#
#	echo "sh ${PROJECTDIR}/scripts_allele_freq_plots/plotting_allele_frequencies_based_on_ethnicity_1000G_p1.sh \
#	-s ${PROJECTDIR}/scripts_allele_freq_plots/Allele_frequencies.1000G_p1_v3.out \
#	-i ${FILE} \
#	-e EAS \
#	-o ${PLOTTED}/${FILENAME} " > ${PLOTTED}/${FILENAME}.AF_PLOTPREP.sh
#	qsub -S /bin/bash -N ${FILENAME}.AF_PLOTPREP -hold_jid ${FILENAME}.FREQ -o ${PLOTTED}/${FILENAME}.AF_PLOTPREP.log -e ${PLOTTED}/${FILENAME}.AF_PLOTPREP.errors -l h_vmem=${QMEM} -l h_rt=${QTIME} -wd ${PROJECTDIR} ${PLOTTED}/${FILENAME}.AF_PLOTPREP.sh
#
#	echo "${SOFTWARE}/MANTEL/SCRIPTS/allele_frequency_plotter.R -p ${PLOTTED} -r ${PLOTTED}/${FILENAME}.AF_PLOT.txt.gz -o ${PLOTTED} -e EAS -f PNG " > ${PLOTTED}/${FILENAME}.AF_PLOT.sh
#	qsub -S /bin/bash -N ${FILENAME}.AF_PLOT -hold_jid ${FILENAME}.AF_PLOTPREP -o ${PLOTTED}/${FILENAME}.AF_PLOT.log -e ${PLOTTED}/${FILENAME}.AF_PLOT.errors -l h_vmem=${QMEM} -l h_rt=${QTIME} -wd ${PROJECTDIR} ${PLOTTED}/${FILENAME}.AF_PLOT.sh
#
#done
#for FILE in $(echo `ls ${PLOTTED}/*.ASN.*.FREQ.txt`); do
#	### PREPARING FILES
#	FILENAME=$(basename ${FILE} .txt)
#	echo "*** Processing file ${FILENAME} ***"
#	echo ""
#	echo "- found file: ${FILE}"
#	echo "- plotting frequencies for ASIANS..."
#
#	echo "sh ${PROJECTDIR}/scripts_allele_freq_plots/plotting_allele_frequencies_based_on_ethnicity_1000G_p1.sh \
#	-s ${PROJECTDIR}/scripts_allele_freq_plots/Allele_frequencies.1000G_p1_v3.out \
#	-i ${FILE} \
#	-e EAS \
#	-o ${PLOTTED}/${FILENAME} " > ${PLOTTED}/${FILENAME}.AF_PLOTPREP.sh
#	qsub -S /bin/bash -N ${FILENAME}.AF_PLOTPREP -hold_jid ${FILENAME}.FREQ -o ${PLOTTED}/${FILENAME}.AF_PLOTPREP.log -e ${PLOTTED}/${FILENAME}.AF_PLOTPREP.errors -l h_vmem=${QMEM} -l h_rt=${QTIME} -wd ${PROJECTDIR} ${PLOTTED}/${FILENAME}.AF_PLOTPREP.sh
#
#	echo "${SOFTWARE}/MANTEL/SCRIPTS/allele_frequency_plotter.R -p ${PLOTTED} -r ${PLOTTED}/${FILENAME}.AF_PLOT.txt.gz -o ${PLOTTED} -e EAS -f PNG " > ${PLOTTED}/${FILENAME}.AF_PLOT.sh
#	qsub -S /bin/bash -N ${FILENAME}.AF_PLOT -hold_jid ${FILENAME}.AF_PLOTPREP -o ${PLOTTED}/${FILENAME}.AF_PLOT.log -e ${PLOTTED}/${FILENAME}.AF_PLOT.errors -l h_vmem=${QMEM} -l h_rt=${QTIME} -wd ${PROJECTDIR} ${PLOTTED}/${FILENAME}.AF_PLOT.sh
#
#done
#for FILE in $(echo `ls ${PLOTTED}/*.EAS.*.FREQ.txt`); do
#	### PREPARING FILES
#	FILENAME=$(basename ${FILE} .txt)
#	echo "*** Processing file ${FILENAME} ***"
#	echo ""
#	echo "- found file: ${FILE}"
#	echo "- plotting frequencies for ASIANS..."
#
#	echo "sh ${PROJECTDIR}/scripts_allele_freq_plots/plotting_allele_frequencies_based_on_ethnicity_1000G_p1.sh \
#	-s ${PROJECTDIR}/scripts_allele_freq_plots/Allele_frequencies.1000G_p1_v3.out \
#	-i ${FILE} \
#	-e EAS \
#	-o ${PLOTTED}/${FILENAME} " > ${PLOTTED}/${FILENAME}.AF_PLOTPREP.sh
#	qsub -S /bin/bash -N ${FILENAME}.AF_PLOTPREP -hold_jid ${FILENAME}.FREQ -o ${PLOTTED}/${FILENAME}.AF_PLOTPREP.log -e ${PLOTTED}/${FILENAME}.AF_PLOTPREP.errors -l h_vmem=${QMEM} -l h_rt=${QTIME} -wd ${PROJECTDIR} ${PLOTTED}/${FILENAME}.AF_PLOTPREP.sh
#
#	echo "${SOFTWARE}/MANTEL/SCRIPTS/allele_frequency_plotter.R -p ${PLOTTED} -r ${PLOTTED}/${FILENAME}.AF_PLOT.txt.gz -o ${PLOTTED} -e EAS -f PNG " > ${PLOTTED}/${FILENAME}.AF_PLOT.sh
#	qsub -S /bin/bash -N ${FILENAME}.AF_PLOT -hold_jid ${FILENAME}.AF_PLOTPREP -o ${PLOTTED}/${FILENAME}.AF_PLOT.log -e ${PLOTTED}/${FILENAME}.AF_PLOT.errors -l h_vmem=${QMEM} -l h_rt=${QTIME} -wd ${PROJECTDIR} ${PLOTTED}/${FILENAME}.AF_PLOT.sh
#
#done
#
#echo ""
#echo "* Plotting AMERICAN ancestral populations..."
#for FILE in $(echo `ls ${PLOTTED}/*.LAT.*.FREQ.txt`); do
#	### PREPARING FILES
#	FILENAME=$(basename ${FILE} .txt)
#	echo "*** Processing file ${FILENAME} ***"
#	echo ""
#	echo "- found file: ${FILE}"
#	echo "- plotting frequencies for AMERICANS..."
#
#	echo "sh ${PROJECTDIR}/scripts_allele_freq_plots/plotting_allele_frequencies_based_on_ethnicity_1000G_p1.sh \
#	-s ${PROJECTDIR}/scripts_allele_freq_plots/Allele_frequencies.1000G_p1_v3.out \
#	-i ${FILE} \
#	-e AMR \
#	-o ${PLOTTED}/${FILENAME} " > ${PLOTTED}/${FILENAME}.AF_PLOTPREP.sh
#	qsub -S /bin/bash -N ${FILENAME}.AF_PLOTPREP -hold_jid ${FILENAME}.FREQ -o ${PLOTTED}/${FILENAME}.AF_PLOTPREP.log -e ${PLOTTED}/${FILENAME}.AF_PLOTPREP.errors -l h_vmem=${QMEM} -l h_rt=${QTIME} -wd ${PROJECTDIR} ${PLOTTED}/${FILENAME}.AF_PLOTPREP.sh
#
#	echo "${SOFTWARE}/MANTEL/SCRIPTS/allele_frequency_plotter.R -p ${PLOTTED} -r ${PLOTTED}/${FILENAME}.AF_PLOT.txt.gz -o ${PLOTTED} -e AMR -f PNG " > ${PLOTTED}/${FILENAME}.AF_PLOT.sh
#	qsub -S /bin/bash -N ${FILENAME}.AF_PLOT -hold_jid ${FILENAME}.AF_PLOTPREP -o ${PLOTTED}/${FILENAME}.AF_PLOT.log -e ${PLOTTED}/${FILENAME}.AF_PLOT.errors -l h_vmem=${QMEM} -l h_rt=${QTIME} -wd ${PROJECTDIR} ${PLOTTED}/${FILENAME}.AF_PLOT.sh
#
#done


