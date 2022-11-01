#!/bin/bash
#
#################################################################################################
### PARAMETERS SLURM
#SBATCH --job-name=resource.creator                                  # the name of the job
#SBATCH -o /hpc/local/CentOS7/dhl_ec/software/MetaGWASToolKit/resource.creator.log 	          # the log file of this job
#SBATCH --error /hpc/local/CentOS7/dhl_ec/software/MetaGWASToolKit/resource.creator.errors    # the error file of this job
#SBATCH --time=03:00:00                                             # the amount of time the job will take: -t [min] OR -t [days-hh:mm:ss]
#SBATCH --mem=8G                                                    # the amount of memory you think the script will consume, found on: https://wiki.bioinformatics.umcutrecht.nl/bin/view/HPC/SlurmScheduler
#SBATCH --gres=tmpspace:64G                                         # the amount of temporary diskspace per node
#SBATCH --mail-user=s.w.vanderlaan-2@umcutrecht.nl                       # where should be mailed to?
#SBATCH --mail-type=FAIL                                            # when do you want to receive a mail from your job?  Valid type values are NONE, BEGIN, END, FAIL, REQUEUE
                                                                    # or ALL (equivalent to BEGIN, END, FAIL, INVALID_DEPEND, REQUEUE, and STAGE_OUT), 
                                                                    # Multiple type values may be specified in a comma separated list. 
####    Note:   You do not have to specify workdir: 
####            'Current working directory is the calling process working directory unless the --chdir argument is passed, which will override the current working directory.'
####            TODO: select the type of interpreter you'd like to use
####            TODO: Find out whether this job should dependant on other scripts (##SBATCH --depend=[state:job_id])
####
#################################################################################################
#
# It is good practice to properly name and annotate your script for future reference for
# yourself and others. Trust me, you'll forget why and how you made this!!!

### Creating display functions
### Setting colouring
NONE='\033[00m'
OPAQUE='\033[2m'
FLASHING='\033[5m'
BOLD='\033[1m'
ITALIC='\033[3m'
UNDERLINE='\033[4m'
STRIKETHROUGH='\033[9m'

RED='\033[01;31m'
GREEN='\033[01;32m'
YELLOW='\033[01;33m'
PURPLE='\033[01;35m'
CYAN='\033[01;36m'
WHITE='\033[01;37m'

function echobold { #'echobold' is the function name
    echo -e "${BOLD}${1}${NONE}" # this is whatever the function needs to execute, note ${1} is the text for echo
}
function echoitalic { 
    echo -e "${ITALIC}${1}${NONE}" 
}
function echonooption { 
    echo -e "${OPAQUE}${RED}${1}${NONE}"
}
function echoerrorflash { 
    echo -e "${RED}${BOLD}${FLASHING}${1}${NONE}" 
}
function echoerror { 
    echo -e "${RED}${1}${NONE}"
}
# errors no option
function echoerrornooption { 
    echo -e "${YELLOW}${1}${NONE}"
}
function echoerrorflashnooption { 
    echo -e "${YELLOW}${BOLD}${FLASHING}${1}${NONE}"
}

script_copyright_message() {
	echo ""
	THISYEAR=$(date +'%Y')
	echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echo "+ The MIT License (MIT)                                                                                 +"
	echo "+ Copyright (c) 2015-${THISYEAR} Sander W. van der Laan                                                        +"
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
}

