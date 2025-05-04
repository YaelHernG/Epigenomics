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
#$ -N download_jaspar_rsat
#
# Send an email after the job has finished
#$ -m e
#$ -M yaelhgs@gmail.com
#
# If modules are needed, source modules environment (Do not delete the next line):
. /etc/profile.d/modules.sh
#
# Write your commands in the next line


# Directorio de destino
DEST_DIR="/mnt/atgc-d1/bioinfoII/yhernandezg/epigenomica/motifs"


# Descargar la colección no redundante de JASPAR CORE (2022)
echo "Descargando la colección no redundante de JASPAR CORE (2022)..."
wget -P $DEST_DIR https://jaspar2022.genereg.net/download/data/2022/CORE/JASPAR2022_CORE_non-redundant_pfms_transfac.txt


echo "  Descarga completada."

