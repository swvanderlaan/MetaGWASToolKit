#!/bin/bash

### Creating display functions
### Setting colouring
NONE='\033[00m'
OPAQUE='\033[2m'
FLASHING='\033[5m'
BOLD='\033[1m'
ITALIC='\033[3m'
UNDERLINE='\033[4m'
STRIKETHROUGH='\033[9m'

RED='\033[01;31m'
GREEN='\033[01;32m'
YELLOW='\033[01;33m'
PURPLE='\033[01;35m'
CYAN='\033[01;36m'
WHITE='\033[01;37m'

function echobold { #'echobold' is the function name
    echo -e "${BOLD}${1}${NONE}" # this is whatever the function needs to execute, note ${1} is the text for echo
}
function echoitalic { 
    echo -e "${ITALIC}${1}${NONE}" 
}
function echonooption { 
    echo -e "${OPAQUE}${RED}${1}${NONE}"
}
function echoerrorflash { 
    echo -e "${RED}${BOLD}${FLASHING}${1}${NONE}" 
}
function echoerror { 
    echo -e "${RED}${1}${NONE}"
}
# errors no option
function echoerrornooption { 
    echo -e "${YELLOW}${1}${NONE}"
}
function echoerrorflashnooption { 
    echo -e "${YELLOW}${BOLD}${FLASHING}${1}${NONE}"
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
	echoerror "- Argument #1 is path_to/filename of the configuration file."
	echoerror "- Argument #2 is path_to/filename of the list of GWAS files with names."
	echoerror ""
	echoerror "An example command would be: run_metagwastoolkit.sh [arg1] [arg2]"
	echoerror "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
 	echo ""
	script_copyright_message
	exit 1
}

