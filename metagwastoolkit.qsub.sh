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

#!/bin/bash
#
#$ -S /bin/bash 																						# the type of BASH you'd like to use
#$ -N metagwastoolkit 																					# the name of this script
# -hold_jid some_other_basic_bash_script 																# the current script (basic_bash_script) will hold until some_other_basic_bash_script has finished
#$ -o /hpc/dhl_ec/svanderlaan/projects/meta_gwasfabp4/metagwastoolkit.PLOTMETATIFF.log 		# the log file of this job
#$ -e /hpc/dhl_ec/svanderlaan/projects/meta_gwasfabp4/metagwastoolkit.PLOTMETATIFF.errors 	# the error file of this job
#$ -l h_rt=24:00:00 																					# h_rt=[max time, e.g. 02:02:01] - this is the time you think the script will take
#$ -l h_vmem=16G 																						# h_vmem=[max. mem, e.g. 45G] - this is the amount of memory you think your script will use
# -l tmpspace=64G 																						# this is the amount of temporary space you think your script will use
#$ -M s.w.vanderlaan-2@umcutrecht.nl 																	# you can send yourself emails when the job is done; "-M" and "-m" go hand in hand
#$ -m beas 																								# you can choose: b=begin of job; e=end of job; a=abort of job; s=suspended job; n=no mail is send
#$ -cwd 																								# set the job start to the current directory - so all the things in this script are relative to the current directory!!!
#
# You can use the variables below (indicated by "#$") to set some things for the submission system.
# Another useful tip: you can set a job to run after another has finished. Name the job 
# with "-N SOMENAME" and hold the other job with -hold_jid SOMENAME". 
# Further instructions: https://wiki.bioinformatics.umcutrecht.nl/bin/view/HPC/HowToS#Run_a_job_after_your_other_jobs
#
# It is good practice to properly name and annotate your script for future reference for
# yourself and others. Trust me, you'll forget why and how you made this!!!

RESOURCES=/hpc/local/CentOS7/dhl_ec/software/MetaGWASToolKit/RESOURCES
SCRIPTS=/hpc/local/CentOS7/dhl_ec/software/MetaGWASToolKit/SCRIPTS
PROJECTDIR=/hpc/dhl_ec/svanderlaan/projects/meta_gwasfabp4
ORIGINALDATA=${PROJECTDIR}/DATA_UPLOAD_FREEZE/1000G
REFERENCE_1KG=/hpc/dhl_ec/data/references/1000G

