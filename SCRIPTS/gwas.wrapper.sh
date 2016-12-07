#!/bin/bash

echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "   GWASWRAPPER: WRAPPER FOR PARSED AND HARMONIZED GENOME-WIDE ASSOCIATION STUDIES"
echo ""
echo " Version: GWAS.WRAPPER.v1.0.0"
echo ""
echo " Last update: 2016-12-05"
echo " Written by:  Sander W. van der Laan (s.w.vanderlaan-2@umcutrecht.nl)."
echo "			    Sara Pulit | s.l.pulit@umcutrecht.nl; "
echo "			    Jessica van Setten | j.vansetten@umcutrecht.nl; "
echo "			    Paul I.W. de Bakker | p.i.w.debakker-2@umcutrecht.nl"
echo ""
echo " Testers:     - Jessica van Setten (j.vansetten@umcutrecht.nl)"
echo ""
echo " Description: Produce concatenated parsed and harmonized GWAS data."
echo ""
echo " REQUIRED: "
echo " * A high-performance computer cluster with a qsub system"
echo " * R v3.2+, Python 2.7+"
echo " * Note: it will also work on a Mac OS X system with R and Python installed."
### ADD-IN: function to check requirements...
echo ""
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

script_arguments_error() {
	echo "$1" # Additional message
	echo "- Argument #1 is path_to/filename of the configuration file."
	echo "- Argument #2 is path_to/filename of the list of GWAS files with names."
	echo "- Argument #3 is reference to use [HM2/1Gp1/1Gp3] for the QC and analysis."
	echo "An example command would be: run_meta.sh [arg1: path_to/configuration_file] [arg2: path_to/gwas_files_list] [arg3: HM2/1Gp1/1Gp3]"
	echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  	# The wrong arguments are passed, so we'll exit the script now!
  	date
  	exit 1
}


echo ""
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "The following directories are set."
PROJECTDIR=#ARGUMENT

### Make directories for script if they do not exist yet (!!!PREREQUISITE!!!)
if [ ! -d ${QCEDDATA}/_plots ]; then
  mkdir -v ${QCEDDATA}/_plots
fi
PLOTTED=${QCEDDATA}/_plots

# Setting some other parameters
QMEM="32G"
QTIME="00:20:00"

echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "Processing files for each study, and plotting for QC."
echo ""


### MAKE A WRAPPER SCRIPT FOR THIS
###- separate wrapper script
###- arg: inputdir, outputdir, basename

echo ""
echo "Check parsing of GWAS datasets."
	
while IFS='' read -r GWASCOHORT || [[ -n "$GWASCOHORT" ]]; do
	LINE=${GWASCOHORT}
	COHORT=$(echo "${LINE}" | awk '{ print $1 }')
	FILE=$(echo "${LINE}" | awk '{ print $2 }')
	VARIANTYPE=$(echo "${LINE}" | awk '{ print $3 }')
	
	BASEFILE=$(basename ${FILE} .txt.gz)
	
	RAWDATACOHORT=${RAWDATA}/${COHORT}
	
	echo "Cohort File VariantType Parsing ParsingErrorFile" > ${RAWDATACOHORT}/${COHORT}.wrap.parsed.readme
	echo "Cohort File VariantType Harmonizing HarmonizingErrorFile" > ${RAWDATACOHORT}/${COHORT}.wrap.harmonized.readme
	echo "Marker CHR BP Strand EffectAllele OtherAllele EAF MAF MAC HWE_P Info Beta SE P N N_cases N_controls Imputed" > ${RAWDATACOHORT}/${COHORT}.pdat
	echo "VariantID Marker CHR BP Strand EffectAllele OtherAllele EAF MAF MAC HWE_P Info Beta SE P N N_cases N_controls Imputed CHR_ref BP_ref REF ALT AlleleA AlleleB VT AF EURAF AFRAF AMRAF ASNAF EASAF SASAF Reference" > ${RAWDATACOHORT}/${COHORT}.rdat
	
	
done < ${GWASFILES}

### Setting the patterns to look for
PARSEDPATTERN="All done parsing"
HARMONIZEDPATTERN="All done! 🍺"

