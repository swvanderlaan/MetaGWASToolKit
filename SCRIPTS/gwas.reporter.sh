#!/bin/bash
#
# You can use the variables below (indicated by "#$") to set some things for the 
# submission system.
#$ -S /bin/bash # the type of BASH you'd like to use
#$ -N QCMEGAPLOT # the name of this script
# -hold_jid some_other_basic_bash_script # the current script (basic_bash_script) will hold until some_other_basic_bash_script has finished
#$ -o /hpc/dhl_ec/svanderlaan/projects/megastroke/plotter_qc_v1_20160713.log # the log file of this job
#$ -e /hpc/dhl_ec/svanderlaan/projects/megastroke/plotter_qc_v1_20160713.errors # the error file of this job
#$ -l h_rt=00:30:00 # h_rt=[max time, e.g. 02:02:01] - this is the time you think the script will take
#$ -l h_vmem=4G #  h_vmem=[max. mem, e.g. 45G] - this is the amount of memory you think your script will use
# -l tmpspace=64G # this is the amount of temporary space you think your script will use
# -pe threaded=3 # this is to indicate the number of "threads", i.e. cores you'd want to use to parameterize your job
#$ -M s.w.vanderlaan-2@umcutrecht.nl # you can send yourself emails when the job is done; "-M" and "-m" go hand in hand
#$ -m ea # you can choose: b=begin of job; e=end of job; a=abort of job; s=
#$ -cwd # set the job start to the current directory - so all the things in this script are relative to the current directory!!!
#
# Another useful tip: you can set a job to run after another has finished. Name the job 
# with "-N SOMENAME" and hold the other job with -hold_jid SOMENAME". 
# Further instructions: https://wiki.bioinformatics.umcutrecht.nl/bin/view/HPC/HowToS#Run_a_job_after_your_other_jobs
#
# It is good practice to properly name and annotate your script for future reference for
# yourself and others. Trust me, you'll forget why and how you made this!!!
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "               CHECKING QUALITY CONTROLLED FILES AND PLOTTING RESULTS"
echo "                                  version 1.0"
echo ""
echo "* Written by  : Sander W. van der Laan"
echo "* E-mail      : s.w.vanderlaan-2@umcutrecht.nl"
echo "* Last update : 2016-07-13"
echo "* Version     : plotter_qc_v1"
echo ""
echo "* Description : This script will check some things on the files, and plot results."
echo ""
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "Today's: "$(date)
TODAY=$(date +"%Y%m%d")
echo ""
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

	### ADD-IN: 
	# - REPORT function script that will write the report on:
	# 	- how many SNPs are present 
	#	- how many SNPs per chromosome
	# will use this parsed.pdat
	#
	# echo "* Counting total number of variants and per chromosome."
	# TOTALVARIANTS=$(zcat ${RAWDATA}/${COHORT}/${BASEFILE}.pdat.gz | wc -l | awk '{printf ("%'\''d\n", $0)}')
	# for CHR in $(seq 0 26) NA; do
	# 	TOTAL_CHR${CHR}=$(zcat ${RAWDATA}/${COHORT}/${BASEFILE}.pdat.gz | awk ' $2 == '\""$CHR"\"' ' | wc -l | awk '{printf ("%'\''d\n", $0)}')
	# done
	# echo "  - Total number of variants............: "${TOTALVARIANTS}
	# echo "  - Variants on chromosome ${CHR}.......: "${TOTAL_CHR${CHR}}

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