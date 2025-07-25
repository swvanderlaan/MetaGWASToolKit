#!/bin/bash

#awk 'NR > 1 { if ($11 > max) max = $11 } END { print max }' /Volumes/MacExtern/UMC/Werk/GENIUS-CHD/polyfun/input/META_cox_DEAD_ALL.b37.gwaslab.ssf.tsv
#/Volumes/MacExtern/UMC/Werk/GENIUS-CHD/polyfun/input/META_cox_DEAD_ALL.b37.gwaslab.ssf.tsv


# awk 'NR > 1 { if ($11 > max) max = $11 } END { print max }' /Volumes/MacExtern/UMC/Werk/GENIUS-CHD/polyfun/input/META_logistic_DEAD_CAD_noMI.b37.gwaslab.ssf.tsv
# 
# awk 'NR > 1 { if ($11 > max) max = $11 } END { print max }' /Volumes/MacExtern/UMC/Werk/GENIUS-CHD/polyfun/input/META_logistic_DEAD_CAD_MI.b37.gwaslab.ssf.tsv
# 
# awk 'NR > 1 { if ($11 > max) max = $11 } END { print max }' /Volumes/MacExtern/UMC/Werk/GENIUS-CHD/polyfun/input/META_logistic_DEAD_ALL.b37.gwaslab.ssf.tsv
# 
# awk 'NR > 1 { if ($11 > max) max = $11 } END { print max }' /Volumes/MacExtern/UMC/Werk/GENIUS-CHD/polyfun/input/META_logistic_CVDEAD_ALL.b37.gwaslab.ssf.tsv
# 
# awk 'NR > 1 { if ($11 > max) max = $11 } END { print max }' /Volumes/MacExtern/UMC/Werk/GENIUS-CHD/polyfun/input/META_cox_CHDDEAD_MI_CAD_MI.b37.gwaslab.ssf.tsv
# 
# awk 'NR > 1 { if ($11 > max) max = $11 } END { print max }' /Volumes/MacExtern/UMC/Werk/GENIUS-CHD/polyfun/input/META_cox_CHDDEAD_MI_ALL.b37.gwaslab.ssf.tsv
# 
# awk 'NR > 1 { if ($11 > max) max = $11 } END { print max }' /Volumes/MacExtern/UMC/Werk/GENIUS-CHD/polyfun/input/META_logistic_CHDDEAD_MI_ALL.b37.gwaslab.ssf.tsv
# 
# awk 'NR > 1 { if ($11 > max) max = $11 } END { print max }' /Volumes/MacExtern/UMC/Werk/GENIUS-CHD/polyfun/input/META_cox_CVDEAD_ALL.b37.gwaslab.ssf.tsv


zcat /hpc/dhl_ec/esmulders/polyfun/input/META_cIMT_EUR.b37.qc.gwaslab.ssf.tsv.gz | awk 'NR > 1 { if ($11 > max) max = $11 } END { print max }'

zcat /hpc/dhl_ec/esmulders/polyfun/input/META_cIMT_AFR.b37.qc.gwaslab.ssf.tsv.gz | awk 'NR > 1 { if ($11 > max) max = $11 } END { print max }'
