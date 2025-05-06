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
#$ -N promoters_fisher_test
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
Rscript fisher_test_TFs.R \
  /mnt/atgc-d1/bioinfoII/yhernandezg/epigenomica/results/counts_tsv/real_counts.tsv \
  /mnt/atgc-d1/bioinfoII/yhernandezg/epigenomica/results/counts_tsv/shuf_counts.tsv \
  /mnt/atgc-d1/bioinfoII/yhernandezg/epigenomica/results/promoters_fisher_results.csv
