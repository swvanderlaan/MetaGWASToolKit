#!/bin/bash

echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "                GWASPLOTTER: VISUALIZE GENOME-WIDE ASSOCIATION STUDIES"
echo ""
echo " Version: GWAS.PLOTTER.v1.0.0"
echo ""
echo " Last update: 2016-12-02"
echo " Written by:  Sander W. van der Laan (s.w.vanderlaan-2@umcutrecht.nl)."
echo "			    Sara Pulit | s.l.pulit@umcutrecht.nl; "
echo "			    Jessica van Setten | j.vansetten@umcutrecht.nl; "
echo "			    Paul I.W. de Bakker | p.i.w.debakker-2@umcutrecht.nl"
echo ""
echo " Testers:     - Jessica van Setten (j.vansetten@umcutrecht.nl)"
echo ""
echo " Description: Produce plots (PDF and PNG) for quick inspection and publication."
echo ""
echo " REQUIRED: "
echo " * A high-performance computer cluster with a qsub system"
echo " * R v3.2+, Python 2.7+"
echo " * Note: it will also work on a Mac OS X system with R and Python installed."
### ADD-IN: function to check requirements...
echo ""
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

script_arguments_error() {
	echo "$1" # Additional message
	echo "- Argument #1 is path_to/filename of the configuration file."
	echo "- Argument #2 is path_to/filename of the list of GWAS files with names."
	echo "- Argument #3 is reference to use [HM2/1Gp1/1Gp3] for the QC and analysis."
	echo "An example command would be: run_meta.sh [arg1: path_to/configuration_file] [arg2: path_to/gwas_files_list] [arg3: HM2/1Gp1/1Gp3]"
	echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  	# The wrong arguments are passed, so we'll exit the script now!
  	date
  	exit 1
}


echo ""
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "The following directories are set."
PROJECTDIR=/hpc/dhl_ec/svanderlaan/projects/megastroke
QCEDDATA=/hpc/dhl_ec/svanderlaan/projects/megastroke/qced_ganesh
SOFTWARE=/hpc/local/CentOS7/dhl_ec/software
QCTOOL=$SOFTWARE/qctool_v1.5-linux-x86_64-static/qctool

echo "Project directory________________ ${PROJECTDIR}"
echo "Original qc'ed data directory____ ${QCEDDATA}"
echo "Software directory_______________ ${SOFTWARE}"
echo "Where \"qctool\" resides___________ ${QCTOOL}"
echo ""

### Make directories for script if they do not exist yet (!!!PREREQUISITE!!!)
if [ ! -d ${QCEDDATA}/_plots ]; then
  mkdir -v ${QCEDDATA}/_plots
fi
PLOTTED=${QCEDDATA}/_plots

# Setting some other parameters
RANDOMSAMPLE="1000000" # for P-Z plot
PVALUE="PVAL" # for QQ-plots
QMEM="32G"
QTIME="00:20:00"

echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "Processing files for each study, and plotting for QC."
echo ""

### Header example
###	1	   2   3  4		 5			  6			  7	  8	  9	  10	11	 12	  13 14	15 16	 17		    18
###	Marker CHR BP Strand EffectAllele OtherAllele EAF MAF MAC HWE_P Info Beta SE P N N_cases N_controls Imputed
###	rs1921 1 939471 1 2 4 0.408 0.408 322.32 0.375511637486551 NA 0.0451 0.04283 0.293 395 NA NA 0
###	rs3128126 1 952073 1 4 1 0.4208 0.4208 332.432 0.375511637486551 NA 0.06069 0.04304 0.1593 395 NA NA 0
###	rs10907175 1 1120590 1 3 1 0.08571 0.08571 67.7109 0.375511637486551 NA 0.008913 0.04301 0.836 395 NA NA 0

#echo "Make a new directory for the original data, and move it there."
#### Make directories for script if they do not exist yet (!!!PREREQUISITE!!!)
#if [ ! -d ${QCEDDATA}/_original_hisayama ]; then
#  mkdir -v ${QCEDDATA}/_original_hisayama
#fi
#HISAYAMADATA=${QCEDDATA}/_original_hisayama
#mv -v ${QCEDDATA}/HISAYAMA.*.meta.gz ${HISAYAMADATA}
#
#echo ""
#echo "Gzip the new stuff"
#gzip -v ${QCEDDATA}/HISAYAMA.*.COMBINED.21C.meta
#chmod -v 0775 ${QCEDDATA}/HISAYAMA.*

