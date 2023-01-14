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
METAGWASTOOLKIT="/hpc/local/CentOS7/dhl_ec/software/MetaGWASToolKit"
RESOURCES="${METAGWASTOOLKIT}/RESOURCES"
SCRIPTS="${METAGWASTOOLKIT}/SCRIPTS"
PROJECTDIR="${METAGWASTOOLKIT}/EXAMPLE"
PYTHON3="/hpc/local/CentOS7/common/lang/python/3.6.1/bin/python3"

echo ""
echo "                 PERFORM META-ANALYSIS OF GENOME-WIDE ASSOCIATION STUDIES"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

### Note: It is advisable to perform the first two steps, first. Upon completion, you should inspect
###       the plots produced to decided whether cohorts should be carried forward to meta-analysis
###       or whether quality control settings should be edited.
###

echo ""
echo "FIRST step: prepare GWAS."
${SCRIPTS}/metagwastoolkit.prep.sh ${PROJECTDIR}/metagwastoolkit.conf ${PROJECTDIR}/metagwastoolkit.files.list

### Note: After visual inspection of diagnostic plots per cohort (see note above), the next
###       steps can be uncommented and executed one-by-one. It is advisable to always 
###		check the intermediate results after each step.
###

# echo ""
# echo "SECOND step: prepare meta-analysis."
# ${SCRIPTS}/metagwastoolkit.prepmeta.sh ${PROJECTDIR}/metagwastoolkit.conf ${PROJECTDIR}/metagwastoolkit.files.list
 
# echo ""
# echo "THIRD step: meta-analysis."
# ${SCRIPTS}/metagwastoolkit.meta.sh ${PROJECTDIR}/metagwastoolkit.conf ${PROJECTDIR}/metagwastoolkit.files.list

# echo ""
# echo "Converting raw meta-analysis summary results using [gwas2cojo]."
# 
# ${PYTHON3} /hpc/local/CentOS7/dhl_ec/software/gwas2cojo/gwas2cojo.py \
# --gen:build hg19 \
# --gen ${RESOURCES}/1000Gp3v5_EUR/1kGp3.ref.1maf.nonbia.sumstats.gz \
# --gwas ${PROJECTDIR}/males/META/meta.results.EXAMPLE_MALES.1Gp3.EUR.summary.txt.gz \
# --gen:ident ID --gen:chr CHROM --gen:bp POS --gen:other REF --gen:effect ALT --gen:eaf EUR_AF \
# --gwas:chr CHR --gwas:bp POS --gwas:other OTHERALLELE --gwas:effect CODEDALLELE \
# --gwas:beta BETA_FIXED --gwas:se SE_FIXED --gwas:p P_FIXED \
# --gwas:freq CAF --gwas:n N_EFF --gwas:build hg19 \
# --out ${PROJECTDIR}/males/META/meta.results.EXAMPLE_MALES.1Gp3.EUR.summary.gwas2cojo.txt \
# --report ${PROJECTDIR}/males/META/meta.results.EXAMPLE_MALES.1Gp3.EUR.summary.gwas2cojo.report

# echo ""
# echo "FOURTH step: result clumping."
# ${SCRIPTS}/metagwastoolkit.clump.sh ${PROJECTDIR}/metagwastoolkit.conf ${PROJECTDIR}/metagwastoolkit.files.list 

# echo ""
# echo "FIFTH step: prepare and perform downstream analyses."
# ${SCRIPTS}/metagwastoolkit.downstream.sh ${PROJECTDIR}/metagwastoolkit.conf ${PROJECTDIR}/metagwastoolkit.files.list

# Clean the Dependancies files
# TODO
