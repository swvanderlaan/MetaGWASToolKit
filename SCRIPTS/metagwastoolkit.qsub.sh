#!/bin/bash
#
#$ -S /bin/bash 																				# the type of BASH you'd like to use
#$ -N qsub.metagwastoolkit 																		# the name of this script
# -hold_jid some_other_basic_bash_script 														# the current script (basic_bash_script) will hold until some_other_basic_bash_script has finished
#$ -o /hpc/dhl_ec/svanderlaan/projects/meta_gwasfabp4/metagwastoolkit.PostMetaLDMR.log 						# the log file of this job
#$ -e /hpc/dhl_ec/svanderlaan/projects/meta_gwasfabp4/metagwastoolkit.PostMetaLDMR.errors 					# the error file of this job
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

RESOURCES=/hpc/local/CentOS7/dhl_ec/software/MetaGWASToolKit/RESOURCES
SCRIPTS=/hpc/local/CentOS7/dhl_ec/software/MetaGWASToolKit/SCRIPTS
PROJECTDIR=/hpc/dhl_ec/svanderlaan/projects/meta_gwasfabp4
ORIGINALDATA=${PROJECTDIR}/DATA_UPLOAD_FREEZE/1000G
REFERENCE_1KG=/hpc/dhl_ec/data/references/1000G

#####################################################################################################

${PROJECTDIR}/metagwastoolkit.run.sh $(pwd)/metagwastoolkit.model1.conf $(pwd)/metagwastoolkit.files.model1.list
${PROJECTDIR}/metagwastoolkit.run.sh $(pwd)/metagwastoolkit.model2.conf $(pwd)/metagwastoolkit.files.model2.list
${PROJECTDIR}/metagwastoolkit.run.sh $(pwd)/metagwastoolkit.model3.conf $(pwd)/metagwastoolkit.files.model3.list