#for FILE in $(ls ${QCEDDATA}/*.gz ); do
#	### PREPARING FILES
#	FILENAME=$(basename ${FILE} .gz)
#	echo "*** Processing file ${FILENAME} ***"
#	echo ""
#	echo "- found file: ${FILE}"
#	echo "- creating files for plotting..." 
#	zcat ${FILE} | awk '{ print $6, $7, $13 }' | tail -n +2 > ${PLOTTED}/${FILENAME}.MANHATTAN.txt
#	zcat ${FILE} | awk '{ print $13 }' | tail -n +2 > ${PLOTTED}/${FILENAME}.QQ.txt
#	zcat ${FILE} | awk '{ print $13, $14 }' | tail -n +2 > ${PLOTTED}/${FILENAME}.QQ_by_INFO.txt
#	zcat ${FILE} | awk '{ print $13, $10 }' | tail -n +2 > ${PLOTTED}/${FILENAME}.QQ_by_CAF.txt
#	zcat ${FILE} | awk '{ print $13, $17 }' | tail -n +2 > ${PLOTTED}/${FILENAME}.QQ_by_TYPE.txt
#	zcat ${FILE} | awk '{ print $11 }' | tail -n +2 > ${PLOTTED}/${FILENAME}.HISTOGRAM_BETA.txt
#	zcat ${FILE} | awk '{ print $11, $12, $13 }' | tail -n +2 > ${PLOTTED}/${FILENAME}.P_Z.txt
#	zcat ${FILE} | awk '{ print $14 }' | tail -n +2 > ${PLOTTED}/${FILENAME}.INFO.txt
#	
#	echo ""
#	echo "- gzipping..."
#	gzip -v ${PLOTTED}/${FILENAME}.MANHATTAN.txt
#	gzip -v ${PLOTTED}/${FILENAME}.QQ.txt
#	gzip -v ${PLOTTED}/${FILENAME}.QQ_by_INFO.txt
#	gzip -v ${PLOTTED}/${FILENAME}.QQ_by_CAF.txt
#	gzip -v ${PLOTTED}/${FILENAME}.QQ_by_TYPE.txt
#	gzip -v ${PLOTTED}/${FILENAME}.HISTOGRAM_BETA.txt
#	gzip -v ${PLOTTED}/${FILENAME}.P_Z.txt
#	gzip -v ${PLOTTED}/${FILENAME}.INFO.txt
#	
#	chmod -v 0775 ${PLOTTED}/${FILENAME}.*
#	
#	### REPORTING
#	echo ""
#	echo "- reporting some basics on the file..."
#	
#	echo "*** Processing file: ${FILENAME} ***" > ${PLOTTED}/${FILENAME}.REPORT.txt
#	echo "================================================================================" >> ${PLOTTED}/${FILENAME}.REPORT.txt
#	ls -l ${FILE} >> ${PLOTTED}/${FILENAME}.REPORT.txt
#	echo "" >> ${PLOTTED}/${FILENAME}.REPORT.txt
#	echo "--------------------------------------------------------------------------------" >> ${PLOTTED}/${FILENAME}.REPORT.txt
#	echo "*** HEADER & TAIL ***" >> ${PLOTTED}/${FILENAME}.REPORT.txt
#	echo "--------------------------------------------------------------------------------" >> ${PLOTTED}/${FILENAME}.REPORT.txt
#	zcat ${FILE} | head >> ${PLOTTED}/${FILENAME}.REPORT.txt
#	echo "" >> ${PLOTTED}/${FILENAME}.REPORT.txt
#	zcat ${FILE} | tail >> ${PLOTTED}/${FILENAME}.REPORT.txt
#	echo "--------------------------------------------------------------------------------" >> ${PLOTTED}/${FILENAME}.REPORT.txt
#	echo "" >> ${PLOTTED}/${FILENAME}.REPORT.txt
#	echo "--------------------------------------------------------------------------------" >> ${PLOTTED}/${FILENAME}.REPORT.txt
#	echo "*** SOME STATS ***" >> ${PLOTTED}/${FILENAME}.REPORT.txt
#	echo "Number of lines:" >> ${PLOTTED}/${FILENAME}.REPORT.txt
#	zcat ${FILE} | tail -n +2 | wc -l >> ${PLOTTED}/${FILENAME}.REPORT.txt
#	echo "Number of unique fields:" >> ${PLOTTED}/${FILENAME}.REPORT.txt
#	zcat ${FILE} | tail -n +2 | awk '{ print NF }' | sort -nu >> ${PLOTTED}/${FILENAME}.REPORT.txt
#	echo "--------------------------------------------------------------------------------" >> ${PLOTTED}/${FILENAME}.REPORT.txt
#	echo "" >> ${PLOTTED}/${FILENAME}.REPORT.txt
#	echo "================================================================================" >> ${PLOTTED}/${FILENAME}.REPORT.txt
#	echo "${TODAY}" >> ${PLOTTED}/${FILENAME}.REPORT.txt
#	
#	
#	### PLOTTING
#	###for FORMAT in PNG TIFF EPS PDF; do
#	for FORMAT in PNG; do
#		echo ""
#		echo "- plotting Manhattan..."
#		echo "${SOFTWARE}/MANTEL/SCRIPTS/manhattan.R --projectdir ${PLOTTED} --resultfile ${PLOTTED}/${FILENAME}.MANHATTAN.txt.gz --outputdir ${PLOTTED} --colorstyle FULL --imageformat ${FORMAT}" > ${PLOTTED}/${FILENAME}.MANHATTAN.FULL.sh
#		qsub -S /bin/bash -N ${FILENAME}.MANHATTAN.FULL -o ${PLOTTED}/${FILENAME}.MANHATTAN.FULL.log -e ${PLOTTED}/${FILENAME}.MANHATTAN.FULL.errors -l h_vmem=${QMEM} -l h_rt=${QTIME} -wd ${PROJECTDIR} ${PLOTTED}/${FILENAME}.MANHATTAN.FULL.sh
#		echo "${SOFTWARE}/MANTEL/SCRIPTS/manhattan.R --projectdir ${PLOTTED} --resultfile ${PLOTTED}/${FILENAME}.MANHATTAN.txt.gz --outputdir ${PLOTTED} --colorstyle QC --imageformat ${FORMAT}" > ${PLOTTED}/${FILENAME}.MANHATTAN.QC.sh
#		qsub -S /bin/bash -N ${FILENAME}.MANHATTAN.QC -o ${PLOTTED}/${FILENAME}.MANHATTAN.QC.log -e ${PLOTTED}/${FILENAME}.MANHATTAN.QC.errors -l h_vmem=${QMEM} -l h_rt=${QTIME} -wd ${PROJECTDIR} ${PLOTTED}/${FILENAME}.MANHATTAN.QC.sh
#		echo "${SOFTWARE}/MANTEL/SCRIPTS/manhattan.R --projectdir ${PLOTTED} --resultfile ${PLOTTED}/${FILENAME}.MANHATTAN.txt.gz --outputdir ${PLOTTED} --colorstyle TWOCOLOR --imageformat ${FORMAT}" > ${PLOTTED}/${FILENAME}.MANHATTAN.TWOCOLOR.sh
#		qsub -S /bin/bash -N ${FILENAME}.MANHATTAN.TWOCOLOR -o ${PLOTTED}/${FILENAME}.MANHATTAN.TWOCOLOR.log -e ${PLOTTED}/${FILENAME}.MANHATTAN.TWOCOLOR.errors -l h_vmem=${QMEM} -l h_rt=${QTIME} -wd ${PROJECTDIR} ${PLOTTED}/${FILENAME}.MANHATTAN.TWOCOLOR.sh
#		
#		echo ""
#		echo "- plotting QQ-plot..."
#		echo "${SOFTWARE}/MANTEL/SCRIPTS/qqplot.R --projectdir ${PLOTTED} --resultfile ${PLOTTED}/${FILENAME}.QQ.txt.gz --outputdir ${PLOTTED} --stattype ${PVALUE} --imageformat ${FORMAT}" > ${PLOTTED}/${FILENAME}.QQ.sh
#		qsub -S /bin/bash -N ${FILENAME}.QQ -o ${PLOTTED}/${FILENAME}.QQ.log -e ${PLOTTED}/${FILENAME}.QQ.errors -l h_vmem=${QMEM} -l h_rt=${QTIME} -wd ${PROJECTDIR} ${PLOTTED}/${FILENAME}.QQ.sh
#		
#		echo ""
#		echo "- plotting QQ-plot by INFO..."
#		echo "${SOFTWARE}/MANTEL/SCRIPTS/qqplot_by_info.R --projectdir ${PLOTTED} --resultfile ${PLOTTED}/${FILENAME}.QQ_by_INFO.txt.gz --outputdir ${PLOTTED} --stattype ${PVALUE} --imageformat ${FORMAT}" > ${PLOTTED}/${FILENAME}.QQ_by_INFO.sh
#		qsub -S /bin/bash -N ${FILENAME}.QQ_by_INFO -o ${PLOTTED}/${FILENAME}.QQ_by_INFO.log -e ${PLOTTED}/${FILENAME}.QQ_by_INFO.errors -l h_vmem=${QMEM} -l h_rt=${QTIME} -wd ${PROJECTDIR} ${PLOTTED}/${FILENAME}.QQ_by_INFO.sh
#		
#		echo ""
#		echo "- plotting QQ-plot by CAF..."
#		echo "${SOFTWARE}/MANTEL/SCRIPTS/qqplot_by_caf.R --projectdir ${PLOTTED} --resultfile ${PLOTTED}/${FILENAME}.QQ_by_CAF.txt.gz --outputdir ${PLOTTED} --stattype ${PVALUE} --imageformat ${FORMAT}" > ${PLOTTED}/${FILENAME}.QQ_by_CAF.sh
#		qsub -S /bin/bash -N ${FILENAME}.QQ_by_CAF -o ${PLOTTED}/${FILENAME}.QQ_by_CAF.log -e ${PLOTTED}/${FILENAME}.QQ_by_CAF.errors -l h_vmem=${QMEM} -l h_rt=${QTIME} -wd ${PROJECTDIR} ${PLOTTED}/${FILENAME}.QQ_by_CAF.sh
#		
#		echo ""
#		echo "- plotting QQ-plot by TYPE..."
#		echo "${SOFTWARE}/MANTEL/SCRIPTS/qqplot_by_type.R --projectdir ${PLOTTED} --resultfile ${PLOTTED}/${FILENAME}.QQ_by_TYPE.txt.gz --outputdir ${PLOTTED} --stattype ${PVALUE} --imageformat ${FORMAT}" > ${PLOTTED}/${FILENAME}.QQ_by_TYPE.sh
#		qsub -S /bin/bash -N ${FILENAME}.QQ_by_TYPE -o ${PLOTTED}/${FILENAME}.QQ_by_TYPE.log -e ${PLOTTED}/${FILENAME}.QQ_by_TYPE.errors -l h_vmem=${QMEM} -l h_rt=${QTIME} -wd ${PROJECTDIR} ${PLOTTED}/${FILENAME}.QQ_by_TYPE.sh
#		
#		echo ""
#		echo "- plotting EffectSize-plot..."
#		echo "${SOFTWARE}/MANTEL/SCRIPTS/effectsize_plotter.R --projectdir ${PLOTTED} --resultfile ${PLOTTED}/${FILENAME}.HISTOGRAM_BETA.txt.gz --outputdir ${PLOTTED} --imageformat ${FORMAT}" > ${PLOTTED}/${FILENAME}.HISTOGRAM_BETA.sh
#		qsub -S /bin/bash -N ${FILENAME}.HISTOGRAM_BETA -o ${PLOTTED}/${FILENAME}.HISTOGRAM_BETA.log -e ${PLOTTED}/${FILENAME}.HISTOGRAM_BETA.errors -l h_vmem=${QMEM} -l h_rt=${QTIME} -wd ${PROJECTDIR} ${PLOTTED}/${FILENAME}.HISTOGRAM_BETA.sh
#		
#		echo ""
#		echo "- plotting P-Z-plot..."
#		echo "${SOFTWARE}/MANTEL/SCRIPTS/p_z_plotter.R --projectdir ${PLOTTED} --resultfile ${PLOTTED}/${FILENAME}.P_Z.txt.gz --outputdir ${PLOTTED} --randomsample ${RANDOMSAMPLE} --imageformat ${FORMAT}" > ${PLOTTED}/${FILENAME}.P_Z.sh
#		qsub -S /bin/bash -N ${FILENAME}.P_Z -o ${PLOTTED}/${FILENAME}.P_Z.log -e ${PLOTTED}/${FILENAME}.P_Z.errors -l h_vmem=${QMEM} -l h_rt=${QTIME} -wd ${PROJECTDIR} ${PLOTTED}/${FILENAME}.P_Z.sh
#		
#		echo ""
#		echo "- plotting INFO-score-plot..."
#		echo "${SOFTWARE}/MANTEL/SCRIPTS/info_score_plotter.R --projectdir ${PLOTTED} --resultfile ${PLOTTED}/${FILENAME}.INFO.txt.gz --outputdir ${PLOTTED} --imageformat ${FORMAT}" > ${PLOTTED}/${FILENAME}.INFO.sh
#		qsub -S /bin/bash -N ${FILENAME}.INFO -o ${PLOTTED}/${FILENAME}.INFO.log -e ${PLOTTED}/${FILENAME}.INFO.errors -l h_vmem=${QMEM} -l h_rt=${QTIME} -wd ${PROJECTDIR} ${PLOTTED}/${FILENAME}.INFO.sh
#		
#	done
#	
#	echo "================================================================================"
#	echo ""
#
#	echo "- cleaning up input data for ${FILE}"
#	rm -v ${PLOTTED}/${FILENAME}.MANHATTAN.txt.gz
#	rm -v ${PLOTTED}/${FILENAME}.QQ.txt.gz
#	rm -v ${PLOTTED}/${FILENAME}.QQ_by_INFO.txt.gz
#	rm -v ${PLOTTED}/${FILENAME}.QQ_by_CAF.txt.gz
#	rm -v ${PLOTTED}/${FILENAME}.QQ_by_TYPE.txt.gz
#	rm -v ${PLOTTED}/${FILENAME}.HISTOGRAM_BETA.txt.gz
#	rm -v ${PLOTTED}/${FILENAME}.P_Z.txt.gz
#	rm -v ${PLOTTED}/${FILENAME}.INFO.txt.gz
#done
echo ""
echo "================================================================================"
echo "*** FREQUENCY PLOTTING ***"
### scripts_allele_freq_plots
### Allele_frequencies.1000G_p1_v3.out
### Allele_frequencies.1000G_p3_v5.out
### allele_frequency_plot_by_ethnicity.Rscript
### dbSNP_146.b37.p13.chr_pos.out
### plotting_allele_frequencies_based_on_ethnicity_1000G_p1.sh
### plotting_allele_frequencies_based_on_ethnicity_1000G_p3.sh

