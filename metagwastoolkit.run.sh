#!/bin/bash
#
#################################################################################################
### PARAMETERS SLURM
#SBATCH --job-name=metagwastoolkit                                  														# the name of the job
#SBATCH -o path_to_projectdir/subdir/metagwastoolkit.prep.log 	        # the log file of this job
#SBATCH --error path_to_projectdir/subdir/metagwastoolkit.prep.errors	# the error file of this job
#SBATCH --time=01:00:00                                             														# the amount of time the job will take: -t [min] OR -t [days-hh:mm:ss]
#SBATCH --mem=8G                                                    														# the amount of memory you think the script will consume, found on: https://wiki.bioinformatics.umcutrecht.nl/bin/view/HPC/SlurmScheduler
#SBATCH --gres=tmpspace:128G                                        														# the amount of temporary diskspace per node
#SBATCH --mail-user=s.w.vanderlaan-2@umcutrecht.nl                  														# where should be mailed to?
#SBATCH --mail-type=FAIL                                            														# when do you want to receive a mail from your job?  Valid type values are NONE, BEGIN, END, FAIL, REQUEUE
                                                                    														# or ALL (equivalent to BEGIN, END, FAIL, INVALID_DEPEND, REQUEUE, and STAGE_OUT), 
                                                                    														# Multiple type values may be specified in a comma separated list. 
####    Note:   You do not have to specify workdir: 
####            'Current working directory is the calling process working directory unless the --chdir argument is passed, which will override the current working directory.'
####            TODO: select the type of interpreter you'd like to use
####            TODO: Find out whether this job should dependant on other scripts (##SBATCH --depend=[state:job_id])
####
#################################################################################################
#
# You can use the variables below (indicated by "#$") to set some things for the submission system.
# Another useful tip: you can set a job to run after another has finished. Name the job 
# with "-N SOMENAME" and hold the other job with -hold_jid SOMENAME". 
# Further instructions: https://wiki.bioinformatics.umcutrecht.nl/bin/view/HPC/HowToS#Run_a_job_after_your_other_jobs
#
# It is good practice to properly name and annotate your script for future reference for
# yourself and others. Trust me, you'll forget why and how you made this!!!
METAGWASTOOLKIT="/hpc/local/Rocky8/dhl_ec/software/MetaGWASToolKit"
RESOURCES="${METAGWASTOOLKIT}/RESOURCES"
SCRIPTS="${METAGWASTOOLKIT}/SCRIPTS"
PROJECTNAME="EXAMPLEPHENOTYPE"
PROJECTDIR="${METAGWASTOOLKIT}/EXAMPLE"
SUBPROJECTDIRNAME="MODEL1"
PYTHON3="/hpc/local/Rocky8/dhl_ec/software/mambaforge3/bin/python3"
METAMODEL="FIXED" # FIXED, SQRTN, or RANDOM. Should match "CLUMP_FIELD" variable from the .conf file.

echo ""
echo "                 PERFORM META-ANALYSIS OF GENOME-WIDE ASSOCIATION STUDIES"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

### Note: It is advisable to perform the first two steps, first. Upon completion, you should inspect
###       the plots produced to decided whether cohorts should be carried forward to meta-analysis
###       or whether quality control settings should be edited.
###

echo ""
echo "FIRST step: prepare GWAS."
### DEBUGGING
### ${SCRIPTS}/metagwastoolkit.prep.sh ${PROJECTDIR}/metagwastoolkit.conf ${PROJECTDIR}/metagwastoolkit.files.list.test
${SCRIPTS}/metagwastoolkit.prep.sh ${PROJECTDIR}/metagwastoolkit.conf ${PROJECTDIR}/metagwastoolkit.files.list

### Note: After visual inspection of diagnostic plots per cohort (see note above), the next
###       steps can be uncommented and executed one-by-one. It is advisable to always 
###		check the intermediate results after each step.
###

echo ""
echo "SECOND step: prepare meta-analysis."
# ${SCRIPTS}/metagwastoolkit.prepmeta.sh ${PROJECTDIR}/metagwastoolkit.conf ${PROJECTDIR}/metagwastoolkit.files.list

echo ""
echo "THIRD step: meta-analysis."
# ${SCRIPTS}/metagwastoolkit.meta.sh ${PROJECTDIR}/metagwastoolkit.conf ${PROJECTDIR}/metagwastoolkit.files.list