echobold "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echobold "          MetaGWASToolKit: A TOOLKIT FOR THE META-ANALYSIS OF GENOME-WIDE ASSOCIATION STUDIES"
echobold "                                       --- META-ANALYSIS ---"
echobold ""
echobold "* Version:      v1.8.0"
echobold ""
echobold "* Last update:  2018-08-07"
echobold "* Based on:     MANTEL, as written by Sara Pulit, Jessica van Setten, and Paul de Bakker."
echobold "* Written by:   Sander W. van der Laan | s.w.vanderlaan@gmail.com."
echobold "                Sara Pulit; "
echobold "                Jessica van Setten; "
echobold "                Paul I.W. de Bakker."
echobold "* Testers:      Jessica van Setten."
echobold "* Description:  Perform a meta-analysis of genome-wide association studies. It will do the following:"
echobold "                - Automatically parse the various cohort files."
echobold "                - Harmonize GWAS datasets relative to a reference."
echobold "                - Perform QC on GWAS datasets using user-defined settings."
echobold "                - Produce plots (PDF and PNG) for quick inspection and publication."
echobold "                - Run a meta-analysis using Random, Fixed, and Z-score methods."
echobold "                - Correct results for the genomic inflation factor."
echobold "                - Clump results based on a p-value threshold for downstream (meta-)analyses."
echobold "                - Produce plots (PDF and PNG) of the final meta-analysis results for publication."
echobold "                - Produce LocusZoom style regional plots for genome-wide significant hits."
echobold "                - Produce a ReadMe file."
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
if [[ $# -lt 2 ]]; then 
	echo ""
	echoerror "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echoerrorflash "               *** Oh, oh, computer says no! Number of arguments found "$#". ***"
	echoerror "You must supply [2] arguments when running *** MetaGWASToolKit ***!"
	script_arguments_error
else
	echo "These are the "$#" arguments that passed:"
	echo "The configuration file.................: "$(basename ${1}) # argument 1
	echo "The list of GWAS files.................: "$(basename ${2}) # argument 2
	
	### SETTING DIRECTORIES (from configuration file).
	# Loading the configuration file (please refer to the MetaGWASToolKit-Manual for specifications of this file). 
	source "$1" # Depends on arg1.
	
	CONFIGURATIONFILE="$1" # Depends on arg1 -- but also on where it resides!!!
	SOFTWARE=${SOFTWARE} # from configuration file
	
	# Where MetaGWASToolKit resides
	METAGWASTOOLKIT=${METAGWASTOOLKITDIR} # from configuration file
	SCRIPTS=${METAGWASTOOLKIT}/SCRIPTS
	RESOURCES=${METAGWASTOOLKIT}/RESOURCES
	
	# Project information
	ORIGINALS=${DATA_UPLOAD_FREEZE} # from configuration file
	PROJECTDIR=${PROJECTDIR} # from configuration file
	SUBPROJECTDIRNAME=${SUBPROJECTDIRNAME} # from configuration file
	OUTPUTDIRNAME=${OUTPUTDIRNAME} # from configuration file
	GWASFILES="$2" # Depends on arg2 -- all the GWAS dataset information
	REFERENCE=${REFERENCE} # from configuration file
	POPULATION=${POPULATION} # from configuration file
	
	##########################################################################################
	### CREATE THE OUTPUT DIRECTORIES
	echo ""
	echo "Checking for the existence of the output directory [ ${OUTPUTDIRNAME} ]."
	if [ ! -d ${PROJECTDIR}/${OUTPUTDIRNAME} ]; then
		echo "> Output directory doesn't exist - Mr. Bourne will create it for you."
		mkdir -v ${PROJECTDIR}/${OUTPUTDIRNAME}
	else
		echo "> Output directory already exists."
	fi
	METAOUTPUT=${OUTPUTDIRNAME}
	
	echo ""
	echo "Checking for the existence of the subproject directory [ ${METAOUTPUT}/${SUBPROJECTDIRNAME} ]."
	if [ ! -d ${PROJECTDIR}/${METAOUTPUT}/${SUBPROJECTDIRNAME} ]; then
		echo "> Subproject directory doesn't exist - Mr. Bourne will create it for you."
		mkdir -v ${PROJECTDIR}/${METAOUTPUT}/${SUBPROJECTDIRNAME}
	else
		echo "> Subproject directory already exists."
	fi
	SUBPROJECTDIR=${PROJECTDIR}/${METAOUTPUT}/${SUBPROJECTDIRNAME}

	echo ""	
	echo "Checking for the existence of the raw data directory [ ${METAOUTPUT}/${SUBPROJECTDIRNAME}/RAW ]."
	if [ ! -d ${PROJECTDIR}/${METAOUTPUT}/${SUBPROJECTDIRNAME}/RAW ]; then
		echo "> Raw data directory doesn't exist - Mr. Bourne will create it for you."
		mkdir -v ${PROJECTDIR}/${METAOUTPUT}/${SUBPROJECTDIRNAME}/RAW
	else
		echo "> Raw data directory already exists."
	fi
	# Setting directory for raw data.
	RAWDATA=${PROJECTDIR}/${METAOUTPUT}/${SUBPROJECTDIRNAME}/RAW

	echo ""		
	echo "Checking for the existence of the meta-analysis results directory [ ${METAOUTPUT}/${SUBPROJECTDIRNAME}/META ]."
	if [ ! -d ${PROJECTDIR}/${METAOUTPUT}/${SUBPROJECTDIRNAME}/META ]; then
		echo "> Meta-analysis results directory doesn't exist - Mr. Bourne will create it for you."
		mkdir -v ${PROJECTDIR}/${METAOUTPUT}/${SUBPROJECTDIRNAME}/META
	else
		echo "> Meta-analysis results directory already exists."
	fi
	# Setting directory for meta-analysis data.
	METARESULTDIR=${PROJECTDIR}/${METAOUTPUT}/${SUBPROJECTDIRNAME}/META
	
	echo "Checking for the existence of the meta-analysis temporary results directory [ ${METAOUTPUT}/${SUBPROJECTDIRNAME}/META/TEMP ]."
	if [ ! -d ${PROJECTDIR}/${METAOUTPUT}/${SUBPROJECTDIRNAME}/META/TEMP ]; then
		echo "> Meta-analysis results temporary directory doesn't exist - Mr. Bourne will create it for you."
		mkdir -v ${PROJECTDIR}/${METAOUTPUT}/${SUBPROJECTDIRNAME}/META/TEMP
	else
		echo "> Meta-analysis results temporary directory already exists."
	fi
	# Setting directory for meta-analysis temporary data.
	METATEMPRESULTDIR=${PROJECTDIR}/${METAOUTPUT}/${SUBPROJECTDIRNAME}/META/TEMP
	
	##########################################################################################
	### SETTING UP THE OUTPUT AND RAWDATA DIRECTORIES
	echo ""
	### Making raw data directories, unless they already exist. Depends on arg2.
	if [[ ${REFERENCE} = "1Gp1" ]]; then

	  	echo ""
	  	echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	  	echo ""
	  	echo "The scene is properly set, and directories are created! 🖖"
	  	echo "MetaGWASToolKit program........................: "${METAGWASTOOLKIT}
	  	echo "MetaGWASToolKit scripts........................: "${SCRIPTS}
	  	echo "MetaGWASToolKit resources......................: "${RESOURCES}
	  	echo "Reference used.................................: "${REFERENCE}
	  	echo "Main directory.................................: "${PROJECTDIR}
	  	echo "Main analysis output directory.................: "${METAOUTPUT}
	  	echo "Subproject's analysis output directory.........: "${METAOUTPUT}/${SUBPROJECTDIRNAME}
	  	echo "Original data directory........................: "${ORIGINALS}
	  	echo "We are processing these cohort(s)..............:"
		while IFS='' read -r GWASCOHORT || [[ -n "$GWASCOHORT" ]]; do
			LINE=${GWASCOHORT}
			COHORT=$(echo "${LINE}" | awk '{ print $1 }')
			echo "     * ${COHORT}"
		done < ${GWASFILES}
	  	echo "Raw data directory.............................: "${METAOUTPUT}/${SUBPROJECTDIRNAME}/RAW
	  	echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	  	echo ""
	
	elif [[ ${REFERENCE} = "HM2" || ${REFERENCE} = "GONL4" || ${REFERENCE} = "GONL5" || ${REFERENCE} = "1Gp3" || ${REFERENCE} = "1Gp3GONL5" ]]; then
		echoerrornooption "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	  	echoerrornooption ""
	  	echoerrorflashnooption "               *** Oh, computer says no! This option is not available yet. ***"
	  	echoerrornooption "Unfortunately using ${REFERENCE} as a reference is not possible yet. Currently only 1Gp1 is available."
	  	echoerrornooption "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
		### The wrong arguments are passed, so we'll exit the script now!
		echo ""
		script_copyright_message
		exit 1
	
	else
	  	echoerror "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	  	echoerror ""
	  	echoerrorflash "                  *** Oh, computer says no! Argument not recognised. ***"
	  	echoerror "You have the following options as reference for the quality control"
	  	echoerror "and meta-analysis:"
	  	echonooption " - [HM2]          HapMap2 (r27, b36, hg18)."
	  	echoerror " - [1Gp1]         1000G (phase 1, release 3, 20101123 version, updated on 20110521 "
	  	echoerror "                  and revised on Feb/Mar 2012, b37, hg19)."
	  	echonooption " - [1Gp3]         1000G (phase 3, release 5, 20130502 version, b37, hg19)."
	  	echonooption " - [GoNL4]        Genome of the Netherlands, version 4."
	  	echonooption " - [GONL5]        Genome of the Netherlands, version 5."
	  	echonooption " - [1Gp3GONL5]    integrated 1000G phase 3, version 5 and GoNL5."
	  	echonooption "(Opaque: not an option yet)"
	  	echoerror "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
		### The wrong arguments are passed, so we'll exit the script now!
		echo ""
		script_copyright_message
		exit 1
	fi

	echobold "#########################################################################################################"
	echobold "### META-ANALYSIS"
	echobold "#########################################################################################################"
	echobold "#" 	 
	echo ""
	echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echo "Starting the meta-analysis. "
	echo ""

	echobold "#========================================================================================================"
	echobold "#== PERFORM META-ANALYSIS & CORRECT P-VALUES PER CHUNK IN PARALLEL"
	echobold "#========================================================================================================"
	echobold "#"

	### FUTURE VERSIONS WILL HAVE A SCRIPT TO AUTOMATICALLY MAKE THIS...
	### * paramCreator.pl will get the necessary information directly from the data:
	### - lambda
	### - sample size
	### - ratio
	### - basename of the to-be-meta-analyzed files
	### - beta-correction factor
	PARAMSFILE="${PARAMSFILE}" 

	# Get all the metaprep ID's to set dependancy, by looping over all lines in the file
	if [ -f ${SUBPROJECTDIRNAME}/meta_prep_ids.txt ]; then
		META_PREP_IDS="" # Init a variable
		while read line; do    
			META_PREP_IDS="${META_PREP_IDS},${line}" # Add every ID with a comma
		done < ${SUBPROJECTDIRNAME}/meta_prep_ids.txt
		META_PREP_IDS="${META_PREP_IDS:1}" # Remove the first character (',')
		META_PREP_IDS_D="--dependency=afterany:${META_PREP_IDS}" # Create a variable which can be used as dependancy
	else 
		echo "Dependancy file does not exist, assuming the METAPREP jobs finished."
		META_PREP_IDS_D="" # Empty variable so there is no dependancy
	fi

	### List of all split and reordered unique variants in this
 	VARIANTSFILES=${METATEMPRESULTDIR}/meta.all.unique.variants.reorder.split.list

	# Create variable to store pcorrector job ids, used for dependancy later
	META_P_CORRECTOR_STORE_ID=""

	echo ""
	echo "We will perform the meta-analysis per chunk of ${CHUNKSIZE} variants."

 	while IFS='' read -r VARIANTFILE || [[ -n "$VARIANTFILE" ]]; do
 		EXTENSION="${VARIANTFILE##*.}"
 		VARIANTFILEBASE="${VARIANTFILE%.*}"
 		echo "* processing chunk [ ${EXTENSION} ] ..."
 		echo ""
 		echo "  - submit meta-analysis job..."
 		### FOR DEBUGGING LOCALLY -- Mac OS X
 		### ${SCRIPTS}/meta.analyzer.sh ${CONFIGURATIONFILE} ${PARAMSFILE} ${VARIANTFILEBASE} ${REFERENCE} ${METARESULTDIR} ${EXTENSION}

 		printf "#!/bin/bash\n${SCRIPTS}/meta.analyzer.sh ${CONFIGURATIONFILE} ${PARAMSFILE} ${VARIANTFILEBASE} ${REFERENCE} ${METARESULTDIR} ${EXTENSION} \n" > ${METARESULTDIR}/meta.analyzer.${EXTENSION}.sh
 		## qsub -S /bin/bash -N meta.analyzer -hold_jid meta.preparator -o ${METARESULTDIR}/meta.analyzer.${EXTENSION}.log -e ${METARESULTDIR}/meta.analyzer.${EXTENSION}.errors -l h_rt=${QRUNTIMEANALYZER} -l h_vmem=${QMEMANALYZER} -M ${QMAIL} -m ${QMAILOPTIONS} -cwd ${METARESULTDIR}/meta.analyzer.${EXTENSION}.sh
 		META_ANALYZER_ID=$(sbatch --parsable --job-name=meta.analyzer ${META_PREP_IDS_D} -o ${METARESULTDIR}/meta.analyzer.${EXTENSION}.log --error ${METARESULTDIR}/meta.analyzer.${EXTENSION}.errors --time=${QRUNTIMEANALYZER} --mem=${QMEMANALYZER} --mail-user=${QMAIL} --mail-type=${QMAILOPTIONS} ${METARESULTDIR}/meta.analyzer.${EXTENSION}.sh)

 		echo ""
 		echo "  - submit p-value correction job..."
 		### P-VALUE CORRECTION
 		# Some p-values are computed as 0 (because the Statistics module in Perl freaks out 
 		# for chi-square above a certain threshold). Here we can recompute these p-values 
 		# in R.
 		#
 		### HEADER OUTPUT
 		### -- verbose --
 		### VARIANTID CHR POS REF ALT REFFREQ EFFECTALLELE_COHORT1 OTHERALLELE_COHORT1 ALLELES_FLIPPED_COHORT1 SIGN_FLIPPED_COHORT1 EAF_COHORT1 BETA_COHORT1 SE_COHORT1 P_COHORT1 Info_COHORT1 NEFF_COHORT1 [...OTHER COHORTS HERE..] EFFECTALLELE OTHERALLELE EAF N_EFF Z_SQRTN P_SQRTN BETA_FIXED SE_FIXED Z_FIXED P_FIXED BETA_LOWER_FIXED BETA_UPPER_FIXED BETA_RANDOM  SE_RANDOM  Z_RANDOM  P_RANDOM  BETA_LOWER_RANDOM BETA_UPPER_RANDOM COCHRANS_Q DF P_COCHRANS_Q I_SQUARED TAU_SQUARED DIRECTIONS GENES_250KB NEAREST_GENE NEAREST_GENE_ENSEMBLID NEAREST_GENE_STRAND VARIANT_FUNCTION CAVEAT
 	
 		printf "#!/bin/bash\ncat ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.${EXTENSION}.out | ${SCRIPTS}/parseTable.pl --col VARIANTID,P_SQRTN,P_FIXED,P_RANDOM,Z_SQRTN,Z_FIXED,Z_RANDOM | awk '\$2 == 0 || \$3 == 0 || \$4 == 0 { print \$1, \$5, \$6, \$7 }' > ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.${EXTENSION}.needs_p_fixing.out \n" > ${METARESULTDIR}/meta.p_corrector.${EXTENSION}.sh
 		echo "Rscript ${SCRIPTS}/meta.pval_corrector.R --inputfile ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.${EXTENSION}.needs_p_fixing.out --outputfile ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.${EXTENSION}.fixed.out" >> ${METARESULTDIR}/meta.p_corrector.${EXTENSION}.sh
 		echo "echo \"VARIANTID P_SQRTN P_FIXED P_RANDOM\" > ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.${EXTENSION}.fixed_headed.out" >> ${METARESULTDIR}/meta.p_corrector.${EXTENSION}.sh
 		echo "tail -n +2 ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.${EXTENSION}.fixed.out >> ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.${EXTENSION}.fixed_headed.out" >> ${METARESULTDIR}/meta.p_corrector.${EXTENSION}.sh
 		echo "${SCRIPTS}/mergeTables.pl --file1 ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.${EXTENSION}.fixed_headed.out --file2 ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.${EXTENSION}.out --index VARIANTID --format NORM --replace > ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.${EXTENSION}.corrected_p.out" >> ${METARESULTDIR}/meta.p_corrector.${EXTENSION}.sh
		## qsub -S /bin/bash -N meta.p_corrector -hold_jid meta.analyzer -o ${METARESULTDIR}/meta.p_corrector.${EXTENSION}.log -e ${METARESULTDIR}/meta.p_corrector.${EXTENSION}.errors -l h_rt=${QRUNTIMEANALYZER} -l h_vmem=${QMEMANALYZER} -M ${QMAIL} -m ${QMAILOPTIONS} -cwd ${METARESULTDIR}/meta.p_corrector.${EXTENSION}.sh
 		META_P_CORRECTOR_ID=$(sbatch --parsable --job-name=meta.p_corrector --dependency=afterany:${META_ANALYZER_ID} -o ${METARESULTDIR}/meta.p_corrector.${EXTENSION}.log --error ${METARESULTDIR}/meta.p_corrector.${EXTENSION}.errors --time=${QRUNTIMEANALYZER} --mem=${QMEMANALYZER} --mail-user=${QMAIL} --mail-type=${QMAILOPTIONS} ${METARESULTDIR}/meta.p_corrector.${EXTENSION}.sh)
		META_P_CORRECTOR_STORE_ID="${META_P_CORRECTOR_STORE_ID},${META_P_CORRECTOR_ID}" 
 	done < ${VARIANTSFILES}

	# Remove the first character (',')
	META_P_CORRECTOR_STORE_ID="${META_P_CORRECTOR_STORE_ID:1}"

	echobold "#========================================================================================================"
	echobold "#== WRAPPING THE META-ANALYSIS RESULTS"
	echobold "#========================================================================================================"
	echobold "#"

	echo "Concatenating meta-analysis of GWAS results."
	VARIANTSFILES=${METATEMPRESULTDIR}/meta.all.unique.variants.reorder.split.list
	### For DEBUGGING
	### ${SCRIPTS}/meta.concatenator.sh ${CONFIGURATIONFILE} ${VARIANTSFILES} ${METARESULTDIR}

	printf "#!/bin/bash\n${SCRIPTS}/meta.concatenator.sh ${CONFIGURATIONFILE} ${VARIANTSFILES} ${METARESULTDIR} \n" > ${METARESULTDIR}/meta.concatenator.${PROJECTNAME}.${REFERENCE}.${POPULATION}.sh
 	## qsub -S /bin/bash -N meta.concatenator -hold_jid meta.p_corrector -o ${METARESULTDIR}/meta.concatenator.${PROJECTNAME}.${REFERENCE}.${POPULATION}.log -e ${METARESULTDIR}/meta.concatenator.${PROJECTNAME}.${REFERENCE}.${POPULATION}.errors -l h_rt=${QRUNTIME} -l h_vmem=${QMEM} -M ${QMAIL} -m ${QMAILOPTIONS} -cwd ${METARESULTDIR}/meta.concatenator.${PROJECTNAME}.${REFERENCE}.${POPULATION}.sh
	META_CONCATENATOR_ID=$(sbatch --parsable --job-name=meta.concatenator --dependency=afterany:${META_P_CORRECTOR_STORE_ID} -o ${METARESULTDIR}/meta.concatenator.${PROJECTNAME}.${REFERENCE}.${POPULATION}.log --error ${METARESULTDIR}/meta.concatenator.${PROJECTNAME}.${REFERENCE}.${POPULATION}.errors --time=${QRUNTIME} --mem=${QMEM} --mail-user=${QMAIL} --mail-type=${QMAILOPTIONS} ${METARESULTDIR}/meta.concatenator.${PROJECTNAME}.${REFERENCE}.${POPULATION}.sh)

	echobold "#========================================================================================================"
	echobold "#== PLOTTING THE CORRECTED META-ANALYSIS RESULTS"
	echobold "#========================================================================================================"
	echobold "#"

	#### Perhaps a separate plotter script for this?
	echo "Plotting the corrected meta-analysis results..."
	IMAGEFORMAT=${IMAGEFORMATMETA}

	echo "* Producing Manhattan-plots..." # CHR, BP, P-value (P_SQRTN P_FIXED P_RANDOM)
	printf "#!/bin/bash\nzcat ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.txt.gz | ${SCRIPTS}/parseTable.pl --col CHR,POS,P_SQRTN | tail -n +2 > ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.MANHATTAN.P_SQRTN.txt \n" > ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.MANHATTAN.sh
	echo "zcat ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.txt.gz | ${SCRIPTS}/parseTable.pl --col CHR,POS,P_FIXED | tail -n +2 > ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.MANHATTAN.P_FIXED.txt" >> ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.MANHATTAN.sh
	echo "zcat ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.txt.gz | ${SCRIPTS}/parseTable.pl --col CHR,POS,P_RANDOM | tail -n +2 > ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.MANHATTAN.P_RANDOM.txt" >> ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.MANHATTAN.sh
	echo "${SCRIPTS}/plotter.manhattan.R --projectdir ${METARESULTDIR} --resultfile ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.MANHATTAN.P_SQRTN.txt --outputdir ${METARESULTDIR} --colorstyle FULL --imageformat ${IMAGEFORMAT} --title ${PROJECTNAME}.${SUBPROJECTDIRNAME}.P_SQRTN" >> ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.MANHATTAN.sh
	echo "${SCRIPTS}/plotter.manhattan.R --projectdir ${METARESULTDIR} --resultfile ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.MANHATTAN.P_FIXED.txt --outputdir ${METARESULTDIR} --colorstyle FULL --imageformat ${IMAGEFORMAT} --title ${PROJECTNAME}.${SUBPROJECTDIRNAME}.P_FIXED" >> ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.MANHATTAN.sh
	echo "${SCRIPTS}/plotter.manhattan.R --projectdir ${METARESULTDIR} --resultfile ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.MANHATTAN.P_RANDOM.txt --outputdir ${METARESULTDIR} --colorstyle FULL --imageformat ${IMAGEFORMAT} --title ${PROJECTNAME}.${SUBPROJECTDIRNAME}.P_RANDOM" >> ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.MANHATTAN.sh
	echo "gzip -fv ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.MANHATTAN*.txt" >> ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.MANHATTAN.sh 
	## qsub -S /bin/bash -N META.MANHATTAN.${PROJECTNAME} -hold_jid meta.concatenator -o ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.MANHATTAN.log -e ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.MANHATTAN.errors -l h_vmem=${QMEMPLOTTER} -l h_rt=${QRUNTIMEPLOTTER} -wd ${METARESULTDIR} ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.MANHATTAN.sh
	META_MANHATTAN_ID=$(sbatch --parsable --job-name=META.MANHATTAN.${PROJECTNAME} --dependency=afterany:${META_CONCATENATOR_ID} -o ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.MANHATTAN.log --error ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.MANHATTAN.errors --time=${QRUNTIMEPLOTTER} --mem=${QMEMPLOTTER} --mail-user=${QMAIL} --mail-type=${QMAILOPTIONS} --chdir ${METARESULTDIR} ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.MANHATTAN.sh)

	echo "* Producing normal QQ-plots..."
	echo "  - p-value based on square root of N" # P_SQRTN
	printf "#!/bin/bash\nzcat ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.txt.gz | ${SCRIPTS}/parseTable.pl --col P_SQRTN | tail -n +2 > ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_sqrtn.txt \n" > ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_sqrtn.sh
	echo "zcat ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.txt.gz | ${SCRIPTS}/parseTable.pl --col P_SQRTN,CAF | tail -n +2 > ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_sqrtn_by_CAF.txt" >> ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_sqrtn.sh
	echo "${SCRIPTS}/plotter.qq.R --projectdir ${METARESULTDIR} --resultfile ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_sqrtn.txt --outputdir ${METARESULTDIR} --stattype ${STATTYPE} --imageformat ${IMAGEFORMAT}" >> ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_sqrtn.sh
	echo "${SCRIPTS}/plotter.qq_by_caf.R --projectdir ${METARESULTDIR} --resultfile ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_sqrtn_by_CAF.txt --outputdir ${METARESULTDIR} --stattype ${STATTYPE} --imageformat ${IMAGEFORMAT}" >> ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_sqrtn.sh
	echo  "gzip -fv ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_sqrtn*.txt" >> ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_sqrtn.sh
	## qsub -S /bin/bash -N META.QQ_SQRTN.${PROJECTNAME} -hold_jid meta.concatenator -o ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_sqrtn.log -e ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_sqrtn.errors -l h_vmem=${QMEMPLOTTER} -l h_rt=${QRUNTIMEPLOTTER} -wd ${METARESULTDIR} ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_sqrtn.sh
	META_QQ_SQRTN_ID=$(sbatch --parsable --job-name=META.QQ_SQRTN.${PROJECTNAME} --dependency=afterany:${META_CONCATENATOR_ID} -o ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_sqrtn.log --error ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_sqrtn.errors --time=${QRUNTIMEPLOTTER} --mem=${QMEMPLOTTER} --mail-user=${QMAIL} --mail-type=${QMAILOPTIONS} --chdir ${METARESULTDIR} ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_sqrtn.sh)

	echo "  - based on fixed-effects p-value..." # P_FIXED
	printf "#!/bin/bash\nzcat ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.txt.gz | ${SCRIPTS}/parseTable.pl --col P_FIXED | tail -n +2 > ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_fixed.txt \n" > ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_fixed.sh
	echo "zcat ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.txt.gz | ${SCRIPTS}/parseTable.pl --col P_FIXED,CAF | tail -n +2 > ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_fixed_by_CAF.txt" >> ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_fixed.sh
	echo "${SCRIPTS}/plotter.qq.R --projectdir ${METARESULTDIR} --resultfile ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_fixed.txt --outputdir ${METARESULTDIR} --stattype ${STATTYPE} --imageformat ${IMAGEFORMAT}" >> ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_fixed.sh
	echo "${SCRIPTS}/plotter.qq_by_caf.R --projectdir ${METARESULTDIR} --resultfile ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_fixed_by_CAF.txt --outputdir ${METARESULTDIR} --stattype ${STATTYPE} --imageformat ${IMAGEFORMAT}" >> ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_fixed.sh
	echo  "gzip -fv ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_fixed*.txt" >> ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_fixed.sh
	## qsub -S /bin/bash -N META.QQ_FIXED.${PROJECTNAME} -hold_jid meta.concatenator -o ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_fixed.log -e ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_fixed.errors -l h_vmem=${QMEMPLOTTER} -l h_rt=${QRUNTIMEPLOTTER} -wd ${METARESULTDIR} ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_fixed.sh
	META_QQ_FIXED_ID=$(sbatch --parsable --job-name=META.QQ_FIXED.${PROJECTNAME} --dependency=afterany:${META_CONCATENATOR_ID} -o ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_fixed.log --error ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_fixed.errors --time=${QRUNTIMEPLOTTER} --mem=${QMEMPLOTTER} --mail-user=${QMAIL} --mail-type=${QMAILOPTIONS} --chdir ${METARESULTDIR} ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_fixed.sh)

	echo "  - based on random-effects p-value..." # P_RANDOM
	printf "#!/bin/bash\nzcat ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.txt.gz | ${SCRIPTS}/parseTable.pl --col P_RANDOM | tail -n +2 > ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_random.txt \n" > ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_random.sh
	echo "zcat ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.txt.gz | ${SCRIPTS}/parseTable.pl --col P_RANDOM,CAF | tail -n +2 > ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_random_by_CAF.txt" >> ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_random.sh
	echo "${SCRIPTS}/plotter.qq.R --projectdir ${METARESULTDIR} --resultfile ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_random.txt --outputdir ${METARESULTDIR} --stattype ${STATTYPE} --imageformat ${IMAGEFORMAT}" >> ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_random.sh
	echo "${SCRIPTS}/plotter.qq_by_caf.R --projectdir ${METARESULTDIR} --resultfile ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_random_by_CAF.txt --outputdir ${METARESULTDIR} --stattype ${STATTYPE} --imageformat ${IMAGEFORMAT}" >> ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_random.sh
	echo  "gzip -fv ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_random*.txt" >> ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_random.sh
	## qsub -S /bin/bash -N META.QQ_RANDOM.${PROJECTNAME} -hold_jid meta.concatenator -o ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_random.log -e ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_random.errors -l h_vmem=${QMEMPLOTTER} -l h_rt=${QRUNTIMEPLOTTER} -wd ${METARESULTDIR} ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_random.sh
	META_QQ_RANDOM_ID=$(sbatch --parsable --job-name=META.QQ_RANDOM.${PROJECTNAME} --dependency=afterany:${META_CONCATENATOR_ID} -o ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_random.log --error ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_random.errors --time=${QRUNTIMEPLOTTER} --mem=${QMEMPLOTTER} --mail-user=${QMAIL} --mail-type=${QMAILOPTIONS} --chdir ${METARESULTDIR} ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_random.sh)
 
	echoerror "###############################"
	echoerror "### THIS PART NEEDS FIXING ####"
	echo "  - to make histograms of N_EFF and DF+1"
	### adjust number of bins in histogram with number of contributing studies 
	### (i.e. -CL -inputfile -number.of.studies -output.file)
	### FUTURE VERSION: updated script which uses Rscript instead of 'R CMD BATCH -CL'; including automatic determination of number of studies
	printf "#!/bin/bash\nNSTUDIES=$(cat ${METARESULTDIR}/meta.cohorts.cleaned.txt | wc -l) \n" > ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.n_eff.sh
	echo "zcat ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.txt.gz | ${SCRIPTS}/parseTable.pl --col N_EFF,DF | tail -n +2 | grep -v NA > ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.n_eff.txt" >> ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.n_eff.sh
	echo "R CMD BATCH -CL -${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.n_eff.txt -\$NSTUDIES -PNG -${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.n_eff ${SCRIPTS}/plotter.n_eff_k_studies.R" >> ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.n_eff.sh
	## qsub -S /bin/bash -N META.N_EFF.${PROJECTNAME} -hold_jid meta.concatenator -o ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.n_eff.log -e ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.n_eff.errors -l h_vmem=${QMEMPLOTTER} -l h_rt=${QRUNTIMEPLOTTER} -wd ${METARESULTDIR} ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.n_eff.sh
	META_N_EFF_ID=$(sbatch --parsable --job-name=META.N_EFF.${PROJECTNAME} --dependency=afterany:${META_CONCATENATOR_ID} -o ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.n_eff.log --error ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.n_eff.errors --time=${QRUNTIMEPLOTTER} --mem=${QMEMPLOTTER} --mail-user=${QMAIL} --mail-type=NONE --chdir ${METARESULTDIR} ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.n_eff.sh)

	### Add in functions based on Winkler et al. (SE-Lambda-Plot, frequency plot among others)
	echo "  - to make SE-N-lambda plot"
	### FUTURE VERSION: updated script which uses Rscript instead of 'R CMD BATCH -CL';
	printf "#!/bin/bash\nperl ${SCRIPTS}/se-n-lambda.pl ${PROJECTDIR}/metagwastoolkit.${SUBPROJECTDIRNAME}.studyfile ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.se_n_lambda.txt 1Gp1 \n" > ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.se_n_lambda.sh
	echo "R CMD BATCH --args -CL -${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.se_n_lambda.txt -PNG -${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.se_n_lambda.PNG ${SCRIPTS}/plotter.se_n_lambda.R" >> ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.se_n_lambda.sh
	## qsub -S /bin/bash -N META.SE_N_LAMBDA.${PROJECTNAME} -hold_jid meta.concatenator -o ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.se_n_lambda.log -e ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.se_n_lambda.errors -l h_vmem=${QMEMPLOTTER} -l h_rt=${QRUNTIMEPLOTTER} -wd ${METARESULTDIR} ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.se_n_lambda.sh
	META_SE_N_LAMBDA_ID=$(sbatch --parsable --job-name=META.SE_N_LAMBDA.${PROJECTNAME} --dependency=afterany:${META_CONCATENATOR_ID} -o ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.se_n_lambda.log --error ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.se_n_lambda.errors --time=${QRUNTIMEPLOTTER} --mem=${QMEMPLOTTER} --mail-user=${QMAIL} --mail-type=NONE --chdir ${METARESULTDIR} ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.se_n_lambda.sh)

	echoerror "### THIS PART NEEDS FIXING ####"
	echoerror ###############################
 
 	echobold "#========================================================================================================"
 	echobold "#== GENOMIC CONTROL *AFTER* META-ANALYSIS USING LAMBDA CORRECTION"
 	echobold "#========================================================================================================"
 	echobold "#"
 
 	printf "#!/bin/bash\nzcat ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.txt.gz | ${SCRIPTS}/parseTable.pl --col VARIANTID,BETA_FIXED,SE_FIXED > ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.beta_se.txt \n" > ${METARESULTDIR}/meta.genomic_control.sh
 	echo "Rscript ${SCRIPTS}/meta.pval_gc_corrector.R --inputfile ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.beta_se.txt --outputfile ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.beta_se.lambda_corrected.txt " >> ${METARESULTDIR}/meta.genomic_control.sh
 	echo "${SCRIPTS}/mergeTables.pl --file1 ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.beta_se.lambda_corrected.txt --file2 ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.txt.gz --index VARIANTID --format GZIP2 > ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.GC.txt " >> ${METARESULTDIR}/meta.genomic_control.sh
 	echo "gzip -fv ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.GC.txt " >> ${METARESULTDIR}/meta.genomic_control.sh
 	echo "rm -v ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.beta_se.lambda_corrected.txt ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.beta_se.txt " >> ${METARESULTDIR}/meta.genomic_control.sh
 	## qsub -S /bin/bash -N meta.genomic_control -hold_jid meta.concatenator -o ${METARESULTDIR}/meta.genomic_control.log -e ${METARESULTDIR}/meta.genomic_control.errors -l h_rt=${QRUNTIMECLEANER} -l h_vmem=${QMEMCLEANER} -M ${QMAIL} -m ${QMAILOPTIONS} -wd ${METARESULTDIR} ${METARESULTDIR}/meta.genomic_control.sh
 	META_GENOMIC_CONTROL_ID=$(sbatch --parsable --job-name=meta.genomic_control --dependency=afterany:${META_CONCATENATOR_ID} -o ${METARESULTDIR}/meta.genomic_control.log --error ${METARESULTDIR}/meta.genomic_control.errors --time=${QRUNTIMEPLOTTER} --mem=${QMEMPLOTTER} --mail-user=${QMAIL} --mail-type=${QMAILOPTIONS} --chdir ${METARESULTDIR} ${METARESULTDIR}/meta.genomic_control.sh)

 	IMAGEFORMAT=${IMAGEFORMATMETA}
 	
 	### make pretty Manhattan plots
 	echo "* Producing Manhattan-plot after genomic-control..." # CHR, BP, P-value (P_GC)
 	printf "#!/bin/bash\nzcat ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.GC.txt.gz | ${SCRIPTS}/parseTable.pl --col CHR,POS,P_GC | tail -n +2 > ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.MANHATTAN.P_GC.txt \n" > ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.MANHATTAN.P_GC.sh
 	echo "${SCRIPTS}/plotter.manhattan.R --projectdir ${METARESULTDIR} --resultfile ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.MANHATTAN.P_GC.txt --outputdir ${METARESULTDIR} --colorstyle FULL --imageformat ${IMAGEFORMAT} --title ${PROJECTNAME}.${SUBPROJECTDIRNAME}.P_GC" >> ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.MANHATTAN.P_GC.sh
 	echo "gzip -fv ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.MANHATTAN.P_GC.txt" >> ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.MANHATTAN.P_GC.sh
	## qsub -S /bin/bash -N META.GC.MANHATTAN.${PROJECTNAME} -hold_jid meta.genomic_control -o ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.MANHATTAN.P_GC.log -e ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.MANHATTAN.P_GC.errors -l h_vmem=${QMEMPLOTTER} -l h_rt=${QRUNTIMEPLOTTER} -wd ${METARESULTDIR} ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.MANHATTAN.P_GC.sh
  	META_GC_MANHATTAN_ID=$(sbatch --parsable --job-name=META.GC.MANHATTAN.${PROJECTNAME} --dependency=afterany:${META_GENOMIC_CONTROL_ID} -o ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.MANHATTAN.P_GC.log --error ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.MANHATTAN.P_GC.errors --time=${QRUNTIMEPLOTTER} --mem=${QMEMPLOTTER} --mail-user=${QMAIL} --mail-type=NONE --chdir ${METARESULTDIR} ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.MANHATTAN.P_GC.sh)

 	echo "* Producing QQ-plots after genomic control" # P_GC
 	printf "#!/bin/bash\nzcat ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.GC.txt.gz | ${SCRIPTS}/parseTable.pl --col P_GC | tail -n +2 > ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_gc.txt \n" > ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_gc.sh
 	echo "zcat ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.GC.txt.gz | ${SCRIPTS}/parseTable.pl --col P_GC,CAF | tail -n +2 > ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_gc_by_CAF.txt" >> ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_gc.sh
 	echo "${SCRIPTS}/plotter.qq.R --projectdir ${METARESULTDIR} --resultfile ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_gc.txt --outputdir ${METARESULTDIR} --stattype ${STATTYPE} --imageformat ${IMAGEFORMAT}" >> ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_gc.sh
 	echo "${SCRIPTS}/plotter.qq_by_caf.R --projectdir ${METARESULTDIR} --resultfile ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_gc_by_CAF.txt --outputdir ${METARESULTDIR} --stattype ${STATTYPE} --imageformat ${IMAGEFORMAT}" >> ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_gc.sh
 	echo "gzip -fv ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_gc*.txt" >> ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_gc.sh
	## qsub -S /bin/bash -N META.GC.QQ.${PROJECTNAME} -hold_jid meta.genomic_control -o ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_gc.log -e ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_gc.errors -l h_vmem=${QMEMPLOTTER} -l h_rt=${QRUNTIMEPLOTTER} -wd ${METARESULTDIR} ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_gc.sh
  	META_GC_QQ_ID=$(sbatch --parsable --job-name=META.GC.QQ.${PROJECTNAME} --dependency=afterany:${META_GENOMIC_CONTROL_ID} -o ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_gc.log --error ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_gc.errors --time=${QRUNTIMEPLOTTER} --mem=${QMEMPLOTTER} --mail-user=${QMAIL} --mail-type=NONE --chdir ${METARESULTDIR} ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.QQ_gc.sh)


 	echobold "#========================================================================================================"
 	echobold "#== META-ANALYSIS SUMMARIZER"
 	echobold "#========================================================================================================"
 	echobold "#"
 	echo "Creating meta-analysis summary file..." 
 	printf "#!/bin/bash\nzcat ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.GC.txt.gz | ${SCRIPTS}/parseTable.pl --col VARIANTID,CHR,POS,MINOR,MAJOR,MAF,CODEDALLELE,OTHERALLELE,CAF,N_EFF,Z_SQRTN,P_SQRTN,BETA_FIXED,SE_FIXED,Z_FIXED,P_FIXED,BETA_LOWER_FIXED,BETA_UPPER_FIXED,BETA_GC,SE_GC,Z_GC,P_GC,BETA_RANDOM,SE_RANDOM,Z_RANDOM,P_RANDOM,BETA_LOWER_RANDOM,BETA_UPPER_RANDOM,COCHRANS_Q,DF,P_COCHRANS_Q,I_SQUARED,TAU_SQUARED,DIRECTIONS,GENES_250KB,NEAREST_GENE,NEAREST_GENE_ENSEMBLID,NEAREST_GENE_STRAND,VARIANT_FUNCTION,CAVEAT > ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.summary.txt \n" > ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.metasum.sh
 	echo "gzip -fv ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.summary.txt " >> ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.metasum.sh
	## qsub -S /bin/bash -N METASUM -hold_jid meta.genomic_control -o ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.metasum.log -e ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.metasum.errors -l h_vmem=${QMEMANALYZER} -l h_rt=${QRUNTIMEANALYZER} -wd ${METARESULTDIR} ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.metasum.sh
   	META_SUM_ID=$(sbatch --parsable --job-name=METASUM --dependency=afterany:${META_GENOMIC_CONTROL_ID} -o ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.metasum.log --error ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.metasum.errors --time=${QRUNTIMEANALYZER} --mem=${QMEMANALYZER} --mail-user=${QMAIL} --mail-type=${QMAILOPTIONS} --chdir ${METARESULTDIR} ${METARESULTDIR}/meta.results.${PROJECTNAME}.${REFERENCE}.${POPULATION}.metasum.sh)

	# Create a textfile to store ids, which can be used as dependancies later
	echo "${META_SUM_ID}" >> ${SUBPROJECTDIRNAME}/meta_sum_ids.txt
	
	### END of if-else statement for the number of command-line arguments passed ###
fi 

script_copyright_message