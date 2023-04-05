#!/bin/bash
#
##########################################################################################
# CREATE 1000G phase 3, version 5b
#
# This script creates a resource for usage with gwas2cojo.
#
# created by: Sander W. van der Laan | s.w.vanderlaan@gmail.com
# last edit: 2023-01-19
# 
##########################################################################################
#
#

echo "Creating initial file."
echo "CHROM POS ID REF ALT CHROM_POS_REF_ALT AF EAS_AF AMR_AF AFR_AF EUR_AF SAS_AF" > 1000Gp3v5_EUR/1kGp3v5b.ref.allfreq.noCN_noINS_noSS_noESV_noMultiAllelic.sumstats.txt

echo ""
echo "Extracting relevant data."
zcat ALL.wgs.phase3_shapeit2_mvncall_integrated_v5b.20130502.sites.vcf.gz | grep -v "##" | \
awk '{ print $1, $2, $3, $4, $5, "chr"$1":"$2":"$4":"$4, $8}' | \
awk -F";" '{print $1, $2, $6, $7, $8, $9, $10, $11}' | \
awk '{ print $1, $2, $3, $4, $5, $6, $8, $9, $10, $11, $12, $13 }' > 1000Gp3v5_EUR/1kGp3v5b.ref.allfreq.noCN_noINS_noSS_noESV_noMultiAllelic.sumstats.txt.foo

echo ""
echo "Removing irrelevant information (CN, INS, esv/ss-variants, and multi-allelics). "
echo "Especially the multi-allelic variants are an issue; many of the downstream tools "
echo "cannot handle these as they are 1) dependent on rsIDs or 2) they can't handle "
echo "variants at the same position."
echo "1000G phase 3, version 5b includes 84,801,880 variants. "
echo "After the filtering of these types of variants 84,204,608 remain."
echo "Thus we loose 597,272 variants."
cat 1000Gp3v5_EUR/1kGp3v5b.ref.allfreq.noCN_noINS_noSS_noESV_noMultiAllelic.sumstats.txt.foo | \
awk '{sub(/.*=/,"",$7); sub(/.*=/,"",$8); sub(/.*=/,"",$9); sub(/.*=/,"",$10); sub(/.*=/,"",$11); sub(/.*=/,"",$12); print}' | \
grep -v "CN" | grep -v "INS" | grep -v "esv" | grep -v "ss" | grep -v "," | \
awk '{ if($3==".") { print $1, $2, "chr"$1":"$2":"$4":"$5, $4, $5, "chr"$1":"$2":"$4":"$5, $7, $8, $9, $10, $11, $12 } else { print $1, $2, $3, $4, $5, "chr"$1":"$2":"$4":"$5, $7, $8, $9, $10, $11, $12 } }' | \
tail -n +2 >> 1000Gp3v5_EUR/1kGp3v5b.ref.allfreq.noCN_noINS_noSS_noESV_noMultiAllelic.sumstats.txt

echo ""
echo "Wrapping up."
gzip -fv 1000Gp3v5_EUR/1kGp3v5b.ref.allfreq.noCN_noINS_noSS_noESV_noMultiAllelic.sumstats.txt
rm -v 1000Gp3v5_EUR/1kGp3v5b.ref.allfreq.noCN_noINS_noSS_noESV_noMultiAllelic.sumstats.txt.foo