# echo ""
# echo " PERFORM META-ANALYSIS FOR FEMALE/MALE NON-AUTOSOMAL X-CHROMOSOME "
# echo "                           --- SORBS ---"
# echo ""
####################################################################################################
### THIS SHOULD ONLY BE RUN ONCE || THIS SHOULD ONLY BE RUN ONCE || THIS SHOULD ONLY BE RUN ONCE ###
###
### REFORMATTING SORBS -- because that is shitty formatted
### SORBS.WHOLE.FABP4.20141117.txt.gz
### SORBS.WHOLE.FABP4adjBMI.20141117.txt.gz
### SORBS.WHOLE.FABP4adjBMIeGFR.20150703.txt.gz
# 
# echo "STEP ZERO: reformatting SORBS data"
# ### REFORMAT SORBS model 1-3 with new MARKERID
# echo "Marker Chr Position EffectAllele OtherAllele Strand Beta SE Pval EAF HWE N Imputed Info" > ${ORIGINALDATA}/SORBS.AUTOSOMAL.FABP4.20141117.edit.txt
# echo "Marker Chr Position EffectAllele OtherAllele Strand Beta SE Pval EAF HWE N Imputed Info" > ${ORIGINALDATA}/SORBS.AUTOSOMAL.FABP4adjBMI.20141117.edit.txt
# echo "Marker Chr Position EffectAllele OtherAllele Strand Beta SE Pval EAF HWE N Imputed Info" > ${ORIGINALDATA}/SORBS.AUTOSOMAL.FABP4adjBMIeGFR.20150703.edit.txt
# 
# ### REFORMAT SORBS model 1 and 2 with new MARKERID AND CHR/BP COLUMNS
# echo "Reformatting SORBS model 1..."
# zcat ${ORIGINALDATA}/SORBS.WHOLE.FABP4.20141117.txt.gz | awk '{if($4=="I") 
# { print $1, $2, $3, $4, "D", $6, $7, $8, $9, $10, $11, $12, $13, $14} else if($4=="D") 
# { print $1, $2, $3, $4, "I", $6, $7, $8, $9, $10, $11, $12, $13, $14} else if($5=="D") 
# { print $1, $2, $3, "I", $5, $6, $7, $8, $9, $10, $11, $12, $13, $14} else if($5=="I") 
# { print $1, $2, $3, "D", $5, $6, $7, $8, $9, $10, $11, $12, $13, $14} else 
# { print $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14} }' | 
# awk -F ":" '{if($3=="") {print $1, $2} else {print $1, $2, $3}}' | 
# awk '{if($16=="") { print "chr"$1":"$2":"$5"_"$6, $1, $2, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15} else 
# {print "chr"$1":"$2":"$6"_"$7, $1, $2, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16} }' | tail -n +2  >> ${ORIGINALDATA}/SORBS.AUTOSOMAL.FABP4.20141117.edit.txt
# 
# echo ""
# echo "Reformatting SORBS model 2..."
# zcat ${ORIGINALDATA}/SORBS.WHOLE.FABP4adjBMI.20141117.txt.gz | awk '{if($4=="I") 
# { print $1, $2, $3, $4, "D", $6, $7, $8, $9, $10, $11, $12, $13, $14} else if($4=="D") 
# { print $1, $2, $3, $4, "I", $6, $7, $8, $9, $10, $11, $12, $13, $14} else if($5=="D") 
# { print $1, $2, $3, "I", $5, $6, $7, $8, $9, $10, $11, $12, $13, $14} else if($5=="I") 
# { print $1, $2, $3, "D", $5, $6, $7, $8, $9, $10, $11, $12, $13, $14} else 
# { print $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14} }' | 
# awk -F ":" '{if($3=="") {print $1, $2} else {print $1, $2, $3}}' | 
# awk '{if($16=="") { print "chr"$1":"$2":"$5"_"$6, $1, $2, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15} else 
# {print "chr"$1":"$2":"$6"_"$7, $1, $2, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16} }' | tail -n +2  >> ${ORIGINALDATA}/SORBS.AUTOSOMAL.FABP4adjBMI.20141117.edit.txt
# 
# echo ""
# echo "Reformatting SORBS model 3..."
# zcat ${ORIGINALDATA}/SORBS.WHOLE.FABP4adjBMIeGFR.20150703.txt.gz | awk '{if($4=="I") 
# { print $1, $2, $3, $4, "D", "+", $7, $8, $9, $10, $11, $12, $13, $14} else if($4=="D") 
# { print $1, $2, $3, $4, "I", "+", $7, $8, $9, $10, $11, $12, $13, $14} else if($5=="D") 
# { print $1, $2, $3, "I", $5, "+", $7, $8, $9, $10, $11, $12, $13, $14} else if($5=="I") 
# { print $1, $2, $3, "D", $5, "+", $7, $8, $9, $10, $11, $12, $13, $14} else 
# { print $1, $2, $3, $4, $5, "+", $7, $8, $9, $10, $11, $12, $13, $14} }' | 
# awk '{ print "chr"$2":"$3":"$4"_"$5, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14}' | tail -n +2 >> ${ORIGINALDATA}/SORBS.AUTOSOMAL.FABP4adjBMIeGFR.20150703.edit.txt 
# 
# echo ""
# echo "- heads"
# echo "MODEL 1"
# cat ${ORIGINALDATA}/SORBS.AUTOSOMAL.FABP4.20141117.edit.txt | head
# echo "MODEL 2"
# cat ${ORIGINALDATA}/SORBS.AUTOSOMAL.FABP4adjBMI.20141117.edit.txt | head
# echo "MODEL 3"
# cat ${ORIGINALDATA}/SORBS.AUTOSOMAL.FABP4adjBMIeGFR.20150703.edit.txt | head
# 
# echo ""
# echo "- tails"
# echo "MODEL 1"
# cat ${ORIGINALDATA}/SORBS.AUTOSOMAL.FABP4.20141117.edit.txt | tail
# echo "MODEL 2"
# cat ${ORIGINALDATA}/SORBS.AUTOSOMAL.FABP4adjBMI.20141117.edit.txt | tail
# echo "MODEL 3"
# cat ${ORIGINALDATA}/SORBS.AUTOSOMAL.FABP4adjBMIeGFR.20150703.edit.txt | tail
# 
# echo ""
# echo "- count"
# cat ${ORIGINALDATA}/SORBS.AUTOSOMAL.FABP4.20141117.edit.txt | tail -n +2 | wc -l
# cat ${ORIGINALDATA}/SORBS.AUTOSOMAL.FABP4adjBMI.20141117.edit.txt | tail -n +2 | wc -l
# cat ${ORIGINALDATA}/SORBS.AUTOSOMAL.FABP4adjBMIeGFR.20150703.edit.txt | tail -n +2 | wc -l
# 
# echo ""
# echo "Gzipping the shizzle."
# gzip -v ${ORIGINALDATA}/SORBS.AUTOSOMAL.FABP4.20141117.edit.txt
# gzip -v ${ORIGINALDATA}/SORBS.AUTOSOMAL.FABP4adjBMI.20141117.edit.txt
# gzip -v ${ORIGINALDATA}/SORBS.AUTOSOMAL.FABP4adjBMIeGFR.20150703.edit.txt
# 
# echo "Moving the shizzle..."
# mv -v ${ORIGINALDATA}/SORBS.WHOLE.FABP4.20141117.txt.gz ${ORIGINALDATA}/SORBS_old/
# mv -v ${ORIGINALDATA}/SORBS.WHOLE.FABP4adjBMI.20141117.txt.gz ${ORIGINALDATA}/SORBS_old/
# mv -v ${ORIGINALDATA}/SORBS.WHOLE.FABP4adjBMIeGFR.20150703.txt.gz ${ORIGINALDATA}/SORBS_old/
# 
# echo "REFORMAT SORBS chromosome 23 with new MARKERID..."
# ### Marker	Chr	Position	Effect_allele	Other_allele	Strand	Beta	SE	Pval	EAF	Hwe	N	Imputed	Info
# ### chrX:152062	X	152062	T	G	NA	-6.30296	22.0269	0.774764538994547	0.78289	NA	535	NA	1e-05
# ### chrX:154678	X	154678	A	G	NA	-11.1693	23.8341	0.639336357981315	0.77739	NA	535	NA	1e-05
# ### chrX:162640	X	162640	G	C	NA	-0.585175	43.8965	0.989363883922898	0.96792	NA	535	NA	1e-05
# ### chrX:164498	X	164498	G	C	NA	-9.73634	41.8497	0.816033062667872	0.9725	NA	535	NA	1e-05
# ###
# ### SORBS.CHR23.FEMALES_AUTO.FABP4.20150812.txt.gz 
# ### SORBS.CHR23.FEMALES_AUTO.FABP4adjBMI.20150812.txt.gz
# ### SORBS.CHR23.FEMALES_AUTO.FABP4adjBMIeGFR.20150812.txt.gz
# ### SORBS.CHR23.FEMALES_NOAUTO.FABP4.20150812.txt.gz
# ### SORBS.CHR23.FEMALES_NOAUTO.FABP4adjBMI.20150812.txt.gz
# ### SORBS.CHR23.FEMALES_NOAUTO.FABP4adjBMIeGFR.20150812.txt.gz
# ### SORBS.CHR23.MALES_NOAUTO.FABP4.20150812.txt.gz
# ### SORBS.CHR23.MALES_NOAUTO.FABP4adjBMI.20150812.txt.gz
# ### SORBS.CHR23.MALES_NOAUTO.FABP4adjBMIeGFR.20150812.txt.gz
# 
# echo "Marker Chr Position EffectAllele OtherAllele Strand Beta SE Pval EAF HWE N Imputed Info" > ${ORIGINALDATA}/SORBS.CHR23.FEMALES_AUTO.FABP4.20150812.edit.txt
# echo "Marker Chr Position EffectAllele OtherAllele Strand Beta SE Pval EAF HWE N Imputed Info" > ${ORIGINALDATA}/SORBS.CHR23.FEMALES_AUTO.FABP4adjBMI.20150812.edit.txt
# echo "Marker Chr Position EffectAllele OtherAllele Strand Beta SE Pval EAF HWE N Imputed Info" > ${ORIGINALDATA}/SORBS.CHR23.FEMALES_AUTO.FABP4adjBMIeGFR.20150812.edit.txt
# 
# echo "Marker Chr Position EffectAllele OtherAllele Strand Beta SE Pval EAF HWE N Imputed Info" > ${ORIGINALDATA}/SORBS.CHR23.FEMALES_NOAUTO.FABP4.20150812.edit.txt
# echo "Marker Chr Position EffectAllele OtherAllele Strand Beta SE Pval EAF HWE N Imputed Info" > ${ORIGINALDATA}/SORBS.CHR23.FEMALES_NOAUTO.FABP4adjBMI.20150812.edit.txt
# echo "Marker Chr Position EffectAllele OtherAllele Strand Beta SE Pval EAF HWE N Imputed Info" > ${ORIGINALDATA}/SORBS.CHR23.FEMALES_NOAUTO.FABP4adjBMIeGFR.20150812.edit.txt
# 
# echo "Marker Chr Position EffectAllele OtherAllele Strand Beta SE Pval EAF HWE N Imputed Info" > ${ORIGINALDATA}/SORBS.CHR23.MALES_NOAUTO.FABP4.20150812.edit.txt
# echo "Marker Chr Position EffectAllele OtherAllele Strand Beta SE Pval EAF HWE N Imputed Info" > ${ORIGINALDATA}/SORBS.CHR23.MALES_NOAUTO.FABP4adjBMI.20150812.edit.txt
# echo "Marker Chr Position EffectAllele OtherAllele Strand Beta SE Pval EAF HWE N Imputed Info" > ${ORIGINALDATA}/SORBS.CHR23.MALES_NOAUTO.FABP4adjBMIeGFR.20150812.edit.txt
# 
# for SORBS in SORBS.CHR23.FEMALES_AUTO.FABP4.20150812  SORBS.CHR23.FEMALES_AUTO.FABP4adjBMI.20150812 SORBS.CHR23.FEMALES_AUTO.FABP4adjBMIeGFR.20150812 SORBS.CHR23.FEMALES_NOAUTO.FABP4.20150812 SORBS.CHR23.FEMALES_NOAUTO.FABP4adjBMI.20150812 SORBS.CHR23.FEMALES_NOAUTO.FABP4adjBMIeGFR.20150812 SORBS.CHR23.MALES_NOAUTO.FABP4.20150812 SORBS.CHR23.MALES_NOAUTO.FABP4adjBMI.20150812 SORBS.CHR23.MALES_NOAUTO.FABP4adjBMIeGFR.20150812 ; do 
# 	echo "Reformatting ${SORBS}..."
# 	zcat ${ORIGINALDATA}/${SORBS}.txt.gz | awk '{if($4=="I") 
# 	{ print $1, $2, $3, $4, "D", $6, $7, $8, $9, $10, $11, $12, $13, $14} else if($4=="D") 
# 	{ print $1, $2, $3, $4, "I", $6, $7, $8, $9, $10, $11, $12, $13, $14} else if($5=="D") 
# 	{ print $1, $2, $3, "I", $5, $6, $7, $8, $9, $10, $11, $12, $13, $14} else if($5=="I") 
# 	{ print $1, $2, $3, "D", $5, $6, $7, $8, $9, $10, $11, $12, $13, $14} else 
# 	{ print $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14} }' | 
# 	awk -F ":" '{if($3=="") {print $1, $2} else {print $1, $2, $3}}' | 
# 	awk '{if($16=="") { print "chr"$1":"$2":"$5"_"$6, $1, $2, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15} else 
# 	{print "chr"$1":"$2":"$6"_"$7, $1, $2, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16} }' | tail -n +2  >> ${ORIGINALDATA}/${SORBS}.edit.txt
# 	echo ""
# 	echo "Gzipping the shizzle..."
# 	gzip -v ${ORIGINALDATA}/${SORBS}.edit.txt
# 	echo "Moving the shizzle..."
# 	mv -v ${ORIGINALDATA}/${SORBS}.txt.gz ${ORIGINALDATA}/SORBS_old/
# done
# 
# echo "FIRST step: file preparation of SORBS data."
# echo "* SORBS"
# echo ""
# echo "Concatenating autosomal with female autosomal-like chromosome X data..."
# zcat ${ORIGINALDATA}/SORBS.AUTOSOMAL.FABP4.20141117.edit.txt.gz > ${ORIGINALDATA}/SORBS.WHOLE.FABP4.20141117.edit.txt
# zcat ${ORIGINALDATA}/SORBS.AUTOSOMAL.FABP4adjBMI.20141117.edit.txt.gz > ${ORIGINALDATA}/SORBS.WHOLE.FABP4adjBMI.20141117.edit.txt
# zcat ${ORIGINALDATA}/SORBS.AUTOSOMAL.FABP4adjBMIeGFR.20150703.edit.txt.gz > ${ORIGINALDATA}/SORBS.WHOLE.FABP4adjBMIeGFR.20150703.edit.txt
# zcat ${ORIGINALDATA}/SORBS.CHR23.FEMALES_AUTO.FABP4.20150812.edit.txt.gz | tail -n +2 >> ${ORIGINALDATA}/SORBS.WHOLE.FABP4.20141117.edit.txt
# zcat ${ORIGINALDATA}/SORBS.CHR23.FEMALES_AUTO.FABP4adjBMI.20150812.edit.txt.gz | tail -n +2 >> ${ORIGINALDATA}/SORBS.WHOLE.FABP4adjBMI.20141117.edit.txt
# zcat ${ORIGINALDATA}/SORBS.CHR23.FEMALES_AUTO.FABP4adjBMIeGFR.20150812.edit.txt.gz | tail -n +2 >> ${ORIGINALDATA}/SORBS.WHOLE.FABP4adjBMIeGFR.20150703.edit.txt
# echo ""
# echo "Getting a head..."
# head ${ORIGINALDATA}/SORBS.WHOLE.FABP4.20141117.edit.txt
# head ${ORIGINALDATA}/SORBS.WHOLE.FABP4adjBMI.20141117.edit.txt
# head ${ORIGINALDATA}/SORBS.WHOLE.FABP4adjBMIeGFR.20150703.edit.txt
# echo ""
# echo "Tailing that shizzle..."
# tail ${ORIGINALDATA}/SORBS.WHOLE.FABP4.20141117.edit.txt
# tail ${ORIGINALDATA}/SORBS.WHOLE.FABP4adjBMI.20141117.edit.txt
# tail ${ORIGINALDATA}/SORBS.WHOLE.FABP4adjBMIeGFR.20150703.edit.txt
# # echo ""
# echo "Counting the variants..."
# echo " - 'old' tally..."
# zcat ${ORIGINALDATA}/SORBS.AUTOSOMAL.FABP4.20141117.edit.txt.gz | tail -n +2 | wc -l
# zcat ${ORIGINALDATA}/SORBS.AUTOSOMAL.FABP4adjBMI.20141117.edit.txt.gz | tail -n +2 | wc -l
# zcat ${ORIGINALDATA}/SORBS.AUTOSOMAL.FABP4adjBMIeGFR.20150703.edit.txt.gz | tail -n +2 | wc -l
# echo " - 'new' tally..."
# cat ${ORIGINALDATA}/SORBS.WHOLE.FABP4.20141117.edit.txt | tail -n +2 | wc -l
# cat ${ORIGINALDATA}/SORBS.WHOLE.FABP4adjBMI.20141117.edit.txt | tail -n +2 | wc -l
# cat ${ORIGINALDATA}/SORBS.WHOLE.FABP4adjBMIeGFR.20150703.edit.txt | tail -n +2 | wc -l
# echo ""
# echo "Gzipping the shizzle..."
# gzip -v ${ORIGINALDATA}/SORBS.WHOLE.FABP4.20141117.edit.txt
# gzip -v ${ORIGINALDATA}/SORBS.WHOLE.FABP4adjBMI.20141117.edit.txt
# gzip -v ${ORIGINALDATA}/SORBS.WHOLE.FABP4adjBMIeGFR.20150703.edit.txt
#
# echo ""
# echo "SECOND step: prepare GWAS."
# echo "* SORBS"
# ${PROJECTDIR}/metagwastoolkit.prep.sh $(pwd)/metagwastoolkit.model1.sorbsnoauto.conf $(pwd)/metagwastoolkit.files.model1.sorbsnoauto.list
# ${PROJECTDIR}/metagwastoolkit.prep.sh $(pwd)/metagwastoolkit.model2.sorbsnoauto.conf $(pwd)/metagwastoolkit.files.model2.sorbsnoauto.list
# ${PROJECTDIR}/metagwastoolkit.prep.sh $(pwd)/metagwastoolkit.model3.sorbsnoauto.conf $(pwd)/metagwastoolkit.files.model3.sorbsnoauto.list
# echo ""
# echo "THIRD step: prepare meta-analysis."
# echo "* SORBS"
# ${PROJECTDIR}/metagwastoolkit.prepmeta.sh $(pwd)/metagwastoolkit.model1.sorbsnoauto.conf $(pwd)/metagwastoolkit.files.model1.sorbsnoauto.list
# ${PROJECTDIR}/metagwastoolkit.prepmeta.sh $(pwd)/metagwastoolkit.model2.sorbsnoauto.conf $(pwd)/metagwastoolkit.files.model2.sorbsnoauto.list
# ${PROJECTDIR}/metagwastoolkit.prepmeta.sh $(pwd)/metagwastoolkit.model3.sorbsnoauto.conf $(pwd)/metagwastoolkit.files.model3.sorbsnoauto.list
# echo ""
# echo "FOURTH step: meta-analysis."
# echo "* SORBS"
# ${PROJECTDIR}/metagwastoolkit.meta.sh $(pwd)/metagwastoolkit.model1.sorbsnoauto.conf $(pwd)/metagwastoolkit.files.model1.sorbsnoauto.list
# ${PROJECTDIR}/metagwastoolkit.meta.sh $(pwd)/metagwastoolkit.model2.sorbsnoauto.conf $(pwd)/metagwastoolkit.files.model2.sorbsnoauto.list
# ${PROJECTDIR}/metagwastoolkit.meta.sh $(pwd)/metagwastoolkit.model3.sorbsnoauto.conf $(pwd)/metagwastoolkit.files.model3.sorbsnoauto.list
# 
# echo ""
# echo "FIFTH step: reformat meta-analysis of non-autosomal chromosome X results."
### NOTE TO SELF: In the end I did the part below mostly by hand... not via this script that is.
#
# ### Output meta-analysis
# ###	VARIANTID CHR POS MINOR MAJOR MAF 
# ###	CODEDALLELE_SORBS_m1femnoauto OTHERALLELE_SORBS_m1femnoauto ALLELES_FLIPPED_SORBS_m1femnoauto SIGN_FLIPPED_SORBS_m1femnoauto CAF_SORBS_m1femnoauto BETA_SORBS_m1femnoauto SE_SORBS_m1femnoauto P_SORBS_m1femnoauto Info_SORBS_m1femnoauto NEFF_SORBS_m1femnoauto 
# ###	CODEDALLELE_SORBS_m1malnoauto OTHERALLELE_SORBS_m1malnoauto ALLELES_FLIPPED_SORBS_m1malnoauto SIGN_FLIPPED_SORBS_m1malnoauto CAF_SORBS_m1malnoauto BETA_SORBS_m1malnoauto SE_SORBS_m1malnoauto P_SORBS_m1malnoauto Info_SORBS_m1malnoauto NEFF_SORBS_m1malnoauto 
# ###	CODEDALLELE OTHERALLELE CAF N_EFF Z_SQRTN P_SQRTN BETA_FIXED SE_FIXED Z_FIXED P_FIXED BETA_LOWER_FIXED BETA_UPPER_FIXED 
# ###	BETA_RANDOM SE_RANDOM Z_RANDOM P_RANDOM BETA_LOWER_RANDOM BETA_UPPER_RANDOM 
# ###	COCHRANS_Q DF P_COCHRANS_Q I_SQUARED TAU_SQUARED DIRECTIONS GENES_250KB NEAREST_GENE NEAREST_GENE_ENSEMBLID NEAREST_GENE_STRAND 
# ###	VARIANT_FUNCTION CAVEAT
# ###
# ### Head cdat.gz
# ###	VariantID	Marker	MarkerOriginal	CHR	BP	Strand	EffectAllele	OtherAllele	MinorAllele	MajorAllele	EAF	MAF	MAC	HWE_P	Info	Beta	BetaMinor	SE	P	N	N_cases	N_controls	Imputed	Reference
#
# echo "Moving the old meta-analysis directory to a new one."
# mv -v ${PROJECTDIR}/METAFABP4_1000G ${PROJECTDIR}/METAFABP4_1000G_SORBS_noauto
# 
# echo "Looping over models while editing shizzle..."
# for NUMBER in 1 2 3 ; do
# 	echo ""
# 	### We will first parse the meta-analysis results into the proper format
# 	echo "Parsing meta-analysis results for female/male non-PAR chromosome X..."
# 	echo ""
# 	echo "VariantID	Marker	MarkerOriginal	CHR	BP	Strand	EffectAllele	OtherAllele	MinorAllele	MajorAllele	EAF	MAF	MAC	HWE_P	Info	Beta	BetaMinor	SE	P	N	N_cases	N_controls	Imputed	Reference	VT" > ${PROJECTDIR}/METAFABP4_1000G_SORBS_noauto/MODEL${NUMBER}/META/SORBS_m${NUMBER}.meta.chrX.cdat
# 	zcat ${PROJECTDIR}/METAFABP4_1000G_SORBS_noauto/MODEL${NUMBER}/META/meta.results.FABP4.1Gp1.EUR.txt.gz | 
# 	${SCRIPTS}/parseTable.pl --col VARIANTID,CHR,POS,CODEDALLELE,OTHERALLELE,MINOR,MAJOR,CAF,MAF,Info_SORBS_m${NUMBER}femnoauto,Info_SORBS_m${NUMBER}malnoauto,BETA_FIXED,SE_FIXED,P_FIXED,NEFF_SORBS_m${NUMBER}femnoauto,NEFF_SORBS_m${NUMBER}malnoauto |
# 	awk -v OFS='\t' '{ if( (length($4) != 1 || length($5) != 1) )  { print $1,$1,$1,$2,$3,"+",$4,$5,$6,$7,$8,$9,($9*($15+$16)*2),"1",($10+$11/2),$12,$12,$13,$14,($15+$16),"NA","NA","1","maybe","INDEL" } else { print $1,$1,$1,$2,$3,"+",$4,$5,$6,$7,$8,$9,($9*($15+$16)*2),"1",($10+$11/2),$12,$12,$13,$14,($15+$16),"NA","NA","1","maybe","SNP" } }' | tail -n +2 >> ${PROJECTDIR}/METAFABP4_1000G_SORBS_noauto/MODEL${NUMBER}/META/SORBS_m${NUMBER}.meta.chrX.cdat
# 	cat ${PROJECTDIR}/METAFABP4_1000G_SORBS_noauto/MODEL${NUMBER}/META/SORBS_m${NUMBER}.meta.chrX.cdat | head
# 	### Than we will concatenate
# done
##########################################################################################