### How to use the script ##
### sh plotting_allele_frequencies_based_on_ethnicity_1000G_p1.sh \
### -s <Allele frequency support file> \
### -i <input file> \
### -r <Rscript file for plotting allele frequencies based on ethnicity> \
### -e <Ethnicity> \    ## Available Options= EUR, AFR, EAS, AMR
### -o <output file prefix>

### sh plotting_allele_frequencies_based_on_ethnicity_1000G_p1.sh \
### -s Allele_frequencies.1000G_p1_v3.out \
### -r allele_frequency_plot_by_ethnicity.Rscript \
### -e EUR \
### -i chr22.CHARGE_EUR.input \
### -o test_chr22_CHARGE_Eur_p1

#	-r ${PROJECTDIR}/scripts_allele_freq_plots/allele_frequency_plot_by_ethnicity.Rscript \

#echo ""
#echo "* Preparing the input files..."
#for FILE in $(ls ${QCEDDATA}/*.gz ); do
#	### PREPARING FILES
#	FILENAME=$(basename ${FILE} .gz)
#	echo "*** Processing file ${FILENAME} ***"
#	echo ""
#	echo "- found file: ${FILE}"
#	echo "- creating files for plotting..." 
#	echo "zcat ${FILE} | awk 'BEGIN {FS==OFS=\"\t\"}; {if (NR==1) { print "'$1'", "'$8'", "'$9'", "'$10'" }}; {if (NR>1 && "'$18'" == 1 && "'$19'" > 0.01 && "'$14'" > 0.50 && "'$13'" != \"NA\") { print "'$1'", "'$8'", "'$9'", "'$10'" }};' > ${PLOTTED}/${FILENAME}.FREQ.txt" > ${PLOTTED}/${FILENAME}.FREQ.sh
#	qsub -S /bin/bash -N ${FILENAME}.FREQ -o ${PLOTTED}/${FILENAME}.FREQ.log -e ${PLOTTED}/${FILENAME}.FREQ.errors -l h_vmem=${QMEM} -l h_rt=${QTIME} -wd ${PROJECTDIR} ${PLOTTED}/${FILENAME}.FREQ.sh
#done

