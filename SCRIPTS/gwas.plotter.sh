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
echobold "* Version:      v1.0.6"
echobold ""
echobold "* Last update:  2017-05-22"
echobold "* Written by:   Sander W. van der Laan - UMC Utrecht - s.w.vanderlaan-2@umcutrecht.nl."
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
	QRUNTIME=${QRUNTIME} # to remove the intermediate data
	QMEM=${QMEM} # to remove the intermediate data
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
	elif [[ ${DATAFORMAT} == "RAW" ]]; then
		echo "...for 'original harmonized' data..."
		DATAEXT="rdat.gz"
		DATAPLOTID="RAW"
	elif [[ ${DATAFORMAT} == "META" ]]; then
		echo "...for 'meta-analyzed, cleaned, and harmonized' data..."
		DATAEXT="mdat.gz"
		DATAPLOTID="META"
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
	### Marker	MarkerOriginal	CHR	BP	Strand	EffectAllele	OtherAllele	MinorAllele	MajorAllele	EAF	MAF	MAC	HWE_P	Info	Beta	BetaMinor	SE	P	N	N_cases	N_controls	Imputed
	### 1	    2               3   4   5       6               7           8           9           10  11  12  13      14      15      16          17  18  19  20      21          22
	
	### HEADER .rdat-file
	### VariantID	Marker	MarkerOriginal	CHR	BP	Strand	EffectAllele	OtherAllele	MinorAllele	MajorAllele	EAF	MAF	MAC	HWE_P	Info	Beta	BetaMinor	SE	P	N	N_cases	N_controls	Imputed	Reference
	### 1		    2       3               4   5   6       7               8           9           10          11  12  13  14      15	    16	    17          18  19  20  21      22          23      24
	
	### HEADER .cdat-file
	### VariantID	Marker	MarkerOriginal	CHR	BP	Strand	EffectAllele	OtherAllele	MinorAllele	MajorAllele	EAF	MAF	MAC	HWE_P	Info	Beta	BetaMinor	SE	P	N	N_cases	N_controls	Imputed	Reference
	### 1		    2       3               4   5   6       7               8           9           10          11  12  13  14      15	    16	    17          18  19  20  21      22          23      24
	
	echo ""
	### PREPARING FILES -- ARGUMENT DEPENDENT
	if [[ ${DATAFORMAT} == "QC" || ${DATAFORMAT} == "RAW" ]]; then # OPTION: RAW, or QC
		echosucces "Plotting original harmonized data."
		echo "* Making necessary intermediate 'plotting'-files."
		echo ""
		echo "- producing Manhattan-plots..." # CHR, BP, P-value
		zcat ${PROJECTDIR}/${COHORTNAME}.${DATAEXT} | ${SCRIPTS}/parseTable.pl --col CHR,BP,P | tail -n +2 > ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.txt
		echo "Rscript ${SCRIPTS}/plotter.manhattan.R --projectdir ${PROJECTDIR} --resultfile ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.txt --outputdir ${PROJECTDIR} --colorstyle FULL --imageformat ${IMAGEFORMAT} --title ${COHORTNAME}" > ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.FULL.sh
		qsub -S /bin/bash -N ${COHORTNAME}.${DATAPLOTID}.MANHATTAN -o ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.FULL.log -e ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.FULL.errors -l h_vmem=${QMEMPLOTTER} -l h_rt=${QRUNTIMEPLOTTER} -wd ${PROJECTDIR} ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.FULL.sh
		echo "Rscript ${SCRIPTS}/plotter.manhattan.R --projectdir ${PROJECTDIR} --resultfile ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.txt --outputdir ${PROJECTDIR} --colorstyle QC --imageformat ${IMAGEFORMAT} --title ${COHORTNAME}" > ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.QC.sh
		qsub -S /bin/bash -N ${COHORTNAME}.${DATAPLOTID}.MANHATTAN -o ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.QC.log -e ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.QC.errors -l h_vmem=${QMEMPLOTTER} -l h_rt=${QRUNTIMEPLOTTER} -wd ${PROJECTDIR} ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.QC.sh
		echo "Rscript ${SCRIPTS}/plotter.manhattan.R --projectdir ${PROJECTDIR} --resultfile ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.txt --outputdir ${PROJECTDIR} --colorstyle TWOCOLOR --imageformat ${IMAGEFORMAT} --title ${COHORTNAME}" > ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.TWOCOLOR.sh
		qsub -S /bin/bash -N ${COHORTNAME}.${DATAPLOTID}.MANHATTAN -o ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.TWOCOLOR.log -e ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.TWOCOLOR.errors -l h_vmem=${QMEMPLOTTER} -l h_rt=${QRUNTIMEPLOTTER} -wd ${PROJECTDIR} ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.TWOCOLOR.sh
		echo "rm -v ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.txt ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.FULL.sh ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.QC.sh ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.TWOCOLOR.sh ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.FULL.errors ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.QC.errors ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.TWOCOLOR.errors ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.FULL.log ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.QC.log ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.TWOCOLOR.log" > ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.remover.sh		
		qsub -S /bin/bash -N ${COHORTNAME}.${DATAPLOTID}.MANHATTAN.remover -hold_jid ${COHORTNAME}.${DATAPLOTID}.MANHATTAN -o ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.remover.log -e ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.remover.errors -l h_vmem=${QMEM} -l h_rt=${QRUNTIME} -wd ${PROJECTDIR} ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.remover.sh

		echo "- producing normal QQ-plots..." # P-value
		zcat ${PROJECTDIR}/${COHORTNAME}.${DATAEXT} | ${SCRIPTS}/parseTable.pl --col P | tail -n +2 > ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ.txt
		echo "Rscript ${SCRIPTS}/plotter.qq.R --projectdir ${PROJECTDIR} --resultfile ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ.txt --outputdir ${PROJECTDIR} --stattype ${STATTYPE} --imageformat ${IMAGEFORMAT}" > ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ.sh
		qsub -S /bin/bash -N ${COHORTNAME}.${DATAPLOTID}.QQ -o ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ.log -e ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ.errors -l h_vmem=${QMEMPLOTTER} -l h_rt=${QRUNTIMEPLOTTER} -wd ${PROJECTDIR} ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ.sh
		echo "rm -v ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ.txt ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ.sh ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ.errors ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ.log" > ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ.remover.sh		
		qsub -S /bin/bash -N ${COHORTNAME}.${DATAPLOTID}.QQ.remover -hold_jid ${COHORTNAME}.${DATAPLOTID}.QQ -o ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ.remover.log -e ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ.remover.errors -l h_vmem=${QMEM} -l h_rt=${QRUNTIME} -wd ${PROJECTDIR} ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ.remover.sh

		echo "- producing QQ-plots stratified by imputation quality..." # P-value, INFO
		zcat ${PROJECTDIR}/${COHORTNAME}.${DATAEXT} | ${SCRIPTS}/parseTable.pl --col P,Info | tail -n +2 > ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_INFO.txt
		echo "Rscript ${SCRIPTS}/plotter.qq_by_info.R --projectdir ${PROJECTDIR} --resultfile ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_INFO.txt --outputdir ${PROJECTDIR} --stattype ${STATTYPE} --imageformat ${IMAGEFORMAT}" > ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_INFO.sh
		qsub -S /bin/bash -N ${COHORTNAME}.${DATAPLOTID}.QQ_by_INFO -o ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_INFO.log -e ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_INFO.errors -l h_vmem=${QMEMPLOTTER} -l h_rt=${QRUNTIMEPLOTTER} -wd ${PROJECTDIR} ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_INFO.sh
		echo "rm -v ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_INFO.txt ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_INFO.sh ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_INFO.errors ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_INFO.log" > ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_INFO.remover.sh		
		qsub -S /bin/bash -N ${COHORTNAME}.${DATAPLOTID}.QQ_by_INFO.remover -hold_jid ${COHORTNAME}.${DATAPLOTID}.QQ_by_INFO -o ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_INFO.remover.log -e ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_INFO.remover.errors -l h_vmem=${QMEM} -l h_rt=${QRUNTIME} -wd ${PROJECTDIR} ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_INFO.remover.sh

		echo "- producing QQ-plots stratified by minor allele frequency..." # P-value, MAF
		zcat ${PROJECTDIR}/${COHORTNAME}.${DATAEXT} | ${SCRIPTS}/parseTable.pl --col P,MAF | tail -n +2 > ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_CAF.txt
		echo "Rscript ${SCRIPTS}/plotter.qqplot_by_caf.R --projectdir ${PROJECTDIR} --resultfile ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_CAF.txt --outputdir ${PROJECTDIR} --stattype ${STATTYPE} --imageformat ${IMAGEFORMAT}" > ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_CAF.sh
		qsub -S /bin/bash -N ${COHORTNAME}.${DATAPLOTID}.QQ_by_CAF -o ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_CAF.log -e ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_CAF.errors -l h_vmem=${QMEMPLOTTER} -l h_rt=${QRUNTIMEPLOTTER} -wd ${PROJECTDIR} ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_CAF.sh
		echo "rm -v ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_CAF.txt ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_CAF.sh ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_CAF.errors ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_CAF.log" > ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_CAF.remover.sh		
		qsub -S /bin/bash -N ${COHORTNAME}.${DATAPLOTID}.QQ_by_CAF.remover -hold_jid ${COHORTNAME}.${DATAPLOTID}.QQ_by_CAF -o ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_CAF.remover.log -e ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_CAF.remover.errors -l h_vmem=${QMEM} -l h_rt=${QRUNTIME} -wd ${PROJECTDIR} ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_CAF.remover.sh
	
		echo "- producing histograms of the beta (effect size)..." # BETA
		zcat ${PROJECTDIR}/${COHORTNAME}.${DATAEXT} | ${SCRIPTS}/parseTable.pl --col BetaMinor | tail -n +2 > ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.HISTOGRAM_BETA.txt
		echo "Rscript ${SCRIPTS}/plotter.effectsize.R --projectdir ${PROJECTDIR} --resultfile ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.HISTOGRAM_BETA.txt --outputdir ${PROJECTDIR} --imageformat ${IMAGEFORMAT}" > ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.HISTOGRAM_BETA.sh
		qsub -S /bin/bash -N ${COHORTNAME}.${DATAPLOTID}.HISTOGRAM_BETA -o ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.HISTOGRAM_BETA.log -e ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.HISTOGRAM_BETA.errors -l h_vmem=${QMEMPLOTTER} -l h_rt=${QRUNTIMEPLOTTER} -wd ${PROJECTDIR} ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.HISTOGRAM_BETA.sh
		echo "rm -v ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.HISTOGRAM_BETA.txt ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.HISTOGRAM_BETA.sh ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.HISTOGRAM_BETA.errors ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.HISTOGRAM_BETA.log" > ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.HISTOGRAM_BETA.remover.sh		
		qsub -S /bin/bash -N ${COHORTNAME}.${DATAPLOTID}.HISTOGRAM_BETA.remover -hold_jid ${COHORTNAME}.${DATAPLOTID}.HISTOGRAM_BETA -o ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.HISTOGRAM_BETA.remover.log -e ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.HISTOGRAM_BETA.remover.errors -l h_vmem=${QMEM} -l h_rt=${QRUNTIME} -wd ${PROJECTDIR} ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.HISTOGRAM_BETA.remover.sh

		echo "- producing a correlation plot of the observed p-value and the p-value based on beta and standard error..." # BETA, SE, P-value
		zcat ${PROJECTDIR}/${COHORTNAME}.${DATAEXT} | ${SCRIPTS}/parseTable.pl --col BetaMinor,SE,P | tail -n +2 > ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.P_Z.txt
		echo "Rscript ${SCRIPTS}/plotter.p_z.R --projectdir ${PROJECTDIR} --resultfile ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.P_Z.txt --outputdir ${PROJECTDIR} --randomsample ${RANDOMSAMPLE} --imageformat ${IMAGEFORMAT}" > ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.P_Z.sh
		qsub -S /bin/bash -N ${COHORTNAME}.${DATAPLOTID}.P_Z -o ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.P_Z.log -e ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.P_Z.errors -l h_vmem=${QMEMPLOTTER} -l h_rt=${QRUNTIMEPLOTTER} -wd ${PROJECTDIR} ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.P_Z.sh
		echo "rm -v ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.P_Z.txt ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.P_Z.sh ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.P_Z.errors ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.P_Z.log" > ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.P_Z.remover.sh		
		qsub -S /bin/bash -N ${COHORTNAME}.${DATAPLOTID}.P_Z.remover -hold_jid ${COHORTNAME}.${DATAPLOTID}.P_Z -o ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.P_Z.remover.log -e ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.P_Z.remover.errors -l h_vmem=${QMEM} -l h_rt=${QRUNTIME} -wd ${PROJECTDIR} ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.P_Z.remover.sh

		echo "- producing histograms of the imputation quality..." # INFO
		zcat ${PROJECTDIR}/${COHORTNAME}.${DATAEXT} | ${SCRIPTS}/parseTable.pl --col Info | tail -n +2 > ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.INFO.txt
		echo "Rscript ${SCRIPTS}/plotter.infoscore.R --projectdir ${PROJECTDIR} --resultfile ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.INFO.txt --outputdir ${PROJECTDIR} --imageformat ${IMAGEFORMAT}" > ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.INFO.sh
		qsub -S /bin/bash -N ${COHORTNAME}.${DATAPLOTID}.INFO -o ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.INFO.log -e ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.INFO.errors -l h_vmem=${QMEMPLOTTER} -l h_rt=${QRUNTIMEPLOTTER} -wd ${PROJECTDIR} ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.INFO.sh
		echo "rm -v ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.INFO.txt ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.INFO.sh ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.INFO.errors ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.INFO.log" > ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.INFO.remover.sh		
		qsub -S /bin/bash -N ${COHORTNAME}.${DATAPLOTID}.INFO.remover -hold_jid ${COHORTNAME}.${DATAPLOTID}.INFO -o ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.INFO.remover.log -e ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.INFO.remover.errors -l h_vmem=${QMEM} -l h_rt=${QRUNTIME} -wd ${PROJECTDIR} ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.INFO.remover.sh
	
	elif [[ ${DATAFORMAT} == "META" ]]; then # OPTION: META
		echosucces "Plotting meta-analysis results."
		echo ""

