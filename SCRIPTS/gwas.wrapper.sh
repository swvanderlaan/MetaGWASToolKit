#!/bin/bash

echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "                GWASPLOTTER: VISUALIZE GENOME-WIDE ASSOCIATION STUDIES"
echo ""
echo " Version: GWAS.PLOTTER.v1.0.0"
echo ""
echo " Last update: 2016-12-02"
echo " Written by:  Sander W. van der Laan (s.w.vanderlaan-2@umcutrecht.nl)."
echo "			    Sara Pulit | s.l.pulit@umcutrecht.nl; "
echo "			    Jessica van Setten | j.vansetten@umcutrecht.nl; "
echo "			    Paul I.W. de Bakker | p.i.w.debakker-2@umcutrecht.nl"
echo ""
echo " Testers:     - Jessica van Setten (j.vansetten@umcutrecht.nl)"
echo ""
echo " Description: Produce plots (PDF and PNG) for quick inspection and publication."
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
PROJECTDIR=/hpc/dhl_ec/svanderlaan/projects/megastroke
QCEDDATA=/hpc/dhl_ec/svanderlaan/projects/megastroke/qced_ganesh
SOFTWARE=/hpc/local/CentOS7/dhl_ec/software
QCTOOL=$SOFTWARE/qctool_v1.5-linux-x86_64-static/qctool

echo "Project directory________________ ${PROJECTDIR}"
echo "Original qc'ed data directory____ ${QCEDDATA}"
echo "Software directory_______________ ${SOFTWARE}"
echo "Where \"qctool\" resides___________ ${QCTOOL}"
echo ""

### Make directories for script if they do not exist yet (!!!PREREQUISITE!!!)
if [ ! -d ${QCEDDATA}/_plots ]; then
  mkdir -v ${QCEDDATA}/_plots
fi
PLOTTED=${QCEDDATA}/_plots

# Setting some other parameters
RANDOMSAMPLE="1000000" # for P-Z plot
PVALUE="PVAL" # for QQ-plots
QMEM="32G"
QTIME="00:20:00"

echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "Processing files for each study, and plotting for QC."
echo ""

# echo ""
# 
# while IFS='' read -r GWASCOHORT || [[ -n "$GWASCOHORT" ]]; do
# 		
# 	LINE=${GWASCOHORT}
# 	COHORT=$(echo "${LINE}" | awk '{ print $1 }')
# 	FILE=$(echo "${LINE}" | awk '{ print $2 }')
# 	VARIANTYPE=$(echo "${LINE}" | awk '{ print $3 }')
# 	
# 	BASEFILE=$(basename ${FILE} .txt.gz)
# 	
# 	RAWDATACOHORT=${RAWDATA}/${COHORT}
# 	echo "Checking output."
# 
# 	### Adding headers -- this is ABSOLUTELY required for the 'gwas.parser.R'.
# 	for ERRORFILE in ${RAWDATACOHORT}/${BASEFILE}.errors; do
# 		### determine basename of the splitfile
# 		BASEERRORFILE=$(basename ${ERRORFILE}, .errors)
# 		echo ""
# 		echo " * checking split chunk: [ ${BASEERRORFILE} ]..."
# 		
# 		PARSEDDONE=$(cat ${ERRORFILE} | grep "All done parsing")
# 		HARMONIZEDDONE=$(cat ${ERRORFILE} | grep "All done! 🍺")
# 
# 		echo ""
# 		echo "- checking parsed and harmonised files..."
# 		if [[ ${PARSEDDONE} = "All done parsing" ]]; then
# 			echo "No errors for [ ${BASEERRORFILE} ]; mr. Bourne will remove it for you."
# 			rm -v ${ERRORFILE}
# 		elif [[ ${HARMONIZEDDONE} = "All done! 🍺" ]]; then
# 			echo "No errors for [ ${BASEERRORFILE} ]; mr. Bourne will remove it for you."
# 			rm -v ${ERRORFILE}
# 		else
# 			echo "There is an issue with [ ${BASEERRORFILE} ]."		
# 		fi
# 		
# 		echo ""
# 	done
# 
# done < ${GWASFILES}

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