echo ""
#echo "* Plotting EUROPEAN ancestral populations..."
#for FILE in $(echo `ls ${PLOTTED}/*.EUR.*.FREQ.txt`); do # weirdly this doesn't work when submitting a job...
#	### PREPARING FILES
#	FILENAME=$(basename ${FILE} .txt)
#	echo "*** Processing file ${FILENAME} ***"
#	echo ""
#	echo "- found file: ${FILE}"
#	echo "- plotting frequencies for EUROPEANS..."
#
#	echo "sh ${PROJECTDIR}/scripts_allele_freq_plots/plotting_allele_frequencies_based_on_ethnicity_1000G_p1.sh \
#	-s ${PROJECTDIR}/scripts_allele_freq_plots/Allele_frequencies.1000G_p1_v3.out \
#	-i ${FILE} \
#	-e EUR \
#	-o ${PLOTTED}/${FILENAME} " > ${PLOTTED}/${FILENAME}.AF_PLOTPREP.sh
#	qsub -S /bin/bash -N ${FILENAME}.AF_PLOTPREP -hold_jid ${FILENAME}.FREQ -o ${PLOTTED}/${FILENAME}.AF_PLOTPREP.log -e ${PLOTTED}/${FILENAME}.AF_PLOTPREP.errors -l h_vmem=${QMEM} -l h_rt=${QTIME} -wd ${PROJECTDIR} ${PLOTTED}/${FILENAME}.AF_PLOTPREP.sh
#
#	echo "${SOFTWARE}/MANTEL/SCRIPTS/allele_frequency_plotter.R -p ${PLOTTED} -r ${PLOTTED}/${FILENAME}.AF_PLOT.txt.gz -o ${PLOTTED} -e EUR -f PNG " > ${PLOTTED}/${FILENAME}.AF_PLOT.sh
#	qsub -S /bin/bash -N ${FILENAME}.AF_PLOT -hold_jid ${FILENAME}.AF_PLOTPREP -o ${PLOTTED}/${FILENAME}.AF_PLOT.log -e ${PLOTTED}/${FILENAME}.AF_PLOT.errors -l h_vmem=${QMEM} -l h_rt=${QTIME} -wd ${PROJECTDIR} ${PLOTTED}/${FILENAME}.AF_PLOT.sh
#
#done