echobold "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echobold "                                      MetaGWASToolKit: Resource Creator"
echobold ""
echobold "* Version:      v1.1.3"
echobold ""
echobold "* Last update:  2022-11-01"
echobold "* Written by:   Sander W. van der Laan | s.w.vanderlaan@gmail.com."
echobold "* Testers:      Jessica van Setten; M.M.M. Baksi."
echobold "* Description:  Downloads, parses and creates the necessary resources for MetaGWASToolKit."
echobold ""
echobold "* REQUIRED: "
echobold "  - A high-performance computer cluster with a qsub system"
echobold "  - R v3.2+, Python 3.7+, Perl."
echobold "  - Required Python 3.7+ modules: [pandas], [scipy], [numpy]."
echobold "  - Required Perl modules: [YAML], [Statistics::Distributions], [Getopt::Long]."
echobold "  - Note: it will also work on a Mac OS X system with R and Python installed."
### ADD-IN: function to check requirements...
### This might be a viable option! https://gist.github.com/JamieMason/4761049
echobold ""
echobold "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
##########################################################################################
### SET THE SCENE FOR THE SCRIPT
##########################################################################################

	# Where GWASToolKit resides
	SOFTWARE="/hpc/local/CentOS7/dhl_ec/software"
	QCTOOL="${SOFTWARE}/qctool_v1.5"
	METAGWASTOOLKIT="${SOFTWARE}/MetaGWASToolKit"
	SCRIPTS=${METAGWASTOOLKIT}/SCRIPTS
	RESOURCES=${METAGWASTOOLKIT}/RESOURCES
# 	
# 	### THIS SHOULD BE A COMMAND LINE OPTION -- via a configuration file, but some how this screws up 'awking'
# 	### in the script below (lines 145, 232, 243)
# 	### "1Gp1          PAN, EUR, AFR, AMR, ASN\n";
# 	### "[1Gp3          PAN, EUR, AFR, AMR, EAS, SAS]\n";
# 	### "[GoNL4         NL] - not available\n";
# 	### "[GoNL5         NL] - not available\n";
# 	### "[1Gp3GONL5     PAN]\n";

	POPULATION="EUR"
	POPULATION1Gp3="EUR"
	POPULATION1Gp3GONL5="PAN"
	DBSNPVERSION="151"
	
	echobold "#########################################################################################################"
	echobold "### DOWNLOADING dbSNP GRCh37 v147 hg19 Feb2009"
	echobold "#########################################################################################################"
	echobold "#"
	echo ""
	echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echo "Downloading and parsing 'dbSNP GRCh37 v147 hg19 Feb2009'. "
	echo ""
	echo "* downloading [ dbSNP ] ..."
	wget http://hgdownload.soe.ucsc.edu/goldenPath/hg19/database/snp${DBSNPVERSION}.txt.gz -O ${RESOURCES}/dbSNP${DBSNPVERSION}_GRCh37_hg19_Feb2009.allVariants.txt.gz
	### HEAD
	### zcat dbSNP${DBSNPVERSION}_GRCh37_hg19_Feb2009.allVariants.txt.gz | head
	### 585	chr1	10019	10020	rs775809821	0	+	A	A	-/A	genomic	deletion	unknown	0	0	near-gene-5	exact	1		1	SSMP,	0
	### 585	chr1	10055	10055	rs768019142	0	+	-	-	-/A	genomic	insertion	unknown	0	0	near-gene-5	between	1		1	SSMP,	0
	### 585	chr1	10107	10108	rs62651026	0	+	C	C	C/T	genomic	single	unknown	0	0	near-gene-5	exact	1		1	BCMHGSC_JDW,	0
	
	echo "* parsing [ dbSNP ] ..."
	echo "Chr ChrStart ChrEnd VariantID Strand Alleles VariantClass VariantFunction" > ${RESOURCES}/dbSNP${DBSNPVERSION}_GRCh37_hg19_Feb2009.txt
	zcat ${RESOURCES}/dbSNP${DBSNPVERSION}_GRCh37_hg19_Feb2009.allVariants.txt.gz | awk '{ print $2, $3, $4, $5, $7, $10, $12, $16 }' >> ${RESOURCES}/dbSNP${DBSNPVERSION}_GRCh37_hg19_Feb2009.txt
	cat ${RESOURCES}/dbSNP${DBSNPVERSION}_GRCh37_hg19_Feb2009.txt | awk '{ print $4, $8 }' > ${RESOURCES}/dbSNP${DBSNPVERSION}_GRCh37_hg19_Feb2009.attrib.txt
	
	echo "gzip -fv ${RESOURCES}/dbSNP${DBSNPVERSION}_GRCh37_hg19_Feb2009.txt " > ${RESOURCES}/resource.dbSNP.parser.sh
	echo "rm -fv ${RESOURCES}/dbSNP${DBSNPVERSION}_GRCh37_hg19_Feb2009.allVariants.txt.gz " >> ${RESOURCES}/resource.dbSNP.parser.sh
	echo "gzip -vf ${RESOURCES}/dbSNP${DBSNPVERSION}_GRCh37_hg19_Feb2009.attrib.txt " >> ${RESOURCES}/resource.dbSNP.parser.sh
	qsub -S /bin/bash -N dbSNPparser -o ${RESOURCES}/resource.dbSNP.parser.log -e ${RESOURCES}/resource.dbSNP.parser.errors -l h_vmem=8G -l h_rt=01:00:00 -wd ${RESOURCES} ${RESOURCES}/resource.dbSNP.parser.sh

	echo ""	
	echo "All done submitting jobs for downloading and parsing dbSNP reference! 🖖"
	echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

	# Note: we exclude this option, as no-one is using this anymore
	# echo ""
	# echobold "#########################################################################################################"
	# echobold "### *** WARNING *** NOT IMPLEMENTED YET DOWNLOADING HapMap 2 reference b36 hg18"
	# echobold "#########################################################################################################"
	# echobold "#"
	# echo ""
	# echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	# echo "Downloading and parsing 'HapMap 2 b36 hg18'. "
	# 
	# echo ""	
	# echo "All done submitting jobs for downloading and parsing HapMap 2 reference! 🖖"
	# echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

	echo ""
	echobold "#########################################################################################################"
	echobold "### DOWNLOADING 1000G phase 1, phase 3, and phase 3 + GoNL5"
	echobold "#########################################################################################################"
	echobold "#"
	echo ""
	echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echo "Downloading and parsing '1000G phase 1 and phase 3'. "

	echo "* downloading [ 1000G phase 1 ] ..."
