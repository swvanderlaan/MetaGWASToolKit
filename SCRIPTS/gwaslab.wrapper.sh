#!/bin/bash
set -e

echo "Wrapping files for cohort: ${COHORT}"
echo "Looking for chunk files in ${RAWDATACOHORT}"

OUTPUTFILE=${RAWDATACOHORT}/${BASEFILE}.merged.gwaslab.tsv.gz
TEMPFILE=${RAWDATACOHORT}/${BASEFILE}.merged.tmp.tsv


# Find all chunked GWASLab outputs
CHUNKFILES=$(ls ${RAWDATACOHORT}/${BASEFILE}.*.gwaslab.tsv.gz)

if [ -z "$CHUNKFILES" ]; then
    echo "No chunk files found for ${COHORT}."
    exit 1
fi

# Extract header from the first file
echo "Extracting header from first chunk..."
zcat $(echo $CHUNKFILES | awk '{print $1}') | head -n 1 > $TEMPFILE

# Append data from all chunks (skip header lines)
echo "Concatenating chunk files..."
for file in $CHUNKFILES; do
    zcat $file | tail -n +2 >> $TEMPFILE
done

# Optional: Sort & Deduplicate
# sort -u $TEMPFILE -o $TEMPFILE

# Compress final merged file
echo "Compressing final merged file to ${OUTPUTFILE}..."
gzip -c $TEMPFILE > $OUTPUTFILE
rm $TEMPFILE

echo "Final merged file created: ${OUTPUTFILE}"

# Optional Cleanup: Remove chunk files
# echo "Removing chunk files..."
# rm ${CHUNKFILES}

echo "Wrapper job for ${COHORT} completed successfully."