echo ""
echo "* Plotting AFRICAN ancestral populations..."
for FILE in $(echo `ls ${PLOTTED}/COMPASS*.AFR.*.FREQ.txt`); do
	### PREPARING FILES
	FILENAME=$(basename ${FILE} .txt)
	echo "*** Processing file ${FILENAME} ***"
	echo ""
	echo "- found file: ${FILE}"
	echo "- plotting frequencies for AFRICANS..."

	echo "sh ${PROJECTDIR}/scripts_allele_freq_plots/plotting_allele_frequencies_based_on_ethnicity_1000G_p1.sh \
	-s ${PROJECTDIR}/scripts_allele_freq_plots/Allele_frequencies.1000G_p1_v3.out \
	-i ${FILE} \
	-e AFR \
	-o ${PLOTTED}/${FILENAME} " > ${PLOTTED}/${FILENAME}.AF_PLOTPREP.sh
	qsub -S /bin/bash -N ${FILENAME}.AF_PLOTPREP -hold_jid ${FILENAME}.FREQ -o ${PLOTTED}/${FILENAME}.AF_PLOTPREP.log -e ${PLOTTED}/${FILENAME}.AF_PLOTPREP.errors -l h_vmem=${QMEM} -l h_rt=${QTIME} -wd ${PROJECTDIR} ${PLOTTED}/${FILENAME}.AF_PLOTPREP.sh
	
	echo "${SOFTWARE}/MANTEL/SCRIPTS/allele_frequency_plotter.R -p ${PLOTTED} -r ${PLOTTED}/${FILENAME}.AF_PLOT.txt.gz -o ${PLOTTED} -e AFR -f PNG " > ${PLOTTED}/${FILENAME}.AF_PLOT.sh
	qsub -S /bin/bash -N ${FILENAME}.AF_PLOT -hold_jid ${FILENAME}.AF_PLOTPREP -o ${PLOTTED}/${FILENAME}.AF_PLOT.log -e ${PLOTTED}/${FILENAME}.AF_PLOT.errors -l h_vmem=${QMEM} -l h_rt=${QTIME} -wd ${PROJECTDIR} ${PLOTTED}/${FILENAME}.AF_PLOT.sh

