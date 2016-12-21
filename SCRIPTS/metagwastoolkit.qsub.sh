#!/bin/bash
#
#$ -S /bin/bash 																				# the type of BASH you'd like to use
#$ -N run_metagwastoolkit 																		# the name of this script
# -hold_jid some_other_basic_bash_script 														# the current script (basic_bash_script) will hold until some_other_basic_bash_script has finished
#$ -o /hpc/dhl_ec/svanderlaan/projects/meta_gwasfabp4/run_metagwastoolkit.debug.log 				# the log file of this job
#$ -e /hpc/dhl_ec/svanderlaan/projects/meta_gwasfabp4/run_metagwastoolkit.debug.errors 			# the error file of this job
#$ -l h_rt=02:00:00 																			# h_rt=[max time, e.g. 02:02:01] - this is the time you think the script will take
#$ -l h_vmem=4G 																				#  h_vmem=[max. mem, e.g. 45G] - this is the amount of memory you think your script will use
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

RESOURCES=/hpc/local/CentOS7/dhl_ec/software/MetaGWASToolKit/RESOURCES
PROJECTDIR=/hpc/dhl_ec/svanderlaan/projects/meta_gwasfabp4
ORIGINALDATA=${PROJECTDIR}/DATA_UPLOAD_FREEZE/1000G

