#echo ""
#echo "================================================================================"
#echo "*** FREQUENCY PLOTTING ***"
#### scripts_allele_freq_plots
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

#echo ""
#echo "* Plotting AFRICAN ancestral populations..."
#for FILE in $(echo `ls ${PLOTTED}/COMPASS*.AFR.*.FREQ.txt`); do
#	### PREPARING FILES
#	FILENAME=$(basename ${FILE} .txt)
#	echo "*** Processing file ${FILENAME} ***"
#	echo ""
#	echo "- found file: ${FILE}"
#	echo "- plotting frequencies for AFRICANS..."
#
#	echo "sh ${PROJECTDIR}/scripts_allele_freq_plots/plotting_allele_frequencies_based_on_ethnicity_1000G_p1.sh \
#	-s ${PROJECTDIR}/scripts_allele_freq_plots/Allele_frequencies.1000G_p1_v3.out \
#	-i ${FILE} \
#	-e AFR \
#	-o ${PLOTTED}/${FILENAME} " > ${PLOTTED}/${FILENAME}.AF_PLOTPREP.sh
#	qsub -S /bin/bash -N ${FILENAME}.AF_PLOTPREP -hold_jid ${FILENAME}.FREQ -o ${PLOTTED}/${FILENAME}.AF_PLOTPREP.log -e ${PLOTTED}/${FILENAME}.AF_PLOTPREP.errors -l h_vmem=${QMEM} -l h_rt=${QTIME} -wd ${PROJECTDIR} ${PLOTTED}/${FILENAME}.AF_PLOTPREP.sh
#	
#	echo "${SOFTWARE}/MANTEL/SCRIPTS/allele_frequency_plotter.R -p ${PLOTTED} -r ${PLOTTED}/${FILENAME}.AF_PLOT.txt.gz -o ${PLOTTED} -e AFR -f PNG " > ${PLOTTED}/${FILENAME}.AF_PLOT.sh
#	qsub -S /bin/bash -N ${FILENAME}.AF_PLOT -hold_jid ${FILENAME}.AF_PLOTPREP -o ${PLOTTED}/${FILENAME}.AF_PLOT.log -e ${PLOTTED}/${FILENAME}.AF_PLOT.errors -l h_vmem=${QMEM} -l h_rt=${QTIME} -wd ${PROJECTDIR} ${PLOTTED}/${FILENAME}.AF_PLOT.sh
#
#done

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