# 	echo "wget ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/phase1/analysis_results/integrated_call_sets/ALL.wgs.integrated_phase1_v3.20101123.snps_indels_sv.sites.vcf.gz -O ${RESOURCES}/ALL.wgs.integrated_phase1_v3.20101123.snps_indels_sv.sites.vcf.gz " > ${RESOURCES}/resource.1kG1.downloader.sh
# 	qsub -S /bin/bash -N ThousandGp1downloader -hold_jid dbSNPparser -o ${RESOURCES}/resource.1kG1.downloader.log -e ${RESOURCES}/resource.1kG1.downloader.errors -l h_vmem=8G -l h_rt=00:45:00 -wd ${RESOURCES} ${RESOURCES}/resource.1kG1.downloader.sh
# 	echo "* downloading [ 1000G phase 3 ] ..."
# 	echo "wget ftp://ftp.ncbi.nih.gov/1000genomes/ftp/release/20130502/ALL.wgs.phase3_shapeit2_mvncall_integrated_v5b.20130502.sites.vcf.gz -O ${RESOURCES}/ALL.wgs.phase3_shapeit2_mvncall_integrated_v5b.20130502.sites.vcf.gz " > ${RESOURCES}/resource.1kG3.downloader.sh
# 	qsub -S /bin/bash -N ThousandGp3downloader -hold_jid dbSNPparser -o ${RESOURCES}/resource.1kG3.downloader.log -e ${RESOURCES}/resource.1kG3.downloader.errors -l h_vmem=8G -l h_rt=00:45:00 -wd ${RESOURCES} ${RESOURCES}/resource.1kG3.downloader.sh
	
