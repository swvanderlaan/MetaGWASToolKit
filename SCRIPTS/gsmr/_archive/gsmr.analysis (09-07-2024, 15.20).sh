#!/bin/bash

# SLURM settings
#SBATCH --array=1-50                # create 23 jobs from this
#SBATCH --job-name=gsmr                  # Job name
#SBATCH --mail-type=FAIL             # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=e.j.a.smulders-2@umcutrecht.nl  # Where to send mail
#SBATCH --nodes=1                        # Run on one node
#SBATCH --ntasks=1                       # Run on a single CPU
#SBATCH --mem=128G                        # Job memory request
#SBATCH --time=1:00:00                   # Time limit hrs:min:sec
#SBATCH --output=gsmr.out   # Standard output and error log

echo "Starting task" $SLURM_ARRAY_TASK_ID

# Ensure that SLURM_ARRAY_TASK_ID is set
if [ -z "$SLURM_ARRAY_TASK_ID" ]; then
  echo "SLURM_ARRAY_TASK_ID is not set."
  exit 1
fi


GSMR="/hpc/dhl_ec/esmulders/gsmr"
GCTA="/hpc/local/Rocky8/dhl_ec/software/gcta_v1.94.1"
DIRECTION=0
REF="${GSMR}/gsmr_ref_data.txt"
#PHENO="META_cox_CHDDEAD_MI_ALL"
#TRAIT_FILE="${GSMR}/gsmr_traits.txt"
PHENO=""
TRAIT_FILE=""
#EXPOSURE_FILE="${GSMR}/gsmr_${trait}_${PHENO}_exposure.txt"


# Parsing command-line options
while getopts ":p:t:d:j:r:" opt; do
    case ${opt} in
        p) PHENO=$OPTARG ;;
        t) TRAIT_FILE=$OPTARG ;;
        d) DATA=$OPTARG ;;
        j) PROJECTNAME=$OPTARG ;;
        r) REF=$OPTARG ;;
        :) echo "Option -$OPTARG requires an argument." >&2; exit 1 ;;
        \?) echo "Invalid option: -$OPTARG" >&2; exit 1 ;;
    esac
done

Total=$(wc -w < "$TRAIT_FILE") # Count total amount of IDs (amount of lines in file)
# Check if the current SLURM_ARRAY_TASK_ID is less than Total
if (( SLURM_ARRAY_TASK_ID < $Total )); then
    # Your commands here
    echo "Processing task ID $SLURM_ARRAY_TASK_ID"
else
    # Cancel the job if SLURM_ARRAY_TASK_ID is not valid
    echo "Invalid task ID $SLURM_ARRAY_TASK_ID. Cancelling job."
    scancel $SLURM_JOB_ID
fi
echo "Analyzing phenotype ${PHENO}"
echo "${REF}"
#TRAIT_FILE="${GSMR}/gsmr_traits.txt"
#output_dir="${DATA}/${PROJECTNAME}/${PHENO}/gsmr"
#mkdir -p "$output_dir"
#echo "$output_dir"
OUTCOME_FILE="${DATA}/${PROJECTNAME}/${PHENO}/gsmr/gsmr_${PHENO}_outcome.txt"
#echo "$TRAIT_FILE"
#echo "$OUTCOME_FILE"
# Write the outcome to the outcome file
echo "$PHENO ${DATA}/${PROJECTNAME}/${PHENO}/input/${PHENO}.cojo.gz" > "$OUTCOME_FILE"

# Step 1: Process each trait file for GSMR analysis
echo "Starting GSMR analysis for each trait..."
#mkdir -p "$GSMR/gsmr_$PHENO"

# while read -r line; do
#     # Extract the trait name and file path
#     trait=$(echo "$line" | awk '{print $1}')
#     file_path=$(echo "$line" | awk '{print $2}')
#     EXPOSURE_FILE="${GSMR}/gsmr_${trait}_${PHENO}_exposure.txt"
#     # Copy the current trait line to the exposure file
#     echo "$line" > "$EXPOSURE_FILE"
#     
# 
#     
#     # Define the output file name
#     output_file="${GSMR}/gsmr_${PHENO}/gsmr_result_${trait}.out"
# 
#     # Run GSMR analysis
#     echo "Running GSMR analysis for $trait..."
#     ${GCTA} --mbfile "$REF" --gsmr-file "$EXPOSURE_FILE" "$OUTCOME_FILE" --gsmr-direction "$DIRECTION" --effect-plot --gsmr2-beta --out "$output_file"
#     
#     echo "GSMR analysis completed for $trait. Results saved to $output_file."
# done < "$TRAIT_FILE"
# 
# # Read the specified line from TRAIT_FILE based on SLURM_ARRAY_TASK_ID
# line=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "$TRAIT_FILE")
# 
# # Extract the trait and file path
# trait=$(echo $line | cut -d' ' -f1)
# file_path=$(echo $line | cut -d' ' -f2)

# Create the output directory if it does not exist


# Get the line corresponding to the current SLURM_ARRAY_TASK_ID
line=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "$TRAIT_FILE")

# Logging
echo "Line extracted: $line"

# Extract the trait name and file path
trait=$(echo "$line" | awk '{print $1}')
file_path=$(echo "$line" | awk '{print $2}')



# Logging
echo "Trait: $trait"
echo "File Path: $file_path"
EXPOSURE_FILE="${DATA}/${PROJECTNAME}/${PHENO}/gsmr/${trait}_${PHENO}_exposure.txt"

# Copy the current trait line to the exposure file
echo "$line" > "$EXPOSURE_FILE"

# Logging
echo "Exposure file content:"
cat "$EXPOSURE_FILE"

# Define the output file name
#output_file="${GSMR}/gsmr_${PHENO}/gsmr_result_${trait}.out"
output_file="${DATA}/${PROJECTNAME}/${PHENO}/gsmr/${trait}.out"
echo "output file: ${output_file}"
# Run GSMR analysis directly with the trait line
echo "Running GSMR analysis for $trait..."
${GCTA} --mbfile "${REF}" --gsmr-file "${EXPOSURE_FILE}" "${OUTCOME_FILE}" --gsmr-direction "${DIRECTION}" --effect-plot --gsmr2-beta --out "${output_file}"

echo "GSMR analysis completed for $trait. Results saved to $output_file."

# Delete the individual exposure file
 rm "$EXPOSURE_FILE"
echo "Deleted exposure file: $EXPOSURE_FILE"