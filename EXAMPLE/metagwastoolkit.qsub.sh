#!/bin/bash
#
#$ -S /bin/bash 																						# the type of BASH you'd like to use
#$ -N metagwastoolkit 																					# the name of this script
# -hold_jid some_other_basic_bash_script 																# the current script (basic_bash_script) will hold until some_other_basic_bash_script has finished
#$ -o /hpc/dhl_ec/svanderlaan/projects/meta_gwasfabp4/metagwastoolkit.CLUMPING.log 		# the log file of this job
#$ -e /hpc/dhl_ec/svanderlaan/projects/meta_gwasfabp4/metagwastoolkit.CLUMPING.errors 	# the error file of this job
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

RESOURCES="/hpc/local/CentOS7/dhl_ec/software/MetaGWASToolKit/RESOURCES"
SCRIPTS="/hpc/local/CentOS7/dhl_ec/software/MetaGWASToolKit/SCRIPTS"
PROJECTDIR="/hpc/dhl_ec/svanderlaan/projects/meta_gwasfabp4"
ORIGINALDATA="${PROJECTDIR}/DATA_UPLOAD_FREEZE/1000G"
REFERENCE_1KG="/hpc/dhl_ec/data/references/1000G"

echo ""
echo "                     PERFORM META-ANALYSIS FOR ALL CHROMOSOMES "
echo "                                 --- ALL COHORTS ---"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
##########################################################################################

