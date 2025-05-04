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
#$ -N Extract_sequences
#
# Send an email after the job has finished
#$ -m e
#$ -M yaelhgs@gmail.com
#
# If modules are needed, source modules environment (Do not delete the next line):
. /etc/profile.d/modules.sh

#Directorios
INPUT_DIR="/mnt/atgc-d1/bioinfoII/yhernandezg/epigenomica/data"
#
# Add any modules you might require:
module load bedtools/2.27.1
#
# Write your commands in the next line
#Extraer secuencias reales desde BED

bedtools getfasta -fi "$INPUT_DIR/hg19.fa" -bed "$INPUT_DIR/Monocyte_Promoters_final.bed" -fo "$INPUT_DIR/promoters.fa"
bedtools getfasta -fi "$INPUT_DIR/hg19.fa" -bed "$INPUT_DIR/Monocyte_PIRs_final.bed" -fo "$INPUT_DIR/PIRs.fa"

echo "Secuencias extraídas."
