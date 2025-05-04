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
#$ -N Generate_sequences
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

# Write your commands in the next line

#DIRECTORIOS
DATA_DIR="/mnt/atgc-d1/bioinfoII/yhernandezg/epigenomica/data"
SCRIPT="/mnt/atgc-d1/bioinfoII/yhernandezg/epigenomica/scripts/sequences_shuffle.R"


# Ejecutar para promoters
echo "Permutando promoters.fa..."
Rscript "$SCRIPT" "$DATA_DIR/promoters.fa" "$DATA_DIR/promoters_shuffled.fa" 2
# Ejecutar para PIRs
echo "Permutando PIRs.fa..."
Rscript "$SCRIPT" "$DATA_DIR/PIRs.fa" "$DATA_DIR/PIRs_shuffled.fa" 2


echo "Permutaciones completadas."