#####################################################################################################
#### THIS SHOULD ONLY BE RUN ONCE || THIS SHOULD ONLY BE RUN ONCE || THIS SHOULD ONLY BE RUN ONCE ###
####
# echo "Making reference file..."
# echo "* 1000G phase 1."
# perl /hpc/local/CentOS7/dhl_ec/software/GWASToolKit/parseVCF.pl --file /hpc/dhl_ec/data/references/1000G/Phase1/VCF_format/ALL.wgs.integrated_phase1_v3.20101123.snps_indels_sv.sites.vcf.gz --out ${RESOURCES}/1000Gp1v3_20101123_integrated_ALL_snv_indels_sv.INFO.txt
# echo "* 1000G phase 3."
# perl /hpc/local/CentOS7/dhl_ec/software/GWASToolKit/parseVCF.pl --file /hpc/dhl_ec/data/references/1000G/Phase3/VCF_format/ALL.wgs.phase3_shapeit2_mvncall_integrated_v5b.20130502.sites.vcf.gz --out ${RESOURCES}/1000Gp3v5_20130502_integrated_ALL_snv_indels_sv.INFO.txt
# 
# echo ""
# echo "Gzipping reference files."
# gzip -v ${RESOURCES}/1000Gp1v3_20101123_integrated_ALL_snv_indels_sv.INFO.txt
# gzip -v ${RESOURCES}/1000Gp3v5_20130502_integrated_ALL_snv_indels_sv.INFO.txt
# 
# 
# echo ""
# 
# echo "Changing header 1000G phase 1."
# mv -v ${RESOURCES}/1000Gp1v3_20101123_integrated_ALL_snv_indels_sv.INFO.txt.gz foo.gz
# echo "VariantID	VariantID_alt1	VariantID_alt2	VariantID_alt3	VariantID_alt4	VariantID_alt5	VariantID_alt6	VariantID_alt7	VariantID_alt8	VariantID_alt9	VariantID_alt10	VariantID_alt11	VariantID_alt12	VariantID_alt13	CHR_REF	BP_REF	REF	ALT	AlleleA	AlleleB	VT	AF	EURAF	AFRAF	AMRAF	ASNAF	EASAF	SASAF" > ${RESOURCES}/1000Gp1v3_20101123_integrated_ALL_snv_indels_sv.INFO.txt
# zcat foo.gz | tail -n +2 >> ${RESOURCES}/1000Gp1v3_20101123_integrated_ALL_snv_indels_sv.INFO.txt
# 
# gzip -v ${RESOURCES}/1000Gp1v3_20101123_integrated_ALL_snv_indels_sv.INFO.txt
# rm -v foo.gz
# 
# echo ""
# echo "Changing header 1000G phase 3."
# mv -v ${RESOURCES}/1000Gp3v5_20130502_integrated_ALL_snv_indels_sv.INFO.txt.gz bar.gz
# echo "VariantID	VariantID_alt1	VariantID_alt2	VariantID_alt3	VariantID_alt4	VariantID_alt5	VariantID_alt6	VariantID_alt7	VariantID_alt8	VariantID_alt9	VariantID_alt10	VariantID_alt11	VariantID_alt12	VariantID_alt13	CHR_REF	BP_REF	REF	ALT	AlleleA	AlleleB	VT	AF	EURAF	AFRAF	AMRAF	ASNAF	EASAF	SASAF" > ${RESOURCES}/1000Gp3v5_20130502_integrated_ALL_snv_indels_sv.INFO.txt
# zcat bar.gz | tail -n +2 >> ${RESOURCES}/1000Gp3v5_20130502_integrated_ALL_snv_indels_sv.INFO.txt
# 
# gzip -v ${RESOURCES}/1000Gp3v5_20130502_integrated_ALL_snv_indels_sv.INFO.txt
# rm -v bar.gz
# 
# echo ""
# echo "Getting some stats for 1000G phase 1."
# echo "- head"
# zcat ${RESOURCES}/1000Gp1v3_20101123_integrated_ALL_snv_indels_sv.INFO.txt.gz | head
# echo "- tail"
# zcat ${RESOURCES}/1000Gp1v3_20101123_integrated_ALL_snv_indels_sv.INFO.txt.gz | tail
# echo "- lines"
# zcat ${RESOURCES}/1000Gp1v3_20101123_integrated_ALL_snv_indels_sv.INFO.txt.gz | wc -l
# 
# echo "Getting some stats for 1000G phase 3."
# echo "- head"
# zcat ${RESOURCES}/1000Gp3v5_20130502_integrated_ALL_snv_indels_sv.INFO.txt.gz | head
# echo "- tail"
# zcat ${RESOURCES}/1000Gp3v5_20130502_integrated_ALL_snv_indels_sv.INFO.txt.gz | tail
# echo "- lines"
# zcat ${RESOURCES}/1000Gp3v5_20130502_integrated_ALL_snv_indels_sv.INFO.txt.gz | wc -l
# 
# ### REFORMATTING SORBS -- because that is shitty formatted
# ### SORBS.WHOLE.FABP4.20141117.txt.gz
# ### SORBS.WHOLE.FABP4adjBMI.20141117.txt.gz
# ### SORBS.WHOLE.FABP4adjBMIeGFR.20150703.txt.gz
# 
# ### REFORMAT SORBS model 3 with new MARKERID
# echo "Marker Chr Position EffectAllele OtherAllele Strand Beta SE Pval EAF HWE N Imputed Info" > ${ORIGINALDATA}/SORBS.WHOLE.FABP4.20141117.edit.txt
# echo "Marker Chr Position EffectAllele OtherAllele Strand Beta SE Pval EAF HWE N Imputed Info" > ${ORIGINALDATA}/SORBS.WHOLE.FABP4adjBMI.20141117.edit.txt
# echo "Marker Chr Position EffectAllele OtherAllele Strand Beta SE Pval EAF HWE N Imputed Info" > ${ORIGINALDATA}/SORBS.WHOLE.FABP4adjBMIeGFR.20150703.edit.txt
# 
# echo ""
# echo "Reformatting SORBS model 3..."
# zcat ${ORIGINALDATA}/SORBS.WHOLE.FABP4adjBMIeGFR.20150703.txt.gz | awk '{if($4=="I") 
# { print $1, $2, $3, $4, "D", "+", $7, $8, $9, $10, $11, $12, $13, $14} else if($4=="D") 
# { print $1, $2, $3, $4, "I", "+", $7, $8, $9, $10, $11, $12, $13, $14} else if($5=="D") 
# { print $1, $2, $3, "I", $5, "+", $7, $8, $9, $10, $11, $12, $13, $14} else if($5=="I") 
# { print $1, $2, $3, "D", $5, "+", $7, $8, $9, $10, $11, $12, $13, $14} else 
# { print $1, $2, $3, $4, $5, "+", $7, $8, $9, $10, $11, $12, $13, $14} }' | 
# awk '{ print "chr"$2":"$3":"$4"_"$5, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14}' | tail -n +2 >> ${ORIGINALDATA}/SORBS.WHOLE.FABP4adjBMIeGFR.20150703.edit.txt 
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
# {print "chr"$1":"$2":"$6"_"$7, $1, $2, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16} }' | tail -n +2  >> ${ORIGINALDATA}/SORBS.WHOLE.FABP4.20141117.edit.txt
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
# {print "chr"$1":"$2":"$6"_"$7, $1, $2, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16} }' | tail -n +2  >> ${ORIGINALDATA}/SORBS.WHOLE.FABP4adjBMI.20141117.edit.txt
# 
# echo ""
# echo "- heads"
# echo "MODEL 1"
# cat ${ORIGINALDATA}/SORBS.WHOLE.FABP4.20141117.edit.txt | head
# echo "MODEL 2"
# cat ${ORIGINALDATA}/SORBS.WHOLE.FABP4adjBMI.20141117.edit.txt | head
# echo "MODEL 3"
# cat ${ORIGINALDATA}/SORBS.WHOLE.FABP4adjBMIeGFR.20150703.edit.txt | head
# 
# echo ""
# echo "- tails"
# echo "MODEL 1"
# cat ${ORIGINALDATA}/SORBS.WHOLE.FABP4.20141117.edit.txt | tail
# echo "MODEL 2"
# cat ${ORIGINALDATA}/SORBS.WHOLE.FABP4adjBMI.20141117.edit.txt | tail
# echo "MODEL 3"
# cat ${ORIGINALDATA}/SORBS.WHOLE.FABP4adjBMIeGFR.20150703.edit.txt | tail
# 
# echo ""
# echo "- count"
# cat ${ORIGINALDATA}/SORBS.WHOLE.FABP4.20141117.edit.txt | tail -n +2 | wc -l
# cat ${ORIGINALDATA}/SORBS.WHOLE.FABP4adjBMI.20141117.edit.txt | tail -n +2 | wc -l
# cat ${ORIGINALDATA}/SORBS.WHOLE.FABP4adjBMIeGFR.20150703.edit.txt | tail -n +2 | wc -l
# 
# echo ""
# echo "Gzipping the shizzle."
# gzip -v ${ORIGINALDATA}/SORBS.WHOLE.FABP4.20141117.edit.txt
# gzip -v ${ORIGINALDATA}/SORBS.WHOLE.FABP4adjBMI.20141117.edit.txt
# gzip -v ${ORIGINALDATA}/SORBS.WHOLE.FABP4adjBMIeGFR.20150703.edit.txt
#
####
#####################################################################################################

### REDO (SORBS m1 + SORBS m2 + SORBS m3)
${PROJECTDIR}/run_metagwastoolkit.sh meta_configuration.conf meta_files.test.list 1Gp1

### ALL
###${PROJECTDIR}/run_metagwastoolkit.sh $(pwd)/meta_configuration.conf $(pwd)/meta_files.model1.list 1Gp1
###${PROJECTDIR}/run_metagwastoolkit.sh $(pwd)/meta_configuration.conf $(pwd)/meta_files.model2.list 1Gp1
###${PROJECTDIR}/run_metagwastoolkit.sh $(pwd)/meta_configuration.conf $(pwd)/meta_files.model3.list 1Gp1