done

#echo ""
#echo "* Plotting SOUTH-/EAST-ASIAN ancestral populations..."
#for FILE in $(echo `ls ${PLOTTED}/*.SAS.*.FREQ.txt`); do
#	### PREPARING FILES
#	FILENAME=$(basename ${FILE} .txt)
#	echo "*** Processing file ${FILENAME} ***"
#	echo ""
#	echo "- found file: ${FILE}"
#	echo "- plotting frequencies for ASIANS..."
#
#	echo "sh ${PROJECTDIR}/scripts_allele_freq_plots/plotting_allele_frequencies_based_on_ethnicity_1000G_p1.sh \
#	-s ${PROJECTDIR}/scripts_allele_freq_plots/Allele_frequencies.1000G_p1_v3.out \
#	-i ${FILE} \
#	-e EAS \
#	-o ${PLOTTED}/${FILENAME} " > ${PLOTTED}/${FILENAME}.AF_PLOTPREP.sh
#	qsub -S /bin/bash -N ${FILENAME}.AF_PLOTPREP -hold_jid ${FILENAME}.FREQ -o ${PLOTTED}/${FILENAME}.AF_PLOTPREP.log -e ${PLOTTED}/${FILENAME}.AF_PLOTPREP.errors -l h_vmem=${QMEM} -l h_rt=${QTIME} -wd ${PROJECTDIR} ${PLOTTED}/${FILENAME}.AF_PLOTPREP.sh
#
#	echo "${SOFTWARE}/MANTEL/SCRIPTS/allele_frequency_plotter.R -p ${PLOTTED} -r ${PLOTTED}/${FILENAME}.AF_PLOT.txt.gz -o ${PLOTTED} -e EAS -f PNG " > ${PLOTTED}/${FILENAME}.AF_PLOT.sh
#	qsub -S /bin/bash -N ${FILENAME}.AF_PLOT -hold_jid ${FILENAME}.AF_PLOTPREP -o ${PLOTTED}/${FILENAME}.AF_PLOT.log -e ${PLOTTED}/${FILENAME}.AF_PLOT.errors -l h_vmem=${QMEM} -l h_rt=${QTIME} -wd ${PROJECTDIR} ${PLOTTED}/${FILENAME}.AF_PLOT.sh
#
#done
#for FILE in $(echo `ls ${PLOTTED}/*.ASN.*.FREQ.txt`); do
#	### PREPARING FILES
#	FILENAME=$(basename ${FILE} .txt)
#	echo "*** Processing file ${FILENAME} ***"
#	echo ""
#	echo "- found file: ${FILE}"
#	echo "- plotting frequencies for ASIANS..."
#
#	echo "sh ${PROJECTDIR}/scripts_allele_freq_plots/plotting_allele_frequencies_based_on_ethnicity_1000G_p1.sh \
#	-s ${PROJECTDIR}/scripts_allele_freq_plots/Allele_frequencies.1000G_p1_v3.out \
#	-i ${FILE} \
#	-e EAS \
#	-o ${PLOTTED}/${FILENAME} " > ${PLOTTED}/${FILENAME}.AF_PLOTPREP.sh
#	qsub -S /bin/bash -N ${FILENAME}.AF_PLOTPREP -hold_jid ${FILENAME}.FREQ -o ${PLOTTED}/${FILENAME}.AF_PLOTPREP.log -e ${PLOTTED}/${FILENAME}.AF_PLOTPREP.errors -l h_vmem=${QMEM} -l h_rt=${QTIME} -wd ${PROJECTDIR} ${PLOTTED}/${FILENAME}.AF_PLOTPREP.sh
#
#	echo "${SOFTWARE}/MANTEL/SCRIPTS/allele_frequency_plotter.R -p ${PLOTTED} -r ${PLOTTED}/${FILENAME}.AF_PLOT.txt.gz -o ${PLOTTED} -e EAS -f PNG " > ${PLOTTED}/${FILENAME}.AF_PLOT.sh
#	qsub -S /bin/bash -N ${FILENAME}.AF_PLOT -hold_jid ${FILENAME}.AF_PLOTPREP -o ${PLOTTED}/${FILENAME}.AF_PLOT.log -e ${PLOTTED}/${FILENAME}.AF_PLOT.errors -l h_vmem=${QMEM} -l h_rt=${QTIME} -wd ${PROJECTDIR} ${PLOTTED}/${FILENAME}.AF_PLOT.sh
#
#done
#for FILE in $(echo `ls ${PLOTTED}/*.EAS.*.FREQ.txt`); do
#	### PREPARING FILES
#	FILENAME=$(basename ${FILE} .txt)
#	echo "*** Processing file ${FILENAME} ***"
#	echo ""
#	echo "- found file: ${FILE}"
#	echo "- plotting frequencies for ASIANS..."
#
#	echo "sh ${PROJECTDIR}/scripts_allele_freq_plots/plotting_allele_frequencies_based_on_ethnicity_1000G_p1.sh \
#	-s ${PROJECTDIR}/scripts_allele_freq_plots/Allele_frequencies.1000G_p1_v3.out \
#	-i ${FILE} \
#	-e EAS \
#	-o ${PLOTTED}/${FILENAME} " > ${PLOTTED}/${FILENAME}.AF_PLOTPREP.sh
#	qsub -S /bin/bash -N ${FILENAME}.AF_PLOTPREP -hold_jid ${FILENAME}.FREQ -o ${PLOTTED}/${FILENAME}.AF_PLOTPREP.log -e ${PLOTTED}/${FILENAME}.AF_PLOTPREP.errors -l h_vmem=${QMEM} -l h_rt=${QTIME} -wd ${PROJECTDIR} ${PLOTTED}/${FILENAME}.AF_PLOTPREP.sh
#
#	echo "${SOFTWARE}/MANTEL/SCRIPTS/allele_frequency_plotter.R -p ${PLOTTED} -r ${PLOTTED}/${FILENAME}.AF_PLOT.txt.gz -o ${PLOTTED} -e EAS -f PNG " > ${PLOTTED}/${FILENAME}.AF_PLOT.sh
#	qsub -S /bin/bash -N ${FILENAME}.AF_PLOT -hold_jid ${FILENAME}.AF_PLOTPREP -o ${PLOTTED}/${FILENAME}.AF_PLOT.log -e ${PLOTTED}/${FILENAME}.AF_PLOT.errors -l h_vmem=${QMEM} -l h_rt=${QTIME} -wd ${PROJECTDIR} ${PLOTTED}/${FILENAME}.AF_PLOT.sh
#
#done
#
#echo ""
#echo "* Plotting AMERICAN ancestral populations..."
#for FILE in $(echo `ls ${PLOTTED}/*.LAT.*.FREQ.txt`); do
#	### PREPARING FILES
#	FILENAME=$(basename ${FILE} .txt)
#	echo "*** Processing file ${FILENAME} ***"
#	echo ""
#	echo "- found file: ${FILE}"
#	echo "- plotting frequencies for AMERICANS..."
#
#	echo "sh ${PROJECTDIR}/scripts_allele_freq_plots/plotting_allele_frequencies_based_on_ethnicity_1000G_p1.sh \
#	-s ${PROJECTDIR}/scripts_allele_freq_plots/Allele_frequencies.1000G_p1_v3.out \
#	-i ${FILE} \
#	-e AMR \
#	-o ${PLOTTED}/${FILENAME} " > ${PLOTTED}/${FILENAME}.AF_PLOTPREP.sh
#	qsub -S /bin/bash -N ${FILENAME}.AF_PLOTPREP -hold_jid ${FILENAME}.FREQ -o ${PLOTTED}/${FILENAME}.AF_PLOTPREP.log -e ${PLOTTED}/${FILENAME}.AF_PLOTPREP.errors -l h_vmem=${QMEM} -l h_rt=${QTIME} -wd ${PROJECTDIR} ${PLOTTED}/${FILENAME}.AF_PLOTPREP.sh
#
#	echo "${SOFTWARE}/MANTEL/SCRIPTS/allele_frequency_plotter.R -p ${PLOTTED} -r ${PLOTTED}/${FILENAME}.AF_PLOT.txt.gz -o ${PLOTTED} -e AMR -f PNG " > ${PLOTTED}/${FILENAME}.AF_PLOT.sh
#	qsub -S /bin/bash -N ${FILENAME}.AF_PLOT -hold_jid ${FILENAME}.AF_PLOTPREP -o ${PLOTTED}/${FILENAME}.AF_PLOT.log -e ${PLOTTED}/${FILENAME}.AF_PLOT.errors -l h_vmem=${QMEM} -l h_rt=${QTIME} -wd ${PROJECTDIR} ${PLOTTED}/${FILENAME}.AF_PLOT.sh
#
#done

echo ""
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "Wow. I'm all done buddy. What a job! let's have a beer!"
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


THISYEAR=$(date +'%Y')
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo ""
echo ""
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "+ The MIT License (MIT)                                                                                 +"
echo "+ Copyright (c) 2015-${THISYEAR} Sander W. van der Laan                                                             +"
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
