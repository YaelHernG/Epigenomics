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
#$ -N rsat_promoters_shuffled_job
#
# Send an email after the job has finished
#$ -m e
#$ -M yaelhgs@gmail.com
#
#$ -l h_vmem=10G
# If modules are needed, source modules environment (Do not delete the next line):
. /etc/profile.d/modules.sh
#
# Add any modules you might require:
module load rsat/8sep2021

# --- Directorios ---
DATA_DIR="/mnt/atgc-d1/bioinfoII/yhernandezg/epigenomica/data"
MOTIFS_DIR="/mnt/atgc-d1/bioinfoII/yhernandezg/epigenomica/motifs"
RESULTS_DIR="/mnt/atgc-d1/bioinfoII/yhernandezg/epigenomica/results"

# Ejecutar matrix-scan-quick
matrix-scan \
  -quick \
  -i "$DATA_DIR/promoters_shuffled.fa" \
  -m "$MOTIFS_DIR/JASPAR2022_CORE_non-redundant_pfms_transfac.txt" \
  -matrix_format transfac \
  -seq_format fasta \
  -origin start \
  -lth score 0.8 \
  -bgfile "$DATA_DIR/promoters_bm.bg" \
  -2str \
  -o "$RESULTS_DIR/matrixscan_promoters_shuffled.tsv"
