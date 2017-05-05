#!/bin/bash
#
#$ -S /bin/bash 																				# the type of BASH you'd like to use
#$ -N metagwastoolkit.qsub 																		# the name of this script
# -hold_jid some_other_basic_bash_script 														# the current script (basic_bash_script) will hold until some_other_basic_bash_script has finished
#$ -o /hpc/dhl_ec/svanderlaan/projects/meta_gwasfabp4/metagwastoolkit.alphaMETA_TESTv27.log 				# the log file of this job
#$ -e /hpc/dhl_ec/svanderlaan/projects/meta_gwasfabp4/metagwastoolkit.alphaMETA_TESTv27.errors 			# the error file of this job
#$ -l h_rt=00:15:00 																			# h_rt=[max time, e.g. 02:02:01] - this is the time you think the script will take
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
SCRIPTS=/hpc/local/CentOS7/dhl_ec/software/MetaGWASToolKit/SCRIPTS
PROJECTDIR=/hpc/dhl_ec/svanderlaan/projects/meta_gwasfabp4
ORIGINALDATA=${PROJECTDIR}/DATA_UPLOAD_FREEZE/1000G
REFERENCE_1KG=/hpc/dhl_ec/data/references/1000G

####################################################################################################
### THIS SHOULD ONLY BE RUN ONCE || THIS SHOULD ONLY BE RUN ONCE || THIS SHOULD ONLY BE RUN ONCE ###
###
# echo "Making reference file..."
# echo "* 1000G phase 1."
# echo "perl ${SCRIPTS}/resource.VCFparser.pl --file ${REFERENCE_1KG}/Phase1/VCF_format/ALL.wgs.integrated_phase1_v3.20101123.snps_indels_sv.sites.vcf.gz --ref 1Gp1 --pop PAN --out ${RESOURCES}/1000Gp1v3_20101123_integrated_ALL_snv_indels_sv " > ${RESOURCES}/resource.VCFparser.1kGp1.sh
# qsub -S /bin/bash -N VCFparser -o ${RESOURCES}/resource.VCFparser.1kGp1.log -e ${RESOURCES}/resource.VCFparser.1kGp1.errors -l h_vmem=8G -l h_rt=02:00:00 -wd ${RESOURCES} ${RESOURCES}/resource.VCFparser.1kGp1.sh
# echo "* 1000G phase 3."
# echo "perl ${SCRIPTS}/resource.VCFparser.pl --file ${REFERENCE_1KG}/Phase3/VCF_format/ALL.wgs.phase3_shapeit2_mvncall_integrated_v5b.20130502.sites.vcf.gz --ref 1Gp1 --pop PAN --out ${RESOURCES}/1000Gp3v5_20130502_integrated_ALL_snv_indels_sv " > ${RESOURCES}/resource.VCFparser.1kGp3.sh
# qsub -S /bin/bash -N VCFparser -o ${RESOURCES}/resource.VCFparser.1kGp3.log -e ${RESOURCES}/resource.VCFparser.1kGp3.errors -l h_vmem=8G -l h_rt=02:00:00 -wd ${RESOURCES} ${RESOURCES}/resource.VCFparser.1kGp3.sh
# echo ""
# echo "Gzipping reference files."
# echo "gzip -fv ${RESOURCES}/1000Gp1v3_20101123_integrated_ALL_snv_indels_sv.INFO.txt " > ${RESOURCES}/resource.zipper.sh
# echo "gzip -fv ${RESOURCES}/1000Gp1v3_20101123_integrated_ALL_snv_indels_sv.FREQ.txt " >> ${RESOURCES}/resource.zipper.sh
# echo "gzip -fv ${RESOURCES}/1000Gp1v3_20101123_integrated_ALL_snv_indels_sv.FUNC.txt " >> ${RESOURCES}/resource.zipper.sh
# echo "gzip -fv ${RESOURCES}/1000Gp3v5_20130502_integrated_ALL_snv_indels_sv.INFO.txt " >> ${RESOURCES}/resource.zipper.sh
# echo "gzip -fv ${RESOURCES}/1000Gp3v5_20130502_integrated_ALL_snv_indels_sv.FREQ.txt " >> ${RESOURCES}/resource.zipper.sh
# echo "gzip -fv ${RESOURCES}/1000Gp3v5_20130502_integrated_ALL_snv_indels_sv.FUNC.txt " >> ${RESOURCES}/resource.zipper.sh
# qsub -S /bin/bash -N resource.zipper -hold_jid VCFparser -o ${RESOURCES}/resource.zipper.log -e ${RESOURCES}/resource.zipper.errors -l h_vmem=8G -l h_rt=02:00:00 -wd ${RESOURCES} ${RESOURCES}/resource.zipper.sh
# echo ""

