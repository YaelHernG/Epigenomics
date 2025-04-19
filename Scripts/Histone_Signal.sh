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
# Your job name
#$ -N Histone_Signal
#
# Send email when job finishes
#$ -m e
#$ -M yaelhgs@gmail.com
#
# If modules are needed, source modules environment
. /etc/profile.d/modules.sh

# Directorios
INPUT_DIR="/mnt/atgc-d1/bioinfoII/yhernandezg/epigenomica/data"
OUTPUT_DIR="/mnt/atgc-d1/bioinfoII/yhernandezg/epigenomica/results"

# Cargar módulo
module load UCSC-executables/12may2022

# Generar chrom_sizes.txt desde bigWig
bigWigInfo "${INPUT_DIR}/ENCFF931PZJ.bigWig" -chroms | awk '{print $1"\t"$3}' > "${INPUT_DIR}/chrom_sizes.txt"

# Filtrar Promoters_final.bed
awk '
  BEGIN { FS=OFS="\t" }
  FNR==NR { chr_len[$1]=$2; next }
  $1 in chr_len && $3 <= chr_len[$1]
' "${INPUT_DIR}/chrom_sizes.txt" "${INPUT_DIR}/Monocyte_Promoters_mainChr.bed" > "${INPUT_DIR}/Monocyte_Promoters_final.bed"

# Filtrar PIRs_final.bed
awk '
  BEGIN { FS=OFS="\t" }
  FNR==NR { chr_len[$1]=$2; next }
  $1 in chr_len && $3 <= chr_len[$1]
' "${INPUT_DIR}/chrom_sizes.txt" "${INPUT_DIR}/Monocyte_PIRs_mainChr.bed" > "${INPUT_DIR}/Monocyte_PIRs_final.bed"

# 1. Señal en promotores
bigWigAverageOverBed \
"${INPUT_DIR}/ENCFF931PZJ.bigWig" \
"${INPUT_DIR}/Monocyte_Promoters_final.bed" \
"${OUTPUT_DIR}/promoters_signal.tab"

# 2. Señal en PIRs
bigWigAverageOverBed \
"${INPUT_DIR}/ENCFF931PZJ.bigWig" \
"${INPUT_DIR}/Monocyte_PIRs_final.bed" \
"${OUTPUT_DIR}/PIRs_signal.tab"

echo "✅ Análisis de señal finalizado."