##########################################################################################
# echo ""
# echo " PERFORM META-ANALYSIS FOR FEMALE/MALE NON-AUTOSOMAL X-CHROMOSOME "
# echo "                           --- EGCUT ---"
# echo ""
# echo ""
# echo "FIRST step: prepare GWAS."
# echo "* EGCUT"
# ${PROJECTDIR}/metagwastoolkit.prep.sh $(pwd)/PARAMS_CONF_EGCUT/metagwastoolkit.model1.egcut.conf $(pwd)/PARAMS_CONF_EGCUT/metagwastoolkit.files.model1.egcut.list
# ${PROJECTDIR}/metagwastoolkit.prep.sh $(pwd)/PARAMS_CONF_EGCUT/metagwastoolkit.model2.egcut.conf $(pwd)/PARAMS_CONF_EGCUT/metagwastoolkit.files.model2.egcut.list
# ${PROJECTDIR}/metagwastoolkit.prep.sh $(pwd)/PARAMS_CONF_EGCUT/metagwastoolkit.model3.egcut.conf $(pwd)/PARAMS_CONF_EGCUT/metagwastoolkit.files.model3.egcut.list
# echo ""
# echo "SECOND step: prepare meta-analysis."
# echo "* EGCUT"
# ${PROJECTDIR}/metagwastoolkit.prepmeta.sh $(pwd)/PARAMS_CONF_EGCUT/metagwastoolkit.model1.egcut.conf $(pwd)/PARAMS_CONF_EGCUT/metagwastoolkit.files.model1.egcut.list
# ${PROJECTDIR}/metagwastoolkit.prepmeta.sh $(pwd)/PARAMS_CONF_EGCUT/metagwastoolkit.model2.egcut.conf $(pwd)/PARAMS_CONF_EGCUT/metagwastoolkit.files.model2.egcut.list
# ${PROJECTDIR}/metagwastoolkit.prepmeta.sh $(pwd)/PARAMS_CONF_EGCUT/metagwastoolkit.model3.egcut.conf $(pwd)/PARAMS_CONF_EGCUT/metagwastoolkit.files.model3.egcut.list
# echo ""
# echo "THIRD step: meta-analysis."
# echo "* EGCUT"
# ${PROJECTDIR}/metagwastoolkit.meta.sh $(pwd)/PARAMS_CONF_EGCUT/metagwastoolkit.model1.egcut.conf $(pwd)/PARAMS_CONF_EGCUT/metagwastoolkit.files.model1.egcut.list
# ${PROJECTDIR}/metagwastoolkit.meta.sh $(pwd)/PARAMS_CONF_EGCUT/metagwastoolkit.model2.egcut.conf $(pwd)/PARAMS_CONF_EGCUT/metagwastoolkit.files.model2.egcut.list
# ${PROJECTDIR}/metagwastoolkit.meta.sh $(pwd)/PARAMS_CONF_EGCUT/metagwastoolkit.model3.egcut.conf $(pwd)/PARAMS_CONF_EGCUT/metagwastoolkit.files.model3.egcut.list
# 
# echo ""
# echo "FOURTH step: reformat meta-analysis of non-autosomal chromosome X results."
# ### NOTE TO SELF: In the end I did the part below mostly by hand... not via this script that is.
# 
# ### Output meta-analysis
# ###	VARIANTID CHR POS MINOR MAJOR MAF 
# ###	CODEDALLELE_EGCUT_m1femnoauto OTHERALLELE_EGCUT_m1femnoauto ALLELES_FLIPPED_EGCUT_m1femnoauto SIGN_FLIPPED_EGCUT_m1femnoauto CAF_EGCUT_m1femnoauto BETA_EGCUT_m1femnoauto SE_EGCUT_m1femnoauto P_EGCUT_m1femnoauto Info_EGCUT_m1femnoauto NEFF_EGCUT_m1femnoauto 
# ###	CODEDALLELE_EGCUT_m1malnoauto OTHERALLELE_EGCUT_m1malnoauto ALLELES_FLIPPED_EGCUT_m1malnoauto SIGN_FLIPPED_EGCUT_m1malnoauto CAF_EGCUT_m1malnoauto BETA_EGCUT_m1malnoauto SE_EGCUT_m1malnoauto P_EGCUT_m1malnoauto Info_EGCUT_m1malnoauto NEFF_EGCUT_m1malnoauto 
# ###	CODEDALLELE OTHERALLELE CAF N_EFF Z_SQRTN P_SQRTN BETA_FIXED SE_FIXED Z_FIXED P_FIXED BETA_LOWER_FIXED BETA_UPPER_FIXED 
# ###	BETA_RANDOM SE_RANDOM Z_RANDOM P_RANDOM BETA_LOWER_RANDOM BETA_UPPER_RANDOM 
# ###	COCHRANS_Q DF P_COCHRANS_Q I_SQUARED TAU_SQUARED DIRECTIONS GENES_250KB NEAREST_GENE NEAREST_GENE_ENSEMBLID NEAREST_GENE_STRAND 
# ###	VARIANT_FUNCTION CAVEAT
#
# ### Head cdat.gz
# ###	VariantID	Marker	MarkerOriginal	CHR	BP	Strand	EffectAllele	OtherAllele	MinorAllele	MajorAllele	EAF	MAF	MAC	HWE_P	Info	Beta	BetaMinor	SE	P	N	N_cases	N_controls	Imputed	Reference
#
# echo "Moving the old meta-analysis directory to a new one."
# mv -v ${PROJECTDIR}/METAFABP4_1000G ${PROJECTDIR}/METAFABP4_1000G_EGCUT_noauto
# 
# echo "Looping over models while editing shizzle..."
# for NUMBER in 1 2 3 ; do
# 	echo ""
# 	### We will first parse the meta-analysis results into the proper format
# 	echo "Parsing meta-analysis results for female/male non-PAR chromosome X..."
# 	echo ""
# 	echo "VariantID	Marker	MarkerOriginal	CHR	BP	Strand	EffectAllele	OtherAllele	MinorAllele	MajorAllele	EAF	MAF	MAC	HWE_P	Info	Beta	BetaMinor	SE	P	N	N_cases	N_controls	Imputed	Reference	VT" > ${PROJECTDIR}/METAFABP4_1000G_EGCUT_noauto/MODEL${NUMBER}/META/EGCUT_m${NUMBER}.meta.chrX.cdat
# 	zcat ${PROJECTDIR}/METAFABP4_1000G_EGCUT_noauto/MODEL${NUMBER}/META/meta.results.FABP4.1Gp1.EUR.txt.gz | 
# 	${SCRIPTS}/parseTable.pl --col VARIANTID,CHR,POS,CODEDALLELE,OTHERALLELE,MINOR,MAJOR,CAF,MAF,Info_EGCUT_m${NUMBER}females,Info_EGCUT_m${NUMBER}males,BETA_FIXED,SE_FIXED,P_FIXED,NEFF_EGCUT_m${NUMBER}females,NEFF_EGCUT_m${NUMBER}males |
# 	awk -v OFS='\t' '{ if( (length($4) != 1 || length($5) != 1) )  { print $1,$1,$1,$2,$3,"+",$4,$5,$6,$7,$8,$9,($9*($15+$16)*2),"1",($10+$11/2),$12,$12,$13,$14,($15+$16),"NA","NA","1","maybe","INDEL" } else { print $1,$1,$1,$2,$3,"+",$4,$5,$6,$7,$8,$9,($9*($15+$16)*2),"1",($10+$11/2),$12,$12,$13,$14,($15+$16),"NA","NA","1","maybe","SNP" } }' | tail -n +2 >> ${PROJECTDIR}/METAFABP4_1000G_EGCUT_noauto/MODEL${NUMBER}/META/EGCUT_m${NUMBER}.meta.chrX.cdat
# 	cat ${PROJECTDIR}/METAFABP4_1000G_EGCUT_noauto/MODEL${NUMBER}/META/EGCUT_m${NUMBER}.meta.chrX.cdat | head
# 	### Than we will concatenate
# done