### BELOW WILL LIKELY BE OBSOLETE AS EVERYTHING CAN BE DONE USING GWASLAB FUNCTIONS ###
# echo ""
# echo "FOURTH step: some intermediate mapping and cleaning of results."
# 
# echo ""
# echo "Matching rsID from 1000G phase 3 (5b) to summary statistics. Quick and dirty method, we accept a few mistakes in the matching."
# 
# echo ""
# echo "> first, count number of variants in meta-analysis results"
# zcat ${PROJECTDIR}/${SUBPROJECTDIRNAME}/META/meta.results.${PROJECTNAME}.1Gp3.EUR.summary.txt.gz | wc -l
# 
# echo ""
# echo "> creating list of variants (only needs to be done once!)"
# echo 'VARIANTID RSID' > ${RESOURCES}/1000Gp3v5_20130502_mvncall_integrated_v5b.only_SNPS_INDELS.EUR.VARIANTID2RSID.txt
# zcat ${RESOURCES}/1000Gp3v5_20130502_mvncall_integrated_v5b.only_SNPS_INDELS.EUR.INFO.txt.gz | awk '{ print $1, $2 }' | tail -n +2 >> ${RESOURCES}/1000Gp3v5_20130502_mvncall_integrated_v5b.only_SNPS_INDELS.EUR.VARIANTID2RSID.txt
# ### zcat ${RESOURCES}/1000Gp3v5_EUR/1kGp3v5b.ref.allfreq.noCN_noINS_noSS_noESV_noMultiAllelic.sumstats.txt.gz | awk '{ if($7<0.5) { print "chr"$1":"$2":"$5"_"$4, $3} else { print "chr"$1":"$2":"$4"_"$5, $3 } }' | tail -n +2 >> ${RESOURCES}/1000Gp3v5_20130502_mvncall_integrated_v5b.only_SNPS_INDELS.EUR.VARIANTID2RSID.txt
# gzip -fv ${RESOURCES}/1000Gp3v5_20130502_mvncall_integrated_v5b.only_SNPS_INDELS.EUR.VARIANTID2RSID.txt
# 
# echo ""
# echo "> counting list of variants"
# zcat ${RESOURCES}/1000Gp3v5_20130502_mvncall_integrated_v5b.only_SNPS_INDELS.EUR.VARIANTID2RSID.txt.gz | wc -l
# 
# echo ""
# echo "> merging list of variants with summary statistics"
# perl ${SCRIPTS}/mergeTables.pl \
# --file1 ${PROJECTDIR}/${SUBPROJECTDIRNAME}/META/meta.results.${PROJECTNAME}.1Gp3.EUR.summary.txt.gz \
# --file2 ${RESOURCES}/1000Gp3v5_20130502_mvncall_integrated_v5b.only_SNPS_INDELS.EUR.VARIANTID2RSID.txt.gz \
# --index VARIANTID --format GZIPB > ${PROJECTDIR}/${SUBPROJECTDIRNAME}/META/foo
# 
# echo ""
# echo "> filtering non-matched variants"
# cat ${PROJECTDIR}/${SUBPROJECTDIRNAME}/META/foo | awk ' $3 != "NA" ' > ${PROJECTDIR}/${SUBPROJECTDIRNAME}/META/meta.results.${PROJECTNAME}.1Gp3.EUR.summary.rsids.txt
# 
# echo ""
# echo "> removing intermediate file"
# rm -v ${PROJECTDIR}/${SUBPROJECTDIRNAME}/META/foo
# 
# echo ""
# echo "> getting head of merged results"
# head ${PROJECTDIR}/${SUBPROJECTDIRNAME}/META/meta.results.${PROJECTNAME}.1Gp3.EUR.summary.rsids.txt
# 
# echo ""
# echo "> counting number of merge variants in results"
# cat ${PROJECTDIR}/${SUBPROJECTDIRNAME}/META/meta.results.${PROJECTNAME}.1Gp3.EUR.summary.rsids.txt | wc -l
# 
# echo ""
# echo "> gzipping merged data"
# gzip -vf ${PROJECTDIR}/${SUBPROJECTDIRNAME}/META/meta.results.${PROJECTNAME}.1Gp3.EUR.summary.rsids.txt
# 
# echo ""
# echo "Filtering results to:"
# echo "> move original data to a new file, and rename the rsID-mapped results"
# echo "> include only relevant columns"
# echo "> include only variants with no caveats"

