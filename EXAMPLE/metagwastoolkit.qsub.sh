#!/bin/bash
#
#$ -S /bin/bash 																						# the type of BASH you'd like to use
#$ -N metagwastoolkit 																					# the name of this script
# -hold_jid some_other_basic_bash_script 																# the current script (basic_bash_script) will hold until some_other_basic_bash_script has finished
#$ -o /hpc/local/CentOS7/dhl_ec/software/MetaGWASToolKit/EXAMPLE/metagwastoolkit.example.log 		# the log file of this job
#$ -e /hpc/local/CentOS7/dhl_ec/software/MetaGWASToolKit/EXAMPLE/metagwastoolkit.example.errors 	# the error file of this job
#$ -l h_rt=03:00:00 																					# h_rt=[max time, e.g. 02:02:01] - this is the time you think the script will take
#$ -l h_vmem=8G 																						# h_vmem=[max. mem, e.g. 45G] - this is the amount of memory you think your script will use
# -l tmpspace=64G 																						# this is the amount of temporary space you think your script will use
#$ -M s.w.vanderlaan-2@umcutrecht.nl 																	# you can send yourself emails when the job is done; "-M" and "-m" go hand in hand
#$ -m a 																								# you can choose: b=begin of job; e=end of job; a=abort of job; s=suspended job; n=no mail is send
#$ -cwd 																								# set the job start to the current directory - so all the things in this script are relative to the current directory!!!
#
# You can use the variables below (indicated by "#$") to set some things for the submission system.
# Another useful tip: you can set a job to run after another has finished. Name the job 
# with "-N SOMENAME" and hold the other job with -hold_jid SOMENAME". 
# Further instructions: https://wiki.bioinformatics.umcutrecht.nl/bin/view/HPC/HowToS#Run_a_job_after_your_other_jobs
#
# It is good practice to properly name and annotate your script for future reference for
# yourself and others. Trust me, you'll forget why and how you made this!!!

METAGWASTOOLKIT="/hpc/local/CentOS7/dhl_ec/software/MetaGWASToolKit"
RESOURCES="${METAGWASTOOLKIT}/RESOURCES"
SCRIPTS="${METAGWASTOOLKIT}/SCRIPTS"
PROJECTDIR="${METAGWASTOOLKIT}/EXAMPLE"

echo ""
echo "                 PERFORM META-ANALYSIS OF GENOME-WIDE ASSOCIATION STUDIES"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

### Note: It is advisable to perform the first two steps, first. Upon completion, you should inspect
###       the plots produced to decided whether cohorts should be carried forward to meta-analysis
###       or whether quality control settings should be edited.
###
# 
# echo ""
# echo "FIRST step: prepare GWAS."
# ${SCRIPTS}/metagwastoolkit.prep.sh ${PROJECTDIR}/metagwastoolkit.conf ${PROJECTDIR}/metagwastoolkit.files.list
# 
# echo ""
# echo "SECOND step: prepare meta-analysis."
# ${SCRIPTS}/metagwastoolkit.prepmeta.sh ${PROJECTDIR}/metagwastoolkit.conf ${PROJECTDIR}/metagwastoolkit.files.list

### Note: After visual inspection of diagnostic plots per cohort (see note above), the next
###       three steps can be uncommented and executed.
###

echo ""
echo "THIRD step: meta-analysis."
${SCRIPTS}/metagwastoolkit.meta.sh ${PROJECTDIR}/metagwastoolkit.conf ${PROJECTDIR}/metagwastoolkit.files.list
# 
# echo ""
# echo "FOURTH step: result clumping."
# ${SCRIPTS}/metagwastoolkit.clump.sh ${PROJECTDIR}/metagwastoolkit.conf ${PROJECTDIR}/metagwastoolkit.files.list 
# 
# echo ""
# echo "FIFTH step: prepare and perform downstream analyses."
# ${SCRIPTS}/metagwastoolkit.downstream.sh ${PROJECTDIR}/metagwastoolkit.conf ${PROJECTDIR}/metagwastoolkit.files.list










