#!/bin/bash
#

#$ -S /bin/bash 																			# the type of BASH you'd like to use
#$ -N basic_bash_script  																	# the name of this script
#$ -hold_jid some_other_basic_bash_script  													# the current script (basic_bash_script) will hold until some_other_basic_bash_script has finished
#$ -o /hpc/dhl_ec/svanderlaan/projects/basic_bash_script.log  								# the log file of this job
#$ -e /hpc/dhl_ec/svanderlaan/projects/basic_bash_script.errors 							# the error file of this job
#$ -l h_rt=00:08:00  																		# h_rt=[max time, e.g. 02:02:01] - this is the time you think the script will take
#$ -l h_vmem=128G  																			#  h_vmem=[max. mem, e.g. 45G] - this is the amount of memory you think your script will use
#$ -l tmpspace=64G  																		# this is the amount of temporary space you think your script will use
#$ -M s.w.vanderlaan-2@umcutrecht.nl  														# you can send yourself emails when the job is done; "-M" and "-m" go hand in hand
#$ -m ea  																					# you can choose: b=begin of job; e=end of job; a=abort of job; s=suspended job; n=no mail is send
#$ -cwd  																					# set the job start to the current directory - so all the things in this script are relative to the current directory!!!
#
# You can use the variables above (indicated by "#$") to set some things for the submission system.
# Another useful tip: you can set a job to run after another has finished. Name the job 
# with "-N SOMENAME" and hold the other job with -hold_jid SOMENAME". 
# Further instructions: https://wiki.bioinformatics.umcutrecht.nl/bin/view/HPC/HowToS#Run_a_job_after_your_other_jobs
#
# It is good practice to properly name and annotate your script for future reference for
# yourself and others. Trust me, you'll forget why and how you made this!!!

### Creating display functions
### Setting colouring
### NONE='\033[00m'
### BOLD='\033[1m'
### OPAQUE='\033[2m'
### FLASHING='\033[5m'
### UNDERLINE='\033[4m'
### 
### RED='\033[01;31m'
### GREEN='\033[01;32m'
### YELLOW='\033[01;33m'
### PURPLE='\033[01;35m'
### CYAN='\033[01;36m'
### WHITE='\033[01;37m'
### Regarding changing the 'type' of the things printed with 'echo'
### Refer to: 
### - http://askubuntu.com/questions/528928/how-to-do-underline-bold-italic-strikethrough-color-background-and-size-i
### - http://misc.flogisoft.com/bash/tip_colors_and_formatting
### - http://unix.stackexchange.com/questions/37260/change-font-in-echo-command

### echo -e "\033[1mbold\033[0m"
### echo -e "\033[3mitalic\033[0m" ### THIS DOESN'T WORK ON MAC!
### echo -e "\033[4munderline\033[0m"
### echo -e "\033[9mstrikethrough\033[0m"
### echo -e "\033[31mHello World\033[0m"
### echo -e "\x1B[31mHello World\033[0m"

for i in $(seq 0 5) 7 8 $(seq 30 37) $(seq 41 47) $(seq 90 97) $(seq 100 107) ; do 
	echo -e "\033["$i"mYou can change the font...\033[0m"; 
done
### Creating some function
function echobold { #'echobold' is the function name
    echo -e "\033[1m${1}\033[0m" # this is whatever the function needs to execute.
}
function echobold { #'echobold' is the function name
    echo -e "${BOLD}${1}${NONE}" # this is whatever the function needs to execute, note ${1} is the text for echo
}
function echoitalic { #'echobold' is the function name
    echo -e "\033[3m${1}\033[0m" # this is whatever the function needs to execute.
}

echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echobold "                         SOME BASH SCRIPT THAT EXECUTES SOMETHING"
echo "                                  version 1.0 (20160302)"
echo ""
echoitalic "* Written by  : Sander W. van der Laan"
echoitalic "* E-mail      : s.w.vanderlaan-2@umcutrecht.nl"
echoitalic "* Last update : 2016-03-02"
echoitalic "* Version     : somebashscript_v1_20160302"
echo ""
echoitalic "* Description : This script will set some directories, execute something in a for "
echoitalic "                loop, and will then submit this in a job."
echo ""
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "Today's: "$(date)
TODAY=$(date +"%Y%m%d")
echo ""
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echobold "The following directories are set."
ORIGINALS=/hpc/dhl_ec/data/_ae_originals/AEGS_COMBINED_IMPUTE2_BBMRI_1000Gp1v3
GBS=/hpc/dhl_ec/svanderlaan/projects/gbs
DOSAGES=${GBS}/dosages
SOFTWARE=/hpc/local/CentOS7/dhl_ec/software
QCTOOL=${SOFTWARE}/qctool_v1.5-linux-x86_64-static/qctool
echo "Original data directory____ ${ORIGINALS}"
echo "Project directory__________ ${GBS}"
echo "Dosage directory___________ ${DOSAGES}"
echo "Software directory_________ ${SOFTWARE}"
echo "Where \"qctool\" resides_____ ${QCTOOL}"
echo ""