# echo "Updating function-information with dbSNP data."
# echo "zcat ${RESOURCES}/dbSNP147_GRCh37_hg19_Feb2009.txt.gz | awk '{ print $4, $8 }' > ${RESOURCES}/dbSNP147_GRCh37_hg19_Feb2009.attrib.txt " > ${RESOURCES}/resource.VCFplusDBSNP147.attrib.sh
# echo "gzip -vf ${RESOURCES}/dbSNP147_GRCh37_hg19_Feb2009.attrib.txt " >> ${RESOURCES}/resource.VCFplusDBSNP147.attrib.sh
# qsub -S /bin/bash -N attrib.VCFplusDBSNP147 -hold_jid resource.zipper -o ${RESOURCES}/resource.VCFplusDBSNP147.attrib.log -e ${RESOURCES}/resource.VCFplusDBSNP147.attrib.errors -l h_vmem=8G -l h_rt=02:00:00 -wd ${RESOURCES} ${RESOURCES}/resource.VCFplusDBSNP147.attrib.sh
# echo "* 1000G phase 1."
# echo "perl ${SCRIPTS}/mergeTables.pl --file1 ${RESOURCES}/dbSNP147_GRCh37_hg19_Feb2009.attrib.txt.gz --file2 ${RESOURCES}/1000Gp1v3_20101123_integrated_ALL_snv_indels_sv.FUNC.txt.gz --index VariantID --format GZIPB --replace > ${RESOURCES}/1000Gp1v3_20101123_integrated_ALL_snv_indels_sv.FUNC.txt " > ${RESOURCES}/resource.VCFplusDBSNP147.1kGp1.sh
# echo "gzip -fv ${RESOURCES}/1000Gp1v3_20101123_integrated_ALL_snv_indels_sv.FUNC.txt " >> ${RESOURCES}/resource.VCFplusDBSNP147.1kGp1.sh
# qsub -S /bin/bash -N VCFplusDBSNP -hold_jid attrib.VCFplusDBSNP147 -o ${RESOURCES}/resource.VCFplusDBSNP147.1kGp1.log -e ${RESOURCES}/resource.VCFplusDBSNP147.1kGp1.errors -l h_vmem=128G -l h_rt=03:00:00 -wd ${RESOURCES} ${RESOURCES}/resource.VCFplusDBSNP147.1kGp1.sh
# echo "* 1000G phase 3."
# echo "perl ${SCRIPTS}/mergeTables.pl --file1 ${RESOURCES}/dbSNP147_GRCh37_hg19_Feb2009.attrib.txt.gz --file2 ${RESOURCES}/1000Gp3v5_20130502_integrated_ALL_snv_indels_sv.FUNC.txt.gz --index VariantID --format GZIPB --replace > ${RESOURCES}/1000Gp3v5_20130502_integrated_ALL_snv_indels_sv.FUNC.txt " > ${RESOURCES}/resource.VCFplusDBSNP147.1kGp3.sh
# echo "gzip -fv ${RESOURCES}/1000Gp3v5_20130502_integrated_ALL_snv_indels_sv.FUNC.txt " >> ${RESOURCES}/resource.VCFplusDBSNP147.1kGp3.sh
# qsub -S /bin/bash -N VCFplusDBSNP -hold_jid attrib.VCFplusDBSNP147 -o ${RESOURCES}/resource.VCFplusDBSNP147.1kGp3.log -e ${RESOURCES}/resource.VCFplusDBSNP147.1kGp3.errors -l h_vmem=128G -l h_rt=03:00:00 -wd ${RESOURCES} ${RESOURCES}/resource.VCFplusDBSNP147.1kGp3.sh

### REFORMATTING SORBS -- because that is shitty formatted
### SORBS.WHOLE.FABP4.20141117.txt.gz
### SORBS.WHOLE.FABP4adjBMI.20141117.txt.gz
### SORBS.WHOLE.FABP4adjBMIeGFR.20150703.txt.gz
# 
# ### REFORMAT SORBS model 1-3 with new MARKERID
# echo "Marker Chr Position EffectAllele OtherAllele Strand Beta SE Pval EAF HWE N Imputed Info" > ${ORIGINALDATA}/SORBS.WHOLE.FABP4.20141117.edit.txt
# echo "Marker Chr Position EffectAllele OtherAllele Strand Beta SE Pval EAF HWE N Imputed Info" > ${ORIGINALDATA}/SORBS.WHOLE.FABP4adjBMI.20141117.edit.txt
# echo "Marker Chr Position EffectAllele OtherAllele Strand Beta SE Pval EAF HWE N Imputed Info" > ${ORIGINALDATA}/SORBS.WHOLE.FABP4adjBMIeGFR.20150703.edit.txt
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
# echo "Reformatting SORBS model 3..."
# zcat ${ORIGINALDATA}/SORBS.WHOLE.FABP4adjBMIeGFR.20150703.txt.gz | awk '{if($4=="I") 
# { print $1, $2, $3, $4, "D", "+", $7, $8, $9, $10, $11, $12, $13, $14} else if($4=="D") 
# { print $1, $2, $3, $4, "I", "+", $7, $8, $9, $10, $11, $12, $13, $14} else if($5=="D") 
# { print $1, $2, $3, "I", $5, "+", $7, $8, $9, $10, $11, $12, $13, $14} else if($5=="I") 
# { print $1, $2, $3, "D", $5, "+", $7, $8, $9, $10, $11, $12, $13, $14} else 
# { print $1, $2, $3, $4, $5, "+", $7, $8, $9, $10, $11, $12, $13, $14} }' | 
# awk '{ print "chr"$2":"$3":"$4"_"$5, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14}' | tail -n +2 >> ${ORIGINALDATA}/SORBS.WHOLE.FABP4adjBMIeGFR.20150703.edit.txt 
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



#####################################################################################################
# 
# ### REDOs
# ${PROJECTDIR}/metagwastoolkit.run.sh $(pwd)/metagwastoolkit.conf $(pwd)/metagwastoolkit.files.redo.list 1Gp1

### ALL
# ${PROJECTDIR}/metagwastoolkit.run.sh $(pwd)/metagwastoolkit.model1.conf $(pwd)/metagwastoolkit.files.model1.list
# ${PROJECTDIR}/metagwastoolkit.run.sh $(pwd)/metagwastoolkit.model2.conf $(pwd)/metagwastoolkit.files.model2.list
# ${PROJECTDIR}/metagwastoolkit.run.sh $(pwd)/metagwastoolkit.model3.conf $(pwd)/metagwastoolkit.files.model3.list
# 
# 
# 

