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
	echoerror "- Argument #4 is the variant type used in the GWAS data."
	echoerror ""
	echoerror "An example command would be: gwas.wrapper.sh [arg1] [arg2] [arg3] [arg4]"
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
echobold "* Last update:  2016-12-11"
echobold "* Written by:   Sander W. van der Laan | UMC Utrecht | s.w.vanderlaan-2@umcutrecht.nl."
echobold "                Sara Pulit | UMC Utrecht | s.l.pulit@umcutrecht.nl; "
echobold "                Jessica van Setten | UMC Utrecht | j.vansetten@umcutrecht.nl; "
echobold "                Paul I.W. de Bakker | UMC Utrecht | p.i.w.debakker-2@umcutrecht.nl."
echobold "* Testers:      Jessica van Setten | UMC Utrecht | j.vansetten@umcutrecht.nl."
echobold "* Description:  Produce plots (PDF and PNG) for quick inspection and publication."
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
if [[ $# -lt 7 ]]; then 
	echo ""
	echoerror "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echoerrorflash "               *** Oh, computer says no! Number of arguments found "$#". ***"
	echoerror "You must supply [5] arguments when running *** GWASPLOTTER -- MetaGWASToolKit ***!"
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
	RANDOMSAMPLE="50000" # depends on arg8

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
	### HEADER .pdat-file
	### Marker CHR BP Strand EffectAllele OtherAllele EAF MAF MAC HWE_P Info Beta SE P  N  N_cases N_controls Imputed
	### 1	   2   3  4      5            6           7   8   9   10    11   12   13 14 15 16      17         18
	
	### HEADER .rdat-file
	### VariantID Marker CHR BP Strand EffectAllele OtherAllele EAF MAF MAC HWE_P Info Beta SE P 	N 	N_cases N_controls Imputed CHR_ref BP_ref REF ALT AlleleA AlleleB VT AF EURAF AFRAF AMRAF ASNAF EASAF SASAF Reference
	### 1		  2      3   4  5      6            7           8   9   10  11    12   13   14 15	16	17      18         19      20      21     22  23  24      25      26 27 28    29    30    31    32    33    34
	
	### HEADER .cdat-file
	### VariantID Marker CHR BP Strand EffectAllele OtherAllele EAF MAF MAC HWE_P Info Beta SE P    N   N_cases N_controls Imputed REF ALT VT AF EURAF AFRAF AMRAF ASNAF EASAF SASAF Reference
	### 1		  2      3   4  5      6            7           8   9   10  11    12   13   14 15	16	17      18         19      20  21  22 23 24    25    26    27    28    29    30
	
	### PREPARING FILES -- ARGUMENT DEPENDENT
	if [[ ${DATAFORMAT} == "QC" || ${DATAFORMAT} == "RAW" ]]; then # OPTION: RAW, QC, META
		echosucces "Plotting original harmonized data."
		echo ""
		echo "* Setting proper extension..."
		if [[ ${DATAFORMAT} == "QC" ]]; then
			echo "...for 'cleaned harmonized' data..."
			DATAEXT="cdat"
			DATAPLOTID="QC"
			VT="22"
		elif [[ ${DATAFORMAT} == "RAW" ]]; then
			echo "...for 'original harmonized' data..."
			DATAEXT="rdat"
			DATAPLOTID="RAW"
			VT="26"
		elif [[ ${DATAFORMAT} == "META" ]]; then
			echo "...for 'original harmonized' data..."
			DATAEXT="rdat"
			DATAPLOTID="RAW"
			VT="26"
		else
			echoerrorflash "This is not an option! Double back, please."
			echo ""
		fi

		echo ""
		echo "* Making necessary intermediate 'plotting'-files and plotting..."
		echo "- ...Manhattan-plots..." # CHR, BP, P-value
		zcat ${PROJECTDIR}${COHORTNAME}.${DATAEXT} | awk '{ print $3, $4, $15 }' | tail -n +2 > ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.txt
		echo "${SOFTWARE}/MANTEL/SCRIPTS/manhattan.R --projectdir ${PROJECTDIR} --resultfile ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.txt --outputdir ${PROJECTDIR} --colorstyle FULL --imageformat ${FORMAT}" > ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.FULL.sh
		#qsub -S /bin/bash -N ${COHORTNAME}.${DATAPLOTID}.MANHATTAN.FULL -o ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.FULL.log -e ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.FULL.errors -l h_vmem=${QMEM} -l h_rt=${QTIME} -wd ${PROJECTDIR} ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.FULL.sh
		echo "${SOFTWARE}/MANTEL/SCRIPTS/manhattan.R --projectdir ${PROJECTDIR} --resultfile ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.txt --outputdir ${PROJECTDIR} --colorstyle QC --imageformat ${FORMAT}" > ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.QC.sh
		#qsub -S /bin/bash -N ${COHORTNAME}.${DATAPLOTID}.MANHATTAN.QC -o ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.QC.log -e ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.QC.errors -l h_vmem=${QMEM} -l h_rt=${QTIME} -wd ${PROJECTDIR} ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.QC.sh
		echo "${SOFTWARE}/MANTEL/SCRIPTS/manhattan.R --projectdir ${PROJECTDIR} --resultfile ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.txt --outputdir ${PROJECTDIR} --colorstyle TWOCOLOR --imageformat ${FORMAT}" > ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.TWOCOLOR.sh
		#qsub -S /bin/bash -N ${COHORTNAME}.${DATAPLOTID}.MANHATTAN.TWOCOLOR -o ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.TWOCOLOR.log -e ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.TWOCOLOR.errors -l h_vmem=${QMEM} -l h_rt=${QTIME} -wd ${PROJECTDIR} ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.MANHATTAN.TWOCOLOR.sh

		echo ""
		echo "- ...normal QQ-plots..." # P-value
		zcat ${PROJECTDIR}${COHORTNAME}.${DATAEXT} | awk '{ print $15 }' | tail -n +2 > ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ.txt
		echo "${SOFTWARE}/MANTEL/SCRIPTS/qqplot.R --projectdir ${PROJECTDIR} --resultfile ${PROJECTDIR}/${COHORTNAME}.QQ.txt.gz --outputdir ${PROJECTDIR} --stattype ${PVALUE} --imageformat ${FORMAT}" > ${PROJECTDIR}/${COHORTNAME}.QQ.sh
		#qsub -S /bin/bash -N ${COHORTNAME}.QQ -o ${PROJECTDIR}/${COHORTNAME}.QQ.log -e ${PROJECTDIR}/${COHORTNAME}.QQ.errors -l h_vmem=${QMEM} -l h_rt=${QTIME} -wd ${PROJECTDIR} ${PROJECTDIR}/${COHORTNAME}.QQ.sh

		echo ""
		echo "- ...QQ-plots stratified by imputation quality..." # P-value, INFO
		zcat ${PROJECTDIR}${COHORTNAME}.${DATAEXT} | awk '{ print $15, $12 }' | tail -n +2 > ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_INFO.txt
		echo "${SOFTWARE}/MANTEL/SCRIPTS/qqplot_by_info.R --projectdir ${PROJECTDIR} --resultfile ${PROJECTDIR}/${COHORTNAME}.QQ_by_INFO.txt.gz --outputdir ${PROJECTDIR} --stattype ${PVALUE} --imageformat ${FORMAT}" > ${PROJECTDIR}/${COHORTNAME}.QQ_by_INFO.sh
		#qsub -S /bin/bash -N ${COHORTNAME}.QQ_by_INFO -o ${PROJECTDIR}/${COHORTNAME}.QQ_by_INFO.log -e ${PROJECTDIR}/${COHORTNAME}.QQ_by_INFO.errors -l h_vmem=${QMEM} -l h_rt=${QTIME} -wd ${PROJECTDIR} ${PROJECTDIR}/${COHORTNAME}.QQ_by_INFO.sh

		echo ""
		echo "- ...QQ-plots stratified by minor allele frequency..." # P-value, MAF
		zcat ${PROJECTDIR}${COHORTNAME}.${DATAEXT} | awk '{ print $15, $9 }' | tail -n +2 > ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_CAF.txt
		echo "${SOFTWARE}/MANTEL/SCRIPTS/qqplot_by_caf.R --projectdir ${PROJECTDIR} --resultfile ${PROJECTDIR}/${COHORTNAME}.QQ_by_CAF.txt.gz --outputdir ${PROJECTDIR} --stattype ${PVALUE} --imageformat ${FORMAT}" > ${PROJECTDIR}/${COHORTNAME}.QQ_by_CAF.sh
		#qsub -S /bin/bash -N ${COHORTNAME}.QQ_by_CAF -o ${PROJECTDIR}/${COHORTNAME}.QQ_by_CAF.log -e ${PROJECTDIR}/${COHORTNAME}.QQ_by_CAF.errors -l h_vmem=${QMEM} -l h_rt=${QTIME} -wd ${PROJECTDIR} ${PROJECTDIR}/${COHORTNAME}.QQ_by_CAF.sh
	
		echo ""
		echo "- ...QQ-plots stratified by variant type..." # P-value, VT
		zcat ${PROJECTDIR}${COHORTNAME}.${DATAEXT} | awk '{ print $15, '$VT' }' | tail -n +2 > ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.QQ_by_TYPE.txt
		echo "${SOFTWARE}/MANTEL/SCRIPTS/qqplot_by_type.R --projectdir ${PROJECTDIR} --resultfile ${PROJECTDIR}/${COHORTNAME}.QQ_by_TYPE.txt.gz --outputdir ${PROJECTDIR} --stattype ${PVALUE} --imageformat ${FORMAT}" > ${PROJECTDIR}/${COHORTNAME}.QQ_by_TYPE.sh
		#qsub -S /bin/bash -N ${COHORTNAME}.QQ_by_TYPE -o ${PROJECTDIR}/${COHORTNAME}.QQ_by_TYPE.log -e ${PROJECTDIR}/${COHORTNAME}.QQ_by_TYPE.errors -l h_vmem=${QMEM} -l h_rt=${QTIME} -wd ${PROJECTDIR} ${PROJECTDIR}/${COHORTNAME}.QQ_by_TYPE.sh
	
		echo ""
		echo "- ...histograms of the beta (effect size)..." # BETA
		zcat ${PROJECTDIR}${COHORTNAME}.${DATAEXT} | awk '{ print $13 }' | tail -n +2 > ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.HISTOGRAM_BETA.txt
		echo "${SOFTWARE}/MANTEL/SCRIPTS/effectsize_plotter.R --projectdir ${PROJECTDIR} --resultfile ${PROJECTDIR}/${COHORTNAME}.HISTOGRAM_BETA.txt.gz --outputdir ${PROJECTDIR} --imageformat ${FORMAT}" > ${PROJECTDIR}/${COHORTNAME}.HISTOGRAM_BETA.sh
		#qsub -S /bin/bash -N ${COHORTNAME}.HISTOGRAM_BETA -o ${PROJECTDIR}/${COHORTNAME}.HISTOGRAM_BETA.log -e ${PROJECTDIR}/${COHORTNAME}.HISTOGRAM_BETA.errors -l h_vmem=${QMEM} -l h_rt=${QTIME} -wd ${PROJECTDIR} ${PROJECTDIR}/${COHORTNAME}.HISTOGRAM_BETA.sh

		echo ""
		echo "- ...a correlation plot of the observed p-value and the p-value based on beta and standard error..." # BETA, SE, P-value
		zcat ${PROJECTDIR}${COHORTNAME}.${DATAEXT} | awk '{ print $13, $14, $15 }' | tail -n +2 > ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.P_Z.txt
		echo "${SOFTWARE}/MANTEL/SCRIPTS/p_z_plotter.R --projectdir ${PROJECTDIR} --resultfile ${PROJECTDIR}/${COHORTNAME}.P_Z.txt.gz --outputdir ${PROJECTDIR} --randomsample ${RANDOMSAMPLE} --imageformat ${FORMAT}" > ${PROJECTDIR}/${COHORTNAME}.P_Z.sh
		#qsub -S /bin/bash -N ${COHORTNAME}.P_Z -o ${PROJECTDIR}/${COHORTNAME}.P_Z.log -e ${PROJECTDIR}/${COHORTNAME}.P_Z.errors -l h_vmem=${QMEM} -l h_rt=${QTIME} -wd ${PROJECTDIR} ${PROJECTDIR}/${COHORTNAME}.P_Z.sh

		echo ""
		echo "- ...histograms of the imputation quality..." # INFO
		zcat ${PROJECTDIR}${COHORTNAME}.${DATAEXT} | awk '{ print $12 }' | tail -n +2 > ${PROJECTDIR}/${COHORTNAME}.${DATAPLOTID}.INFO.txt
		echo "${SOFTWARE}/MANTEL/SCRIPTS/info_score_plotter.R --projectdir ${PROJECTDIR} --resultfile ${PROJECTDIR}/${COHORTNAME}.INFO.txt.gz --outputdir ${PROJECTDIR} --imageformat ${FORMAT}" > ${PROJECTDIR}/${COHORTNAME}.INFO.sh
		#qsub -S /bin/bash -N ${COHORTNAME}.INFO -o ${PROJECTDIR}/${COHORTNAME}.INFO.log -e ${PROJECTDIR}/${COHORTNAME}.INFO.errors -l h_vmem=${QMEM} -l h_rt=${QTIME} -wd ${PROJECTDIR} ${PROJECTDIR}/${COHORTNAME}.INFO.sh
	

	elif 
		echosucces "Plotting meta-analysis results."
		echo ""

	else 
		echoerrorflash "This is not an option! Double back, please."
		echo ""

	fi


	#	echo "- cleaning up input data for ${FILE}"
	#	rm -v ${PLOTTED}/${FILENAME}.MANHATTAN.txt.gz
	#	rm -v ${PLOTTED}/${FILENAME}.QQ.txt.gz
	#	rm -v ${PLOTTED}/${FILENAME}.QQ_by_INFO.txt.gz
	#	rm -v ${PLOTTED}/${FILENAME}.QQ_by_CAF.txt.gz
	#	rm -v ${PLOTTED}/${FILENAME}.QQ_by_TYPE.txt.gz
	#	rm -v ${PLOTTED}/${FILENAME}.HISTOGRAM_BETA.txt.gz
	#	rm -v ${PLOTTED}/${FILENAME}.P_Z.txt.gz
	#	rm -v ${PLOTTED}/${FILENAME}.INFO.txt.gz
		
### END of if-else statement for the number of command-line arguments passed ###
fi 

script_copyright_message




### Header example
###	1	   2   3  4		 5			  6			  7	  8	  9	  10	11	 12	  13 14	15 16	 17		    18
###	Marker CHR BP Strand EffectAllele OtherAllele EAF MAF MAC HWE_P Info Beta SE P N N_cases N_controls Imputed
###	rs1921 1 939471 1 2 4 0.408 0.408 322.32 0.375511637486551 NA 0.0451 0.04283 0.293 395 NA NA 0
###	rs3128126 1 952073 1 4 1 0.4208 0.4208 332.432 0.375511637486551 NA 0.06069 0.04304 0.1593 395 NA NA 0
###	rs10907175 1 1120590 1 3 1 0.08571 0.08571 67.7109 0.375511637486551 NA 0.008913 0.04301 0.836 395 NA NA 0

#echo "Make a new directory for the original data, and move it there."
#### Make directories for script if they do not exist yet (!!!PREREQUISITE!!!)
#if [ ! -d ${QCEDDATA}/_original_hisayama ]; then
#  mkdir -v ${QCEDDATA}/_original_hisayama
#fi
#HISAYAMADATA=${QCEDDATA}/_original_hisayama
#mv -v ${QCEDDATA}/HISAYAMA.*.meta.gz ${HISAYAMADATA}
#
#echo ""
#echo "Gzip the new stuff"
#gzip -v ${QCEDDATA}/HISAYAMA.*.COMBINED.21C.meta
#chmod -v 0775 ${QCEDDATA}/HISAYAMA.*

#for FILE in $(ls ${QCEDDATA}/*.gz ); do
#	### PREPARING FILES
#	FILENAME=$(basename ${FILE} .gz)
#	echo "*** Processing file ${FILENAME} ***"
#	echo ""
#	echo "- found file: ${FILE}"
#	echo "- creating files for plotting..." 
#	zcat ${FILE} | awk '{ print $6, $7, $13 }' | tail -n +2 > ${PLOTTED}/${FILENAME}.MANHATTAN.txt
#	zcat ${FILE} | awk '{ print $13 }' | tail -n +2 > ${PLOTTED}/${FILENAME}.QQ.txt
#	zcat ${FILE} | awk '{ print $13, $14 }' | tail -n +2 > ${PLOTTED}/${FILENAME}.QQ_by_INFO.txt
#	zcat ${FILE} | awk '{ print $13, $10 }' | tail -n +2 > ${PLOTTED}/${FILENAME}.QQ_by_CAF.txt
#	zcat ${FILE} | awk '{ print $13, $17 }' | tail -n +2 > ${PLOTTED}/${FILENAME}.QQ_by_TYPE.txt
#	zcat ${FILE} | awk '{ print $11 }' | tail -n +2 > ${PLOTTED}/${FILENAME}.HISTOGRAM_BETA.txt
#	zcat ${FILE} | awk '{ print $11, $12, $13 }' | tail -n +2 > ${PLOTTED}/${FILENAME}.P_Z.txt
#	zcat ${FILE} | awk '{ print $14 }' | tail -n +2 > ${PLOTTED}/${FILENAME}.INFO.txt
#	
#	echo ""
#	echo "- gzipping..."
#	gzip -v ${PLOTTED}/${FILENAME}.MANHATTAN.txt
#	gzip -v ${PLOTTED}/${FILENAME}.QQ.txt
#	gzip -v ${PLOTTED}/${FILENAME}.QQ_by_INFO.txt
#	gzip -v ${PLOTTED}/${FILENAME}.QQ_by_CAF.txt
#	gzip -v ${PLOTTED}/${FILENAME}.QQ_by_TYPE.txt
#	gzip -v ${PLOTTED}/${FILENAME}.HISTOGRAM_BETA.txt
#	gzip -v ${PLOTTED}/${FILENAME}.P_Z.txt
#	gzip -v ${PLOTTED}/${FILENAME}.INFO.txt
#	
#	chmod -v 0775 ${PLOTTED}/${FILENAME}.*
#	
#	### REPORTING
#	echo ""
#	echo "- reporting some basics on the file..."
#	
#	echo "*** Processing file: ${FILENAME} ***" > ${PLOTTED}/${FILENAME}.REPORT.txt
#	echo "================================================================================" >> ${PLOTTED}/${FILENAME}.REPORT.txt
#	ls -l ${FILE} >> ${PLOTTED}/${FILENAME}.REPORT.txt
#	echo "" >> ${PLOTTED}/${FILENAME}.REPORT.txt
#	echo "--------------------------------------------------------------------------------" >> ${PLOTTED}/${FILENAME}.REPORT.txt
#	echo "*** HEADER & TAIL ***" >> ${PLOTTED}/${FILENAME}.REPORT.txt
#	echo "--------------------------------------------------------------------------------" >> ${PLOTTED}/${FILENAME}.REPORT.txt
#	zcat ${FILE} | head >> ${PLOTTED}/${FILENAME}.REPORT.txt
#	echo "" >> ${PLOTTED}/${FILENAME}.REPORT.txt
#	zcat ${FILE} | tail >> ${PLOTTED}/${FILENAME}.REPORT.txt
#	echo "--------------------------------------------------------------------------------" >> ${PLOTTED}/${FILENAME}.REPORT.txt
#	echo "" >> ${PLOTTED}/${FILENAME}.REPORT.txt
#	echo "--------------------------------------------------------------------------------" >> ${PLOTTED}/${FILENAME}.REPORT.txt
#	echo "*** SOME STATS ***" >> ${PLOTTED}/${FILENAME}.REPORT.txt
#	echo "Number of lines:" >> ${PLOTTED}/${FILENAME}.REPORT.txt
#	zcat ${FILE} | tail -n +2 | wc -l >> ${PLOTTED}/${FILENAME}.REPORT.txt
#	echo "Number of unique fields:" >> ${PLOTTED}/${FILENAME}.REPORT.txt
#	zcat ${FILE} | tail -n +2 | awk '{ print NF }' | sort -nu >> ${PLOTTED}/${FILENAME}.REPORT.txt
#	echo "--------------------------------------------------------------------------------" >> ${PLOTTED}/${FILENAME}.REPORT.txt
#	echo "" >> ${PLOTTED}/${FILENAME}.REPORT.txt
#	echo "================================================================================" >> ${PLOTTED}/${FILENAME}.REPORT.txt
#	echo "${TODAY}" >> ${PLOTTED}/${FILENAME}.REPORT.txt
#	
#	
#	### PLOTTING
#	###for FORMAT in PNG TIFF EPS PDF; do
#	for FORMAT in PNG; do
#		echo ""
#		echo "- plotting Manhattan..."
#		echo "${SOFTWARE}/MANTEL/SCRIPTS/manhattan.R --projectdir ${PLOTTED} --resultfile ${PLOTTED}/${FILENAME}.MANHATTAN.txt.gz --outputdir ${PLOTTED} --colorstyle FULL --imageformat ${FORMAT}" > ${PLOTTED}/${FILENAME}.MANHATTAN.FULL.sh
#		qsub -S /bin/bash -N ${FILENAME}.MANHATTAN.FULL -o ${PLOTTED}/${FILENAME}.MANHATTAN.FULL.log -e ${PLOTTED}/${FILENAME}.MANHATTAN.FULL.errors -l h_vmem=${QMEM} -l h_rt=${QTIME} -wd ${PROJECTDIR} ${PLOTTED}/${FILENAME}.MANHATTAN.FULL.sh
#		echo "${SOFTWARE}/MANTEL/SCRIPTS/manhattan.R --projectdir ${PLOTTED} --resultfile ${PLOTTED}/${FILENAME}.MANHATTAN.txt.gz --outputdir ${PLOTTED} --colorstyle QC --imageformat ${FORMAT}" > ${PLOTTED}/${FILENAME}.MANHATTAN.QC.sh
#		qsub -S /bin/bash -N ${FILENAME}.MANHATTAN.QC -o ${PLOTTED}/${FILENAME}.MANHATTAN.QC.log -e ${PLOTTED}/${FILENAME}.MANHATTAN.QC.errors -l h_vmem=${QMEM} -l h_rt=${QTIME} -wd ${PROJECTDIR} ${PLOTTED}/${FILENAME}.MANHATTAN.QC.sh
#		echo "${SOFTWARE}/MANTEL/SCRIPTS/manhattan.R --projectdir ${PLOTTED} --resultfile ${PLOTTED}/${FILENAME}.MANHATTAN.txt.gz --outputdir ${PLOTTED} --colorstyle TWOCOLOR --imageformat ${FORMAT}" > ${PLOTTED}/${FILENAME}.MANHATTAN.TWOCOLOR.sh
#		qsub -S /bin/bash -N ${FILENAME}.MANHATTAN.TWOCOLOR -o ${PLOTTED}/${FILENAME}.MANHATTAN.TWOCOLOR.log -e ${PLOTTED}/${FILENAME}.MANHATTAN.TWOCOLOR.errors -l h_vmem=${QMEM} -l h_rt=${QTIME} -wd ${PROJECTDIR} ${PLOTTED}/${FILENAME}.MANHATTAN.TWOCOLOR.sh
#		
#		echo ""
#		echo "- plotting QQ-plot..."
#		echo "${SOFTWARE}/MANTEL/SCRIPTS/qqplot.R --projectdir ${PLOTTED} --resultfile ${PLOTTED}/${FILENAME}.QQ.txt.gz --outputdir ${PLOTTED} --stattype ${PVALUE} --imageformat ${FORMAT}" > ${PLOTTED}/${FILENAME}.QQ.sh
#		qsub -S /bin/bash -N ${FILENAME}.QQ -o ${PLOTTED}/${FILENAME}.QQ.log -e ${PLOTTED}/${FILENAME}.QQ.errors -l h_vmem=${QMEM} -l h_rt=${QTIME} -wd ${PROJECTDIR} ${PLOTTED}/${FILENAME}.QQ.sh
#		
#		echo ""
#		echo "- plotting QQ-plot by INFO..."
#		echo "${SOFTWARE}/MANTEL/SCRIPTS/qqplot_by_info.R --projectdir ${PLOTTED} --resultfile ${PLOTTED}/${FILENAME}.QQ_by_INFO.txt.gz --outputdir ${PLOTTED} --stattype ${PVALUE} --imageformat ${FORMAT}" > ${PLOTTED}/${FILENAME}.QQ_by_INFO.sh
#		qsub -S /bin/bash -N ${FILENAME}.QQ_by_INFO -o ${PLOTTED}/${FILENAME}.QQ_by_INFO.log -e ${PLOTTED}/${FILENAME}.QQ_by_INFO.errors -l h_vmem=${QMEM} -l h_rt=${QTIME} -wd ${PROJECTDIR} ${PLOTTED}/${FILENAME}.QQ_by_INFO.sh
#		
#		echo ""
#		echo "- plotting QQ-plot by CAF..."
#		echo "${SOFTWARE}/MANTEL/SCRIPTS/qqplot_by_caf.R --projectdir ${PLOTTED} --resultfile ${PLOTTED}/${FILENAME}.QQ_by_CAF.txt.gz --outputdir ${PLOTTED} --stattype ${PVALUE} --imageformat ${FORMAT}" > ${PLOTTED}/${FILENAME}.QQ_by_CAF.sh
#		qsub -S /bin/bash -N ${FILENAME}.QQ_by_CAF -o ${PLOTTED}/${FILENAME}.QQ_by_CAF.log -e ${PLOTTED}/${FILENAME}.QQ_by_CAF.errors -l h_vmem=${QMEM} -l h_rt=${QTIME} -wd ${PROJECTDIR} ${PLOTTED}/${FILENAME}.QQ_by_CAF.sh
#		
#		echo ""
#		echo "- plotting QQ-plot by TYPE..."
#		echo "${SOFTWARE}/MANTEL/SCRIPTS/qqplot_by_type.R --projectdir ${PLOTTED} --resultfile ${PLOTTED}/${FILENAME}.QQ_by_TYPE.txt.gz --outputdir ${PLOTTED} --stattype ${PVALUE} --imageformat ${FORMAT}" > ${PLOTTED}/${FILENAME}.QQ_by_TYPE.sh
#		qsub -S /bin/bash -N ${FILENAME}.QQ_by_TYPE -o ${PLOTTED}/${FILENAME}.QQ_by_TYPE.log -e ${PLOTTED}/${FILENAME}.QQ_by_TYPE.errors -l h_vmem=${QMEM} -l h_rt=${QTIME} -wd ${PROJECTDIR} ${PLOTTED}/${FILENAME}.QQ_by_TYPE.sh
#		
#		echo ""
#		echo "- plotting EffectSize-plot..."
#		echo "${SOFTWARE}/MANTEL/SCRIPTS/effectsize_plotter.R --projectdir ${PLOTTED} --resultfile ${PLOTTED}/${FILENAME}.HISTOGRAM_BETA.txt.gz --outputdir ${PLOTTED} --imageformat ${FORMAT}" > ${PLOTTED}/${FILENAME}.HISTOGRAM_BETA.sh
#		qsub -S /bin/bash -N ${FILENAME}.HISTOGRAM_BETA -o ${PLOTTED}/${FILENAME}.HISTOGRAM_BETA.log -e ${PLOTTED}/${FILENAME}.HISTOGRAM_BETA.errors -l h_vmem=${QMEM} -l h_rt=${QTIME} -wd ${PROJECTDIR} ${PLOTTED}/${FILENAME}.HISTOGRAM_BETA.sh
#		
#		echo ""
#		echo "- plotting P-Z-plot..."
#		echo "${SOFTWARE}/MANTEL/SCRIPTS/p_z_plotter.R --projectdir ${PLOTTED} --resultfile ${PLOTTED}/${FILENAME}.P_Z.txt.gz --outputdir ${PLOTTED} --randomsample ${RANDOMSAMPLE} --imageformat ${FORMAT}" > ${PLOTTED}/${FILENAME}.P_Z.sh
#		qsub -S /bin/bash -N ${FILENAME}.P_Z -o ${PLOTTED}/${FILENAME}.P_Z.log -e ${PLOTTED}/${FILENAME}.P_Z.errors -l h_vmem=${QMEM} -l h_rt=${QTIME} -wd ${PROJECTDIR} ${PLOTTED}/${FILENAME}.P_Z.sh
#		
#		echo ""
#		echo "- plotting INFO-score-plot..."
#		echo "${SOFTWARE}/MANTEL/SCRIPTS/info_score_plotter.R --projectdir ${PLOTTED} --resultfile ${PLOTTED}/${FILENAME}.INFO.txt.gz --outputdir ${PLOTTED} --imageformat ${FORMAT}" > ${PLOTTED}/${FILENAME}.INFO.sh
#		qsub -S /bin/bash -N ${FILENAME}.INFO -o ${PLOTTED}/${FILENAME}.INFO.log -e ${PLOTTED}/${FILENAME}.INFO.errors -l h_vmem=${QMEM} -l h_rt=${QTIME} -wd ${PROJECTDIR} ${PLOTTED}/${FILENAME}.INFO.sh
#		
#	done
#	
#	echo "================================================================================"
#	echo ""
#
#	echo "- cleaning up input data for ${FILE}"
#	rm -v ${PLOTTED}/${FILENAME}.MANHATTAN.txt.gz
#	rm -v ${PLOTTED}/${FILENAME}.QQ.txt.gz
#	rm -v ${PLOTTED}/${FILENAME}.QQ_by_INFO.txt.gz
#	rm -v ${PLOTTED}/${FILENAME}.QQ_by_CAF.txt.gz
#	rm -v ${PLOTTED}/${FILENAME}.QQ_by_TYPE.txt.gz
#	rm -v ${PLOTTED}/${FILENAME}.HISTOGRAM_BETA.txt.gz
#	rm -v ${PLOTTED}/${FILENAME}.P_Z.txt.gz
#	rm -v ${PLOTTED}/${FILENAME}.INFO.txt.gz
#done
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

echo ""
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


