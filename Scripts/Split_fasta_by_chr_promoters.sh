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
#$ -N split_fasta_by_chr_promoters
#
# Send an email after the job has finished
#$ -m e
#$ -M yaelhgs@gmail.com
#
# If modules are needed, source modules environment (Do not delete the next line):
. /etc/profile.d/modules.sh
#

# Directorios
DATA_DIR="/mnt/atgc-d1/bioinfoII/yhernandezg/epigenomica/data"
REAL_OUT="$DATA_DIR/promoters_real_fast_chr"

# Crear carpetas de salida si no existen
mkdir -p "$REAL_OUT"

# Cromosomas (1-22 + X, Y)
CHROMOSOMES=$(seq 1 22)
CHROMOSOMES+=" X Y"

# Dividir promoters.fa (real)
for CHR in $CHROMOSOMES; do
    awk -v chr="$CHR" 'BEGIN{RS=">"; FS="\n"} $1 ~ ("chr" chr) {print ">" $0}' "${DATA_DIR}/promoters.fa" > "${REAL_OUT}/chr${CHR}.fa"
done

echo "✅ División por cromosoma completada."