##########################################################################################
echo ""
echo " PERFORM META-ANALYSIS FOR ALL DATA AND ALL CHROMOSOMES "
echo ""
# echo "FIRST step: prepare GWAS."
# echo "* with EGCUT"
# ${PROJECTDIR}/metagwastoolkit.prep.sh $(pwd)/metagwastoolkit.model1.conf $(pwd)/metagwastoolkit.files.model1.list
# ${PROJECTDIR}/metagwastoolkit.prep.sh $(pwd)/metagwastoolkit.model2.conf $(pwd)/metagwastoolkit.files.model2.list
# ${PROJECTDIR}/metagwastoolkit.prep.sh $(pwd)/metagwastoolkit.model3.conf $(pwd)/metagwastoolkit.files.model3.list
# echo ""
# echo "* withOUT EGCUT"
# ${PROJECTDIR}/metagwastoolkit.prep.sh $(pwd)/metagwastoolkit.model1.noegcut.conf $(pwd)/metagwastoolkit.files.model1.noegcut.list
# ${PROJECTDIR}/metagwastoolkit.prep.sh $(pwd)/metagwastoolkit.model2.noegcut.conf $(pwd)/metagwastoolkit.files.model2.noegcut.list
# ${PROJECTDIR}/metagwastoolkit.prep.sh $(pwd)/metagwastoolkit.model3.noegcut.conf $(pwd)/metagwastoolkit.files.model3.noegcut.list
#
# echo ""
# echo "SECOND step: concatenate chrX to the shizzle for *BOTH* SORBS and EGCUT."
# for NUMBER in 1 2 3 ; do
# 
# 	echo ""
# 	echo "* SORBS chromosome X for model ${NUMBER}..."
# 	head ${PROJECTDIR}/METAFABP4_1000G_SORBS_noauto/MODEL${NUMBER}/META/SORBS_m${NUMBER}.meta.chrX.cdat
# 	echo ""
# 	echo "* EGCUT chromosome X for model ${NUMBER}..."
# 	head ${PROJECTDIR}/METAFABP4_1000G_EGCUT_noauto/MODEL${NUMBER}/META/EGCUT_m${NUMBER}.meta.chrX.cdat
# 
# 	echo ""
# 	echo ""
# 	echo "* SORBS autosomal chromosomes for model ${NUMBER} - meta-analysis *with* EGCUT..."
# # 	zcat ${PROJECTDIR}/METAFABP4_1000G/MODEL${NUMBER}/RAW/SORBS_m${NUMBER}/SORBS_m${NUMBER}.cdat.gz | head
# 	mv -v ${PROJECTDIR}/METAFABP4_1000G/MODEL${NUMBER}/RAW/SORBS_m${NUMBER}/SORBS_m${NUMBER}.cdat.gz ${PROJECTDIR}/METAFABP4_1000G/MODEL${NUMBER}/RAW/SORBS_m${NUMBER}/SORBS_m${NUMBER}.BACKUP.cdat.gz
# 	zcat ${PROJECTDIR}/METAFABP4_1000G/MODEL${NUMBER}/RAW/SORBS_m${NUMBER}/SORBS_m${NUMBER}.BACKUP.cdat.gz > ${PROJECTDIR}/METAFABP4_1000G/MODEL${NUMBER}/RAW/SORBS_m${NUMBER}/SORBS_m${NUMBER}.cdat
# 	cat ${PROJECTDIR}/METAFABP4_1000G_SORBS_noauto/MODEL${NUMBER}/META/SORBS_m${NUMBER}.meta.chrX.cdat | tail -n +2 >> ${PROJECTDIR}/METAFABP4_1000G/MODEL${NUMBER}/RAW/SORBS_m${NUMBER}/SORBS_m${NUMBER}.cdat
# 	gzip -v ${PROJECTDIR}/METAFABP4_1000G/MODEL${NUMBER}/RAW/SORBS_m${NUMBER}/SORBS_m${NUMBER}.cdat
# 	zcat ${PROJECTDIR}/METAFABP4_1000G/MODEL${NUMBER}/RAW/SORBS_m${NUMBER}/SORBS_m${NUMBER}.cdat.gz | head
# 	zcat ${PROJECTDIR}/METAFABP4_1000G/MODEL${NUMBER}/RAW/SORBS_m${NUMBER}/SORBS_m${NUMBER}.cdat.gz | tail
# 	
# 	echo ""
# 	echo ""
# 	echo "* SORBS autosomal chromosomes for model ${NUMBER} - meta-analysis *withOUT* EGCUT..."
# # 	zcat ${PROJECTDIR}/METAFABP4_1000G_NOEGCUT/MODEL${NUMBER}/RAW/SORBS_m${NUMBER}/SORBS_m${NUMBER}.cdat.gz | head
# 	mv -v ${PROJECTDIR}/METAFABP4_1000G_NOEGCUT/MODEL${NUMBER}/RAW/SORBS_m${NUMBER}/SORBS_m${NUMBER}.cdat.gz ${PROJECTDIR}/METAFABP4_1000G_NOEGCUT/MODEL${NUMBER}/RAW/SORBS_m${NUMBER}/SORBS_m${NUMBER}.BACKUP.cdat.gz
# 	zcat ${PROJECTDIR}/METAFABP4_1000G_NOEGCUT/MODEL${NUMBER}/RAW/SORBS_m${NUMBER}/SORBS_m${NUMBER}.BACKUP.cdat.gz > ${PROJECTDIR}/METAFABP4_1000G_NOEGCUT/MODEL${NUMBER}/RAW/SORBS_m${NUMBER}/SORBS_m${NUMBER}.cdat
# 	cat ${PROJECTDIR}/METAFABP4_1000G_SORBS_noauto/MODEL${NUMBER}/META/SORBS_m${NUMBER}.meta.chrX.cdat | tail -n +2 >> ${PROJECTDIR}/METAFABP4_1000G_NOEGCUT/MODEL${NUMBER}/RAW/SORBS_m${NUMBER}/SORBS_m${NUMBER}.cdat
# 	gzip -v ${PROJECTDIR}/METAFABP4_1000G_NOEGCUT/MODEL${NUMBER}/RAW/SORBS_m${NUMBER}/SORBS_m${NUMBER}.cdat
# 	zcat ${PROJECTDIR}/METAFABP4_1000G_NOEGCUT/MODEL${NUMBER}/RAW/SORBS_m${NUMBER}/SORBS_m${NUMBER}.cdat.gz | head
# 	zcat ${PROJECTDIR}/METAFABP4_1000G_NOEGCUT/MODEL${NUMBER}/RAW/SORBS_m${NUMBER}/SORBS_m${NUMBER}.cdat.gz | tail
# 
# 	echo ""
# 	echo ""
# 	echo "* EGCUT autosomal chromosomes for model ${NUMBER}..."
# # 	zcat ${PROJECTDIR}/METAFABP4_1000G/MODEL${NUMBER}/RAW/EGCUT_m${NUMBER}/EGCUT_m${NUMBER}.cdat.gz | head
# 	mv -v ${PROJECTDIR}/METAFABP4_1000G/MODEL${NUMBER}/RAW/EGCUT_m${NUMBER}/EGCUT_m${NUMBER}.cdat.gz ${PROJECTDIR}/METAFABP4_1000G/MODEL${NUMBER}/RAW/EGCUT_m${NUMBER}/EGCUT_m${NUMBER}.BACKUP.cdat.gz
# 	zcat ${PROJECTDIR}/METAFABP4_1000G/MODEL${NUMBER}/RAW/EGCUT_m${NUMBER}/EGCUT_m${NUMBER}.BACKUP.cdat.gz > ${PROJECTDIR}/METAFABP4_1000G/MODEL${NUMBER}/RAW/EGCUT_m${NUMBER}/EGCUT_m${NUMBER}.cdat
# 	cat ${PROJECTDIR}/METAFABP4_1000G_EGCUT_noauto/MODEL${NUMBER}/META/EGCUT_m${NUMBER}.meta.chrX.cdat | tail -n +2 >> ${PROJECTDIR}/METAFABP4_1000G/MODEL${NUMBER}/RAW/EGCUT_m${NUMBER}/EGCUT_m${NUMBER}.cdat
# 	gzip -v ${PROJECTDIR}/METAFABP4_1000G/MODEL${NUMBER}/RAW/EGCUT_m${NUMBER}/EGCUT_m${NUMBER}.cdat
# 	zcat ${PROJECTDIR}/METAFABP4_1000G/MODEL${NUMBER}/RAW/EGCUT_m${NUMBER}/EGCUT_m${NUMBER}.cdat.gz | head
# 	zcat ${PROJECTDIR}/METAFABP4_1000G/MODEL${NUMBER}/RAW/EGCUT_m${NUMBER}/EGCUT_m${NUMBER}.cdat.gz | tail
# 	
# done
#
# echo ""
# echo "THIRD step: prepare meta-analysis."
# echo "* with EGCUT"
# ${PROJECTDIR}/metagwastoolkit.prepmeta.sh $(pwd)/metagwastoolkit.model1.conf $(pwd)/metagwastoolkit.files.model1.list
# ${PROJECTDIR}/metagwastoolkit.prepmeta.sh $(pwd)/metagwastoolkit.model2.conf $(pwd)/metagwastoolkit.files.model2.list
# ${PROJECTDIR}/metagwastoolkit.prepmeta.sh $(pwd)/metagwastoolkit.model3.conf $(pwd)/metagwastoolkit.files.model3.list
# echo ""
# echo "* withOUT EGCUT"
# ${PROJECTDIR}/metagwastoolkit.prepmeta.sh $(pwd)/metagwastoolkit.model1.noegcut.conf $(pwd)/metagwastoolkit.files.model1.noegcut.list
# ${PROJECTDIR}/metagwastoolkit.prepmeta.sh $(pwd)/metagwastoolkit.model2.noegcut.conf $(pwd)/metagwastoolkit.files.model2.noegcut.list
# ${PROJECTDIR}/metagwastoolkit.prepmeta.sh $(pwd)/metagwastoolkit.model3.noegcut.conf $(pwd)/metagwastoolkit.files.model3.noegcut.list

