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
echobold "                      --- REFORMAT, PARSE, HARMONIZE, CLEAN ORIGINAL GWAS DATA ---"
echobold ""
echobold "* Version:      v1.6.6"
echobold ""
echobold "* Last update:  2023-09-22"
echobold "* Based on:     MANTEL, as written by Sara Pulit, Jessica van Setten, and Paul de Bakker."
echobold "* Written by:   Sander W. van der Laan | s.w.vanderlaan@gmail.com."
echobold "                Sara Pulit; "
echobold "                Jessica van Setten; "
echobold "                Paul I.W. de Bakker; "
echobold "                Emma J.A. Smulders."
echobold "* Testers:      Jessica van Setten; Emma J.A. Smulders; M. Baksi; Mike Puijk."
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
echobold "  - A high-performance computer cluster with a SLURM system"
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
	
	# Time & Memory
	QMEMPARSER=${QMEMPARSER}
	QRUNTIMEPARSER=${QRUNTIMEPARSER}
	GWASLABTIME=${GWASLABTIME}
	GWASLABMEM=${GWASLABMEM}
	QMAIL=${QMAIL}
	# Where MetaGWASToolKit resides
	METAGWASTOOLKIT=${METAGWASTOOLKITDIR} # from configuration file
	SCRIPTS=${METAGWASTOOLKIT}/SCRIPTS
	RESOURCES=${METAGWASTOOLKIT}/RESOURCES
	
	# Project information
	ORIGINALS=${DATA_UPLOAD_FREEZE} # from configuration file
	PROJECTDIR=${PROJECTDIR} # from configuration file
	SUBPROJECTDIRNAME=${SUBPROJECTDIRNAME} # from configuration file
	OUTPUTDIRNAME=${OUTPUTDIRNAME} # from configuration file
	GWASFILES="$2" # Depends on arg2 -- all the GWAS dataset information; e.g. metagwastoolkit.files.list
	REFERENCE=${REFERENCE} # from configuration file
	REFFREQFILE=${REFFREQFILE} # from configuration file
	POPULATION=${POPULATION} # from configuration file
	REF=${GWASLAB_REF}
	ONLY_QC=${ONLY_QC}
	PARSING=${PARSING}
	SELECT_LEADS=${SELECT_LEADS}
	MAKE_FIGURES=${MAKE_FIGURES}
	PERFORM_QC=${PERFORM_QC}
	DAF=${DAF}
	EAF=${EAF}
	MAC=${MAC}
	HWE=${HWE}
	INFO=${INFO}
	BETA=${BETA}
	SE=${SE}
	CHUNKSIZE=${CHUNKSIZE}
	GWASLAB_ENV=${GWASLAB_ENV}
	LIFTOVER=${LIFTOVER}
	##########################################################################################
	### CREATE THE OUTPUT DIRECTORIES
	echo ""
	echo "Checking for the existence of the output directory [ ${OUTPUTDIRNAME} ]."
	if [ ! -d ${PROJECTDIR}/${OUTPUTDIRNAME} ]; then
		echo "> Output directory doesn't exist - Mr. Bourne will create it for you."
		mkdir -v ${PROJECTDIR}/${OUTPUTDIRNAME}
	else
		echo "> Output directory already exists."
		ls -lh ${PROJECTDIR}/${OUTPUTDIRNAME}
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
	if [[ ${REFERENCE} = "19" ]]; then

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
	
	elif [[ ${REFERENCE} = "38" ]]; then
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
	else
	  	echoerror "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	  	echoerror ""
	  	echoerrorflash "                  *** Oh, computer says no! Argument not recognised. ***"
	  	echoerror "You have the following options as reference for the quality control"
	  	echoerror "and meta-analysis:"
	  	echoerror " - [19]          hg19 / build 37"
	  	echoerror " - [38]         hg38 / build 38"
	  	echoerror "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
		### The wrong arguments are passed, so we'll exit the script now!
		echo ""
		script_copyright_message
		exit 1
	fi
		echo "Raw data directory.............................: "${METAOUTPUT}/${SUBPROJECTDIRNAME}/RAW
		echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
		echo ""
	
	echobold "#########################################################################################################"
	echobold "### REFORMAT, PARSE, HARMONIZE, CLEAN, AND PLOT ORIGINAL GWAS DATA REFORMAT, PARSE, HARMONIZE, CLEANING ORIGINAL GWAS DATA: [ ${COHORT} ]" 
	echobold "#########################################################################################################"
	echobold "#"
	echo ""
	echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echo "Start the reformatting, parsing, harmonizing, and cleaning of each cohort and dataset. "
	echo ""
	### SLURM version
	### Create a file to put the SBATCH IDs for the raw and cleaned file plotting in.
	###This can be used as depenendancy down the road.
	
	
	### Create a file with reference allele frequencies which is neccesary for plotting later.
	### Creates slight bottleneck, this step could be changed to an sbatch command, while making the gwas.plotter.sh steps dependant on this.
	
	while read -r GWASCOHORT || [[ -n "$GWASCOHORT" ]]; do
		(
		COHORT=$(echo "${GWASCOHORT}" | awk '{ print $1 }')
		FILE=$(echo "${GWASCOHORT}" | awk '{ print $2 }')
		#BASEFILE=$(basename ${FILE} .gz)
		RAWDATACOHORT=${RAWDATA}/${COHORT}
		mkdir -p ${RAWDATACOHORT}/{PLOTS,GWASCatalog}
		# Smart basename stripping all known suffixes
		# Extract filename without path
		FILENAME="${FILE##*/}"
		BASEFILE="${FILENAME%.txt.gz}"
		BASEFILE="${BASEFILE%.tsv.gz}"
		BASEFILE="${BASEFILE%.gz}"
		BASEFILE="${BASEFILE%.txt}"
		source "${GWASLAB_ENV}" gwaslab_env
		if [ "$ONLY_QC" == "YES" ]; then
		GWASLAB_JOBID=$(sbatch --parsable \
        --job-name=${COHORT}_GWAS \
        --output=${PROJECTDIR}/${METAOUTPUT}/${SUBPROJECTDIRNAME}/RAW/${COHORT}/${COHORT}.gwaslab.out \
        --error=${PROJECTDIR}/${METAOUTPUT}/${SUBPROJECTDIRNAME}/RAW/${COHORT}/${COHORT}.gwaslab.err \
        --time=24:00:00 \
        --mem=128G \
        --cpus-per-task=2 \
        --mail-user=${QMAIL} \
        --export=ALL,COHORT=${COHORT},FILE=${BASEFILE}.merged.gwaslab.tsv.gz,RAWDATACOHORT=${RAWDATACOHORT},GWASLAB_ENV=${GWASLAB_ENV},ONLY_QC=${ONLY_QC},SCRIPTS=${SCRIPTS},ORIGINALS=${ORIGINALS},POPULATION=${POPULATION},REFERENCE=${REFERENCE},REF=${REF},PERFORM_QC=${PERFORM_QC},MAKE_FIGURES=${MAKE_FIGURES},DAF=${DAF},EAF=${EAF},BETA=${BETA},SE=${SE},INFO=${INFO},MAC=${MAC},HWE=${HWE},LIFTOVER=${LIFTOVER},SELECT_LEADS=${SELECT_LEADS}  \
        ${SCRIPTS}/gwaslab.cohort.sh)

		elif [ "$PARSING" == "YES" ]; then
		# Submit the R parsing job
		PARSE_JOBID=$(sbatch --parsable \
            --job-name=${COHORT}_parser \
            --output=${RAWDATACOHORT}/${COHORT}.parser.out \
            --error=${RAWDATACOHORT}/${COHORT}.parser.err \
            --mem=${QMEMPARSER} \
            --gres=tmpspace:128G \
            --time=${QRUNTIMEPARSER} \
            --cpus-per-task=1 \
            --mail-user=${QMAIL} \
            --export=ALL,COHORT=${COHORT},FILE=${FILE},SCRIPTS=${SCRIPTS},ORIGINALS=${ORIGINALS} \
            ${SCRIPTS}/pipeline.parser.sh)

		if ! [[ "$PARSE_JOBID" =~ ^[0-9]+$ ]]; then
			echo "Parser job submission failed for ${COHORT}."
			exit 1
		fi
		echo "Submitted parser for ${COHORT} as job ${PARSE_JOBID}"
      # Prepare a splitting job dependent on the parser
        SPLITSCRIPT=${RAWDATACOHORT}/split_after_parse.${COHORT}.sh
        if [[ -f ${ORIGINALS}/${COHORT}/${BASEFILE}.txt.gz ]]; then
           PARSED_FILE=${ORIGINALS}/${COHORT}/${BASEFILE}.txt.gz
        elif [[ -f ${ORIGINALS}/${COHORT}/${BASEFILE}.tsv.gz ]]; then
           PARSED_FILE=${ORIGINALS}/${COHORT}/${BASEFILE}.tsv.gz
        elif [[ -f ${ORIGINALS}/${COHORT}/${BASEFILE}.gz ]]; then
           PARSED_FILE=${ORIGINALS}/${COHORT}/${BASEFILE}.gz
        else
           echo "Parsed file not found for ${COHORT} at expected locations."
           exit 1
         fi
        echo "${PARSED_FILE}"

        cat <<EOF > $SPLITSCRIPT
#!/bin/bash
zcat ${PARSED_FILE} | tail -n +2 | split -a 3 -l ${CHUNKSIZE} - ${RAWDATACOHORT}/${BASEFILE}.
zcat ${PARSED_FILE} | head -1 > ${RAWDATACOHORT}/header.tmp
> ${RAWDATACOHORT}/splitfiles.txt
for f in ${RAWDATACOHORT}/${BASEFILE}.[a-z][a-z][a-z]; do
    cat ${RAWDATACOHORT}/header.tmp \$f > \$f.tmp && mv \$f.tmp \$f
    echo \$f >> ${RAWDATACOHORT}/splitfiles.txt
done
rm ${RAWDATACOHORT}/header.tmp
EOF
        chmod +x $SPLITSCRIPT
        SPLIT_LAUNCH_JOBID=$(sbatch --parsable \
            --dependency=afterany:${PARSE_JOBID} \
            --job-name=split.${COHORT} \
            --mem=2G --time=00:30:00 \
            --output=${RAWDATACOHORT}/split.${COHORT}.out \
            --error=${RAWDATACOHORT}/split.${COHORT}.err \
            $SPLITSCRIPT)

        if ! [[ "$SPLIT_LAUNCH_JOBID" =~ ^[0-9]+$ ]]; then
            echo "Split job submission failed for ${COHORT}."
            exit 1
        fi
        echo "Submitted split job for ${COHORT} as job ${SPLIT_LAUNCH_JOBID}"
        ARRAY_SUBMIT_SCRIPT=${RAWDATACOHORT}/submit_array_${COHORT}.sh
cat <<'EOF' > $ARRAY_SUBMIT_SCRIPT
#!/bin/bash
# This script runs *as a job* after splitting, to submit the array job once splitfiles.txt exists

SPLITFILELIST=${RAWDATACOHORT}/splitfiles.txt

if [ ! -f $SPLITFILELIST ]; then
  echo "ERROR: splitfiles.txt not found at $SPLITFILELIST"
  exit 1
fi

NFILES=$(wc -l < $SPLITFILELIST)
NFILES=$((NFILES - 1))

if [ \$NFILES -lt 0 ]; then
  echo "ERROR: No valid split files found."
  exit 1
fi

# Submit the array job now that NFILES is known
ARRAY_JOBID=$(sbatch --parsable \
		--job-name=${COHORT}.splitfiles \
		--array=0-${NFILES} \
		--time=3:00:00 \
		--mem=32G \
		-c 1 \
		-o ${RAWDATACOHORT}/gwas.parser_harm_cleaner.array.%a.log \
		--error ${RAWDATACOHORT}/gwas.parser_harm_cleaner.array.%a.errors \
		--export=RAWDATACOHORT=${RAWDATACOHORT},COHORT=${COHORT},FILE=${FILE},INIT_ID=${INIT_ID} \
		${SCRIPTS}/metagwastoolkit.gwaslab.splitfiles.HPC.sh ${CONFIGURATIONFILE})
echo $ARRAY_JOBID > ${RAWDATACOHORT}/array_jobid.txt
echo "Submitted array job for ${COHORT} as job $ARRAY_JOBID"
EOF

chmod +x $ARRAY_SUBMIT_SCRIPT

# Submit this job script as a dependency of the split job
ARRAY_LAUNCH_JOBID=$(sbatch --parsable \
  --dependency=afterany:${SPLIT_LAUNCH_JOBID} \
  --job-name=arraylauncher.${COHORT} \
  --mem=10G \
  --time=01:00:00 \
  --output=${RAWDATACOHORT}/launch_array.${COHORT}.out \
  --export=RAWDATACOHORT=${RAWDATACOHORT},COHORT=${COHORT},FILE=${FILE},INIT_ID=${INIT_ID},SCRIPTS=${SCRIPTS},CONFIGURATIONFILE=${CONFIGURATIONFILE} \
  --error=${RAWDATACOHORT}/launch_array.${COHORT}.err \
  ${ARRAY_SUBMIT_SCRIPT})

ARRAY_JOBID_FILE="${RAWDATACOHORT}/array_jobid.txt"
MIN_WAIT=5
MAX_WAIT=120
COUNTER=0

echo "⏳ Waiting at least $MIN_WAIT minutes, and up to $MAX_WAIT minutes, for array_jobid.txt..."

while [ $COUNTER -lt $MIN_WAIT ]; do
  sleep 60
  ((COUNTER++))
  echo "  → (Minimum wait) Minute $COUNTER..."
done

while [ ! -f "$ARRAY_JOBID_FILE" ] && [ $COUNTER -lt $MAX_WAIT ]; do
  sleep 60
  ((COUNTER++))
  echo "  → (Checking) Minute $COUNTER... file not found yet."
done

if [ -f "$ARRAY_JOBID_FILE" ]; then
  REAL_ARRAY_JOBID=$(cat "$ARRAY_JOBID_FILE")
  echo "✅ Found array job ID: $REAL_ARRAY_JOBID"
else
  echo "❌ ERROR: array_jobid.txt was not created after $MAX_WAIT minutes."
  exit 1
fi

		WRAP_JOBID=$(sbatch --parsable \
    --job-name=wrap.${COHORT} \
    --dependency=afterany:${REAL_ARRAY_JOBID} \
    --mem=${QMEMWRAPPER} \
    --time=${QRUNTIMEWRAPPER} \
    --export=ALL,RAWDATACOHORT=${RAWDATACOHORT},COHORT=${COHORT},BASEFILE=${BASEFILE},SCRIPTS=${SCRIPTS} \
    -o ${RAWDATACOHORT}/gwas.wrapper.${BASEFILE}.log \
    --error=${RAWDATACOHORT}/gwas.wrapper.${BASEFILE}.errors \
    ${SCRIPTS}/gwaslab.wrapper.sh)
    source "${GWASLAB_ENV}" gwaslab_env
		GWASLAB_JOBID=$(sbatch --parsable \
        --job-name=${COHORT}_GWAS \
        --output=${PROJECTDIR}/${METAOUTPUT}/${SUBPROJECTDIRNAME}/RAW/${COHORT}/${COHORT}.gwaslab.out \
        --error=${PROJECTDIR}/${METAOUTPUT}/${SUBPROJECTDIRNAME}/RAW/${COHORT}/${COHORT}.gwaslab.err \
        --dependency=afterany:${WRAP_JOBID} \
        --time=24:00:00 \
        --mem=92G \
        --cpus-per-task=2 \
        --mail-user=${QMAIL} \
        --export=ALL,COHORT=${COHORT},FILE=${BASEFILE}.merged.gwaslab.tsv.gz,RAWDATACOHORT=${RAWDATACOHORT},GWASLAB_ENV=${GWASLAB_ENV},ONLY_QC=${ONLY_QC},SCRIPTS=${SCRIPTS},ORIGINALS=${ORIGINALS},POPULATION=${POPULATION},REFERENCE=${REFERENCE},REF=${REF},PERFORM_QC=${PERFORM_QC},MAKE_FIGURES=${MAKE_FIGURES},DAF=${DAF},EAF=${EAF},BETA=${BETA},SE=${SE},INFO=${INFO},MAC=${MAC},HWE=${HWE},LIFTOVER=${LIFTOVER},SELECT_LEADS=${SELECT_LEADS} \
        ${SCRIPTS}/gwaslab.cohort.sh)

		else
        SPLITSCRIPT=${RAWDATACOHORT}/split_after_parse.${COHORT}.sh
        if [[ -f ${ORIGINALS}/${COHORT}/${BASEFILE}.txt.gz ]]; then
           PARSED_FILE=${ORIGINALS}/${COHORT}/${BASEFILE}.txt.gz
        elif [[ -f ${ORIGINALS}/${COHORT}/${BASEFILE}.tsv.gz ]]; then
           PARSED_FILE=${ORIGINALS}/${COHORT}/${BASEFILE}.tsv.gz
        elif [[ -f ${ORIGINALS}/${COHORT}/${BASEFILE}.gz ]]; then
           PARSED_FILE=${ORIGINALS}/${COHORT}/${BASEFILE}.gz
        else
           echo "Parsed file not found for ${COHORT} at expected locations."
           exit 1
         fi
        echo "${PARSED_FILE}"

        cat <<EOF > $SPLITSCRIPT
#!/bin/bash
zcat ${PARSED_FILE} | tail -n +2 | split -a 3 -l ${CHUNKSIZE} - ${RAWDATACOHORT}/${BASEFILE}.
zcat ${PARSED_FILE} | head -1 > ${RAWDATACOHORT}/header.tmp
> ${RAWDATACOHORT}/splitfiles.txt
for f in ${RAWDATACOHORT}/${BASEFILE}.[a-z][a-z][a-z]; do
    cat ${RAWDATACOHORT}/header.tmp \$f > \$f.tmp && mv \$f.tmp \$f
    echo \$f >> ${RAWDATACOHORT}/splitfiles.txt
done
rm ${RAWDATACOHORT}/header.tmp
EOF
        chmod +x $SPLITSCRIPT
        SPLIT_LAUNCH_JOBID=$(sbatch --parsable \
            --job-name=split.${COHORT} \
            --mem=2G --time=00:30:00 \
            --output=${RAWDATACOHORT}/split.${COHORT}.out \
            --error=${RAWDATACOHORT}/split.${COHORT}.err \
            $SPLITSCRIPT)

        if ! [[ "$SPLIT_LAUNCH_JOBID" =~ ^[0-9]+$ ]]; then
            echo "Split job submission failed for ${COHORT}."
            exit 1
        fi
        echo "Submitted split job for ${COHORT} as job ${SPLIT_LAUNCH_JOBID}"
        ARRAY_SUBMIT_SCRIPT=${RAWDATACOHORT}/submit_array_${COHORT}.sh
cat <<'EOF' > $ARRAY_SUBMIT_SCRIPT
#!/bin/bash
# This script runs *as a job* after splitting, to submit the array job once splitfiles.txt exists

SPLITFILELIST=${RAWDATACOHORT}/splitfiles.txt

if [ ! -f $SPLITFILELIST ]; then
  echo "ERROR: splitfiles.txt not found at $SPLITFILELIST"
  exit 1
fi

NFILES=$(wc -l < $SPLITFILELIST)
NFILES=$((NFILES - 1))

if [ \$NFILES -lt 0 ]; then
  echo "ERROR: No valid split files found."
  exit 1
fi

# Submit the array job now that NFILES is known
ARRAY_JOBID=$(sbatch --parsable \
		--job-name=${COHORT}.splitfiles \
		--array=0-${NFILES} \
		--time=6:00:00 \
		--mem=32G \
		-c 1 \
		-o ${RAWDATACOHORT}/gwas.parser_harm_cleaner.array.%a.log \
		--error ${RAWDATACOHORT}/gwas.parser_harm_cleaner.array.%a.errors \
		--export=RAWDATACOHORT=${RAWDATACOHORT},COHORT=${COHORT},FILE=${FILE},INIT_ID=${INIT_ID} \
		${SCRIPTS}/metagwastoolkit.gwaslab.splitfiles.HPC.sh ${CONFIGURATIONFILE})
echo $ARRAY_JOBID > ${RAWDATACOHORT}/array_jobid.txt
echo "Submitted array job for ${COHORT} as job $ARRAY_JOBID"
EOF

chmod +x $ARRAY_SUBMIT_SCRIPT

# Submit this job script as a dependency of the split job
ARRAY_LAUNCH_JOBID=$(sbatch --parsable \
  --dependency=afterany:${SPLIT_LAUNCH_JOBID} \
  --job-name=arraylauncher.${COHORT} \
  --mem=32G \
  --time=01:00:00 \
  --output=${RAWDATACOHORT}/launch_array.${COHORT}.out \
  --export=RAWDATACOHORT=${RAWDATACOHORT},COHORT=${COHORT},FILE=${FILE},INIT_ID=${INIT_ID},SCRIPTS=${SCRIPTS},CONFIGURATIONFILE=${CONFIGURATIONFILE} \
  --error=${RAWDATACOHORT}/launch_array.${COHORT}.err \
  ${ARRAY_SUBMIT_SCRIPT})

ARRAY_JOBID_FILE="${RAWDATACOHORT}/array_jobid.txt"
MIN_WAIT=1
MAX_WAIT=3600
COUNTER=0

echo "⏳ Waiting at least $MIN_WAIT minutes, and up to $MAX_WAIT minutes, for array_jobid.txt..."

while [ $COUNTER -lt $MIN_WAIT ]; do
  sleep 60
  ((COUNTER++))
  echo "  → (Minimum wait) Minute $COUNTER..."
done

while [ ! -f "$ARRAY_JOBID_FILE" ] && [ $COUNTER -lt $MAX_WAIT ]; do
  sleep 60
  ((COUNTER++))
  echo "  → (Checking) Minute $COUNTER... file not found yet."
done

if [ -f "$ARRAY_JOBID_FILE" ]; then
  REAL_ARRAY_JOBID=$(cat "$ARRAY_JOBID_FILE")
  echo "✅ Found array job ID: $REAL_ARRAY_JOBID"
else
  echo "❌ ERROR: array_jobid.txt was not created after $MAX_WAIT minutes."
  exit 1
fi
		WRAP_JOBID=$(sbatch --parsable \
    --job-name=wrap.${COHORT} \
    --dependency=afterany:${REAL_ARRAY_JOBID} \
    --mem=${QMEMWRAPPER} \
    --time=${QRUNTIMEWRAPPER} \
    --export=ALL,RAWDATACOHORT=${RAWDATACOHORT},COHORT=${COHORT},BASEFILE=${BASEFILE},SCRIPTS=${SCRIPTS} \
    -o ${RAWDATACOHORT}/gwas.wrapper.${BASEFILE}.log \
    --error=${RAWDATACOHORT}/gwas.wrapper.${BASEFILE}.errors \
    ${SCRIPTS}/gwaslab.wrapper.sh)
		GWASLAB_JOBID=$(sbatch --parsable \
        --job-name=${COHORT}_GWAS \
        --output=${PROJECTDIR}/${METAOUTPUT}/${SUBPROJECTDIRNAME}/RAW/${COHORT}/${COHORT}.gwaslab.out \
        --error=${PROJECTDIR}/${METAOUTPUT}/${SUBPROJECTDIRNAME}/RAW/${COHORT}/${COHORT}.gwaslab.err \
        --dependency=afterany:${WRAP_JOBID} \
        --time=24:00:00 \
        --mem=128G \
        --cpus-per-task=2 \
        --mail-user=${QMAIL} \
        --export=ALL,COHORT=${COHORT},FILE=${BASEFILE}.merged.gwaslab.tsv.gz,RAWDATACOHORT=${RAWDATACOHORT},GWASLAB_ENV=${GWASLAB_ENV},ONLY_QC=${ONLY_QC},SCRIPTS=${SCRIPTS},ORIGINALS=${ORIGINALS},POPULATION=${POPULATION},REFERENCE=${REFERENCE},REF=${REF},PERFORM_QC=${PERFORM_QC},MAKE_FIGURES=${MAKE_FIGURES},DAF=${DAF},EAF=${EAF},BETA=${BETA},SE=${SE},INFO=${INFO},MAC=${MAC},HWE=${HWE},LIFTOVER=${LIFTOVER},SELECT_LEADS=${SELECT_LEADS}  \
        ${SCRIPTS}/gwaslab.cohort.sh)
	fi
	) &
	done < ${GWASFILES}
	wait
### END of if-else statement for the number of command-line arguments passed ###
fi 
script_copyright_message