while IFS='' read -r GWASCOHORT || [[ -n "$GWASCOHORT" ]]; do
		
	LINE=${GWASCOHORT}
	COHORT=$(echo "${LINE}" | awk '{ print $1 }')
	FILE=$(echo "${LINE}" | awk '{ print $2 }')
	VARIANTYPE=$(echo "${LINE}" | awk '{ print $3 }')
	
	BASEFILE=$(basename ${FILE} .txt.gz)
	
	RAWDATACOHORT=${RAWDATA}/${COHORT}
	
	for ERRORFILE in ${RAWDATACOHORT}/gwas.parser.${BASEFILE}.*.log; do
		### determine basename of the ERRORFILE
		BASENAMEERRORFILE=$(basename ${ERRORFILE})
		BASEERRORFILE=$(basename ${ERRORFILE} .log)
		prefix_parsed='gwas.parser.' # removing the 'gwas.parser.'-part from the ERRORFILE
		BASEPARSEDFILE=$(echo "${BASEERRORFILE}" | sed -e "s/^$prefix_parsed//")
		echo ""
		echo "* checking split chunk: [ ${BASEPARSEDFILE} ] for pattern \"${PARSEDPATTERN}\"..."

		echo "Error file...........................:" ${BASENAMEERRORFILE}
		if [[ ! -z $(grep "${PARSEDPATTERN}" "${ERRORFILE}") ]]; then 
			PARSEDMESSAGE="success"
			echo "Parsing report.......................:" ${PARSEDMESSAGE}
			echo "${COHORT} ${FILE} ${VARIANTYPE} ${PARSEDMESSAGE} ${BASENAMEERRORFILE}" >> ${RAWDATACOHORT}/${COHORT}.wrap.parsed.readme
			echo "- concatenating data to [ ${RAWDATACOHORT}/${COHORT}.pdat ]..."
			cat ${RAWDATACOHORT}/${BASEPARSEDFILE}.pdat | tail -n +2 >> ${RAWDATACOHORT}/${COHORT}.pdat
			echo "- removing files [ ${RAWDATACOHORT}/${BASEPARSEDFILE}[.pdat/.errors/.log] ]..."
			rm -v ${RAWDATACOHORT}/${BASEPARSEDFILE}.pdat
			rm -v ${RAWDATACOHORT}/${prefix_parsed}${BASEPARSEDFILE}.errors
			rm -v ${RAWDATACOHORT}/${prefix_parsed}${BASEPARSEDFILE}.log
			rm -v ${RAWDATACOHORT}/${prefix_parsed}${BASEPARSEDFILE}.sh
			rm -v ${RAWDATACOHORT}/*${BASEPARSEDFILE}_DEBUG_GWAS_Parser.RData
			rm -v ${RAWDATACOHORT}/${BASEPARSEDFILE}
		else
			echo "*** Error *** The pattern \"${PARSEDPATTERN}\" was NOT found in [ ${BASENAMEERRORFILE} ]..."
			echo "Reported in the [ ${BASENAMEERRORFILE} ]:      "
			echo "####################################################################################"
			cat ${ERRORFILE}
			echo "####################################################################################"
			PARSEDMESSAGE="failure"
			echo "Parsing report.......................:" ${PARSEDMESSAGE}
			echo "${COHORT} ${FILE} ${VARIANTYPE} ${PARSEDMESSAGE} ${BASENAMEERRORFILE}" >> ${RAWDATACOHORT}/${COHORT}.wrap.parsed.readme
		fi
		
		echo ""
	done

	
	for ERRORFILE in ${RAWDATACOHORT}/gwas2ref.harmonizer.${BASEFILE}.*.log; do
		### determine basename of the ERRORFILE
		BASENAMEERRORFILE=$(basename ${ERRORFILE})
		BASEERRORFILE=$(basename ${ERRORFILE} .log)
		prefix_harmonized='gwas2ref.harmonizer.' # removing the 'gwas2ref.harmonizer.'-part from the ERRORFILE
		BASEHARMONIZEDFILE=$(echo "${BASEERRORFILE}" | sed -e "s/^$prefix_harmonized//")
		echo ""
		echo "* checking split chunk: [ ${BASEHARMONIZEDFILE} ] for pattern \"${HARMONIZEDPATTERN}\"..."

		echo "Error file...........................:" ${BASENAMEERRORFILE}
		if [[ ! -z $(grep "${HARMONIZEDPATTERN}" "${ERRORFILE}") ]]; then 
			HARMONIZEDMESSAGE="success"
			echo "Harmonizing report...................:" ${HARMONIZEDMESSAGE}
			echo "- concatenating data to [ ${RAWDATACOHORT}/${COHORT}.rdat ]..."
			echo "${COHORT} ${FILE} ${VARIANTYPE} ${HARMONIZEDMESSAGE} ${BASENAMEERRORFILE}" >> ${RAWDATACOHORT}/${COHORT}.wrap.harmonized.readme
			cat ${RAWDATACOHORT}/${BASEHARMONIZEDFILE}.ref.pdat | tail -n +2 >> ${RAWDATACOHORT}/${COHORT}.rdat
			echo "- removing files [ ${RAWDATACOHORT}/${BASEHARMONIZEDFILE}[.ref.pdat/.errors/.log] ]..."
			rm -v ${RAWDATACOHORT}/${BASEHARMONIZEDFILE}.ref.pdat
			rm -v ${RAWDATACOHORT}/${prefix_harmonized}${BASEHARMONIZEDFILE}.errors
			rm -v ${RAWDATACOHORT}/${prefix_harmonized}${BASEHARMONIZEDFILE}.log
			rm -v ${RAWDATACOHORT}/${prefix_harmonized}${BASEHARMONIZEDFILE}.sh
		else
			echo "*** Error *** The pattern \"${HARMONIZEDPATTERN}\" was NOT found in [ ${BASENAMEERRORFILE} ]..."
			echo "Reported in the [ ${BASENAMEERRORFILE} ]:      "
			echo "####################################################################################"
			cat ${ERRORFILE}
			echo "####################################################################################"
			HARMONIZEDMESSAGE="failure"
			echo "Harmonizing report...................:" ${HARMONIZEDMESSAGE}
			echo "${COHORT} ${FILE} ${VARIANTYPE} ${HARMONIZEDMESSAGE} ${BASENAMEERRORFILE}" >> ${RAWDATACOHORT}/${COHORT}.wrap.harmonized.readme
		fi
		
		echo ""
	done
	
done < ${GWASFILES}
 

THISYEAR=$(date +'%Y')
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo ""
echo ""
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "+ The MIT License (MIT)                                                                                 +"
echo "+ Copyright (c) 2015-${THISYEAR} Sander W. van der Laan                                                             +"
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