# 	echo "* parsing 1000G phase 1."
# 	echo "perl ${SCRIPTS}/resource.VCFparser.pl --file ${RESOURCES}/ALL.wgs.integrated_phase1_v3.20101123.snps_indels_sv.sites.vcf.gz --ref 1Gp1 --pop ${POPULATION} --out ${RESOURCES}/1000Gp1v3_20101123_integrated_ALL_snv_indels_sv " > ${RESOURCES}/resource.VCFparser.1kGp1.sh
# 	echo "gzip -fv ${RESOURCES}/1000Gp1v3_20101123_integrated_ALL_snv_indels_sv.${POPULATION}.INFO.txt " >> ${RESOURCES}/resource.VCFparser.1kGp1.sh
# 	echo "gzip -fv ${RESOURCES}/1000Gp1v3_20101123_integrated_ALL_snv_indels_sv.${POPULATION}.FREQ.txt " >> ${RESOURCES}/resource.VCFparser.1kGp1.sh
# 	echo "gzip -fv ${RESOURCES}/1000Gp1v3_20101123_integrated_ALL_snv_indels_sv.${POPULATION}.FUNC.txt " >> ${RESOURCES}/resource.VCFparser.1kGp1.sh
# 	echo "rm -fv ${RESOURCES}/ALL.wgs.integrated_phase1_v3.20101123.snps_indels_sv.sites.vcf.gz " >> ${RESOURCES}/resource.VCFparser.1kGp1.sh
# 	qsub -S /bin/bash -N VCFparser1Gp1 -hold_jid ThousandGp1downloader -o ${RESOURCES}/resource.VCFparser.1kGp1.log -e ${RESOURCES}/resource.VCFparser.1kGp1.errors -l h_vmem=16G -l h_rt=03:00:00 -wd ${RESOURCES} ${RESOURCES}/resource.VCFparser.1kGp1.sh
	
	# echo "* parsing 1000G phase 3."
	# echo "perl ${SCRIPTS}/resource.VCFparser.pl --file ${RESOURCES}/ALL.wgs.phase3_shapeit2_mvncall_integrated_v5b.20130502.sites.vcf.gz --ref 1Gp3 --pop ${POPULATION1Gp3} --out ${RESOURCES}/1000Gp3v5_20130502_integrated_ALL_snv_indels_sv " > ${RESOURCES}/resource.VCFparser.1kGp3.sh
	# echo "gzip -fv ${RESOURCES}/1000Gp3v5_20130502_integrated_ALL_snv_indels_sv.${POPULATION1Gp3}.INFO.txt " >> ${RESOURCES}/resource.VCFparser.1kGp3.sh
	# echo "gzip -fv ${RESOURCES}/1000Gp3v5_20130502_integrated_ALL_snv_indels_sv.${POPULATION1Gp3}.FREQ.txt " >> ${RESOURCES}/resource.VCFparser.1kGp3.sh
	# echo "gzip -fv ${RESOURCES}/1000Gp3v5_20130502_integrated_ALL_snv_indels_sv.${POPULATION1Gp3}.FUNC.txt " >> ${RESOURCES}/resource.VCFparser.1kGp3.sh
### 	echo "rm -fv ${RESOURCES}/ALL.wgs.phase3_shapeit2_mvncall_integrated_v5b.20130502.sites.vcf.gz " >> ${RESOURCES}/resource.VCFparser.1kGp3.sh
	# qsub -S /bin/bash -N VCFparser1Gp3 -hold_jid ThousandGp3downloader -o ${RESOURCES}/resource.VCFparser.1kGp3.log -e ${RESOURCES}/resource.VCFparser.1kGp3.errors -l h_vmem=16G -l h_rt=03:00:00 -wd ${RESOURCES} ${RESOURCES}/resource.VCFparser.1kGp3.sh
	# echo ""
		