# echo ""
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
#  	zcat ${PROJECTDIR}/METAFABP4_1000G/MODEL${NUMBER}/RAW/SORBS_m${NUMBER}/SORBS_m${NUMBER}.cdat.gz | head
# 	mv -v ${PROJECTDIR}/METAFABP4_1000G/MODEL${NUMBER}/RAW/SORBS_m${NUMBER}/SORBS_m${NUMBER}.cdat.gz ${PROJECTDIR}/METAFABP4_1000G/MODEL${NUMBER}/RAW/SORBS_m${NUMBER}/SORBS_m${NUMBER}.BACKUP.gz
# 	zcat ${PROJECTDIR}/METAFABP4_1000G/MODEL${NUMBER}/RAW/SORBS_m${NUMBER}/SORBS_m${NUMBER}.BACKUP.gz > ${PROJECTDIR}/METAFABP4_1000G/MODEL${NUMBER}/RAW/SORBS_m${NUMBER}/SORBS_m${NUMBER}.cdat
# 	cat ${PROJECTDIR}/METAFABP4_1000G_SORBS_noauto/MODEL${NUMBER}/META/SORBS_m${NUMBER}.meta.chrX.cdat | tail -n +2 >> ${PROJECTDIR}/METAFABP4_1000G/MODEL${NUMBER}/RAW/SORBS_m${NUMBER}/SORBS_m${NUMBER}.cdat
# 	gzip -fv ${PROJECTDIR}/METAFABP4_1000G/MODEL${NUMBER}/RAW/SORBS_m${NUMBER}/SORBS_m${NUMBER}.cdat
# 	zcat ${PROJECTDIR}/METAFABP4_1000G/MODEL${NUMBER}/RAW/SORBS_m${NUMBER}/SORBS_m${NUMBER}.cdat.gz | head
# 	zcat ${PROJECTDIR}/METAFABP4_1000G/MODEL${NUMBER}/RAW/SORBS_m${NUMBER}/SORBS_m${NUMBER}.cdat.gz | tail
# 	
# 	echo ""
# 	echo ""
# 	echo "* SORBS autosomal chromosomes for model ${NUMBER} - meta-analysis *withOUT* EGCUT..."
#  	zcat ${PROJECTDIR}/METAFABP4_1000G_NOEGCUT/MODEL${NUMBER}/RAW/SORBS_m${NUMBER}/SORBS_m${NUMBER}.cdat.gz | head
# 	mv -v ${PROJECTDIR}/METAFABP4_1000G_NOEGCUT/MODEL${NUMBER}/RAW/SORBS_m${NUMBER}/SORBS_m${NUMBER}.cdat.gz ${PROJECTDIR}/METAFABP4_1000G_NOEGCUT/MODEL${NUMBER}/RAW/SORBS_m${NUMBER}/SORBS_m${NUMBER}.BACKUP.gz
# 	zcat ${PROJECTDIR}/METAFABP4_1000G_NOEGCUT/MODEL${NUMBER}/RAW/SORBS_m${NUMBER}/SORBS_m${NUMBER}.BACKUP.gz > ${PROJECTDIR}/METAFABP4_1000G_NOEGCUT/MODEL${NUMBER}/RAW/SORBS_m${NUMBER}/SORBS_m${NUMBER}.cdat
# 	cat ${PROJECTDIR}/METAFABP4_1000G_SORBS_noauto/MODEL${NUMBER}/META/SORBS_m${NUMBER}.meta.chrX.cdat | tail -n +2 >> ${PROJECTDIR}/METAFABP4_1000G_NOEGCUT/MODEL${NUMBER}/RAW/SORBS_m${NUMBER}/SORBS_m${NUMBER}.cdat
# 	gzip -fv ${PROJECTDIR}/METAFABP4_1000G_NOEGCUT/MODEL${NUMBER}/RAW/SORBS_m${NUMBER}/SORBS_m${NUMBER}.cdat
# 	zcat ${PROJECTDIR}/METAFABP4_1000G_NOEGCUT/MODEL${NUMBER}/RAW/SORBS_m${NUMBER}/SORBS_m${NUMBER}.cdat.gz | head
# 	zcat ${PROJECTDIR}/METAFABP4_1000G_NOEGCUT/MODEL${NUMBER}/RAW/SORBS_m${NUMBER}/SORBS_m${NUMBER}.cdat.gz | tail
# 
# 	echo ""
# 	echo ""
# 	echo "* EGCUT autosomal chromosomes for model ${NUMBER}..."
#  	zcat ${PROJECTDIR}/METAFABP4_1000G/MODEL${NUMBER}/RAW/EGCUT_m${NUMBER}/EGCUT_m${NUMBER}.cdat.gz | head
# 	mv -v ${PROJECTDIR}/METAFABP4_1000G/MODEL${NUMBER}/RAW/EGCUT_m${NUMBER}/EGCUT_m${NUMBER}.cdat.gz ${PROJECTDIR}/METAFABP4_1000G/MODEL${NUMBER}/RAW/EGCUT_m${NUMBER}/EGCUT_m${NUMBER}.BACKUP.gz
# 	zcat ${PROJECTDIR}/METAFABP4_1000G/MODEL${NUMBER}/RAW/EGCUT_m${NUMBER}/EGCUT_m${NUMBER}.BACKUP.gz > ${PROJECTDIR}/METAFABP4_1000G/MODEL${NUMBER}/RAW/EGCUT_m${NUMBER}/EGCUT_m${NUMBER}.cdat
# 	cat ${PROJECTDIR}/METAFABP4_1000G_EGCUT_noauto/MODEL${NUMBER}/META/EGCUT_m${NUMBER}.meta.chrX.cdat | tail -n +2 >> ${PROJECTDIR}/METAFABP4_1000G/MODEL${NUMBER}/RAW/EGCUT_m${NUMBER}/EGCUT_m${NUMBER}.cdat
# 	gzip -fv ${PROJECTDIR}/METAFABP4_1000G/MODEL${NUMBER}/RAW/EGCUT_m${NUMBER}/EGCUT_m${NUMBER}.cdat
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
# 
# echo ""
# echo "FOURTH step: meta-analysis."
# echo "* with EGCUT"
# ### copied the input directories of the meta-analysis by hand:
# # ### cp -Rv METAFABP4_1000G/* METAFABP4_1000G_prepMETA_BACKUP/
# # ### rsync -avz --progress ${PROJECTDIR}/METAFABP4_1000G/ ${PROJECTDIR}/METAFABP4_1000G_BACKUP
# 
# ${PROJECTDIR}/metagwastoolkit.meta.sh $(pwd)/metagwastoolkit.model1.conf $(pwd)/metagwastoolkit.files.model1.list
# ${PROJECTDIR}/metagwastoolkit.meta.sh $(pwd)/metagwastoolkit.model2.conf $(pwd)/metagwastoolkit.files.model2.list
# ${PROJECTDIR}/metagwastoolkit.meta.sh $(pwd)/metagwastoolkit.model3.conf $(pwd)/metagwastoolkit.files.model3.list
# echo ""
# echo "* withOUT EGCUT"
# ### copied the input directories of the meta-analysis by hand:
# # ### cp -Rv METAFABP4_1000G_NOEGCUT/* METAFABP4_1000G_NOEGCUT_prepMETA_BACKUP/
# # ### rsync -avz --progress ${PROJECTDIR}/METAFABP4_1000G_NOEGCUT/ ${PROJECTDIR}/METAFABP4_1000G_NOEGCUT_prepMETA_BACKUP
# 
# ${PROJECTDIR}/metagwastoolkit.meta.sh $(pwd)/metagwastoolkit.model1.noegcut.conf $(pwd)/metagwastoolkit.files.model1.noegcut.list
# ${PROJECTDIR}/metagwastoolkit.meta.sh $(pwd)/metagwastoolkit.model2.noegcut.conf $(pwd)/metagwastoolkit.files.model2.noegcut.list
# ${PROJECTDIR}/metagwastoolkit.meta.sh $(pwd)/metagwastoolkit.model3.noegcut.conf $(pwd)/metagwastoolkit.files.model3.noegcut.list
# 
echo ""
echo "FIFTH step: result clumping."
echo "* with EGCUT"

${PROJECTDIR}/metagwastoolkit.clump.sh $(pwd)/metagwastoolkit.model1.conf $(pwd)/metagwastoolkit.files.model1.list
${PROJECTDIR}/metagwastoolkit.clump.sh $(pwd)/metagwastoolkit.model2.conf $(pwd)/metagwastoolkit.files.model2.list
${PROJECTDIR}/metagwastoolkit.clump.sh $(pwd)/metagwastoolkit.model3.conf $(pwd)/metagwastoolkit.files.model3.list
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