####################################################################################################
### THIS SHOULD ONLY BE RUN ONCE || THIS SHOULD ONLY BE RUN ONCE || THIS SHOULD ONLY BE RUN ONCE ###
###
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
# 
# 
# echo "We need to edit the post-QC SORBS data for meta-analysis."
# for NUMBER in 1 2 3 ; do
# 	echo "Moving original data for model no. [ ${NUMBER} ]..."
# 	mv -v ${PROJECTDIR}/METAFABP4_1000G/MODEL${NUMBER}/RAW/SORBS_m${NUMBER} ${PROJECTDIR}/METAFABP4_1000G/MODEL${NUMBER}/RAW/SORBS_m${NUMBER}_original
# 	mv -v ${PROJECTDIR}/METAFABP4_1000G/MODEL${NUMBER}/RAW/SORBS_m${NUMBER}femauto ${PROJECTDIR}/METAFABP4_1000G/MODEL${NUMBER}/RAW/SORBS_m${NUMBER}femauto_original
# 	mv -v ${PROJECTDIR}/METAFABP4_1000G/MODEL${NUMBER}/RAW/SORBS_m${NUMBER}femnoauto ${PROJECTDIR}/METAFABP4_1000G/MODEL${NUMBER}/RAW/SORBS_m${NUMBER}femnoauto_original
# 	mv -v ${PROJECTDIR}/METAFABP4_1000G/MODEL${NUMBER}/RAW/SORBS_m${NUMBER}malnoauto ${PROJECTDIR}/METAFABP4_1000G/MODEL${NUMBER}/RAW/SORBS_m${NUMBER}malnoauto_original
# 	
# 	echo "Making a new staging directory for model no. [ ${NUMBER} ]..."
# 	mkdir -v ${PROJECTDIR}/METAFABP4_1000G/MODEL${NUMBER}/RAW/SORBS_m${NUMBER}
# 	mkdir -v ${PROJECTDIR}/METAFABP4_1000G/MODEL${NUMBER}/RAW/SORBS_m${NUMBER}femauto
# 	mkdir -v ${PROJECTDIR}/METAFABP4_1000G/MODEL${NUMBER}/RAW/SORBS_m${NUMBER}femnoauto
# 	mkdir -v ${PROJECTDIR}/METAFABP4_1000G/MODEL${NUMBER}/RAW/SORBS_m${NUMBER}malnoauto
# 	
# 	echo "Concatenating autosomal with female autosomal-like chromosome X data for model no. [ ${NUMBER} ]..."
# 	zcat ${PROJECTDIR}/METAFABP4_1000G/MODEL${NUMBER}/RAW/SORBS_m${NUMBER}_original/SORBS_m${NUMBER}.cdat.gz > ${PROJECTDIR}/METAFABP4_1000G/MODEL${NUMBER}/RAW/SORBS_m${NUMBER}/SORBS_m${NUMBER}.cdat
# 	zcat ${PROJECTDIR}/METAFABP4_1000G/MODEL${NUMBER}/RAW/SORBS_m${NUMBER}femauto_original/SORBS_m${NUMBER}femauto.cdat.gz | tail -n +2 >> ${PROJECTDIR}/METAFABP4_1000G/MODEL${NUMBER}/RAW/SORBS_m${NUMBER}/SORBS_m${NUMBER}.cdat
# 	echo ""
# 	echo "Getting a head..."
# 	head ${PROJECTDIR}/METAFABP4_1000G/MODEL${NUMBER}/RAW/SORBS_m${NUMBER}/SORBS_m${NUMBER}.cdat
# 	echo ""
# 	echo "Tailing that shizzle..."
# 	tail ${PROJECTDIR}/METAFABP4_1000G/MODEL${NUMBER}/RAW/SORBS_m${NUMBER}/SORBS_m${NUMBER}.cdat
# 	echo ""
# 	echo "Counting the variants..."
# 	echo " - 'old' tally..."
# 	zcat ${PROJECTDIR}/METAFABP4_1000G/MODEL${NUMBER}/RAW/SORBS_m${NUMBER}_original/SORBS_m${NUMBER}.cdat.gz | tail -n +2 | wc -l
# 	echo " - 'new' tally..."
# 	cat ${PROJECTDIR}/METAFABP4_1000G/MODEL${NUMBER}/RAW/SORBS_m${NUMBER}/SORBS_m${NUMBER}.cdat | tail -n +2 | wc -l
# 	
# 	echo "Copying female and male non-PAR chromosome X data for model no. [ ${NUMBER} ]..."
# 	cp -Rv ${PROJECTDIR}/METAFABP4_1000G/MODEL${NUMBER}/RAW/SORBS_m${NUMBER}femnoauto_original/* ${PROJECTDIR}/METAFABP4_1000G/MODEL${NUMBER}/RAW/SORBS_m${NUMBER}femnoauto/
# 	cp -Rv ${PROJECTDIR}/METAFABP4_1000G/MODEL${NUMBER}/RAW/SORBS_m${NUMBER}malnoauto_original/* ${PROJECTDIR}/METAFABP4_1000G/MODEL${NUMBER}/RAW/SORBS_m${NUMBER}malnoauto/
# 
# done
#  
# ### FIRST round: meta-analysis preparator
# ${PROJECTDIR}/metagwastoolkit.run.sh $(pwd)/metagwastoolkit.model1.sorbsnoauto.conf $(pwd)/metagwastoolkit.files.model1.sorbsnoauto.list
# ${PROJECTDIR}/metagwastoolkit.run.sh $(pwd)/metagwastoolkit.model2.sorbsnoauto.conf $(pwd)/metagwastoolkit.files.model2.sorbsnoauto.list
# ${PROJECTDIR}/metagwastoolkit.run.sh $(pwd)/metagwastoolkit.model3.sorbsnoauto.conf $(pwd)/metagwastoolkit.files.model3.sorbsnoauto.list
# 
# ### SECOND round: meta-analysis
# ${PROJECTDIR}/metagwastoolkit.run.sh $(pwd)/metagwastoolkit.model1.sorbsnoauto.conf $(pwd)/metagwastoolkit.files.model1.sorbsnoauto.list
# ${PROJECTDIR}/metagwastoolkit.run.sh $(pwd)/metagwastoolkit.model2.sorbsnoauto.conf $(pwd)/metagwastoolkit.files.model2.sorbsnoauto.list
# ${PROJECTDIR}/metagwastoolkit.run.sh $(pwd)/metagwastoolkit.model3.sorbsnoauto.conf $(pwd)/metagwastoolkit.files.model3.sorbsnoauto.list
# 
# ### NOTE TO SELF: In the end I did the part below mostly by hand... not via this script that is.
# echo "Here we concatenate the meta-analysis results of the female/male non-PAR chromosome X to SORBS_m*"
# 
# 	### Output meta-analysis
# ###	VARIANTID CHR POS MINOR MAJOR MAF 
# ###	CODEDALLELE_SORBS_m1femnoauto OTHERALLELE_SORBS_m1femnoauto ALLELES_FLIPPED_SORBS_m1femnoauto SIGN_FLIPPED_SORBS_m1femnoauto CAF_SORBS_m1femnoauto BETA_SORBS_m1femnoauto SE_SORBS_m1femnoauto P_SORBS_m1femnoauto Info_SORBS_m1femnoauto NEFF_SORBS_m1femnoauto 
# ###	CODEDALLELE_SORBS_m1malnoauto OTHERALLELE_SORBS_m1malnoauto ALLELES_FLIPPED_SORBS_m1malnoauto SIGN_FLIPPED_SORBS_m1malnoauto CAF_SORBS_m1malnoauto BETA_SORBS_m1malnoauto SE_SORBS_m1malnoauto P_SORBS_m1malnoauto Info_SORBS_m1malnoauto NEFF_SORBS_m1malnoauto 
# ###	CODEDALLELE OTHERALLELE CAF N_EFF Z_SQRTN P_SQRTN BETA_FIXED SE_FIXED Z_FIXED P_FIXED BETA_LOWER_FIXED BETA_UPPER_FIXED 
# ###	BETA_RANDOM SE_RANDOM Z_RANDOM P_RANDOM BETA_LOWER_RANDOM BETA_UPPER_RANDOM 
# ###	COCHRANS_Q DF P_COCHRANS_Q I_SQUARED TAU_SQUARED DIRECTIONS GENES_250KB NEAREST_GENE NEAREST_GENE_ENSEMBLID NEAREST_GENE_STRAND 
# ###	VARIANT_FUNCTION CAVEAT
# 
# 	### Head cdat.gz
# 	###	VariantID	Marker	MarkerOriginal	CHR	BP	Strand	EffectAllele	OtherAllele	MinorAllele	MajorAllele	EAF	MAF	MAC	HWE_P	Info	Beta	BetaMinor	SE	P	N	N_cases	N_controls	Imputed	Reference
# for NUMBER in 1 2 3 ; do
# 	echo ""
# 	### We will first parse the meta-analysis results into the proper format
# 	echo "Parsing meta-analysis results for female/male non-PAR chromosome X..."
# 	echo ""
# 	echo "VariantID	Marker	MarkerOriginal	CHR	BP	Strand	EffectAllele	OtherAllele	MinorAllele	MajorAllele	EAF	MAF	MAC	HWE_P	Info	Beta	BetaMinor	SE	P	N	N_cases	N_controls	Imputed	Reference" > ${PROJECTDIR}/METAFABP4_1000G/MODEL${NUMBER}/META/SORBS_m${NUMBER}.meta.chrX.cdat
# 	zcat ${PROJECTDIR}/METAFABP4_1000G/MODEL${NUMBER}/META/meta.results.FABP4.1Gp1.EUR.txt.gz | 
# 	${SCRIPTS}/parseTable.pl --col VARIANTID,CHR,POS,CODEDALLELE,OTHERALLELE,MINOR,MAJOR,CAF,MAF,Info_SORBS_m${NUMBER}femnoauto,Info_SORBS_m${NUMBER}malnoauto,BETA_FIXED,SE_FIXED,P_FIXED,NEFF_SORBS_m${NUMBER}femnoauto,NEFF_SORBS_m${NUMBER}malnoauto |
# 	awk '{ print $1,$1,$1,$2,$3,"+",$4,$5,$6,$7,$8,$9,($9*($15+$16)*2),"1",($10+$11/2),$12,$12,$13,$14,($15+$16),"NA","NA","1","maybe" }' | tail -n +2 >> ${PROJECTDIR}/METAFABP4_1000G/MODEL${NUMBER}/META/SORBS_m${NUMBER}.meta.chrX.cdat
# 	head ${PROJECTDIR}/METAFABP4_1000G/MODEL${NUMBER}/META/SORBS_m${NUMBER}.meta.cdat
# 	### Than we will concatenate
# 	echo "Concatenating parsed meta-analysis results to autosomal/PAR data for SORBS..."
# 	echo "* nothing to do: variants not in reference!?!"
# 	echo "Gzipping the new shizzle..."
# 	mkdir -v ${PROJECTDIR}/METAFABP4_1000G/MODEL${NUMBER}/RAW/SORBS_m${NUMBER}
# 	cp -v ${PROJECTDIR}/METAFABP4_1000G/MODEL${NUMBER}/RAW_all/SORBS_m${NUMBER}/SORBS_m${NUMBER}.cdat ${PROJECTDIR}/METAFABP4_1000G/MODEL${NUMBER}/RAW/SORBS_m${NUMBER}/SORBS_m${NUMBER}.cdat
# 	cat ${PROJECTDIR}/METAFABP4_1000G/MODEL${NUMBER}/META/SORBS_m${NUMBER}.meta.chrX.cdat | tail -n +2 >> ${PROJECTDIR}/METAFABP4_1000G/MODEL${NUMBER}/RAW/SORBS_m${NUMBER}/SORBS_m${NUMBER}.cdat
# 	gzip -v ${PROJECTDIR}/METAFABP4_1000G/MODEL${NUMBER}/RAW/SORBS_m${NUMBER}/SORBS_m${NUMBER}.cdat
# 	echo ""
# 	echo "- getting a head..."
# 	zcat ${PROJECTDIR}/METAFABP4_1000G/MODEL${NUMBER}/RAW/SORBS_m${NUMBER}/SORBS_m${NUMBER}.cdat.gz | head
# 	echo "- getting a tail..."
# 	zcat ${PROJECTDIR}/METAFABP4_1000G/MODEL${NUMBER}/RAW/SORBS_m${NUMBER}/SORBS_m${NUMBER}.cdat.gz | tail
# 	echo "- getting a tally..."
# 	zcat ${PROJECTDIR}/METAFABP4_1000G/MODEL${NUMBER}/RAW/SORBS_m${NUMBER}/SORBS_m${NUMBER}.cdat.gz | tail -n +2 | wc -l
# 	echo ""
# 	echo "We will clean up this sub-meta-analysis..."
# 	mkdir -v ${PROJECTDIR}/METAFABP4_1000G/MODEL${NUMBER}/subMETA
# 	mv -v ${PROJECTDIR}/METAFABP4_1000G/MODEL${NUMBER}/RAW/SORBS_m${NUMBER}_MetaAuto ${PROJECTDIR}/METAFABP4_1000G/MODEL${NUMBER}/subMETA/SORBS_m${NUMBER}_MetaAuto
# 	mv -v ${PROJECTDIR}/METAFABP4_1000G/MODEL${NUMBER}/META/* ${PROJECTDIR}/METAFABP4_1000G/MODEL${NUMBER}/subMETA/
# 	
# done




