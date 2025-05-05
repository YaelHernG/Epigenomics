#!/bin/bash
# Use current working directory
#$ -cwd
#
# Join stdout and stderr
#$ -j y
#
# Run job through bash shell
#$ -S /bin/bash
#
#You can edit the scriptsince this line
#
# Your job name
#$ -N promoters_fisher_test_job
#
# Send an email after the job has finished
#$ -m e
#$ -M yaelhgs@gmail.com
#
# If modules are needed, source modules environment (Do not delete the next line):
. /etc/profile.d/modules.sh
#
# Add any modules you might require:
module load r/4.0.2
#
# Write your commands in the next line

# Your actual commands below:
echo "Starting Fisher test analysis at $(date)"

#
# Define input/output paths (customize these)
INPUT_DIR="/mnt/atgc-d1/bioinfoII/yhernandezg/epigenomica/results/matrixscan_complete"
OUTPUT_DIR="/mnt/atgc-d1/bioinfoII/yhernandezg/epigenomica/results"
#
# Run R script with full paths
echo "Starting Fisher test analysis at $(date)"
Rscript fisher_test_TFs.R \
  ${INPUT_DIR}/matrixscan_promoters_real.tsv \
  ${INPUT_DIR}/matrixscan_promoters_shuffled.tsv \
  ${OUTPUT_DIR}/fisher_results.csv
echo "Job completed at $(date)"