echo ""
echo "FOURTH step: meta-analysis."
echo "* with EGCUT"
# rsync -avz --progress ${PROJECTDIR}/METAFABP4_1000G/ ${PROJECTDIR}/METAFABP4_1000G_BACKUP

${PROJECTDIR}/metagwastoolkit.meta.sh $(pwd)/metagwastoolkit.model1.conf $(pwd)/metagwastoolkit.files.model1.list
${PROJECTDIR}/metagwastoolkit.meta.sh $(pwd)/metagwastoolkit.model2.conf $(pwd)/metagwastoolkit.files.model2.list
${PROJECTDIR}/metagwastoolkit.meta.sh $(pwd)/metagwastoolkit.model3.conf $(pwd)/metagwastoolkit.files.model3.list
echo ""
echo "* withOUT EGCUT"
# rsync -avz --progress ${PROJECTDIR}/METAFABP4_1000G_NOEGCUT/ ${PROJECTDIR}/METAFABP4_1000G_NOEGCUT_BACKUP

${PROJECTDIR}/metagwastoolkit.meta.sh $(pwd)/metagwastoolkit.model1.noegcut.conf $(pwd)/metagwastoolkit.files.model1.noegcut.list
${PROJECTDIR}/metagwastoolkit.meta.sh $(pwd)/metagwastoolkit.model2.noegcut.conf $(pwd)/metagwastoolkit.files.model2.noegcut.list
${PROJECTDIR}/metagwastoolkit.meta.sh $(pwd)/metagwastoolkit.model3.noegcut.conf $(pwd)/metagwastoolkit.files.model3.noegcut.list

