#!/bin/bash
#
##########################################################################################
# CREATE 1000G phase 3, version 5b
#
# This script creates a resource for usage with gwas2cojo.
#
# created by: Sander W. van der Laan | s.w.vanderlaan@gmail.com
# last edit: 2023-01-18
# 
##########################################################################################
#
#

echo "Creating initial file."
echo "CHROM POS ID REF ALT CHROM:POS:REF:ALT AF EAS_AF AMR_AF AFR_AF EUR_AF SAS_AF" > 1000Gp3v5_EUR/1kGp3v5b.ref.allfreq.sumstats.txt

echo ""
echo "Extracting relevant data."
zcat ALL.wgs.phase3_shapeit2_mvncall_integrated_v5b.20130502.sites.vcf.gz | grep -v "##" | \
awk '{ print $1, $2, $3, $4, $5, "chr"$1":"$2":"$4":"$4, $8}' | \
awk -F";" '{print $1, $2, $6, $7, $8, $9, $10, $11}' | \
awk '{ print $1, $2, $3, $4, $5, $6, $8, $9, $10, $11, $12, $13 }' > 1000Gp3v5_EUR/1kGp3v5b.ref.allfreq.sumstats.foo

echo ""
echo "Removing irrelevant information."
cat 1000Gp3v5_EUR/1kGp3v5b.ref.allfreq.sumstats.foo | \
awk '{sub(/.*=/,"",$7); sub(/.*=/,"",$8); sub(/.*=/,"",$9); sub(/.*=/,"",$10); sub(/.*=/,"",$11); sub(/.*=/,"",$12); print}' | tail -n +2 >> 1000Gp3v5_EUR/1kGp3v5b.ref.allfreq.sumstats.txt

echo ""
echo "Wrapping up."
gzip -v 1000Gp3v5_EUR/1kGp3v5b.ref.allfreq.sumstats.txt

