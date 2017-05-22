#!/bin/bash
#
#$ -S /bin/bash 																	# the type of BASH you'd like to use
#$ -N resource.creator  															# the name of this script
#$ -hold_jid some_other_basic_bash_script  											# the current script (basic_bash_script) will hold until some_other_basic_bash_script has finished
#$ -o /hpc/local/CentOS7/dhl_ec/software/MetaGWASToolKit/resource.creator.log  		# the log file of this job
#$ -e /hpc/local/CentOS7/dhl_ec/software/MetaGWASToolKit/resource.creator.errors	# the error file of this job
#$ -l h_rt=04:00:00  																# h_rt=[max time, e.g. 02:02:01] - this is the time you think the script will take
#$ -l h_vmem=8G  																	#  h_vmem=[max. mem, e.g. 45G] - this is the amount of memory you think your script will use
# -l tmpspace=64G  																	# this is the amount of temporary space you think your script will use
#$ -M s.w.vanderlaan-2@umcutrecht.nl  												# you can send yourself emails when the job is done; "-M" and "-m" go hand in hand
#$ -m beas  																		# you can choose: b=begin of job; e=end of job; a=abort of job; s=suspended job; n=no mail is send
#$ -cwd  																			# set the job start to the current directory - so all the things in this script are relative to the current directory!!!
#
# You can use the variables above (indicated by "#$") to set some things for the submission system.
# Another useful tip: you can set a job to run after another has finished. Name the job 
# with "-N SOMENAME" and hold the other job with -hold_jid SOMENAME". 
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
echobold "                                    MetaGWASToolKit: Resource Creator"
echobold ""
echobold "* Version:      v1.0.3"
echobold ""
echobold "* Last update:  2017-05-22"
echobold "* Written by:   Sander W. van der Laan | UMC Utrecht | s.w.vanderlaan-2@umcutrecht.nl."
echobold "* Testers:      Jessica van Setten | UMC Utrecht | j.vansetten@umcutrecht.nl."
echobold "* Description:  Downloads, parses and creates the necessary resources for MetaGWASToolKit."
echobold ""
echobold "* REQUIRED: "
echobold "  - A high-performance computer cluster with a qsub system"
echobold "  - R v3.2+, Python 2.7+, Perl."
echobold "  - Required Python 2.7+ modules: [pandas], [scipy], [numpy]."
echobold "  - Required Perl modules: [YAML], [Statistics::Distributions], [Getopt::Long]."
echobold "  - Note: it will also work on a Mac OS X system with R and Python installed."
### ADD-IN: function to check requirements...
### This might be a viable option! https://gist.github.com/JamieMason/4761049
echobold ""
echobold "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
##########################################################################################
### SET THE SCENE FOR THE SCRIPT
##########################################################################################

	# Where MetaGWASToolKit resides
	SOFTWARE="/hpc/local/CentOS7/dhl_ec/software"
	METAGWASTOOLKIT="${SOFTWARE}/MetaGWASToolKit"
	SCRIPTS=${METAGWASTOOLKIT}/SCRIPTS
	RESOURCES=${METAGWASTOOLKIT}/RESOURCES
	
	### THIS SHOULD BE A COMMAND LINE OPTION -- via a configuration file, but some how this screws up 'awking'
	### in the script below (lines 145, 232, 243)
	### "1Gp1          PAN, EUR, AFR, AMR, ASN\n";
	### "[1Gp3          PAN, EUR, AFR, AMR, EAS, SAS] - not available yet\n";
	### "[GoNL4         NL] - not available yet\n";
	### "[GoNL5         NL] - not available yet\n";
	### "[1Gp3GONL5     PAN] - not available yet\n";
	POPULATION="EUR"
	POPULATION1Gp3="EUR"
	
	echobold "#########################################################################################################"
	echobold "### DOWNLOADING dbSNP GRCh37 v147 hg19 Feb2009"
	echobold "#########################################################################################################"
	echobold "#"
	echo ""
	echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echo "Downloading and parsing 'dbSNP GRCh37 v147 hg19 Feb2009'. "
	echo ""
	echo "* downloading [ dbSNP ] ..."
	wget http://hgdownload.cse.ucsc.edu/goldenPath/hg19/database/snp147.txt.gz -O ${RESOURCES}/dbSNP147_GRCh37_hg19_Feb2009.allVariants.txt.gz
	### HEAD
	### zcat dbSNP147_GRCh37_hg19_Feb2009.allVariants.txt.gz | head
	### 585	chr1	10019	10020	rs775809821	0	+	A	A	-/A	genomic	deletion	unknown	0	0	near-gene-5	exact	1		1	SSMP,	0
	### 585	chr1	10055	10055	rs768019142	0	+	-	-	-/A	genomic	insertion	unknown	0	0	near-gene-5	between	1		1	SSMP,	0
	### 585	chr1	10107	10108	rs62651026	0	+	C	C	C/T	genomic	single	unknown	0	0	near-gene-5	exact	1		1	BCMHGSC_JDW,	0
	
	echo "* parsing [ dbSNP ] ..."
	echo "Chr ChrStart ChrEnd VariantID Strand Alleles VariantClass VariantFunction" > ${RESOURCES}/dbSNP147_GRCh37_hg19_Feb2009.txt
	zcat ${RESOURCES}/dbSNP147_GRCh37_hg19_Feb2009.allVariants.txt.gz | awk '{ print $2, $3, $4, $5, $7, $10, $12, $16 }' >> ${RESOURCES}/dbSNP147_GRCh37_hg19_Feb2009.txt
	cat ${RESOURCES}/dbSNP147_GRCh37_hg19_Feb2009.txt | awk '{ print $4, $8 }' > ${RESOURCES}/dbSNP147_GRCh37_hg19_Feb2009.attrib.txt
	
	echo "gzip -fv ${RESOURCES}/dbSNP147_GRCh37_hg19_Feb2009.txt " > ${RESOURCES}/resource.dbSNP.parser.sh
	echo "rm -fv ${RESOURCES}/dbSNP147_GRCh37_hg19_Feb2009.allVariants.txt.gz " >> ${RESOURCES}/resource.dbSNP.parser.sh
	echo "gzip -vf ${RESOURCES}/dbSNP147_GRCh37_hg19_Feb2009.attrib.txt " >> ${RESOURCES}/resource.dbSNP.parser.sh
	qsub -S /bin/bash -N dbSNPparser -o ${RESOURCES}/resource.dbSNP.parser.log -e ${RESOURCES}/resource.dbSNP.parser.errors -l h_vmem=8G -l h_rt=01:00:00 -wd ${RESOURCES} ${RESOURCES}/resource.dbSNP.parser.sh

	echo ""	
	echo "All done submitting jobs for downloading and parsing dbSNP reference! 🖖"
	echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

	echo ""
	echobold "#########################################################################################################"
	echobold "### *** WARNING *** NOT IMPLEMENTED YET DOWNLOADING HapMap 2 reference b36 hg18"
	echobold "#########################################################################################################"
	echobold "#"
	echo ""
	echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echo "Downloading and parsing 'HapMap 2 b36 hg18'. "

	echo ""	
	echo "All done submitting jobs for downloading and parsing HapMap 2 reference! 🖖"
	echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

	echo ""
	echobold "#########################################################################################################"
	echobold "### DOWNLOADING 1000G phase 1 and phase 3"
	echobold "#########################################################################################################"
	echobold "#"
	echo ""
	echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echo "Downloading and parsing '1000G phase 1 and phase 3'. "

	echo "* downloading [ 1000G phase 1 ] ..."
	echo "wget ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/phase1/analysis_results/integrated_call_sets/ALL.wgs.integrated_phase1_v3.20101123.snps_indels_sv.sites.vcf.gz -O ${RESOURCES}/ALL.wgs.integrated_phase1_v3.20101123.snps_indels_sv.sites.vcf.gz " > ${RESOURCES}/resource.1kG1.downloader.sh
	qsub -S /bin/bash -N ThousandGp1downloader -hold_jid dbSNPparser -o ${RESOURCES}/resource.1kG1.downloader.log -e ${RESOURCES}/resource.1kG1.downloader.errors -l h_vmem=8G -l h_rt=00:45:00 -wd ${RESOURCES} ${RESOURCES}/resource.1kG1.downloader.sh
	echo "* downloading [ 1000G phase 3 ] ..."
	echo "wget ftp://ftp.ncbi.nih.gov/1000genomes/ftp/release/20130502/ALL.wgs.phase3_shapeit2_mvncall_integrated_v5b.20130502.sites.vcf.gz -O ${RESOURCES}/ALL.wgs.phase3_shapeit2_mvncall_integrated_v5b.20130502.sites.vcf.gz " > ${RESOURCES}/resource.1kG3.downloader.sh
	qsub -S /bin/bash -N ThousandGp3downloader -hold_jid dbSNPparser -o ${RESOURCES}/resource.1kG3.downloader.log -e ${RESOURCES}/resource.1kG3.downloader.errors -l h_vmem=8G -l h_rt=00:45:00 -wd ${RESOURCES} ${RESOURCES}/resource.1kG3.downloader.sh
	echo "* parsing 1000G phase 1."
	echo "perl ${SCRIPTS}/resource.VCFparser.pl --file ${RESOURCES}/ALL.wgs.integrated_phase1_v3.20101123.snps_indels_sv.sites.vcf.gz --ref 1Gp1 --pop ${POPULATION} --out ${RESOURCES}/1000Gp1v3_20101123_integrated_ALL_snv_indels_sv " > ${RESOURCES}/resource.VCFparser.1kGp1.sh
	echo "gzip -fv ${RESOURCES}/1000Gp1v3_20101123_integrated_ALL_snv_indels_sv.${POPULATION}.INFO.txt " >> ${RESOURCES}/resource.VCFparser.1kGp1.sh
	echo "gzip -fv ${RESOURCES}/1000Gp1v3_20101123_integrated_ALL_snv_indels_sv.${POPULATION}.FREQ.txt " >> ${RESOURCES}/resource.VCFparser.1kGp1.sh
	echo "gzip -fv ${RESOURCES}/1000Gp1v3_20101123_integrated_ALL_snv_indels_sv.${POPULATION}.FUNC.txt " >> ${RESOURCES}/resource.VCFparser.1kGp1.sh
	echo "rm -fv ${RESOURCES}/ALL.wgs.integrated_phase1_v3.20101123.snps_indels_sv.sites.vcf.gz " >> ${RESOURCES}/resource.VCFparser.1kGp1.sh
	qsub -S /bin/bash -N VCFparser1Gp1 -hold_jid ThousandGp1downloader -o ${RESOURCES}/resource.VCFparser.1kGp1.log -e ${RESOURCES}/resource.VCFparser.1kGp1.errors -l h_vmem=16G -l h_rt=03:00:00 -wd ${RESOURCES} ${RESOURCES}/resource.VCFparser.1kGp1.sh
	echo "* parsing 1000G phase 3."
	echo "perl ${SCRIPTS}/resource.VCFparser.pl --file ${RESOURCES}/ALL.wgs.phase3_shapeit2_mvncall_integrated_v5b.20130502.sites.vcf.gz --ref 1Gp3 --pop ${POPULATION1Gp3} --out ${RESOURCES}/1000Gp3v5_20130502_integrated_ALL_snv_indels_sv " > ${RESOURCES}/resource.VCFparser.1kGp3.sh
	echo "gzip -fv ${RESOURCES}/1000Gp3v5_20130502_integrated_ALL_snv_indels_sv.${POPULATION1Gp3}.INFO.txt " >> ${RESOURCES}/resource.VCFparser.1kGp3.sh
	echo "gzip -fv ${RESOURCES}/1000Gp3v5_20130502_integrated_ALL_snv_indels_sv.${POPULATION1Gp3}.FREQ.txt " >> ${RESOURCES}/resource.VCFparser.1kGp3.sh
	echo "gzip -fv ${RESOURCES}/1000Gp3v5_20130502_integrated_ALL_snv_indels_sv.${POPULATION1Gp3}.FUNC.txt " >> ${RESOURCES}/resource.VCFparser.1kGp3.sh
	echo "rm -fv ${RESOURCES}/ALL.wgs.phase3_shapeit2_mvncall_integrated_v5b.20130502.sites.vcf.gz " >> ${RESOURCES}/resource.VCFparser.1kGp3.sh
	qsub -S /bin/bash -N VCFparser1Gp3 -hold_jid ThousandGp3downloader -o ${RESOURCES}/resource.VCFparser.1kGp3.log -e ${RESOURCES}/resource.VCFparser.1kGp3.errors -l h_vmem=16G -l h_rt=03:00:00 -wd ${RESOURCES} ${RESOURCES}/resource.VCFparser.1kGp3.sh
	echo ""
	
	echo "* updating 1000G phase 1."
	echo "perl ${SCRIPTS}/mergeTables.pl --file1 ${RESOURCES}/dbSNP147_GRCh37_hg19_Feb2009.attrib.txt.gz --file2 ${RESOURCES}/1000Gp1v3_20101123_integrated_ALL_snv_indels_sv.${POPULATION}.FUNC.txt.gz --index VariantID --format GZIPB --replace > ${RESOURCES}/1000Gp1v3_20101123_integrated_ALL_snv_indels_sv.${POPULATION}.FUNC.txt " > ${RESOURCES}/resource.VCFplusdbSNP.1kGp1.sh
	echo "gzip -fv ${RESOURCES}/1000Gp1v3_20101123_integrated_ALL_snv_indels_sv.${POPULATION}.FUNC.txt " >> ${RESOURCES}/resource.VCFplusdbSNP.1kGp1.sh
	qsub -S /bin/bash -N VCF1Gp1plusdbSNP -hold_jid VCFparser1Gp1 -o ${RESOURCES}/resource.VCFplusdbSNP.1kGp1.log -e ${RESOURCES}/resource.VCFplusdbSNP.1kGp1.errors -l h_vmem=128G -l h_rt=04:00:00 -wd ${RESOURCES} ${RESOURCES}/resource.VCFplusdbSNP.1kGp1.sh
	echo "* updating 1000G phase 3."
	echo "perl ${SCRIPTS}/mergeTables.pl --file1 ${RESOURCES}/dbSNP147_GRCh37_hg19_Feb2009.attrib.txt.gz --file2 ${RESOURCES}/1000Gp3v5_20130502_integrated_ALL_snv_indels_sv.${POPULATION1Gp3}.FUNC.txt.gz --index VariantID --format GZIPB --replace > ${RESOURCES}/1000Gp3v5_20130502_integrated_ALL_snv_indels_sv.${POPULATION1Gp3}.FUNC.txt " > ${RESOURCES}/resource.VCFplusdbSNP.1kGp3.sh
	echo "gzip -fv ${RESOURCES}/1000Gp3v5_20130502_integrated_ALL_snv_indels_sv.${POPULATION1Gp3}.FUNC.txt " >> ${RESOURCES}/resource.VCFplusdbSNP.1kGp3.sh
	qsub -S /bin/bash -N VCF1Gp3plusdbSNP -hold_jid VCFparser1Gp3 -o ${RESOURCES}/resource.VCFplusdbSNP.1kGp3.log -e ${RESOURCES}/resource.VCFplusdbSNP.1kGp3.errors -l h_vmem=128G -l h_rt=04:00:00 -wd ${RESOURCES} ${RESOURCES}/resource.VCFplusdbSNP.1kGp3.sh

	echo ""	
	echo "All done submitting jobs for downloading and parsing 1000G references! 🖖"
	echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	
	echo ""
	echobold "#########################################################################################################"
	echobold "### DOWNLOADING GENCODE and refseq gene lists"
	echobold "#########################################################################################################"
	echobold "#"
	echo ""
	echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echo "Downloading and parsing 'GENCODE and refseq gene lists'. "
	
	echo "* downloading [ GENCODE ] ... "
	wget http://hgdownload.soe.ucsc.edu/goldenPath/hg19/database/wgEncodeGencodeBasicV19.txt.gz -O ${RESOURCES}/GENCODE_wgEncodeBasicV19_GRCh37_hg19_Feb2009.txt.gz
	### HEAD
	### 585	ENST00000456328.2	chr1	+	11868	14409	11868	11868	3	11868,12612,13220,	12227,12721,14409,	0	DDX11L1	none	none	-1,-1,-1,
	### 585	ENST00000607096.1	chr1	+	30365	30503	30365	30365	1	30365,	30503,	0	MIR1302-11	none	none	-1,
	### 585	ENST00000417324.1	chr1	-	34553	36081	34553	34553	3	34553,35276,35720,	35174,35481,36081,	0	FAM138A	none	none	-1,-1,-1,
	### 585	ENST00000335137.3	chr1	+	69090	70008	69090	70008	1	69090,	70008,	0	OR4F5	cmpl	cmpl	0,
	
	echo "* parsing [ GENCODE ] ... "
	zcat ${RESOURCES}/GENCODE_wgEncodeBasicV19_GRCh37_hg19_Feb2009.txt.gz | awk '{ print $3, $5, $6, $13, $2, $4}' | awk -F" " '{gsub(/chr/, "", $1)}1' | tail -n +2 > ${RESOURCES}/gencode_v19_GRCh37_hg19_Feb2009.txt 
	gzip -fv ${RESOURCES}/gencode_v19_GRCh37_hg19_Feb2009.txt 
	rm -fv ${RESOURCES}/GENCODE_wgEncodeBasicV19_GRCh37_hg19_Feb2009.txt.gz
	
	echo "* downloading [ refseq ] ... "
	wget http://hgdownload.soe.ucsc.edu/goldenPath/hg19/database/refGene.txt.gz -O ${RESOURCES}/refGene_GRCh37_hg19_Feb2009.txt.gz
	### HEAD
	### 585	NR_046018	chr1	+	11873	14409	14409	14409	3	11873,12612,13220,	12227,12721,14409,	0	DDX11L1	unk	unk	-1,-1,-1,
	### 585	NR_024540	chr1	-	14361	29370	29370	29370	11	14361,14969,15795,16606,16857,17232,17605,17914,18267,24737,29320,	14829,15038,15947,16765,17055,17368,17742,18061,18366,24891,29370,	0	WASH7P	unk	unk	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,

	echo "* parsing [ refseq ] ... "
	zcat ${RESOURCES}/refGene_GRCh37_hg19_Feb2009.txt.gz | awk '{ print $3, $5, $6, $13, $2, $4 }' | awk -F" " '{gsub(/chr/, "", $1)}1' > ${RESOURCES}/refseq_GRCh37_hg19_Feb2009.txt
	gzip -fv ${RESOURCES}/refseq_GRCh37_hg19_Feb2009.txt
	rm -fv ${RESOURCES}/refGene_GRCh37_hg19_Feb2009.txt.gz
	echo ""	
	echo "All done submitting jobs for downloading and parsing gene lists! 🖖"
	echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

	echo ""
	echobold "#########################################################################################################"
	echobold "### *** WARNING *** NOT IMPLEMENTED YET DOWNLOADING Recombination Maps for b36 and b37"
	echobold "#########################################################################################################"
	echobold "#"
	echo ""
	echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echo "Downloading and parsing 'Recombination Maps'. "
	#http://www.shapeit.fr/files/genetic_map_b37.tar.gz
	#http://hapmap.ncbi.nlm.nih.gov/downloads/recombination/2008-03_rel22_B36/rates
	#wget http://www.shapeit.fr/files/genetic_map_b37.tar.gz -O ${RESOURCES}/genetic_map_b37.tar.gz
	#tar -zxvf ${RESOURCES}/genetic_map_b37.tar.gz
	#mv -v ${RESOURCES}/genetic_map_b37 ${RESOURCES}/RECOMB_RATES 
	echo ""	
	echo "All done submitting jobs for downloading and parsing Recombination Maps! 🖖"
	echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

	echo ""
	echobold "#########################################################################################################"
	echobold "### DOWNLOADING LD-Hub reference variants"
	echobold "#########################################################################################################"
	echobold "#"
	echo ""
	echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echo "Downloading and parsing 'LD-Score reference variant list'. "
	wget http://ldsc.broadinstitute.org/static/media/w_hm3.noMHC.snplist.zip -O ${RESOURCES}/w_hm3.noMHC.snplist.zip
	echo "snpid A1 A2" > ${RESOURCES}/w_hm3.noMHC.snplist.txt
	unzip -p ${RESOURCES}/w_hm3.noMHC.snplist.zip | tail -n +2 >> ${RESOURCES}/w_hm3.noMHC.snplist.txt
	gzip -v ${RESOURCES}/w_hm3.noMHC.snplist.txt
	rm -v ${RESOURCES}/w_hm3.noMHC.snplist.zip
	echo ""	
	echo "All done submitting jobs for downloading and parsing LD-Score reference variant list! 🖖"
	echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