# echo ""
# echo "FIFTH step: result clumping."
# echo "* with EGCUT"
# 
# ${PROJECTDIR}/metagwastoolkit.clump.sh $(pwd)/metagwastoolkit.model1.conf $(pwd)/metagwastoolkit.files.model1.list
# ${PROJECTDIR}/metagwastoolkit.clump.sh $(pwd)/metagwastoolkit.model2.conf $(pwd)/metagwastoolkit.files.model2.list
# ${PROJECTDIR}/metagwastoolkit.clump.sh $(pwd)/metagwastoolkit.model3.conf $(pwd)/metagwastoolkit.files.model3.list
# 
# echo ""
# echo "* withOUT EGCUT"
# 
# ${PROJECTDIR}/metagwastoolkit.clump.sh $(pwd)/metagwastoolkit.model1.noegcut.conf $(pwd)/metagwastoolkit.files.model1.noegcut.list
# ${PROJECTDIR}/metagwastoolkit.clump.sh $(pwd)/metagwastoolkit.model2.noegcut.conf $(pwd)/metagwastoolkit.files.model2.noegcut.list
# ${PROJECTDIR}/metagwastoolkit.clump.sh $(pwd)/metagwastoolkit.model3.noegcut.conf $(pwd)/metagwastoolkit.files.model3.noegcut.list
# 
# echo ""
# echo "SIXTH step: prepare and perform downstream analyses."
# echo "* with EGCUT"
# 
# ${PROJECTDIR}/metagwastoolkit.downstream.sh $(pwd)/metagwastoolkit.model1.conf $(pwd)/metagwastoolkit.files.model1.list
# ${PROJECTDIR}/metagwastoolkit.downstream.sh $(pwd)/metagwastoolkit.model2.conf $(pwd)/metagwastoolkit.files.model2.list
# ${PROJECTDIR}/metagwastoolkit.downstream.sh $(pwd)/metagwastoolkit.model3.conf $(pwd)/metagwastoolkit.files.model3.list
# 
# echo ""
# echo "* withOUT EGCUT"
# 
# ${PROJECTDIR}/metagwastoolkit.downstream.sh $(pwd)/metagwastoolkit.model1.noegcut.conf $(pwd)/metagwastoolkit.files.model1.noegcut.list
# ${PROJECTDIR}/metagwastoolkit.downstream.sh $(pwd)/metagwastoolkit.model2.noegcut.conf $(pwd)/metagwastoolkit.files.model2.noegcut.list
# ${PROJECTDIR}/metagwastoolkit.downstream.sh $(pwd)/metagwastoolkit.model3.noegcut.conf $(pwd)/metagwastoolkit.files.model3.noegcut.list