### already done !
# mv -v ${PROJECTDIR}/${SUBPROJECTDIRNAME}/META/meta.results.${PROJECTNAME}.1Gp3.EUR.summary.txt.gz ${PROJECTDIR}/${SUBPROJECTDIRNAME}/META/meta.results.${PROJECTNAME}.1Gp3.EUR.summary.originalID.txt.gz 

### Determining the type of data to parse depending on the chosen metamodel
if [[ ${METAMODEL} = "FIXED" ]]; then
	BETA="BETA_FIXED"
	SE="SE_FIXED"
	BETA_LOWER="BETA_LOWER_FIXED"
	BETA_UPPER="BETA_UPPER_FIXED"
	ZSCORE="Z_FIXED"
	PVALUE="P_FIXED"
elif [[ ${METAMODEL} = "SQRTN" ]]; then
	BETA="BETA_FIXED"
	SE="SE_FIXED"
	BETA_LOWER="BETA_LOWER_FIXED"
	BETA_UPPER="BETA_UPPER_FIXED"
	ZSCORE="Z_SQRTN"
	PVALUE="P_SQRTN"
elif [[ ${METAMODEL} = "RANDOM" ]]; then
	BETA="BETA_RANDOM"
	SE="SE_RANDOM"
	BETA_LOWER="BETA_LOWER_RANDOM"
	BETA_UPPER="BETA_UPPER_RANDOM"
	ZSCORE="Z_RANDOM"
	PVALUE="P_RANDOM"
else
	echo "Incorrect or no METAMODEL variable specified, defaulting to a FIXED model."
	BETA="BETA_FIXED"
	SE="SE_FIXED"
	BETA_LOWER="BETA_LOWER_FIXED"
	BETA_UPPER="BETA_UPPER_FIXED"
	ZSCORE="Z_FIXED"
	PVALUE="P_FIXED"
fi

# zcat ${PROJECTDIR}/${SUBPROJECTDIRNAME}/META/meta.results.${PROJECTNAME}.1Gp3.EUR.summary.rsids.txt.gz | \
# perl ${SCRIPTS}/parseTable.pl --col RSID,VARIANTID,CHR,POS,CODEDALLELE,OTHERALLELE,CAF,N_EFF,${BETA},${SE},${BETA_LOWER},${BETA_UPPER},${ZSCORE},${PVALUE},COCHRANS_Q,P_COCHRANS_Q,I_SQUARED,TAU_SQUARED,DF,DIRECTIONS,GENES_250KB,NEAREST_GENE,VARIANT_FUNCTION,CAVEAT > ${PROJECTDIR}/${SUBPROJECTDIRNAME}/META/meta.results.${PROJECTNAME}.1Gp3.EUR.summary.rsid.filter.txt
# 
# gzip -vf ${PROJECTDIR}/${SUBPROJECTDIRNAME}/META/meta.results.${PROJECTNAME}.1Gp3.EUR.summary.rsid.filter.txt
# 
# zcat ${PROJECTDIR}/${SUBPROJECTDIRNAME}/META/meta.results.${PROJECTNAME}.1Gp3.EUR.summary.rsid.filter.txt.gz | awk '$1=="RSID" || $24!="NA"' > ${PROJECTDIR}/${SUBPROJECTDIRNAME}/META/meta.results.${PROJECTNAME}.1Gp3.EUR.summary.rsid.filter.badVariants.txt
# cat ${PROJECTDIR}/${SUBPROJECTDIRNAME}/META/meta.results.${PROJECTNAME}.1Gp3.EUR.summary.rsid.filter.badVariants.txt | wc -l
# 
# zcat ${PROJECTDIR}/${SUBPROJECTDIRNAME}/META/meta.results.${PROJECTNAME}.1Gp3.EUR.summary.rsid.filter.txt.gz | awk '$1=="RSID" || $24=="NA"' > ${PROJECTDIR}/${SUBPROJECTDIRNAME}/META/meta.results.${PROJECTNAME}.1Gp3.EUR.summary.filtered_incl_non_rsID.txt
# cat ${PROJECTDIR}/${SUBPROJECTDIRNAME}/META/meta.results.${PROJECTNAME}.1Gp3.EUR.summary.filtered_incl_non_rsID.txt | wc -l 
#
# echo "Filtering on DF>0, meaning only 1 cohort was included in the meta-result; we require a minimum of 2."
# cat ${PROJECTDIR}/${SUBPROJECTDIRNAME}/META/meta.results.${PROJECTNAME}.1Gp3.EUR.summary.filtered_incl_non_rsID.txt | head -1 > ${PROJECTDIR}/${SUBPROJECTDIRNAME}/META/meta.results.${PROJECTNAME}.1Gp3.EUR.summary.txt
# cat ${PROJECTDIR}/${SUBPROJECTDIRNAME}/META/meta.results.${PROJECTNAME}.1Gp3.EUR.summary.filtered_incl_non_rsID.txt | awk '$19 > 0' | grep "rs" >> ${PROJECTDIR}/${SUBPROJECTDIRNAME}/META/meta.results.${PROJECTNAME}.1Gp3.EUR.summary.txt
# cat ${PROJECTDIR}/${SUBPROJECTDIRNAME}/META/meta.results.${PROJECTNAME}.1Gp3.EUR.summary.txt | wc -l
# 
# gzip -vf ${PROJECTDIR}/${SUBPROJECTDIRNAME}/META/meta.results.${PROJECTNAME}.1Gp3.EUR.summary.rsid.filter.badVariants.txt
# gzip -vf ${PROJECTDIR}/${SUBPROJECTDIRNAME}/META/meta.results.${PROJECTNAME}.1Gp3.EUR.summary.filtered_incl_non_rsID.txt
# gzip -vf ${PROJECTDIR}/${SUBPROJECTDIRNAME}/META/meta.results.${PROJECTNAME}.1Gp3.EUR.summary.txt
# 
# echo ""
# echo "FIFTH step: result clumping."
# ${SCRIPTS}/metagwastoolkit.clump.sh ${PROJECTDIR}/metagwastoolkit.conf ${PROJECTDIR}/metagwastoolkit.files.list 
# 
# echo ""
# echo "SIXTH step: prepare and perform downstream analyses."
# Note that rsIDs are expected!
# ${SCRIPTS}/metagwastoolkit.downstream.sh ${PROJECTDIR}/metagwastoolkit.conf ${PROJECTDIR}/metagwastoolkit.files.list
# 
# echo ""
# echo "Converting filtered meta-analysis summary results using [gwas2cojo]."

