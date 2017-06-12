#!/bin/bash
#
#$ -S /bin/bash 																				# the type of BASH you'd like to use
#$ -N qsub.metagwastoolkit 																		# the name of this script
# -hold_jid some_other_basic_bash_script 														# the current script (basic_bash_script) will hold until some_other_basic_bash_script has finished
#$ -o /hpc/dhl_ec/svanderlaan/projects/meta_gwasfabp4/metagwastoolkit.log 						# the log file of this job
#$ -e /hpc/dhl_ec/svanderlaan/projects/meta_gwasfabp4/metagwastoolkit.errors 					# the error file of this job
#$ -l h_rt=04:00:00 																			# h_rt=[max time, e.g. 02:02:01] - this is the time you think the script will take
#$ -l h_vmem=4G 																				# h_vmem=[max. mem, e.g. 45G] - this is the amount of memory you think your script will use
# -l tmpspace=64G 																				# this is the amount of temporary space you think your script will use
#$ -M s.w.vanderlaan-2@umcutrecht.nl 															# you can send yourself emails when the job is done; "-M" and "-m" go hand in hand
#$ -m a 																						# you can choose: b=begin of job; e=end of job; a=abort of job; s=suspended job; n=no mail is send
#$ -cwd 																						# set the job start to the current directory - so all the things in this script are relative to the current directory!!!
#
# You can use the variables below (indicated by "#$") to set some things for the submission system.
# Another useful tip: you can set a job to run after another has finished. Name the job 
# with "-N SOMENAME" and hold the other job with -hold_jid SOMENAME". 
# Further instructions: https://wiki.bioinformatics.umcutrecht.nl/bin/view/HPC/HowToS#Run_a_job_after_your_other_jobs
#
# It is good practice to properly name and annotate your script for future reference for
# yourself and others. Trust me, you'll forget why and how you made this!!!

SCRIPTS=/hpc/local/CentOS7/dhl_ec/software/MetaGWASToolKit/SCRIPTS
PROJECTDIR=/hpc/local/CentOS7/dhl_ec/software/MetaGWASToolKit/EXAMPLE
ORIGINALDATA=${PROJECTDIR}/DATA_UPLOAD_FREEZE/1000G
REFERENCE_1KG=/hpc/dhl_ec/data/references/1000G

#####################################################################################################

### Running MetaGWASToolKit ###
# There are three files: 
# - metagwastoolkit.run.sh .......: Contains the main qsub-commands to do parse, harmonize, and QC data,
#                                   as well as prepare and perform meta-analysis. Plots are also auto-
#                                   matically generated. NOTE: you should *never* touch this file.
# - metagwastoolkit.conf .........: Configuration file. You should change this to set project name
#                                   directory, software directories, and other settings. This file should
#                                   be in the project directory.
# - metagwastoolkit.files.list ...: List of GWAS files to include in this meta-analysis. This file should
#                                   be in the project directory. 
# NOTE: the originals of each of the above files are also in the 'SCRIPTS' directory. 

${SCRIPTS}/metagwastoolkit.run.sh ${EXAMPLE}/metagwastoolkit.conf ${EXAMPLE}/metagwastoolkit.files.list