script_copyright_message

###	UtrechtSciencePark Colours Scheme
###
### Website to convert HEX to RGB: http://hex.colorrrs.com.
### For some functions you should divide these numbers by 255.
###
###	No.	Color				HEX		RGB							CMYK					CHR		MAF/INFO
### --------------------------------------------------------------------------------------------------------------------
###	1	yellow				#FBB820 (251,184,32)				(0,26.69,87.25,1.57) 	=>	1 		or 1.0 > INFO
###	2	gold				#F59D10 (245,157,16)				(0,35.92,93.47,3.92) 	=>	2		
###	3	salmon				#E55738 (229,87,56) 				(0,62.01,75.55,10.2) 	=>	3 		or 0.05 < MAF < 0.2 or 0.4 < INFO < 0.6
###	4	darkpink			#DB003F ((219,0,63)					(0,100,71.23,14.12) 	=>	4		
###	5	lightpink			#E35493 (227,84,147)				(0,63,35.24,10.98) 	=>	5 		or 0.8 < INFO < 1.0
###	6	pink				#D5267B (213,38,123)				(0,82.16,42.25,16.47) 	=>	6		
###	7	hardpink			#CC0071 (204,0,113)					(0,0,0,0) 	=>	7		
###	8	lightpurple			#A8448A (168,68,138)				(0,0,0,0) 	=>	8		
###	9	purple				#9A3480 (154,52,128)				(0,0,0,0) 	=>	9		
###	10	lavendel			#8D5B9A (141,91,154)				(0,0,0,0) 	=>	10		
###	11	bluepurple			#705296 (112,82,150)				(0,0,0,0) 	=>	11		
###	12	purpleblue			#686AA9 (104,106,169)				(0,0,0,0) 	=>	12		
###	13	lightpurpleblue		#6173AD (97,115,173/101,120,180)	(0,0,0,0) 	=>	13		
###	14	seablue				#4C81BF (76,129,191)				(0,0,0,0) 	=>	14		
###	15	skyblue				#2F8BC9 (47,139,201)				(0,0,0,0) 	=>	15		
###	16	azurblue			#1290D9 (18,144,217)				(0,0,0,0) 	=>	16		 or 0.01 < MAF < 0.05 or 0.2 < INFO < 0.4
###	17	lightazurblue		#1396D8 (19,150,216)				(0,0,0,0) 	=>	17		
###	18	greenblue			#15A6C1 (21,166,193)				(0,0,0,0) 	=>	18		
###	19	seaweedgreen		#5EB17F (94,177,127)				(0,0,0,0) 	=>	19		
###	20	yellowgreen			#86B833 (134,184,51)				(0,0,0,0) 	=>	20		
###	21	lightmossgreen		#C5D220 (197,210,32)				(0,0,0,0) 	=>	21		
###	22	mossgreen			#9FC228 (159,194,40)				(0,0,0,0) 	=>	22		or MAF > 0.20 or 0.6 < INFO < 0.8
###	23	lightgreen			#78B113 (120,177,19)				(0,0,0,0) 	=>	23/X
###	24	green				#49A01D (73,160,29)					(0,0,0,0) 	=>	24/Y
###	25	grey				#595A5C (89,90,92)					(0,0,0,0) 	=>	25/XY	or MAF < 0.01 or 0.0 < INFO < 0.2
###	26	lightgrey			#A2A3A4	(162,163,164)				(0,0,0,0) 	=> 	26/MT
### --------------------------------------------------------------------------------------------------------------------