# 	echo "* updating 1000G phase 1."
# 	echo "perl ${SCRIPTS}/mergeTables.pl --file1 ${RESOURCES}/dbSNP147_GRCh37_hg19_Feb2009.attrib.txt.gz --file2 ${RESOURCES}/1000Gp1v3_20101123_integrated_ALL_snv_indels_sv.${POPULATION}.FUNC.txt.gz --index VariantID --format GZIPB --replace > ${RESOURCES}/1000Gp1v3_20101123_integrated_ALL_snv_indels_sv.${POPULATION}.FUNC.txt " > ${RESOURCES}/resource.VCFplusdbSNP.1kGp1.sh
# 	echo "gzip -fv ${RESOURCES}/1000Gp1v3_20101123_integrated_ALL_snv_indels_sv.${POPULATION}.FUNC.txt " >> ${RESOURCES}/resource.VCFplusdbSNP.1kGp1.sh
# 	qsub -S /bin/bash -N VCF1Gp1plusdbSNP -hold_jid VCFparser1Gp1 -o ${RESOURCES}/resource.VCFplusdbSNP.1kGp1.log -e ${RESOURCES}/resource.VCFplusdbSNP.1kGp1.errors -l h_vmem=128G -l h_rt=04:00:00 -wd ${RESOURCES} ${RESOURCES}/resource.VCFplusdbSNP.1kGp1.sh

	# echo "* updating 1000G phase 3."
	# echo "perl ${SCRIPTS}/mergeTables.pl --file1 ${RESOURCES}/dbSNP147_GRCh37_hg19_Feb2009.attrib.txt.gz --file2 ${RESOURCES}/1000Gp3v5_20130502_integrated_ALL_snv_indels_sv.${POPULATION1Gp3}.FUNC.txt.gz --index VariantID --format GZIPB --replace > ${RESOURCES}/1000Gp3v5_20130502_integrated_ALL_snv_indels_sv.${POPULATION1Gp3}.FUNC.txt " > ${RESOURCES}/resource.VCFplusdbSNP.1kGp3.sh
	# echo "gzip -fv ${RESOURCES}/1000Gp3v5_20130502_integrated_ALL_snv_indels_sv.${POPULATION1Gp3}.FUNC.txt " >> ${RESOURCES}/resource.VCFplusdbSNP.1kGp3.sh
	# qsub -S /bin/bash -N VCF1Gp3plusdbSNP -hold_jid VCFparser1Gp3 -o ${RESOURCES}/resource.VCFplusdbSNP.1kGp3.log -e ${RESOURCES}/resource.VCFplusdbSNP.1kGp3.errors -l h_vmem=128G -l h_rt=04:00:00 -wd ${RESOURCES} ${RESOURCES}/resource.VCFplusdbSNP.1kGp3.sh