# 		echo "- producing Manhattan-plots..." # CHR, BP, P-value (P_SQRTN P_FIXED P_RANDOM)
# 		zcat ${PROJECTDIR}/${COHORTNAME}.${DATAEXT} | ${SCRIPTS}/parseTable.pl --col CHR,BP,P_SQRTN | tail -n +2 > ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.txt
# 		echo "Rscript ${SCRIPTS}/plotter.manhattan.R --projectdir ${PROJECTDIR} --resultfile ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.txt --outputdir ${PROJECTDIR} --colorstyle FULL --imageformat ${IMAGEFORMAT} --title ${COHORTNAME}" > ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.FULL.sh
# 		qsub -S /bin/bash -N ${COHORTNAME}.${DATAPLOTID}.MANHATTAN -o ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.FULL.log -e ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.FULL.errors -l h_vmem=${QMEMPLOTTER} -l h_rt=${QRUNTIMEPLOTTER} -wd ${PROJECTDIR} ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.FULL.sh
# 		echo "rm -v ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.txt ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.FULL.sh ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.QC.sh ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.TWOCOLOR.sh ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.FULL.errors ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.QC.errors ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.TWOCOLOR.errors ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.FULL.log ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.QC.log ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.TWOCOLOR.log" > ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.remover.sh		
# 		qsub -S /bin/bash -N ${COHORTNAME}.${DATAPLOTID}.MANHATTAN.remover -hold_jid ${COHORTNAME}.${DATAPLOTID}.MANHATTAN -o ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.remover.log -e ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.remover.errors -l h_vmem=${QMEM} -l h_rt=${QRUNTIME} -wd ${PROJECTDIR} ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.remover.sh
# 
# 		echo "- producing normal QQ-plots..." # P-value
# 		zcat ${PROJECTDIR}/${COHORTNAME}.${DATAEXT} | ${SCRIPTS}/parseTable.pl --col P | tail -n +2 > ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ.txt
# 		echo "Rscript ${SCRIPTS}/plotter.qq.R --projectdir ${PROJECTDIR} --resultfile ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ.txt --outputdir ${PROJECTDIR} --stattype ${STATTYPE} --imageformat ${IMAGEFORMAT}" > ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ.sh
# 		qsub -S /bin/bash -N ${COHORTNAME}.${DATAPLOTID}.QQ -o ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ.log -e ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ.errors -l h_vmem=${QMEMPLOTTER} -l h_rt=${QRUNTIMEPLOTTER} -wd ${PROJECTDIR} ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ.sh
# 		echo "rm -v ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ.txt ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ.sh ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ.errors ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ.log" > ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ.remover.sh		
# 		qsub -S /bin/bash -N ${COHORTNAME}.${DATAPLOTID}.QQ.remover -hold_jid ${COHORTNAME}.${DATAPLOTID}.QQ -o ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ.remover.log -e ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ.remover.errors -l h_vmem=${QMEM} -l h_rt=${QRUNTIME} -wd ${PROJECTDIR} ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ.remover.sh
# 
# 		echo "- producing QQ-plots stratified by minor allele frequency..." # P-value, MAF
# 		zcat ${PROJECTDIR}/${COHORTNAME}.${DATAEXT} | ${SCRIPTS}/parseTable.pl --col P,MAF | tail -n +2 > ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_CAF.txt
# 		echo "Rscript ${SCRIPTS}/plotter.qqplot_by_caf.R --projectdir ${PROJECTDIR} --resultfile ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_CAF.txt --outputdir ${PROJECTDIR} --stattype ${STATTYPE} --imageformat ${IMAGEFORMAT}" > ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_CAF.sh
# 		qsub -S /bin/bash -N ${COHORTNAME}.${DATAPLOTID}.QQ_by_CAF -o ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_CAF.log -e ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_CAF.errors -l h_vmem=${QMEMPLOTTER} -l h_rt=${QRUNTIMEPLOTTER} -wd ${PROJECTDIR} ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_CAF.sh
# 		echo "rm -v ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_CAF.txt ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_CAF.sh ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_CAF.errors ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_CAF.log" > ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_CAF.remover.sh		
# 		qsub -S /bin/bash -N ${COHORTNAME}.${DATAPLOTID}.QQ_by_CAF.remover -hold_jid ${COHORTNAME}.${DATAPLOTID}.QQ_by_CAF -o ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_CAF.remover.log -e ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_CAF.remover.errors -l h_vmem=${QMEM} -l h_rt=${QRUNTIME} -wd ${PROJECTDIR} ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_CAF.remover.sh
# 
# 		echo "- producing QQ-plots stratified by variant type..." # P-value, VT
# 		zcat ${PROJECTDIR}/${COHORTNAME}.${DATAEXT} | ${SCRIPTS}/parseTable.pl --col P,VT | tail -n +2 > ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_TYPE.txt
# 		echo "Rscript ${SCRIPTS}/plotter.qqplot_by_type.R --projectdir ${PROJECTDIR} --resultfile ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_TYPE.txt --outputdir ${PROJECTDIR} --stattype ${STATTYPE} --imageformat ${IMAGEFORMAT}" > ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_TYPE.sh
# 		qsub -S /bin/bash -N ${COHORTNAME}.${DATAPLOTID}.QQ_by_TYPE -o ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_TYPE.log -e ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_TYPE.errors -l h_vmem=${QMEMPLOTTER} -l h_rt=${QRUNTIMEPLOTTER} -wd ${PROJECTDIR} ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_TYPE.sh
# 		echo "rm -v ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_TYPE.txt ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_TYPE.sh ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_TYPE.errors ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_TYPE.log" > ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_TYPE.remover.sh		
# 		qsub -S /bin/bash -N ${COHORTNAME}.${DATAPLOTID}.QQ_by_TYPE.remover -hold_jid ${COHORTNAME}.${DATAPLOTID}.QQ_by_TYPE -o ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_TYPE.remover.log -e ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_TYPE.remover.errors -l h_vmem=${QMEM} -l h_rt=${QRUNTIME} -wd ${PROJECTDIR} ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_TYPE.remover.sh

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