### Make directories for script if they do not exist yet (!!!PREREQUISITE!!!)
#if [ ! -d ${GBS}/rawdata/ ]; then
#  mkdir -v ${GBS}/rawdata/
#fi
#RAW=${GBS}/rawdata

echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echobold "Creating resources."

### TO DO
# We need to make scripts that automagically make required files when installing this
# meta-analysis package.
# DBSNPFILE 
# could be 1000G based or a specific dbSNP download
wget http://hgdownload.cse.ucsc.edu/goldenPath/hg19/database/snp147.txt.gz -O dbSNP147_GRCh37_hg19_Feb2009.allVariants.txt.gz
echo "Chr ChrStart ChrEnd VariantID Strand Alleles VariantClass VariantFunction" > dbSNP147_GRCh37_hg19_Feb2009.txt
zcat dbSNP147_GRCh37_hg19_Feb2009.allVariants.txt.gz | awk '{ print $2, $3, $4, $5, $7, $10, $12, $16 }' >> dbSNP147_GRCh37_hg19_Feb2009.txt
gzip -v dbSNP147_GRCh37_hg19_Feb2009.txt
mkdir -v ORIGINALS
mv -v dbSNP147_GRCh37_hg19_Feb2009.allVariants.txt.gz ORIGINALS/

# REFFREQFILE
# could be 1000G based or a specific dbSNP download
# GENESFILE  -- probably use GENCODE as this is made based on a combination of manual and automatic work

#wget ftp://ftp.sanger.ac.uk/pub/gencode/Gencode_human/release_19/gencode.v19.annotation.gtf.gz -O GENCODE_wgEncodeBasicV19_GRCh37_hg19_Feb2009.gtf.gz
cat GENCODE_wgEncodeBasicV19_GRCh37_hg19_Feb2009.txt | awk '{ print $3, $5, $6, $13, $2, $4}' > gencode_v19_GRCh37_hg19_Feb2009.txt.temp
cat gencode_v19_GRCh37_hg19_Feb2009.txt.temp | awk -F" " '{gsub(/chr/, "", $1)}1'  | tail -n +2 > gencode_v19_GRCh37_hg19_Feb2009.txt
rm -v gencode_v19_GRCh37_hg19_Feb2009.txt.temp
gzip -v gencode_v19_GRCh37_hg19_Feb2009.txt
mkdir -v ORIGINALS
mv -v GENCODE_wgEncodeBasicV19_GRCh37_hg19_Feb2009.txt ORIGINALS/
gzip -v ORIGINALS/GENCODE_wgEncodeBasicV19_GRCh37_hg19_Feb2009.txt

#wget http://hgdownload.soe.ucsc.edu/goldenPath/hg19/database/refGene.txt.gz -O refseq_GRCh37_hg19_Feb2009.txt.gz

for CHR in $(seq 1 22) X; do 
	echo "* processing chromosome [ ${CHR} ]..."
	###echo "$QCTOOL -g $ORIGINALS/aegs_combo_1000g_RAW_chr${CHR}.bgen -og ${GBS}/dosages/aegs_1000Gp1v3_RAW.chr${CHR}.gen -incl-rsids ${GBS}/dosages/extractionlist.chr${CHR}.txt " > ${DOSAGES}/get1kgdos.chr${CHR}.CADLAS.sh
	###echo "" >> ${DOSAGES}/get1kgdos.chr${CHR}.CADLAS.sh
	###qsub -S /bin/bash -e ${DOSAGES}/get1kgdos.chr${CHR}.CADLAS.errors -o ${DOSAGES}/get1kgdos.chr${CHR}.CADLAS.output -l h_rt=24:00:00 -l h_vmem=8G -l tmpspace=64G -M s.w.vanderlaan-2@umcutrecht.nl -m ea -cwd ${DOSAGES}/get1kgdos.chr${CHR}.CADLAS.sh
done
echo ""
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echobold "Wow. I'm all done buddy. What a job! let's have a beer!"
date

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