# 	echo "* parsing 1000G phase 3 + GoNL5."
# 	echo "  - generating the necessary per-variant descriptive statistics."
# 
# 	for CHR in $(seq 1 22); do
# 		echo "* Processing chromosome [ ${CHR} ]."
# 		echo "${QCTOOL} -g ${RESOURCES}/1000Gp3v5_GoNL5/1000Gp3v5_GoNL5_chr${CHR}.vcf.gz -snp-stats ${RESOURCES}/1000Gp3v5_GoNL5/1000Gp3v5_GoNL5_chr${CHR}.stats " > ${RESOURCES}/1000Gp3v5_GoNL5/resource.VCFSTATS.1Gp3GONL5.chr${CHR}.sh
# 		qsub -S /bin/bash -N VCFSTATS1Gp3GONL5 -hold_jid ThousandGp3GONL5downloader -o ${RESOURCES}/1000Gp3v5_GoNL5/resource.VCFSTATS.1Gp3GONL5.chr${CHR}.log -e ${RESOURCES}/1000Gp3v5_GoNL5/resource.VCFSTATS.1Gp3GONL5.chr${CHR}.errors -l h_vmem=8G -l h_rt=01:00:00 -wd ${RESOURCES} ${RESOURCES}/1000Gp3v5_GoNL5/resource.VCFSTATS.1Gp3GONL5.chr${CHR}.sh
# 	done
# 		
# 	###	EXAMPLE HEAD OF STATS files
# 	###	SNPID	RSID	chromosome	position	A_allele	B_allele	minor_allele	major_allele	AA	AB	BB	AA_calls	AB_calls	BB_calls	MAF	HWE	missing	missing_calls	information
# 	###	1:10177:A:AC	1:10177:A:AC	NA	10177	A	AC	AC	A	885	1725	393	885	1725	393	0.41808	22.523	0	0	1
# 	###	1:10235:T:TA	1:10235:T:TA	NA	10235	T	TA	TA	T	2997	6	0	2997	6	0	0.000999	-0	0	0	1
# 	###	rs145072688:10352:T:TA	rs145072688:10352:T:TA	NA	10352	T	TA	TA	T	556	2278	169	556	2278	169	0.43556	209.87	0	0	1
# 	###	1:10505:A:T	1:10505:A:T	NA	10505	A	T	T	A	3002	1	0	3002	1	0	0.0001665	-0	0	0	1
# 	###	1:10506:C:G	1:10506:C:G	NA	10506	C	G	G	C	3002	1	0	3002	1	0	0.0001665	-0	0	0	1
# 	###	1:10511:G:A	1:10511:G:A	NA	10511	G	A	A	G	3001	2	0	3001	2	0	0.000333	-0	0	0	1
# 	###	rs62636508	rs62636508	NA	10519	G	C	C	G	2976	27	0	2976	27	0	0.0044955	4.8216e-17	0	0	1
# 	###	chr1:10539	chr1:10539	NA	10539	C	A	A	C	2998	5	0	2998	5	0	0.0008325	-0	0	0	1
# 	###	1:10542:C:T	1:10542:C:T	NA	10542	C	T	T	C	3002	1	0	3002	1	0	0.0001665	-0	0	0	1
# 
# 	echo "  - concatenating per-variant descriptive statistics."
# 	echo "#CHROM POS ID A_Allele B_Allele MinorAllele MajorAllele MAF" > ${RESOURCES}/1000Gp3v5_GoNL5/1000Gp3v5_GoNL5.stats.txt
# 	for CHR in $(seq 1 22); do
# 		echo "* Processing chromosome [ ${CHR} ]."
# 		cat ${RESOURCES}/1000Gp3v5_GoNL5/1000Gp3v5_GoNL5_chr${CHR}.stats | awk '{ print '$CHR', $4, $2, $5, $6, $7, $8, $15 }' | tail -n +2 >> ${RESOURCES}/1000Gp3v5_GoNL5/1000Gp3v5_GoNL5.stats.auto.txt
# 	done
# 	gzip -v ${RESOURCES}/1000Gp3v5_GoNL5/1000Gp3v5_GoNL5.stats.auto.txt	
# 
# 	echo "  - parsing the new reference dataset."
# 		echo "perl ${SCRIPTS}/resource.VCFparser.pl --file ${RESOURCES}/1000Gp3v5_GoNL5/1000Gp3v5_GoNL5.stats.auto.txt.gz --ref 1Gp3GONL5 --pop ${POPULATION1Gp3GONL5} --out ${RESOURCES}/1000Gp3v5_GoNL5/1000Gp3v5_GoNL5.stats.auto " > ${RESOURCES}/resource.VCFparser.1Gp3GONL5.sh
# 		echo "gzip -fv ${RESOURCES}/1000Gp3v5_GoNL5.stats.auto.${POPULATION1Gp3GONL5}.INFO.txt " >> ${RESOURCES}/resource.VCFparser.1Gp3GONL5.sh
# 		echo "gzip -fv ${RESOURCES}/1000Gp3v5_GoNL5.stats.auto.${POPULATION1Gp3GONL5}.FREQ.txt " >> ${RESOURCES}/resource.VCFparser.1Gp3GONL5.sh
# 		echo "gzip -fv ${RESOURCES}/1000Gp3v5_GoNL5.stats.auto.${POPULATION1Gp3GONL5}.FUNC.txt " >> ${RESOURCES}/resource.VCFparser.1Gp3GONL5.sh
# 		qsub -S /bin/bash -N VCFparser1Gp3GONL5 -hold_jid STATS21Gp3GONL5 -o ${RESOURCES}/resource.VCFparser.1Gp3GONL5.log -e ${RESOURCES}/resource.VCFparser.1Gp3GONL5.errors -l h_vmem=16G -l h_rt=03:00:00 -wd ${RESOURCES} ${RESOURCES}/resource.VCFparser.1Gp3GONL5.sh
# 		echo ""
# 
# 	echo "* updating 1000G phase 3 + GoNL5."
# 	for CHR in $(seq 1 22); do
# 		echo "* Processing chromosome [ ${chr} ]."
# 		echo "perl ${SCRIPTS}/mergeTables.pl --file1 ${RESOURCES}/dbSNP147_GRCh37_hg19_Feb2009.attrib.txt.gz --file2 ${RESOURCES}/1000Gp3v5_GoNL5_chr${CHR}.${POPULATION1Gp3GONL5}.FUNC.txt.gz --index VariantID --format GZIPB --replace > ${RESOURCES}/1000Gp3v5_GoNL5_chr${CHR}.${POPULATION1Gp3GONL5}.FUNC.txt " > ${RESOURCES}/resource.VCFplusdbSNP.1Gp3GONL5.chr${CHR}.sh
# 		echo "gzip -fv ${RESOURCES}/1000Gp3v5_GoNL5_chr${CHR}.${POPULATION1Gp3GONL5}.FUNC.txt " >> ${RESOURCES}/resource.VCFplusdbSNP.1Gp3GONL5.chr${CHR}.sh
# 		qsub -S /bin/bash -N VCF1Gp3GONL5plusdbSNP.chr${CHR} -hold_jid VCFparser1Gp3GONL5.chr${CHR} -o ${RESOURCES}/resource.VCFplusdbSNP.1Gp3GONL5.chr${CHR}.log -e ${RESOURCES}/resource.VCFplusdbSNP.1Gp3GONL5.chr${CHR}.errors -l h_vmem=128G -l h_rt=04:00:00 -wd ${RESOURCES} ${RESOURCES}/resource.VCFplusdbSNP.1Gp3GONL5.chr${CHR}.sh
# 	done

	echo ""
	echobold "#########################################################################################################"
	echobold "### DOWNLOADING GENCODE and refseq gene lists"
	echobold "#########################################################################################################"
	echobold "#"
	echo ""
	echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echo "Downloading and parsing 'GENCODE and refseq gene lists'. "
	
	echo "* downloading [ GENCODE ] ... "
	wget http://hgdownload.soe.ucsc.edu/goldenPath/hg19/database/wgEncodeGencodeBasicV41lift37.txt.gz -O ${RESOURCES}/GENCODE_wgEncodeBasicV41_GRCh37_hg19_Feb2009.txt.gz
	### HEAD
	### 585	ENST00000456328.2	chr1	+	11868	14409	11868	11868	3	11868,12612,13220,	12227,12721,14409,	0	DDX11L1	none	none	-1,-1,-1,
	### 585	ENST00000607096.1	chr1	+	30365	30503	30365	30365	1	30365,	30503,	0	MIR1302-11	none	none	-1,
	### 585	ENST00000417324.1	chr1	-	34553	36081	34553	34553	3	34553,35276,35720,	35174,35481,36081,	0	FAM138A	none	none	-1,-1,-1,
	### 585	ENST00000335137.3	chr1	+	69090	70008	69090	70008	1	69090,	70008,	0	OR4F5	cmpl	cmpl	0,
	
	echo "* parsing [ GENCODE ] ... "
	zcat ${RESOURCES}/GENCODE_wgEncodeBasicV41_GRCh37_hg19_Feb2009.txt.gz | awk '{ print $3, $5, $6, $13 }' | awk -F" " '{gsub(/chr/, "", $1)}1' | awk -F" " '{gsub(/X/, "23", $1)}1' | awk -F" " '{gsub(/Y/, "24", $1)}1' | awk -F" " '{gsub(/M/, "26", $1)}1' > ${RESOURCES}/gencode_v41_GRCh37_hg19_Feb2009.txt 
	mv -v ${RESOURCES}/gencode_v41_GRCh37_hg19_Feb2009.txt foo
	touch ${RESOURCES}/gencode_v41_GRCh37_hg19_Feb2009.txt
	for CHR in $(seq 1 24); do
		cat foo | awk ' $1 == '$CHR' ' >> ${RESOURCES}/gencode_v41_GRCh37_hg19_Feb2009.txt
	done
	
	rm -fv ${RESOURCES}/GENCODE_wgEncodeBasicV41_GRCh37_hg19_Feb2009.txt.gz foo
	
	echo "* downloading [ refseq ] ... "
	wget http://hgdownload.soe.ucsc.edu/goldenPath/hg19/database/refGene.txt.gz -O ${RESOURCES}/refGene_GRCh37_hg19_Feb2009.txt.gz
	### HEAD
	### 585	NR_046018	chr1	+	11873	14409	14409	14409	3	11873,12612,13220,	12227,12721,14409,	0	DDX11L1	unk	unk	-1,-1,-1,
	### 585	NR_024540	chr1	-	14361	29370	29370	29370	11	14361,14969,15795,16606,16857,17232,17605,17914,18267,24737,29320,	14829,15038,15947,16765,17055,17368,17742,18061,18366,24891,29370,	0	WASH7P	unk	unk	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,

	echo "* parsing [ refseq ] ... "
	zcat ${RESOURCES}/refGene_GRCh37_hg19_Feb2009.txt.gz | awk '{ print $3, $5, $6, $13 }' | awk -F" " '{gsub(/chr/, "", $1)}1' | awk -F" " '{gsub(/X/, "23", $1)}1' | awk -F" " '{gsub(/Y/, "24", $1)}1' > ${RESOURCES}/refseq_GRCh37_hg19_Feb2009.txt
	mv -v ${RESOURCES}/refseq_GRCh37_hg19_Feb2009.txt foo
	touch ${RESOURCES}/refseq_GRCh37_hg19_Feb2009.txt
	for CHR in $(seq 1 24); do
		cat foo | awk ' $1 == '$CHR' ' >> ${RESOURCES}/refseq_GRCh37_hg19_Feb2009.txt
	done
	
	rm -fv ${RESOURCES}/refGene_GRCh37_hg19_Feb2009.txt.gz foo 

	echo ""	
	echo "All done submitting jobs for downloading and parsing gene lists! 🖖"
	echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
 
  # NOTE: THE URLs ARE NOT 'LIVE' ANYMORE
  # We retain here the recombination rates from HapMap2 and 1000G phase 1 era.
	# echo ""
	# echobold "#########################################################################################################"
	# echobold "### DOWNLOADING Recombination Maps for b37"
	# echobold "#########################################################################################################"
	# echobold "#"
	# echo ""
	# echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	# echo "Downloading and parsing 'Recombination Maps'. "
	# ### http://www.shapeit.fr/files/genetic_map_b37.tar.gz
	# ### http://hapmap.ncbi.nlm.nih.gov/downloads/recombination/2008-03_rel22_B36/rates
	# # wget http://www.shapeit.fr/files/genetic_map_b37.tar.gz -O ${RESOURCES}/genetic_map_b37.tar.gz
	# # tar -zxvf ${RESOURCES}/genetic_map_b37.tar.gz
	# # mv -v ${RESOURCES}/genetic_map_b37 ${RESOURCES}/RECOMB_RATES 
	# echo ""	
	# echo "All done submitting jobs for downloading and parsing Recombination Maps! 🖖"
	# echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"


  echo ""
  echobold "#########################################################################################################"
  echobold "### DOWNLOADING LD-Hub reference variants"
  echobold "#########################################################################################################"
  echobold "#"
  echo ""
  echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  echo "Downloading and parsing 'LD-Score reference variant list'. "
  wget https://data.broadinstitute.org/alkesgroup/LDSCORE/w_hm3.snplist.bz2 -O ${RESOURCES}/w_hm3.noMHC.snplist.zip
  echo "snpid A1 A2" > ${RESOURCES}/w_hm3.noMHC.snplist.txt
  bunzip2 w_hm3.snplist.bz2 | tail -n +2 >> ${RESOURCES}/w_hm3.noMHC.snplist.txt
  gzip -fv ${RESOURCES}/w_hm3.noMHC.snplist.txt
  echo ""
  echo "All done submitting jobs for downloading and parsing LD-Score reference variant list! 🖖"
  echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

script_copyright_message