# ${PYTHON3} /hpc/local/CentOS7/dhl_ec/software/gwas2cojo/gwas2cojo.py \
# --gen:build hg19 \
# --gen ${RESOURCES}/1000Gp3v5_EUR/1kGp3v5b.ref.allfreq.noCN_noINS_noSS_noESV_noMultiAllelic.sumstats.txt.gz \
# --gwas ${PROJECTDIR}/${SUBPROJECTDIRNAME}/META/meta.results.${PROJECTNAME}.1Gp3.EUR.summary.txt.gz \
# --gen:ident ID --gen:chr CHROM --gen:bp POS --gen:other REF --gen:effect ALT --gen:eaf EUR_AF \
# --gwas:chr CHR --gwas:bp POS --gwas:other OTHERALLELE --gwas:effect CODEDALLELE \
# --gwas:beta ${BETA} --gwas:se ${SE} --gwas:p ${PVALUE} \
# --gwas:freq CAF --gwas:n N_EFF --gwas:build hg19 \
# --fmid 0 --fclose 0 \
# --out ${PROJECTDIR}/${SUBPROJECTDIRNAME}/META/meta.results.${PROJECTNAME}.1Gp3.EUR.summary.gwas2cojo.txt \
# --report ${PROJECTDIR}/${SUBPROJECTDIRNAME}/META/meta.results.${PROJECTNAME}.1Gp3.EUR.summary.gwas2cojo.report
# 
# ${PYTHON3} /hpc/local/CentOS7/dhl_ec/software/gwas2cojo/gwas2cojo-verify.py ${PROJECTDIR}/${SUBPROJECTDIRNAME}/META/meta.results.${PROJECTNAME}.1Gp3.EUR.summary.gwas2cojo.report
# 
# gzip -vf ${PROJECTDIR}/${SUBPROJECTDIRNAME}/META/meta.results.${PROJECTNAME}.1Gp3.EUR.summary.gwas2cojo.*

# Clean the Dependencies files
# TODO
