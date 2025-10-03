#!/bin/bash
COHORT=$1
BASEFILE=$2
RAWDATACOHORT=$3
PARSED_FILE=$4
CHUNKSIZE=$5
SCRIPTS=$6

SPLITSCRIPT=${RAWDATACOHORT}/split_after_parse.${COHORT}.sh

echo "Generating Split Script for ${COHORT}..."

cat <<EOF > $SPLITSCRIPT
#!/bin/bash
zcat ${PARSED_FILE} | tail -n +2 | split -a 3 -l ${CHUNKSIZE} - ${RAWDATACOHORT}/${BASEFILE}.
zcat ${PARSED_FILE} | head -1 > ${RAWDATACOHORT}/header.tmp
> ${RAWDATACOHORT}/splitfiles.txt
for f in ${RAWDATACOHORT}/${BASEFILE}.[a-z][a-z][a-z]; do
    cat ${RAWDATACOHORT}/header.tmp \$f > \$f.tmp && mv \$f.tmp \$f
    echo \$f >> ${RAWDATACOHORT}/splitfiles.txt
done
rm ${RAWDATACOHORT}/header.tmp
EOF

chmod +x $SPLITSCRIPT
echo "Running Split Script..."
bash $SPLITSCRIPT