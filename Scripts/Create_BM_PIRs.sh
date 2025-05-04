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
#$ -N background_model_pirs_job
#
# Send an email after the job has finished
#$ -m e
#$ -M yaelhgs@gmail.com
#
#$ -l h_vmem=2G 
# If modules are needed, source modules environment (Do not delete the next line):
. /etc/profile.d/modules.sh
#
# Add any modules you might require:
module load rsat/8sep2021

# --- Directorios ---
DATA_DIR="/mnt/atgc-d1/bioinfoII/yhernandezg/epigenomica/data"

#----Concatenar archivos---
cat "$DATA_DIR/PIRs.fa" "$DATA_DIR/PIRs_shuffled.fa" > "$DATA_DIR/PIRs_combined.fa"

#----Generar el background model---
create-background-model \
  -i "$DATA_DIR/PIRs_combined.fa" \
  -markov 1 \
  -out_format oligo-analysis \
  -o "$DATA_DIR/PIRs_bm.bg"

