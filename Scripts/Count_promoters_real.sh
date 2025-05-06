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
#$ -N count_pr_job
#
# Send an email after the job has finished
#$ -m e
#$ -M yaelhgs@gmail.com
#
#$ -l h_vmem=50G  # 50GB de RAM
#$ -pe openmp 16
# If modules are needed, source modules environment (Do not delete the next line):
. /etc/profile.d/modules.sh
#
# Write your commands in the next line
set -euo pipefail

INPUT="/mnt/atgc-d1/bioinfoII/yhernandezg/epigenomica/results/matrixscan_complete/matrixscan_promoters_real.tsv"
OUTPUT_DIR="/mnt/atgc-d1/bioinfoII/yhernandezg/epigenomica/results/counts_tsv"
TMPDIR="/tmp/$USER/$JOB_ID"  # Directorio temporal local para I/O rápido
mkdir -p "$TMPDIR"
mkdir -p "$OUTPUT_DIR"

NUM_CORES=${NSLOTS:-1}
export LC_ALL=C  # Acelera 'sort'

# Extraer columnas 1 y 3, eliminar duplicados
echo "Extrayendo columnas relevantes (secuencia y TF)..."
cut -f1,3 "$INPUT" > "$TMPDIR/cols.tsv"

echo "🧹 Eliminando duplicados..."
sort --parallel="$NUM_CORES" -u -T "$TMPDIR" "$TMPDIR/cols.tsv" > "$TMPDIR/real_tfs_unique.tsv"

echo "📊 Contando ocurrencias por TF..."
awk '
  { count[$2]++ } 
  END { 
    for (tf in count) print tf, count[tf] 
  }' "$TMPDIR/real_tfs_unique.tsv" > "$OUTPUT_DIR/real_counts.tsv"

echo "📈 Contando número total de secuencias únicas..."
cut -f1 "$TMPDIR/real_tfs_unique.tsv" | sort --parallel="$NUM_CORES" -u | wc -l > "$OUTPUT_DIR/total_real.txt"

echo "🧽 Limpiando temporales..."
rm -rf "$TMPDIR"

echo "✅ ¡Job completado exitosamente! Resultados en $OUTPUT_DIR"
